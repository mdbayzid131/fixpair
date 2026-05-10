import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

String generateNonce([int length = 32]) {
  const charset =
      '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz-._';
  final random = Random.secure();
  return List.generate(length, (_) => charset[random.nextInt(charset.length)])
      .join();
}

String sha256OfString(String input) {
  final bytes = utf8.encode(input);
  return sha256.convert(bytes).toString();
}
