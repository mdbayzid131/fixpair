import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'biometric_service.dart';

class AppLockService extends GetxService with WidgetsBindingObserver {
  static AppLockService get to => Get.find<AppLockService>();

  final GetStorage _box = GetStorage();

  static const String biometricEnabledKey = 'biometric_enabled';
  static const String appUnlockedKey = 'app_unlocked_once';

  final RxBool biometricEnabled = false.obs;
  final RxBool isUnlocked = false.obs;
  final RxBool isAuthenticating = false.obs;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    biometricEnabled.value = _box.read(biometricEnabledKey) ?? false;
    isUnlocked.value = _box.read(appUnlockedKey) ?? false;
  }

  Future<void> setBiometricEnabled(bool value) async {
    if (value) {
      isAuthenticating.value = true;
      try {
        final hasBiometric = await BiometricService.instance
            .hasUsableBiometric();
        if (!hasBiometric) {
          Get.snackbar(
            'Unavailable',
            'No biometric is set up on this device.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.errorContainer,
          );
          biometricEnabled.value = false;
          await _box.write(biometricEnabledKey, false);
          return;
        }

        // Small delay to let UI settle
        await Future.delayed(const Duration(milliseconds: 300));
        final ok = await BiometricService.instance.authenticate();
        if (!ok) {
          biometricEnabled.value = false;
          await _box.write(biometricEnabledKey, false);
          Get.snackbar(
            'Verification Failed',
            'Try again or ensure biometrics are enabled in system settings.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Get.theme.colorScheme.errorContainer,
          );
          return;
        }
      } finally {
        isAuthenticating.value = false;
      }
    }

    biometricEnabled.value = value;
    await _box.write(biometricEnabledKey, value);
  }

  Future<void> markUnlocked() async {
    isUnlocked.value = true;
    await _box.write(appUnlockedKey, true);
  }

  Future<void> markLocked() async {
    isUnlocked.value = false;
    await _box.write(appUnlockedKey, false);
  }

  Future<bool> unlockWithBiometric() async {
    if (isAuthenticating.value) return false;
    isAuthenticating.value = true;

    try {
      final ok = await BiometricService.instance.authenticate();
      if (ok) {
        await markUnlocked();
      }
      return ok;
    } finally {
      isAuthenticating.value = false;
    }
  }

  bool shouldShowLockOnLaunch() {
    return biometricEnabled.value && !isUnlocked.value;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!biometricEnabled.value || isAuthenticating.value) return;

    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      await markLocked();
    }

    if (state == AppLifecycleState.resumed) {
      if (!isUnlocked.value && Get.currentRoute != AppRoutes.LOCK) {
        Get.toNamed(AppRoutes.LOCK);
      }
    }
  }
}
