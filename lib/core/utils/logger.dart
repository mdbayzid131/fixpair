import 'dart:convert';
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
      _printLongString('Body: ${_formatData(options.data)}');
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
    _printLongString('Data: ${_formatData(response.data)}');
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
      _printLongString('Data: ${_formatData(e.response?.data)}');
    }
    debugPrint('└ ❌❌❌❌ ERROR $_divider ❌❌❌❌ ');
    debugPrint('');
  }

  /// General debug log (only in debug mode)
  static void debug(String message) {
    if (!kDebugMode) return;
    _printLongString('🔍🔍🔍 DEBUG: $message', prefix: '');
  }

  /// Info-level log
  static void info(String message) {
    if (!kDebugMode) return;
    _printLongString('ℹ️ℹ️ℹ️ℹ INFO: $message', prefix: '');
  }

  /// Warning-level log
  static void warning(String message) {
    if (!kDebugMode) return;
    _printLongString('⚠️⚠️⚠️ WARNING: $message', prefix: '');
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

  /// Safely format data as JSON string or raw string
  static String _formatData(dynamic data) {
    if (data == null) return 'null';
    try {
      if (data is Map || data is List) {
        return const JsonEncoder.withIndent('  ').convert(data);
      }
    } catch (_) {}
    return data.toString();
  }

  /// Print long strings in chunks of ~800 characters line-by-line
  /// to prevent Android Logcat / debugPrint truncation.
  static void _printLongString(String text, {String prefix = '│ '}) {
    const int chunkSize = 800;
    final lines = text.split('\n');
    for (final line in lines) {
      if (line.isEmpty) {
        debugPrint(prefix);
        continue;
      }
      if (line.length <= chunkSize) {
        debugPrint('$prefix$line');
      } else {
        int start = 0;
        while (start < line.length) {
          int end = start + chunkSize;
          if (end > line.length) end = line.length;
          debugPrint('$prefix${line.substring(start, end)}');
          start = end;
        }
      }
    }
  }
}
