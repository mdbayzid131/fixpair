import 'dart:async';
import 'package:agora_rtc_engine/agora_rtc_engine.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/utils/helpers.dart';

class VideoCallController extends GetxController {
  final UserRepository _userRepository = Get.find();

  // Agora Config (Placeholders - Replace with your real ones)
  static const String appId = "1ab0566716c44d22bc8afc15a6d62205";

  late RtcEngine engine;
  final RxInt remoteUid = 0.obs;
  final RxBool isJoined = false.obs;

  final callDuration = 0.obs;
  final currentCost = 0.0.obs;
  final isMicOn = true.obs;
  final isCameraOn = true.obs;

  Timer? _timer;
  late BookingModel booking;
  late String sessionId;
  late String token;
  late String channelName;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      booking = args['booking'];
      sessionId = args['sessionId'];
      token = args['token'] ?? "";
      channelName = args['channelName'] ?? "test_channel";
    }
    initAgora();
  }

  Future<void> initAgora() async {
    // 1. Request permissions
    await [Permission.microphone, Permission.camera].request();

    // 2. Create engine
    engine = createAgoraRtcEngine();
    await engine.initialize(
      const RtcEngineContext(
        appId: appId,
        channelProfile: ChannelProfileType.channelProfileCommunication,
      ),
    );

    // 3. Register Event Handlers
    engine.registerEventHandler(
      RtcEngineEventHandler(
        onJoinChannelSuccess: (RtcConnection connection, int elapsed) {
          isJoined.value = true;
          startTimer();
        },
        onUserJoined: (RtcConnection connection, int uid, int elapsed) {
          remoteUid.value = uid;
        },
        onUserOffline:
            (RtcConnection connection, int uid, UserOfflineReasonType reason) {
              remoteUid.value = 0;
              endCall();
            },
        onLeaveChannel: (RtcConnection connection, RtcStats stats) {
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
      options: const ChannelMediaOptions(),
    );
  }

  void startTimer() {
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
    await engine.muteLocalAudioStream(!isMicOn.value);
  }

  void toggleCamera() async {
    isCameraOn.value = !isCameraOn.value;
    await engine.muteLocalVideoStream(!isCameraOn.value);
  }

  Future<void> endCall() async {
    try {
      await _userRepository.endVideoSession(sessionId);
    } catch (e) {
      Helpers.showDebugLog('Error ending session: $e');
    }
    _timer?.cancel();
    await engine.leaveChannel();
    await engine.release();
    Get.offNamed(
      AppRoutes.CONSULTATION_SUMMARY,
      arguments: {
        'booking': booking,
        'duration': callDuration.value,
        'cost': currentCost.value,
      },
    );
  }

  @override
  void onClose() {
    _timer?.cancel();
    engine.leaveChannel();
    engine.release();
    super.onClose();
  }
}
