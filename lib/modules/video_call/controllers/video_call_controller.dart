import 'dart:async';
import 'dart:io' show Platform;
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:get/get.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:fixpair/core/services/auth_service.dart';
import 'package:fixpair/core/services/socket_service.dart';
import 'package:fixpair/core/utils/logger.dart';
import 'package:fixpair/config/constants/api_constants.dart';

class VideoCallController extends GetxController with WidgetsBindingObserver {
  final UserRepository _userRepository = Get.find();

  // Agora Config
  static String get appId => ApiConstants.agoraAppId;

  late RtcEngine engine;
  final RxBool isEngineInitialized = false.obs;
  late final AgoraPipController _pipController;
  final RxBool isInPipMode = false.obs;

  bool _hasConsultantJoined = false;
  bool get hasConsultantJoined =>
      _hasConsultantJoined || callDuration.value > 0 || remoteUid.value != 0;

  final RxInt remoteUid = 0.obs;
  final RxBool isJoined = false.obs;
  final RxBool isRemoteVideoMuted = false.obs;

  final callDuration = 0.obs;
  final currentCost = 0.0.obs;
  final isMicOn = true.obs;
  final isCameraOn = true.obs;

  // Drag coordinates for local PiP window & floating overlay
  final RxDouble pipTop = 0.0.obs;
  final RxDouble pipLeft = 0.0.obs;

  // Role & layout swap view toggle
  final RxBool isConsultant = false.obs;
  final RxBool isLocalUserFullScreen = false.obs;

  // Global overlay minimization state
  final RxBool isOverlayMinimized = false.obs;
  OverlayEntry? _overlayEntry;

  final callingStatusText = 'Calling...'.obs;
  final callingDotsText = '...'.obs;
  final isCallRejected = false.obs;
  final rejectedMessage = ''.obs;
  Timer? _callingDotTimer;
  int _dotCount = 3;

  Timer? _timer;
  bool _isEndingCall = false;
  BookingModel booking = BookingModel();
  final bookingRx = Rxn<BookingModel>();
  String sessionId = '';
  String token = '';
  String channelName = 'test_channel';

  @override
  void onInit() {
    super.onInit();
    _startCallingDotAnimation();
    WidgetsBinding.instance.addObserver(this);
    // Default initial position near the bottom-right corner
    pipTop.value = Get.height - 290.0;
    pipLeft.value = Get.width - 115.0;

    final authService = Get.find<AuthService>();
    final role = authService.user.value?.role?.toLowerCase() ?? '';
    isConsultant.value =
        role == 'consultant' || role == 'provider' || role == 'expert';

    // Requirement 2: Customer's screen full-screen by default
    // If Customer (!isConsultant), default local camera to full-screen
    // If Consultant (isConsultant), default remote customer camera to full-screen
    isLocalUserFullScreen.value = !isConsultant.value;

    // Requirement 1: Consultant's camera is OFF under all circumstances
    if (isConsultant.value) {
      isCameraOn.value = false;
    }

    final args = Get.arguments;
    if (args != null && args is Map) {
      if (args['booking'] is BookingModel) {
        booking = args['booking'];
      } else if (args['booking'] is Map) {
        try {
          booking = BookingModel.fromJson(Map<String, dynamic>.from(args['booking']));
        } catch (_) {
          booking = BookingModel(
            id: (args['bookingId'] ?? '').toString(),
          );
        }
      } else {
        booking = BookingModel(
          id: (args['bookingId'] ?? args['channelName'] ?? '').toString(),
        );
      }
      sessionId = (args['sessionId'] ?? '').toString();
      token = (args['token'] ?? '').toString();
      channelName = (args['channelName'] ?? 'test_channel').toString();
    }
    bookingRx.value = booking;

    initAgora();
    _fetchRealBookingDetails();
    _setupSocketListeners();
  }

