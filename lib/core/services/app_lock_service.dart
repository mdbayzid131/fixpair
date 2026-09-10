import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import '../utils/helpers.dart';
import 'biometric_service.dart';

/// ===================== APP LOCK SERVICE =====================
/// Handles biometric authentication and app lock/unlock lifecycle.
/// Requires get_storage and local_auth packages.
class AppLockService extends GetxService with WidgetsBindingObserver {
  static AppLockService get to => Get.find<AppLockService>();

  final GetStorage _box = GetStorage();
  static const MethodChannel _deviceLockChannel =
      MethodChannel('com.fixpair.app/device_lock');

  static const String biometricEnabledKey = 'biometric_enabled';
  static const String appUnlockedKey = 'app_unlocked_once';
  static const String autoLockTimeoutKey = 'auto_lock_timeout';

  final RxBool biometricEnabled = false.obs;
  final RxBool isUnlocked = false.obs;
  final RxBool isAuthenticating = false.obs;
  final RxInt autoLockTimeoutSeconds = (-1).obs; // -1 = When device locks

  DateTime? _pausedTime;
  bool isLockScreenOpen = false;

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);

    biometricEnabled.value = _box.read(biometricEnabledKey) ?? false;
    isUnlocked.value = _box.read(appUnlockedKey) ?? false;
    final storedTimeout = _box.read<int>(autoLockTimeoutKey);
    autoLockTimeoutSeconds.value =
        (storedTimeout == null || storedTimeout == 0) ? -1 : storedTimeout;
  }

  void navigateToLockScreen() {
    if (isLockScreenOpen) return;
    isLockScreenOpen = true;
    markLocked();
    if (Get.currentRoute != AppRoutes.LOCK) {
      Get.toNamed(AppRoutes.LOCK)?.then((_) {
        isLockScreenOpen = false;
      });
    }
  }

  Future<void> setAutoLockTimeout(int seconds) async {
    autoLockTimeoutSeconds.value = seconds;
    await _box.write(autoLockTimeoutKey, seconds);
  }

  String get timeoutLabel {
    final sec = autoLockTimeoutSeconds.value;
    if (sec == -1 || sec == 0) return 'When device locks';
    if (sec == 60) return 'After 1 minute';
    if (sec == 300) return 'After 5 minutes';
    if (sec == 900) return 'After 15 minutes';
    return '$sec seconds';
  }

  Future<void> setBiometricEnabled(bool value) async {
    if (value) {
      isAuthenticating.value = true;
      try {
        final hasBiometric = await BiometricService.instance
            .hasUsableBiometric();
        if (!hasBiometric) {
          Helpers.showError(
            'No biometric is set up on this device.',
            title: 'Unavailable',
          );
          biometricEnabled.value = false;
          await _box.write(biometricEnabledKey, false);
          return;
        }

        await Future.delayed(const Duration(milliseconds: 300));
        final ok = await BiometricService.instance.authenticate();
        if (!ok) {
          biometricEnabled.value = false;
          await _box.write(biometricEnabledKey, false);
          Helpers.showError(
            'Try again or ensure biometrics are enabled in system settings.',
            title: 'Verification Failed',
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
      // Keep isAuthenticating true briefly after dialog closes to absorb the lifecycle resumed event
      Future.delayed(const Duration(milliseconds: 600), () {
        isAuthenticating.value = false;
      });
    }
  }

  bool shouldShowLockOnLaunch() {
    return biometricEnabled.value && !isUnlocked.value;
  }

  Future<bool> _checkIsDeviceLockedNative() async {
    try {
      final bool? isLocked =
          await _deviceLockChannel.invokeMethod<bool>('isDeviceLocked');
      return isLocked ?? false;
    } catch (_) {
      return false;
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (!biometricEnabled.value || isAuthenticating.value || isLockScreenOpen) {
      return;
    }

    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.paused) {
      _pausedTime = DateTime.now();
    }

    if (state == AppLifecycleState.resumed) {
      if (autoLockTimeoutSeconds.value == -1) {
        final isDeviceLocked = await _checkIsDeviceLockedNative();
        if (isDeviceLocked) {
          navigateToLockScreen();
        }
      } else if (autoLockTimeoutSeconds.value >= 0 && _pausedTime != null) {
        final elapsed = DateTime.now().difference(_pausedTime!).inSeconds;
        if (elapsed >= autoLockTimeoutSeconds.value) {
          navigateToLockScreen();
        }
      }
    }
  }
}
