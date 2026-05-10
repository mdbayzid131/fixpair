import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/helpers.dart';

class RegisterController extends GetxController {
  final AuthService _authService = Get.find();

  final addressController = TextEditingController();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final agreeToTerms = false.obs; // Checkbox for terms and conditions

  @override
  void onClose() {
    addressController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  void toggleConfirmPasswordVisibility() {
    isConfirmPasswordVisible.value = !isConfirmPasswordVisible.value;
  }

  Future<void> register() async {
    if (!formKey.currentState!.validate()) return;

    try {
      isLoading.value = true;

      var response = await _authService.signup(
        name: nameController.text.trim(),
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        Helpers.showSuccess(
          'Registration successful, please verify your email',
      
        );
        Get.toNamed(
          AppRoutes.OTP_FORM_REGISTER,
          arguments: emailController.text.trim(),
        );
      } else {
        // ApiChecker.checkWriteApi(response);
        Helpers.showError(response.data['message'] ?? 'Registration failed');
      }
    } catch (e) {
      Helpers.showDebugLog(e.toString());
      Helpers.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void goToLogin() {
    Get.back();
  }
}
