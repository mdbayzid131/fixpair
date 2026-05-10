import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../config/routes/app_pages.dart';

class ForgotPasswordController extends GetxController {
  final AuthService _authService = Get.find();

  final emailController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;

  @override
  void onClose() {
    emailController.dispose();
    super.onClose();
  }

  Future<void> sendResetLink() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      var response = await _authService.forgotPassword(emailController.text.trim());

      if (response.statusCode == 200) {
        Helpers.showSuccess(
          'Reset link sent to your email',
        );
        Get.toNamed(
          AppRoutes.OTP,
          arguments: {
            'email': emailController.text.trim(),
            'isForgotPassword': true
          },
        );
      } else {
        Helpers.showError(
          response.data['message'] ?? 'Failed to send reset link',
        );
      }
    } catch (e) {
      Helpers.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void goBack() {
    Get.back();
  }
}
