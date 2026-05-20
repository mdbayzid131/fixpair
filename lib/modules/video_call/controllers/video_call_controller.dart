import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/logger.dart';

class VideoCallController extends GetxController {
  final UserRepository _userRepository = Get.find();

  static const _channel = MethodChannel('fixpair/pip');

  // Agora Config
  static const String appId = "1ab0566716c44d22bc8afc15a6d62205";

  late RtcEngine engine;
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

  // Layout swap view toggle
  final RxBool isLocalUserFullScreen = false.obs;

  // Global overlay minimization state
  final RxBool isOverlayMinimized = false.obs;
  OverlayEntry? _overlayEntry;

  Timer? _timer;
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

    // 3. Register Event Handlers
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) async {
          isJoined.value = true;
          _setNativeCallActive(true);
          AppLogger.info(
            '[Agora] Channel joined successfully! elapsed: $elapsed',
          );
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

    await engine.joinChannel(
      token: token,
      channelId: channelName,
      uid: 0, // 0 means Agora will assign a UID
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
    _setNativeCallActive(false);
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
    _setNativeCallActive(false);
    _timer?.cancel();
    engine.leaveChannel();
    engine.release();
    closeOverlay();
    super.onClose();
  }

}
