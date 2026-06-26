import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/helpers.dart';

class ChangePasswordController extends GetxController {
  final AuthService _authService = Get.find();

  final formKey = GlobalKey<FormState>();
  final currentPasswordController = TextEditingController();
  final newPasswordController = TextEditingController();
  final confirmPasswordController = TextEditingController();

  final obscureCurrentPassword = true.obs;
  final obscureNewPassword = true.obs;
  final obscureConfirmPassword = true.obs;

  final isLoading = false.obs;

  Future<void> changePassword() async {
    if (!formKey.currentState!.validate()) {
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      Helpers.showError('New password and confirm password do not match');
      return;
    }

    Helpers.hideKeyboard();
    Helpers.showLoadingDialog(message: 'Updating password...');
    isLoading.value = true;

    try {
      final response = await _authService.changePassword(
        oldPassword: currentPasswordController.text,
        newPassword: newPasswordController.text,
      );

      Helpers.hideLoadingDialog();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Helpers.showSuccess('Password updated successfully');
        _clearFields();
        Get.back();
      } else {
        final errorMsg =
            response.data?['message'] ??
            response.statusMessage ??
            'Failed to change password';
        Helpers.showError(errorMsg);
      }
    } catch (e) {
      Helpers.hideLoadingDialog();
      Helpers.showError('An error occurred: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void _clearFields() {
    currentPasswordController.clear();
    newPasswordController.clear();
    confirmPasswordController.clear();
  }

  @override
  void onClose() {
    currentPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();
    super.onClose();
  }
}
