import 'package:get/get.dart';
import '../utils/helpers.dart';
import 'biometric_service.dart';

/// ===================== APP LOCK / BIOMETRIC CONTROLLER SERVICE =====================
/// Manages reactive biometric login state and settings across the app.
class AppLockService extends GetxService {
  static AppLockService get to => Get.find<AppLockService>();

  final RxBool biometricEnabled = false.obs;
  final RxBool isAuthenticating = false.obs;
  final RxString biometricLabel = 'Biometrics'.obs;

  @override
  void onInit() {
    super.onInit();
    biometricEnabled.value = BiometricService.instance.isBiometricEnabled();
    _loadBiometricLabel();
  }

  Future<void> _loadBiometricLabel() async {
    biometricLabel.value = await BiometricService.instance.biometricLabel();
  }

  Future<void> setBiometricEnabled(bool value) async {
    if (value) {
      isAuthenticating.value = true;
      try {
        final hasBiometric =
            await BiometricService.instance.hasUsableBiometric();
        if (!hasBiometric) {
          Helpers.showError(
            'No biometric is set up on this device. Please configure Face ID or Fingerprint in system settings.'.tr,
            title: 'Unavailable'.tr,
          );
          biometricEnabled.value = false;
          await BiometricService.instance.setBiometricEnabled(false);
          return;
        }

        final ok = await BiometricService.instance.authenticate(
          localizedReason: 'Verify your biometric to enable quick login',
        );
        if (!ok) {
          biometricEnabled.value = false;
          await BiometricService.instance.setBiometricEnabled(false);
          Helpers.showError(
            'Verification failed. Biometric login was not enabled.'.tr,
            title: 'Verification Failed'.tr,
          );
          return;
        }

        biometricEnabled.value = true;
        await BiometricService.instance.setBiometricEnabled(true);
        Helpers.showSuccess('Biometric login enabled successfully'.tr);
      } finally {
        isAuthenticating.value = false;
      }
    } else {
      biometricEnabled.value = false;
      await BiometricService.instance.setBiometricEnabled(false);
      Helpers.showSuccess('Biometric login disabled'.tr);
    }
  }

  Future<bool> unlockWithBiometric() async {
    if (isAuthenticating.value) return false;
    isAuthenticating.value = true;

    try {
      return await BiometricService.instance.authenticate();
    } finally {
      isAuthenticating.value = false;
    }
  }
}
