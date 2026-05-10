import 'dart:async';
import 'package:fixpair/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/core/utils/helpers.dart';

class OtpController extends GetxController {
  final AuthService _authService = Get.find();
  final otpController = TextEditingController();
  late final String email;
  late final bool isForgotPassword;
  final isLoading = false.obs;

  Timer? _timer;
  final remainingSeconds = 120.obs; // 2 minutes
  final isResendEnabled = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is Map) {
      email = Get.arguments['email'] ?? '';
      isForgotPassword = Get.arguments['isForgotPassword'] == true;
    } else {
      email = Get.arguments ?? '';
      isForgotPassword = false;
    }
    startTimer();
  }

  void startTimer() {
    remainingSeconds.value = 120;
    isResendEnabled.value = false;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (remainingSeconds.value > 0) {
        remainingSeconds.value--;
      } else {
        isResendEnabled.value = true;
        _timer?.cancel();
      }
    });
  }

  @override
  void onClose() {
    otpController.dispose();
    _timer?.cancel();
    super.onClose();
  }

  Future<void> verifyOtp() async {
    if (otpController.text.length < 6) {
      Helpers.showError('Please enter valid 6-digit OTP');
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
        Helpers.showSuccess('Verification successful');

        if (isForgotPassword) {
          final resetToken = response.data['data'];
          Get.toNamed(AppRoutes.SET_NEW_PASSWORD,
              arguments: {'resetToken': resetToken, 'email': email});
        } else {
          await _authService.handleAuthResponse(response);
          Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
        }
      } else {
        Helpers.showError(response.data['message'] ?? 'Verification failed');
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

      Helpers.showSuccess('OTP resent successfully');
      startTimer();
    } catch (e) {
      Helpers.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
