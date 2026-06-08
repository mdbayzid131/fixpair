import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:get/get.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fixpair/core/services/socket_service.dart';
import 'package:fixpair/data/models/transcript_message.dart';
import 'package:fixpair/core/services/auth_service.dart';
import 'package:fixpair/core/utils/logger.dart';
import 'package:fixpair/config/constants/api_constants.dart';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';

class VideoCallController extends GetxController {
  final UserRepository _userRepository = Get.find();
  final SocketService _socketService = Get.find();

  static const _channel = MethodChannel('fixpair/pip');

  // Agora Config
  static const String appId = ApiConstants.agoraAppId;

  late RtcEngine engine;
  final RxInt remoteUid = 0.obs;
  final RxBool isJoined = false.obs;
  final RxBool isRemoteVideoMuted = false.obs;

  final callDuration = 0.obs;
  final currentCost = 0.0.obs;
  final isMicOn = true.obs;
  final isCameraOn = true.obs;

  // Real-time transcription / transcript lists
  final RxList<TranscriptMessage> transcriptHistory = <TranscriptMessage>[].obs;
  final Rxn<TranscriptMessage> activeUserSubtitle = Rxn<TranscriptMessage>();
  final Rxn<TranscriptMessage> activeConsultantSubtitle = Rxn<TranscriptMessage>();

  // Drag coordinates for local PiP window & floating overlay
  final RxDouble pipTop = 0.0.obs;
  final RxDouble pipLeft = 0.0.obs;

  // Layout swap view toggle
  final RxBool isLocalUserFullScreen = false.obs;

  // Global overlay minimization state
  final RxBool isOverlayMinimized = false.obs;
  OverlayEntry? _overlayEntry;

  Timer? _timer;
  bool _isEndingCall = false;
  late BookingModel booking;
  late String sessionId;
  late String token;
  late String channelName;

