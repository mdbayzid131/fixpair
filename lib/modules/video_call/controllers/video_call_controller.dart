import 'package:fixpair/config/routes/app_pages.dart';
import 'dart:async';
import 'package:get/get.dart';

class VideoCallController extends GetxController {
  final callDuration = 0.obs;
  final currentCost = 0.0.obs;
  final isMicOn = true.obs;
  final isCameraOn = true.obs;
  
  Timer? _timer;
  final double ratePerMinute = 4.0; // Based on previous screen (€4.00 / min)

  @override
  void onInit() {
    startTimer();
    super.onInit();
  }

  void startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      callDuration.value++;
      // Calculate cost per second: (rate / 60) * totalSeconds
      currentCost.value = (ratePerMinute / 60) * callDuration.value;
    });
  }

  String get formattedTime {
    int minutes = callDuration.value ~/ 60;
    int seconds = callDuration.value % 60;
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }

  void toggleMic() => isMicOn.value = !isMicOn.value;
  void toggleCamera() => isCameraOn.value = !isCameraOn.value;

  void endCall() {
    _timer?.cancel();
    Get.offNamed(AppRoutes.CONSULTATION_SUMMARY);
  }

  @override
  void onClose() {
    _timer?.cancel();
    super.onClose();
  }
}
