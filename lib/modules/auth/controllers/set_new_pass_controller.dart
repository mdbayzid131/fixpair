import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/core/services/auth_service.dart';
import 'package:fixpair/core/utils/helpers.dart';

class SetNewPassController extends GetxController {
  final AuthService _authService = Get.find();

  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  late final String resetToken;
  late final String email;
  final isLoading = false.obs;

  // Password visibility
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;

  // Password rules
  final hasMinLength = false.obs;
  final hasUppercase = false.obs;
  final hasNumberOrSpecial = false.obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args is Map) {
      resetToken = args['resetToken'] ?? '';
      email = args['email'] ?? '';
    } else {
      resetToken = '';
      email = '';
    }
  }

  void validatePasswordRules(String text) {
    hasMinLength.value = text.length >= 8;
    hasUppercase.value = text.contains(RegExp(r'[A-Z]'));
    // Checks for number OR special character
    hasNumberOrSpecial.value =
        text.contains(RegExp(r'[0-9]')) ||
        text.contains(
          RegExp(r'[!@#\$&*~`%\^\(\)\-_=\+\[\{\]\}\|;:\x27",<\.>\/\?]'),
        );
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  @override
  void onClose() {
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  Future<void> submitNewPassword() async {
    if (newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      Helpers.showCustomSnackBar('Please fill in both fields');
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Helpers.showCustomSnackBar('Passwords do not match');
      return;
    }

    try {
      isLoading.value = true;
      var response = await _authService.resetPassword(
        resetToken: resetToken,
        password: newPasswordController.text,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Helpers.showCustomSnackBar('Password reset successfully', isError: false);
        Get.offAllNamed(AppRoutes.SUCCESS);
      } else {
        Helpers.showCustomSnackBar(
          response.data['message'] ?? 'Failed to reset password',
        );
      }
      } catch (e) {
      Helpers.showCustomSnackBar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }
}