  void _setupSocketListeners() {
    final consultationId = booking.id ?? '';
    if (consultationId.isNotEmpty && Get.isRegistered<SocketService>()) {
      final socketService = Get.find<SocketService>();
      socketService.joinConsultation(consultationId);

      // Listen to live per-minute billing updates
      socketService.on('billing-updated', (data) {
        if (data is Map && data['consumedAmount'] != null) {
          final double amount = (data['consumedAmount'] as num).toDouble();
          currentCost.value = amount;
        }
      });

      // Listen to billing warning (1 minute remaining)
      socketService.on('billing-warning', (data) {
        Get.snackbar(
          'Balance Warning'.tr,
          'Your authorized balance is running low (1 minute remaining).'.tr,
          snackPosition: SnackPosition.TOP,
          backgroundColor: const Color(0xFFF59E0B),
          colorText: Colors.white,
        );
      });
    }
  }

  void updatePipPosition(double dx, double dy) {
    // Safe margins to prevent dragging completely off screen
    final double minLeft = 10.0;
    final double maxLeft = Get.width - 110.0;
    final double minTop = 80.0; // avoid top status/timer bar
    final double maxTop =
        Get.height - 230.0; // avoid overlapping bottom control bar

    pipLeft.value = (pipLeft.value + dx).clamp(minLeft, maxLeft);
    pipTop.value = (pipTop.value + dy).clamp(minTop, maxTop);
  }

  void updateOverlayPosition(double dx, double dy) {
    // Overlays can move freely but keep some safe margins
    final double minLeft = 10.0;
    final double maxLeft = Get.width - 105.0;
    final double minTop = 40.0;
    final double maxTop = Get.height - 180.0;

    pipLeft.value = (pipLeft.value + dx).clamp(minLeft, maxLeft);
    pipTop.value = (pipTop.value + dy).clamp(minTop, maxTop);
  }

  Future<void> initAgora() async {
    // 1. Request permissions
    await [Permission.microphone, Permission.camera].request();

    // 2. Create engine
    engine = createAgoraRtcEngine();
    await engine.initialize(
      RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        audioScenario: AudioScenarioType.audioScenarioGameStreaming,
      ),
    );
    isEngineInitialized.value = true;

    // Initialize PiP Controller
    _pipController = engine.createPipController();
    _pipController.registerPipStateChangedObserver(
      AgoraPipStateChangedObserver(
        onPipStateChanged: (AgoraPipState state, String? error) {
          AppLogger.info('[Agora PiP] State changed to: $state, error: $error');
          isInPipMode.value = (state == AgoraPipState.pipStateStarted);
        },
      ),
    );

    final bool isAutoEnterSupported = await _pipController.pipIsAutoEnterSupported();
    AppLogger.info('[Agora PiP] Auto-enter PiP supported: $isAutoEnterSupported');

    await _pipController.pipSetup(
      AgoraPipOptions(
        autoEnterEnabled: isAutoEnterSupported,
        aspectRatioX: 2,
        aspectRatioY: 3,
      ),
    );

    // Set speakerphone enabled by default as requested by backend
    await engine.setDefaultAudioRouteToSpeakerphone(true);

