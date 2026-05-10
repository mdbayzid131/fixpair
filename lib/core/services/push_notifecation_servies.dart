import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

// 🔥 Background handler (must be top-level)
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('📬 Background Message: ${message.messageId}');
}

class FirebaseNotificationService {
  static final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  static Future<void> initialize() async {
    // ✅ Permission (Android auto, iOS needed)
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    print('🔐 Permission: ${settings.authorizationStatus}');

    // ✅ Get FCM Token
    try {
      if (Platform.isIOS) {
        // iOS-এ APNS token পেতে সময় লাগতে পারে, তাই কিছুটা অপেক্ষা করা ভালো
        String? apnsToken = await _messaging.getAPNSToken();
        int retryCount = 0;
        while (apnsToken == null && retryCount < 3) {
          await Future.delayed(const Duration(seconds: 2));
          apnsToken = await _messaging.getAPNSToken();
          retryCount++;
          debugPrint('⏳ Waiting for APNS Token... (Retry: $retryCount)');
        }
      }

      String? token = await _messaging.getToken();
      debugPrint('🔑 FCM Token: $token');
    } catch (e) {
      debugPrint('❌ Error getting FCM Token: $e');
    }

    // ✅ Listen for Token Refresh
    _messaging.onTokenRefresh.listen((newToken) {
      debugPrint('🔄 FCM Token Refreshed: $newToken');
    });

    // 👉 TODO: backend এ পাঠাতে চাইলে এখানে পাঠাও

    // ✅ Foreground message
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      print('📨 Foreground Message: ${message.notification?.title}');
    });

    // ✅ Notification click (background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      print('🔔 Notification clicked: ${message.data}');
    });

    // ✅ App closed থাকলে open হলে
    RemoteMessage? initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      print('🚀 Opened from terminated: ${initialMessage.data}');
    }

    // ✅ Background handler
    FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);
  }
}