import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

/// ===================== APP LOGGER =====================
/// Centralized logging utility for API requests, responses, and errors.
/// Only logs in debug mode to avoid leaking sensitive data in production.

class AppLogger {
  AppLogger._();

  static const String _divider = '══════════════════════════════════════';

  /// Log outgoing API request
  static void request(RequestOptions options) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('┌ ➡️➡️➡️➡️ REQUEST $_divider ➡️➡️➡️➡️');
    debugPrint('│ ${options.method} ${options.uri}');
    debugPrint('│ Headers: ${_sanitizeHeaders(options.headers)}');
    if (options.queryParameters.isNotEmpty) {
      debugPrint('│ Query: ${options.queryParameters}');
    }
    if (options.data != null) {
      debugPrint('│ Body: ${options.data}');
    }
    debugPrint('└ ➡️➡️➡️➡️ REQUEST $_divider ➡️➡️➡️➡️');
    debugPrint('');
  }

  /// Log incoming API response
  static void response(Response response) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('┌ ✅✅✅✅ RESPONSE $_divider ✅✅✅✅');
    debugPrint('│ [${response.statusCode}] ${response.requestOptions.uri}');
    debugPrint(
      '│ Data: ${_truncate(response.data?.toString(), showAll: true)}',
    );
    debugPrint('└ ✅✅✅✅ RESPONSE $_divider ✅✅✅✅');
    debugPrint('');
  }

  /// Log API error
  static void error(DioException e) {
    if (!kDebugMode) return;

    debugPrint('');
    debugPrint('┌ ❌❌❌❌ ERROR $_divider ❌❌❌❌ ');
    debugPrint('│ ${e.type.name}: ${e.message}');
    debugPrint('│ URL: ${e.requestOptions.uri}');
    if (e.response != null) {
      debugPrint('│ Status: ${e.response?.statusCode}');
      debugPrint(
        '│ Data: ${_truncate(e.response?.data?.toString(), showAll: true)}',
      );
    }
    debugPrint('└ ❌❌❌❌ ERROR $_divider ❌❌❌❌ ');
    debugPrint('');
  }

  /// General debug log (only in debug mode)
  static void debug(String message) {
    if (!kDebugMode) return;
    debugPrint('');
    debugPrint('🔍🔍🔍 DEBUG: $message');
    debugPrint('');
  }

  /// Info-level log
  static void info(String message) {
    if (!kDebugMode) return;
    debugPrint('');
    debugPrint('ℹ️ℹ️ℹ️ℹ INFO: $message');
    debugPrint('');
  }

  /// Warning-level log
  static void warning(String message) {
    if (!kDebugMode) return;
    debugPrint('');
    debugPrint('⚠️⚠️⚠️ WARNING: $message');
    debugPrint('');
  }

  // ──────────────────── PRIVATE HELPERS ────────────────────

  /// Remove Authorization header value for safe logging
  static Map<String, dynamic> _sanitizeHeaders(Map<String, dynamic> headers) {
    final sanitized = Map<String, dynamic>.from(headers);
    if (sanitized.containsKey('Authorization')) {
      sanitized['Authorization'] = '***';
    }
    return sanitized;
  }

  /// Truncate long strings to keep logs readable
  static String _truncate(
    String? text, {
    int maxLength = 500,
    bool showAll = false,
  }) {
    if (text == null) return 'null';
    if (showAll) {
      return text;
    }
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength)}... [truncated]';
  }
}