    // 3. Register Event Handlers
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          isJoined.value = true;
          AppLogger.info(
            '[Agora] Channel joined successfully! elapsed: $elapsed',
          );
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          _hasConsultantJoined = true;
          remoteUid.value = uid;
          isRemoteVideoMuted.value = false;
          AppLogger.info(
            '[Agora] Remote user joined: uid: $uid, elapsed: $elapsed',
          );
          // Start timing & billing ONLY when the consultant joins!
          startTimer();
        },
        onUserOffline:
            (RtcConnection connection, int uid, UserOfflineReasonType reason) {
              AppLogger.info(
                '[Agora] Remote user offline: uid: $uid, reason: $reason',
              );
              remoteUid.value = 0;
              isRemoteVideoMuted.value = false;
              endCall();
            },
        onUserMuteVideo: (RtcConnection connection, int uid, bool muted) {
          AppLogger.info(
            '[Agora] Remote user muted video: uid: $uid, muted: $muted',
          );
          if (uid == remoteUid.value) {
            isRemoteVideoMuted.value = muted;
          }
        },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
          AppLogger.info('[Agora] Left channel: stats: $stats');
          isJoined.value = false;
        },
      ),
    );

    // 4. Enable video and join
    await engine.enableVideo();

    if (!isConsultant.value) {
      await engine.startPreview();
    } else {
      await engine.muteLocalVideoStream(true);
    }

    final int myUid = isConsultant.value ? 2001 : 1001;

    AppLogger.info('[Agora] Joining channel $channelName with UID $myUid (isConsultant: ${isConsultant.value})');

    await engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: myUid,
      options: ChannelMediaOptions(
        publishCameraTrack: !isConsultant.value && isCameraOn.value,
        publishMicrophoneTrack: true,
        autoSubscribeAudio: true,
        autoSubscribeVideo: true,
        clientRoleType: ClientRoleType.clientRoleBroadcaster,
      ),
    );
  }

  void startTimer() {
    // Prevent starting timer multiple times
    if (_timer != null) return;

    final double rate = booking.perMinuteRate?.toDouble() ?? 4.0;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callDuration.value++;
      currentCost.value = (rate / 60) * callDuration.value;
    });
  }

  String get formattedTime {
    int minutes = callDuration.value ~/ 60;
    int seconds = callDuration.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void toggleMic() async {
    if (!isEngineInitialized.value) return;
    isMicOn.value = !isMicOn.value;
    AppLogger.info('[Agora] toggleMic() called. isMicOn: ${isMicOn.value}');
    await engine.muteLocalAudioStream(!isMicOn.value);
  }

  void toggleCamera() async {
    if (isConsultant.value || !isEngineInitialized.value) return; // Consultant camera is permanently off
    isCameraOn.value = !isCameraOn.value;
    await engine.muteLocalVideoStream(!isCameraOn.value);
  }

  void switchCamera() async {
    if (isConsultant.value || !isEngineInitialized.value) return; // Consultant camera is permanently off
    await engine.switchCamera();
  }

  void toggleFullScreenView() {
    isLocalUserFullScreen.value = !isLocalUserFullScreen.value;
  }

  // ===================== IMO/MESSENGER MINIMIZATION SYSTEM =====================

  void minimizeCall() {
    isOverlayMinimized.value = true;
    showFloatingOverlay();
    Get.back(); // Pop the full screen view
  }

  void restoreFromOverlay() {
    closeOverlay();
    isOverlayMinimized.value = false;

    // Navigate back to the full-screen view
    Get.toNamed(
      AppRoutes.VIDEO_CALL,
      arguments: {
        'booking': booking,
        'sessionId': sessionId,
        'token': token,
        'channelName': channelName,
      },
    );
  }

  void showFloatingOverlay() {
    if (_overlayEntry != null) return;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Obx(() {
          return Positioned(
            left: pipLeft.value,
            top: pipTop.value,
            child: GestureDetector(
              onPanUpdate: (details) {
                updateOverlayPosition(details.delta.dx, details.delta.dy);
              },
              onTap: () {
                restoreFromOverlay();
              },
              child: Material(
                color: Colors.transparent,
                child: Container(
                  width: 95.w,
                  height: 135.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(16.r),
                    border: Border.all(
                      color: const Color(0xFF22C55E).withOpacity(0.5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(14.r),
                        child: _buildOverlayVideoWidget(),
                      ),
                      // Mini Hang up button directly on bubble
                      Positioned(
                        bottom: 6.h,
                        right: 6.w,
                        child: GestureDetector(
                          onTap: () {
                            endCall();
                          },
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF4444),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.call_end_rounded,
                              color: Colors.white,
                              size: 14.sp,
                            ),
                          ),
                        ),
                      ),
                      // Pulse active dot
                      Positioned(
                        top: 6.h,
                        left: 6.w,
                        child: Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        });
      },
    );

    OverlayState? overlay;
    try {
      overlay = Navigator.of(Get.context!).overlay;
    } catch (_) {
      overlay = Get.key.currentState?.overlay;
    }

    if (overlay != null) {
      overlay.insert(_overlayEntry!);
    } else {
      AppLogger.warning('[Agora] Could not find root OverlayState!');
    }
  }

  Widget _buildOverlayVideoWidget() {
    if (!isEngineInitialized.value) {
      return const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF22C55E),
          strokeWidth: 2,
        ),
      );
    }
    final isLocalFull = isLocalUserFullScreen.value;
    if (isLocalFull) {
      // Local is in overlay background
      if (!isCameraOn.value) {
        return Container(
          color: const Color(0xFF1E293B),
          child: const Center(
            child: Icon(
              Icons.videocam_off_rounded,
              color: Color(0xFFEF4444),
              size: 24,
            ),
          ),
        );
      }
      return AgoraVideoView(
        controller: VideoViewController(
          rtcEngine: engine,
          canvas: const VideoCanvas(uid: 0),
        ),
      );
    } else {
      // Overlay shows remote user
      if (remoteUid.value != 0 && isConsultant.value) {
        // Consultant seeing customer video stream
        return AgoraVideoView(
          controller: VideoViewController.remote(
            rtcEngine: engine,
            canvas: VideoCanvas(uid: remoteUid.value),
            connection: RtcConnection(channelId: channelName),
          ),
        );
      }
      // Customer seeing consultant (consultant camera is off, show avatar)
      final bookingModel = bookingRx.value ?? booking;
      final avatarUrl = isConsultant.value
          ? (bookingModel.user?.image ?? bookingModel.user?.avatar)
          : (bookingModel.consultant?.image ?? bookingModel.consultant?.avatar);
      return Container(
        color: const Color(0xFF0F172A),
        child: Center(
          child: CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFF1E293B),
            child: ClipOval(
              child: avatarUrl != null && avatarUrl.isNotEmpty
                  ? CachedNetworkImage(
                      imageUrl: ApiConstants.getImageUrl(avatarUrl),
                      fit: BoxFit.cover,
                      width: 36,
                      height: 36,
                      errorWidget: (context, url, error) => const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
                    )
                  : const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
            ),
          ),
        ),
      );
    }
  }

  void _startCallingDotAnimation() {
    _callingDotTimer?.cancel();
    _callingDotTimer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      if (isCallRejected.value || remoteUid.value != 0) {
        timer.cancel();
        return;
      }
      _dotCount = (_dotCount % 3) + 1;
      callingDotsText.value = '.' * _dotCount;
    });
  }

  void handleCallRejected({String? reason}) {
    if (isCallRejected.value) return;
    isCallRejected.value = true;
    _callingDotTimer?.cancel();
    final String msg = 'Call rejected by consultant'.tr;
    rejectedMessage.value = msg;
    callingStatusText.value = msg;

    // Give 2.5 seconds for user to read the short rejection status text before popping screen
    Future.delayed(const Duration(milliseconds: 2500), () {
      endCall();
    });
  }

  void closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> endCall() async {
    if (_isEndingCall) return;
    _isEndingCall = true;
    _callingDotTimer?.cancel();

    final bool didConsultantJoin =
        _hasConsultantJoined || callDuration.value > 0 || remoteUid.value != 0;

    WidgetsBinding.instance.removeObserver(this);

    try {
      await FlutterCallkitIncoming.endCall(sessionId);
      await FlutterCallkitIncoming.endAllCalls();
      final CallKitParams callKitParams = CallKitParams(id: sessionId);
      await FlutterCallkitIncoming.hideCallkitIncoming(callKitParams);
    } catch (e) {
      AppLogger.warning('[CallKit] Error ending call session: $e');
    }

    if (didConsultantJoin) {
      try {
        await _userRepository.endVideoSession(sessionId);
      } catch (e) {
        AppLogger.warning('[Agora] Error ending session: $e');
      }
    } else {
      try {
        await _userRepository.actionVideoSession(sessionId, 'CANCEL');
        if (Get.isRegistered<SocketService>()) {
          Get.find<SocketService>().emitCancelCall(sessionId);
        }
      } catch (e) {
        AppLogger.warning('[Agora] Error cancelling session: $e');
      }
    }

    _timer?.cancel();

    try {
      await _pipController.pipDispose();
      await _pipController.dispose();
    } catch (e) {
      AppLogger.warning('[Agora PiP] Error disposing PiP on endCall: $e');
    }

    if (isEngineInitialized.value) {
      try {
        await engine.leaveChannel();
        await engine.release();
      } catch (e) {
        AppLogger.warning('[Agora] Error leaving/releasing channel on endCall: $e');
      }
    }

    closeOverlay();

    if (didConsultantJoin) {
      Get.offNamed(
        AppRoutes.CONSULTATION_SUMMARY,
        arguments: {
          'booking': booking,
          'duration': callDuration.value,
          'cost': currentCost.value,
        },
      );
    } else {
      try {
        if (Get.isDialogOpen == true) {
          Get.back();
        }
        Get.until((route) => Get.currentRoute != AppRoutes.VIDEO_CALL);
        if (Get.currentRoute == AppRoutes.VIDEO_CALL) {
          Get.back();
        }
      } catch (e) {
        AppLogger.warning('[Agora] Error navigating back on endCall: $e');
        Get.back();
      }
    }

    // Completely delete permanent GetX controller on end call
    Get.delete<VideoCallController>(force: true);
  }

  @override
  void onClose() {
    if (_isEndingCall) {
      super.onClose();
      return;
    }
    _isEndingCall = true;

    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();

    try {
      _pipController.pipDispose();
      _pipController.dispose();
    } catch (e) {
      AppLogger.warning('[Agora PiP] Error disposing PiP on onClose: $e');
    }

    if (isEngineInitialized.value) {
      try {
        engine.leaveChannel();
        engine.release();
      } catch (e) {
        AppLogger.warning('[Agora] Error leaving/releasing channel on onClose: $e');
      }
    }
    closeOverlay();

    try {
      FlutterCallkitIncoming.endCall(sessionId);
      FlutterCallkitIncoming.endAllCalls();
      final CallKitParams callKitParams = CallKitParams(id: sessionId);
      FlutterCallkitIncoming.hideCallkitIncoming(callKitParams);
    } catch (e) {
      AppLogger.warning('[CallKit] Error ending call on close: $e');
    }

    super.onClose();
  }

  @override
  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    AppLogger.info('[App Lifecycle] State changed to: $state');

    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      // Only enter system PiP if the call is joined, we are not already in PiP, and not ending call
      if (isJoined.value && !isInPipMode.value && !_isEndingCall) {
        try {
          AppLogger.info('[Agora PiP] App went to background, starting PiP mode');
          await _pipController.pipStart();
        } catch (e) {
          AppLogger.warning('[Agora PiP] Error entering PiP mode: $e');
        }
      }
    } else if (state == AppLifecycleState.resumed) {
      if (Platform.isIOS && isInPipMode.value) {
        try {
          AppLogger.info('[Agora PiP] App resumed, stopping PiP mode');
          await _pipController.pipStop();
        } catch (e) {
          AppLogger.warning('[Agora PiP] Error exiting PiP mode: $e');
        }
      }
    }
  }

  Future<void> _fetchRealBookingDetails() async {
    try {
      final bId = booking.id ?? '';
      final realBooking = await _userRepository.getBookingById(bId);
      if (realBooking != null) {
        booking = realBooking;
        bookingRx.value = realBooking;
      }
    } catch (e) {
      AppLogger.debug('Error updating video call booking details: $e');
    }
  }
}
