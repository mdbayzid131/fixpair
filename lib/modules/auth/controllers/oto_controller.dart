import 'dart:async';
import 'package:fixpair/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/core/utils/helpers.dart';

class OtpController extends GetxController with WidgetsBindingObserver {
  final AuthService _authService = Get.find();
  final otpController = TextEditingController();
  late final String email;
  late final bool isForgotPassword;
  final isLoading = false.obs;

  Timer? _timer;
  DateTime? _endTime;
  final remainingSeconds = 60.obs; // 1 minute
  final isResendEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    if (Get.arguments is Map) {
      email = Get.arguments['email'] ?? '';
      isForgotPassword = Get.arguments['isForgotPassword'] == true;
    } else {
      email = Get.arguments ?? '';
      isForgotPassword = false;
    }
    startTimer();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _updateTimer();
    }
  }

  void startTimer() {
    _endTime = DateTime.now().add(const Duration(seconds: 60));
    remainingSeconds.value = 60;
    isResendEnabled.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      _updateTimer();
    });
  }

  void _updateTimer() {
    if (_endTime == null) return;
    final diff = _endTime!.difference(DateTime.now()).inSeconds;
    if (diff > 0) {
      remainingSeconds.value = diff;
    } else {
      remainingSeconds.value = 0;
      isResendEnabled.value = true;
      _timer?.cancel();
    }
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    otpController.dispose();
    _timer?.cancel();
    super.onClose();
  }

  Future<void> verifyOtp() async {
    if (otpController.text.length < 6) {
      Helpers.showError('Please enter valid 6-digit OTP'.tr);
      return;
    }

    try {
      isLoading.value = true;
      var response = await _authService.verifyOtp(
        email: email,
        otp: int.parse(otpController.text),
        isForgotPassword: isForgotPassword,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Helpers.showSuccess('Verification successful'.tr);

        if (isForgotPassword) {
          final resetToken = response.data['data'];
          Get.toNamed(
            AppRoutes.SET_NEW_PASSWORD,
            arguments: {'resetToken': resetToken, 'email': email},
          );
        } else {
          // await _authService.handleAuthResponse(response);
          // Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
          Get.offAllNamed(AppRoutes.LOGIN);
        }
      } else {
        Helpers.showError(response.data['message'] ?? 'Verification failed'.tr);
      }
    } catch (e) {
      Helpers.showDebugLog(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> resendOtp() async {
    try {
      isLoading.value = true;

      if (isForgotPassword) {
        await _authService.forgotPassword(email);
      } else {
        await _authService.resendOtp(email);
      }

      Helpers.showSuccess('OTP resent successfully'.tr);
      startTimer();
    } catch (e) {
      Helpers.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