  @override
  void onInit() {
    super.onInit();
    // Default initial position near the bottom-right corner
    pipTop.value = Get.height - 290.0;
    pipLeft.value = Get.width - 115.0;

    final args = Get.arguments;
    if (args != null) {
      booking = args['booking'];
      sessionId = args['sessionId'];
      token = args['token'] ?? "";
      channelName = args['channelName'] ?? "test_channel";
    }

    // Initialize socket connection and listen for transcripts
    _initSocketTranscription();

    initAgora();
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
      const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileLiveBroadcasting,
        audioScenario: AudioScenarioType.audioScenarioGameStreaming,
      ),
    );

    // Set speakerphone enabled by default as requested by backend
    await engine.setDefaultAudioRouteToSpeakerphone(true);

    // 3. Register Event Handlers
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
          isJoined.value = true;
          _setNativeCallActive(true);
          AppLogger.info(
            '[Agora] Channel joined successfully! elapsed: $elapsed',
          );
          _startBackendTranscription();
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
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
    await engine.startPreview();

    // Determine UID according to backend guidelines: 1001 for user, 2001 for consultant
    final authService = Get.find<AuthService>();
    final isConsultant = authService.user.value?.role?.toLowerCase() == 'consultant';
    final int myUid = isConsultant ? 2001 : 1001;

    AppLogger.info('[Agora] Joining channel $channelName with UID $myUid');

    await engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: myUid,
      options: const ChannelMediaOptions(
        publishCameraTrack: true,
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
    isMicOn.value = !isMicOn.value;
    AppLogger.info('[Agora] toggleMic() called. isMicOn: ${isMicOn.value}');
    await engine.muteLocalAudioStream(!isMicOn.value);
  }

  void toggleCamera() async {
    isCameraOn.value = !isCameraOn.value;
    await engine.muteLocalVideoStream(!isCameraOn.value);
  }

  void switchCamera() async {
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
    final isLocalFull = isLocalUserFullScreen.value;
    if (isLocalFull) {
      // Local is in overlay background (meaning in full screen when maximized, so overlay shows client)
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
      // Overlay shows remote consultant
      if (remoteUid.value != 0) {
        if (isRemoteVideoMuted.value) {
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
          controller: VideoViewController.remote(
            rtcEngine: engine,
            canvas: VideoCanvas(uid: remoteUid.value),
            connection: RtcConnection(channelId: channelName),
          ),
        );
      } else {
        return const Center(
          child: CircularProgressIndicator(
            color: Color(0xFF22C55E),
            strokeWidth: 2,
          ),
        );
      }
    }
  }

  void closeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  Future<void> endCall() async {
    if (_isEndingCall) return;
    _isEndingCall = true;
    
    _setNativeCallActive(false);
    
    try {
      await FlutterCallkitIncoming.endCall(sessionId);
      await FlutterCallkitIncoming.endAllCalls();
      final CallKitParams callKitParams = CallKitParams(id: sessionId);
      await FlutterCallkitIncoming.hideCallkitIncoming(callKitParams);
    } catch (e) {
      AppLogger.warning('[CallKit] Error ending call session: $e');
    }

    // Stop backend transcription and leave room
    if (booking.id != null) {
      try {
        AppLogger.info('[Agora STT] Requesting stop transcription for booking: ${booking.id}');
        await _userRepository.stopTranscription(booking.id!);
      } catch (e) {
        AppLogger.warning('[Agora STT] Error stopping backend transcription: $e');
      }
      _socketService.leaveRoom(booking.id!);
    }

    try {
      await _userRepository.endVideoSession(sessionId);
    } catch (e) {
      AppLogger.warning('[Agora] Error ending session: $e');
    }
    _timer?.cancel();
    await engine.leaveChannel();
    await engine.release();

    closeOverlay();

    Get.offNamed(
      AppRoutes.CONSULTATION_SUMMARY,
      arguments: {
        'booking': booking,
        'duration': callDuration.value,
        'cost': currentCost.value,
        'transcript': transcriptHistory.toList(),
      },
    );

    // Completely delete permanent GetX controller on end call
    Get.delete<VideoCallController>(force: true);
  }

  void _setNativeCallActive(bool isActive) {
    try {
      _channel.invokeMethod('setCallActive', {'isActive': isActive});
    } catch (e) {
      AppLogger.warning(
        '[Agora] Error invoking setCallActive MethodChannel: $e',
      );
    }
  }

  @override
  void onClose() {
    if (_isEndingCall) {
      super.onClose();
      return;
    }
    _isEndingCall = true;
    
    _setNativeCallActive(false);
    _timer?.cancel();
    engine.leaveChannel();
    engine.release();
    closeOverlay();
    
    try {
      FlutterCallkitIncoming.endCall(sessionId);
      FlutterCallkitIncoming.endAllCalls();
      final CallKitParams callKitParams = CallKitParams(id: sessionId);
      FlutterCallkitIncoming.hideCallkitIncoming(callKitParams);
    } catch (e) {
      AppLogger.warning('[CallKit] Error ending call on close: $e');
    }
    
    if (booking.id != null) {
      _socketService.leaveRoom(booking.id!);
    }
    super.onClose();
  }

  void _initSocketTranscription() {
    _socketService.connect();

    if (booking.id != null) {
      _socketService.joinRoom(booking.id!);
      AppLogger.info('[Agora STT] Joined socket room: ${booking.id}');
    }

    _socketService.on('transcript:new', (data) {
      if (data == null) return;
      try {
        AppLogger.info('[Agora STT] Received transcript event: $data');
        final message = TranscriptMessage.fromJson(
          Map<String, dynamic>.from(data),
          'You',
          booking.consultant?.name ?? 'Consultant',
        );

        // Check if this belongs to this consultation
        if (data['consultationId'] != booking.id) {
          return;
        }

        if (message.isFinal) {
          transcriptHistory.add(message);
          // Clear active subtitle for this role
          if (message.speakerRole == 'user') {
            activeUserSubtitle.value = null;
          } else if (message.speakerRole == 'consultant') {
            activeConsultantSubtitle.value = null;
          }
        } else {
          // Update active subtitle
          if (message.speakerRole == 'user') {
            activeUserSubtitle.value = message;
          } else if (message.speakerRole == 'consultant') {
            activeConsultantSubtitle.value = message;
          }
        }
      } catch (e) {
        AppLogger.warning('[Agora STT] Error parsing socket transcript: $e');
      }
    });
  }

  Future<void> _startBackendTranscription() async {
    if (booking.id == null) return;
    try {
      AppLogger.info('[Agora STT] Requesting start transcription for booking: ${booking.id}');
      await _userRepository.startTranscription(booking.id!);
      AppLogger.info('[Agora STT] Start transcription request successful.');
    } catch (e) {
      AppLogger.warning('[Agora STT] Error starting backend transcription: $e');
    }
  }

  void showTranscriptBottomSheet() {
    Get.bottomSheet(
      Container(
        height: Get.height * 0.6,
        decoration: BoxDecoration(
          color: const Color(0xFF0F172A),
          borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
          border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
        ),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Live Transcript Log',
                  style: GoogleFonts.manrope(
                    color: Colors.white,
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white70),
                  onPressed: () => Get.back(),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Expanded(
              child: Obx(() {
                if (transcriptHistory.isEmpty) {
                  return Center(
                    child: Text(
                      'No conversations recorded yet.',
                      style: GoogleFonts.manrope(
                        color: Colors.white54,
                        fontSize: 14.sp,
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: transcriptHistory.length,
                  itemBuilder: (context, index) {
                    final msg = transcriptHistory[index];
                    final isUser = msg.speakerRole == 'user';
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                msg.speakerName,
                                style: GoogleFonts.manrope(
                                  color: isUser ? const Color(0xFF3B82F6) : const Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              ),
                              Text(
                                '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                style: GoogleFonts.manrope(
                                  color: Colors.white30,
                                  fontSize: 11.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            msg.text,
                            style: GoogleFonts.manrope(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14.sp,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ),
          ],
        ),
      ),
      isScrollControlled: true,
    );
  }

}
