import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:local_auth/local_auth.dart';
import 'package:fixpair/core/utils/helpers.dart';

/// ===================== BIOMETRIC SERVICE =====================
/// Handles fingerprint, Face ID, local authentication and secure
/// credential storage for seamless one-tap login.
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();
  final GetStorage _box = GetStorage();

  static const _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock,
    ),
  );

  static const String keyBiometricEnabled = 'biometric_login_enabled';
  static const String _keySecureEmail = 'secure_bio_user_email';
  static const String _keySecurePassword = 'secure_bio_user_password';

  /// Check if device hardware supports biometrics
  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  /// Check if biometrics can be checked
  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  /// Get enrolled biometric types on device
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return <BiometricType>[];
    }
  }

  /// Returns true if the device has usable and enrolled biometrics
  Future<bool> hasUsableBiometric() async {
    final supported = await isDeviceSupported();
    final canCheck = await canCheckBiometrics();
    if (!supported || !canCheck) return false;

    final list = await getAvailableBiometrics();
    return list.isNotEmpty;
  }

  /// Trigger Face ID / Fingerprint prompt
  Future<bool> authenticate({String? localizedReason}) async {
    try {
      final result = await _auth.authenticate(
        localizedReason: localizedReason ?? 'Authenticate to log in securely',
        options: const AuthenticationOptions(
          biometricOnly: true,
          stickyAuth: true,
          useErrorDialogs: true,
        ),
      );
      return result;
    } catch (e) {
      Helpers.showDebugLog('Biometric Error: ${e.toString()}');
      return false;
    }
  }

  /// Human-friendly label (e.g. "Face ID", "Touch ID", "Fingerprint")
  Future<String> biometricLabel() async {
    final biometrics = await getAvailableBiometrics();

    if (Platform.isIOS) {
      if (biometrics.contains(BiometricType.face)) return 'Face ID';
      if (biometrics.contains(BiometricType.fingerprint)) return 'Touch ID';
      return 'Biometric';
    }

    if (Platform.isAndroid) {
      if (biometrics.contains(BiometricType.fingerprint)) return 'Fingerprint';
      if (biometrics.contains(BiometricType.face)) return 'Face Unlock';
      return 'Biometric';
    }

    return 'Biometric';
  }

  /// Icon corresponding to biometric type
  Future<IconData> biometricIcon() async {
    final biometrics = await getAvailableBiometrics();
    if (Platform.isIOS && biometrics.contains(BiometricType.face)) {
      return Icons.face_rounded;
    }
    if (Platform.isAndroid && biometrics.contains(BiometricType.face)) {
      return Icons.face_rounded;
    }
    return Icons.fingerprint_rounded;
  }

  /// Check if user has enabled biometric login
  bool isBiometricEnabled() {
    return _box.read(keyBiometricEnabled) ?? false;
  }

  /// Enable or disable biometric login
  Future<void> setBiometricEnabled(bool enabled) async {
    await _box.write(keyBiometricEnabled, enabled);
    if (!enabled) {
      await clearCredentials();
    }
  }

  /// Save encrypted credentials for biometric login
  Future<void> saveCredentials({
    required String email,
    required String password,
  }) async {
    try {
      await _secureStorage.write(key: _keySecureEmail, value: email);
      await _secureStorage.write(key: _keySecurePassword, value: password);
      await _box.write(keyBiometricEnabled, true);
    } catch (e) {
      Helpers.showDebugLog('Error saving biometric credentials: $e');
    }
  }

  /// Check if valid credentials exist in secure storage
  Future<bool> hasSavedCredentials() async {
    try {
      final email = await _secureStorage.read(key: _keySecureEmail);
      final pass = await _secureStorage.read(key: _keySecurePassword);
      return (email != null && email.isNotEmpty && pass != null && pass.isNotEmpty);
    } catch (_) {
      return false;
    }
  }

  /// Get stored credentials
  Future<Map<String, String>?> getSavedCredentials() async {
    try {
      final email = await _secureStorage.read(key: _keySecureEmail);
      final password = await _secureStorage.read(key: _keySecurePassword);
      if (email != null &&
          email.isNotEmpty &&
          password != null &&
          password.isNotEmpty) {
        return {'email': email, 'password': password};
      }
      return null;
    } catch (e) {
      Helpers.showDebugLog('Error reading biometric credentials: $e');
      return null;
    }
  }

  /// Clear saved credentials from secure storage
  Future<void> clearCredentials() async {
    try {
      await _secureStorage.delete(key: _keySecureEmail);
      await _secureStorage.delete(key: _keySecurePassword);
    } catch (e) {
      Helpers.showDebugLog('Error clearing biometric credentials: $e');
    }
  }
}
