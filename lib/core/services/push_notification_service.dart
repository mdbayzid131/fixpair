import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixpair/core/utils/logger.dart';

/// ===================== FIREBASE NOTIFICATION SERVICE =====================
/// Handles Firebase Cloud Messaging (FCM) push notifications.
/// Requires: firebase_core, firebase_messaging
/// Also needs google-services.json (Android) and GoogleService-Info.plist (iOS).

/// 🔥 Background handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  AppLogger.debug('Background Message: ${message.messageId}');
}

class FirebaseNotificationService {
  FirebaseNotificationService._();

  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Callback for foreground messages
  static void Function(RemoteMessage)? onForegroundMessage;

  /// Callback for notification tap (app in background)
  static void Function(RemoteMessage)? onNotificationTap;

  /// Callback for FCM token refresh
  static void Function(String)? onTokenRefresh;

  /// Initialize FCM: permissions, token, listeners, background handler
  static Future<String?> initialize() async {
    // Request permission (Android auto-grants, iOS requires this)
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
    AppLogger.debug('FCM Permission: ${settings.authorizationStatus}');

    // Get APNS token for iOS reliability
    try {
      if (Platform.isIOS) {
        String? apnsToken = await _messaging.getAPNSToken();
        int retryCount = 0;
        while (apnsToken == null && retryCount < 3) {
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await _messaging.getAPNSToken();
          retryCount++;
          AppLogger.debug('⏳ Waiting for APNS Token... (Retry: $retryCount)');
        }
      }
    } catch (e) {
      AppLogger.debug('Error fetching APNS Token: $e');
    }

    // Get FCM token
    final token = await _messaging.getToken();
    print('🔥 [FCM SERVICE] ---------------------------------------------');
    print('🔥 FCM TOKEN: $token');
    print('🔥 -----------------------------------------------------------');
    AppLogger.debug('FCM Token: $token');

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      AppLogger.debug('FCM Token refreshed: $newToken');
      onTokenRefresh?.call(newToken);
    });

    // Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      AppLogger.debug('Foreground: ${message.notification?.title}');
      onForegroundMessage?.call(message);
    });

    // Notification tap (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      AppLogger.debug('Notification clicked: ${message.data}');
      onNotificationTap?.call(message);
    });

    // App opened from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      AppLogger.debug('Opened from terminated: ${initialMessage.data}');
      onNotificationTap?.call(initialMessage);
    }

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    return token;
  }

  /// Subscribe to a topic
  static Future<void> subscribeToTopic(String topic) async {
    await _messaging.subscribeToTopic(topic);
    AppLogger.debug('Subscribed to topic: $topic');
  }

  /// Unsubscribe from a topic
  static Future<void> unsubscribeFromTopic(String topic) async {
    await _messaging.unsubscribeFromTopic(topic);
    AppLogger.debug('Unsubscribed from topic: $topic');
  }
}
