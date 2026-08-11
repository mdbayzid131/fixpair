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
  final dobController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;
  final isConfirmPasswordVisible = false.obs;
  final agreeToTerms = false.obs; // Checkbox for terms, disclaimer, and privacy
  final isAgeConfirmed = false.obs; // 18+ Age confirmation checkbox
  final selectedDob = Rxn<DateTime>();
  final dobError = ''.obs;

  final passwordFocusNode = FocusNode();
  final isPasswordFocused = false.obs;

  // Password rules
  final hasMinLength = false.obs;
  final hasUppercase = false.obs;
  final hasLowercase = false.obs;
  final hasDigit = false.obs;
  final hasSpecial = false.obs;

  @override
  void onInit() {
    super.onInit();
    passwordFocusNode.addListener(() {
      isPasswordFocused.value = passwordFocusNode.hasFocus;
    });
  }

  bool get areAllPasswordRulesMet =>
      hasMinLength.value &&
      hasUppercase.value &&
      hasLowercase.value &&
      hasDigit.value &&
      hasSpecial.value;

  void validatePasswordRules(String text) {
    hasMinLength.value = text.length >= 8;
    hasUppercase.value = text.contains(RegExp(r'[A-Z]'));
    hasLowercase.value = text.contains(RegExp(r'[a-z]'));
    hasDigit.value = text.contains(RegExp(r'[0-9]'));
    hasSpecial.value = text.contains(
      RegExp(r'[!@#\$&*~`%\^\(\)\-_=\+\[\{\]\}\|;:\x27",<\.>\/\?]'),
    );
  }

  Future<void> pickDateOfBirth(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = selectedDob.value ?? DateTime(now.year - 18, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: now,
      helpText: 'Select Date of Birth (Must be 18+)'.tr,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF0066FF),
              onPrimary: Colors.white,
              onSurface: Color(0xFF1D293D),
            ),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate != null) {
      int age = now.year - pickedDate.year;
      if (now.month < pickedDate.month ||
          (now.month == pickedDate.month && now.day < pickedDate.day)) {
        age--;
      }

      if (age < 18) {
        selectedDob.value = null;
        dobController.clear();
        isAgeConfirmed.value = false;
        dobError.value = 'You must be at least 18 years old to register'.tr;
      } else {
        selectedDob.value = pickedDate;
        dobController.text =
            '${pickedDate.day.toString().padLeft(2, '0')}.${pickedDate.month.toString().padLeft(2, '0')}.${pickedDate.year}';
        isAgeConfirmed.value = true;
        dobError.value = '';
      }
    }
  }

  @override
  void onClose() {
    passwordFocusNode.dispose();
    addressController.dispose();
    nameController.dispose();
    emailController.dispose();
    dobController.dispose();
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

    if (selectedDob.value == null || !isAgeConfirmed.value) {
      dobError.value = 'You must be at least 18 years old to register'.tr;
      return;
    }

    if (!agreeToTerms.value) {
      Helpers.showError(
        'Please accept the Terms & Conditions and Liability Disclaimer'.tr,
      );
      return;
    }

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

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final response = await _authService.loginWithGoogle();
      if (response.statusCode == 200) {
        Helpers.showSuccess('Login successful');
        Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
      } else {
        Helpers.showError(response.data['message'] ?? 'Google Login failed');
      }
    } catch (e) {
      Helpers.showDebugLog(e.toString());
      Helpers.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> loginWithApple() async {
    try {
      isLoading.value = true;
      final response = await _authService.loginWithApple();
      if (response.statusCode == 200) {
        Helpers.showSuccess('Login successful');
        Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
      } else {
        Helpers.showError(response.data['message'] ?? 'Apple Login failed');
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
