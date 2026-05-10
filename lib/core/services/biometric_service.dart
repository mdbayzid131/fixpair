import 'dart:io';
import 'package:fixpair/core/utils/helpers.dart';
import 'package:local_auth/local_auth.dart';

/// ===================== BIOMETRIC SERVICE =====================
/// Handles fingerprint, face ID, and other biometric authentication.
/// Requires local_auth package.
class BiometricService {
  BiometricService._();
  static final BiometricService instance = BiometricService._();

  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> isDeviceSupported() async {
    try {
      return await _auth.isDeviceSupported();
    } catch (_) {
      return false;
    }
  }

  Future<bool> canCheckBiometrics() async {
    try {
      return await _auth.canCheckBiometrics;
    } catch (_) {
      return false;
    }
  }

  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      return await _auth.getAvailableBiometrics();
    } catch (_) {
      return <BiometricType>[];
    }
  }

  Future<bool> hasUsableBiometric() async {
    final supported = await isDeviceSupported();
    final canCheck = await canCheckBiometrics();
    if (!supported || !canCheck) return false;

    final list = await getAvailableBiometrics();
    return list.isNotEmpty;
  }

  Future<bool> authenticate() async {
    try {
      final result = await _auth.authenticate(
        localizedReason: 'Secure your account with biometric authentication',
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
}
