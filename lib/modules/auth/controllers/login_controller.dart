import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/services/biometric_service.dart';
import '../../../core/utils/helpers.dart';

class LoginController extends GetxController {
  final AuthService _authService = Get.find();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final formKey = GlobalKey<FormState>();

  final isLoading = false.obs;
  final isPasswordVisible = false.obs;

  // Biometric state
  final isBiometricAvailable = false.obs;
  final isBiometricLoading = false.obs;
  final biometricLabel = 'Biometrics'.obs;
  final Rx<IconData> biometricIcon = Icons.fingerprint_rounded.obs;

  @override
  void onInit() {
    super.onInit();
    checkBiometricAvailability();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  void togglePasswordVisibility() {
    isPasswordVisible.value = !isPasswordVisible.value;
  }

  /// Check if device supports biometrics and has saved login credentials
  Future<void> checkBiometricAvailability() async {
    try {
      final hasHardware = await BiometricService.instance.hasUsableBiometric();
      final hasCredentials = await BiometricService.instance.hasSavedCredentials();
      final isEnabled = BiometricService.instance.isBiometricEnabled();

      biometricLabel.value = await BiometricService.instance.biometricLabel();
      biometricIcon.value = await BiometricService.instance.biometricIcon();

      // Available if hardware exists and credentials are saved (or enabled)
      isBiometricAvailable.value = hasHardware && hasCredentials && isEnabled;
    } catch (_) {
      isBiometricAvailable.value = false;
    }
  }

  /// Standard Email & Password Login
  Future<void> login() async {
    if (!formKey.currentState!.validate()) return;

    final email = emailController.text.trim();
    final password = passwordController.text;

    try {
      isLoading.value = true;

      final response = await _authService.login(
        email: email,
        password: password,
      );

      if (response.statusCode == 200) {
        // Save credentials securely for biometric login
        await BiometricService.instance.saveCredentials(
          email: email,
          password: password,
        );

        Helpers.showSuccess('Login successful'.tr);
        await _authService.handleAuthResponse(response);
        Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
      } else if (response.statusCode == 403 &&
          response.data is Map &&
          response.data['message'] == 'Verify account first') {
        try {
          await _authService.resendOtp(email);
          Helpers.showSuccess('Verification needed. OTP sent to your email.'.tr);
          Get.toNamed(
            AppRoutes.OTP_FORM_REGISTER,
            arguments: email,
          );
        } catch (resendError) {
          Helpers.showError(resendError.toString());
        }
      } else {
        String errorMessage = 'Login failed'.tr;
        if (response.data is Map && response.data['message'] != null) {
          errorMessage = response.data['message'].toString();
        } else if (response.statusMessage != null && response.statusMessage!.isNotEmpty) {
          errorMessage = response.statusMessage!;
        }
        Helpers.showError(errorMessage);
      }
    } catch (e) {
      Helpers.showDebugLog(e.toString());
      Helpers.showError('Something went wrong, please try again'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  /// One-tap Face ID / Biometric Login
  Future<void> loginWithBiometrics() async {
    if (isLoading.value || isBiometricLoading.value) return;

    try {
      isBiometricLoading.value = true;

      final bool authenticated = await BiometricService.instance.authenticate(
        localizedReason: 'Log in with ${biometricLabel.value}'.tr,
      );

      if (!authenticated) {
        return;
      }

      final credentials = await BiometricService.instance.getSavedCredentials();
      if (credentials == null ||
          credentials['email'] == null ||
          credentials['password'] == null) {
        Helpers.showError('No saved biometric credentials found. Please log in with password once.'.tr);
        isBiometricAvailable.value = false;
        return;
      }

      isLoading.value = true;

      final response = await _authService.login(
        email: credentials['email']!,
        password: credentials['password']!,
      );

      if (response.statusCode == 200) {
        Helpers.showSuccess('Login successful'.tr);
        await _authService.handleAuthResponse(response);
        Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
      } else {
        Helpers.showError(response.data['message'] ?? 'Biometric login failed. Please enter your password.'.tr);
      }
    } catch (e) {
      Helpers.showDebugLog('Biometric Login Error: $e');
      Helpers.showError('Biometric login failed. Please sign in manually.'.tr);
    } finally {
      isBiometricLoading.value = false;
      isLoading.value = false;
    }
  }

  Future<void> loginWithGoogle() async {
    try {
      isLoading.value = true;
      final response = await _authService.loginWithGoogle();
      if (response.statusCode == 200) {
        Helpers.showSuccess('Login successful'.tr);
        Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
      } else {
        Helpers.showError(response.data['message'] ?? 'Google Login failed'.tr);
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
        Helpers.showSuccess('Login successful'.tr);
        Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
      } else {
        Helpers.showError(response.data['message'] ?? 'Apple Login failed'.tr);
      }
    } catch (e) {
      Helpers.showDebugLog(e.toString());
      Helpers.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void goToRegister() {
    Get.toNamed(AppRoutes.REGISTER);
  }

  void goToHome() {
    _authService.isLoggedIn.value = true;
    Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
  }

  void goToForgotPassword() {
    Get.toNamed(AppRoutes.FORGOT_PASSWORD);
  }
}
