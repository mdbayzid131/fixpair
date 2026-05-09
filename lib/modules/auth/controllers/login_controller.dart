import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/helpers.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  Future<void> login() async {
    // if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      // final response = await _authService.login(
      //   email: emailController.text,
      //   password: passwordController.text,
      // );
      // ApiChecker.checkWriteApi(response);
      // if (response.statusCode == 200) {
      //   Helpers.showCustomSnackBar('Login successful', isError: false);
      //   _authService.handleAuthResponse(response);
      //   Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
      // }
      // if (response.statusCode == 403 &&
      //     response.data['message'] == 'Verify account first') {
      //   try {
      //     await _authService.resendOtp(emailController.text);
      //     Helpers.showCustomSnackBar(
      //       'Verification needed. OTP sent to your email.',
      //       isError: false,
      //     );
      //     Get.toNamed(
      //       AppRoutes.OTP_FORM_REGISTER,
      //       arguments: emailController.text,
      //     );
      //     return;
      //   } catch (resendError) {
      //     Helpers.showDebugLog(resendError.toString());
      //     return;
      //   }
      // }

      Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
    } catch (e) {
      Helpers.showDebugLog(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    Get.toNamed(AppRoutes.REGISTER);
  }

  void goToHome() {
    // Temporarily set isLoggedIn to true to bypass AuthMiddleware
    _authService.isLoggedIn.value = true;
    Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.FORGOT_PASSWORD);
  }
}
