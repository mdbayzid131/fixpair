import 'dart:convert';
import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixpair/config/constants/api_constants.dart';
import 'package:fixpair/core/utils/logger.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ===================== FIREBASE NOTIFICATION SERVICE =====================
/// Handles Firebase Cloud Messaging (FCM) push notifications.
/// Requires: firebase_core, firebase_messaging
/// Also needs google-services.json (Android) and GoogleService-Info.plist (iOS).

import 'package:fixpair/firebase_options.dart';

/// 🔥 Background handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Load dotenv so ApiConstants (BASE_URL, SERVER_URL) works correctly
  // in this isolated background isolate where main() is not called.
  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Ignore if already loaded or file missing — ApiConstants has fallback values
  }

  // ── Debug: print full raw payload so we can verify backend is sending name/avatar ──
  print('🔔 [BG CALL] =========================================');
  print('🔔 [BG CALL] messageId: ${message.messageId}');
  print('🔔 [BG CALL] notification title: ${message.notification?.title}');
  print('🔔 [BG CALL] notification body:  ${message.notification?.body}');
  print('🔔 [BG CALL] data keys: ${message.data.keys.toList()}');
  print('🔔 [BG CALL] full data: ${message.data}');
  print('🔔 [BG CALL] =========================================');

  AppLogger.debug('Background Message: ${message.messageId}');
  AppLogger.debug('Background Data: ${message.data}');

  // Handle incoming call notifications in background/terminated state
  Map<String, dynamic> rawData = Map<String, dynamic>.from(message.data);
  if (rawData['data'] != null) {
    final subData = rawData['data'];
    if (subData is Map) {
      rawData.addAll(Map<String, dynamic>.from(subData));
    } else if (subData is String && subData.trim().startsWith('{')) {
      try {
        final dec = jsonDecode(subData);
        if (dec is Map) rawData.addAll(Map<String, dynamic>.from(dec));
      } catch (_) {}
    }
  }

  final type = (rawData['type'] ?? rawData['callType'] ?? rawData['notificationType'])
      ?.toString()
      .toUpperCase();

  if (type == 'INCOMING_CALL' ||
      type == 'CALL' ||
      type == 'VIDEO_CALL' ||
      type == 'CALL_INCOMING') {
    final sessionId = rawData['sessionId']?.toString() ??
        rawData['session_id']?.toString() ??
        rawData['callId']?.toString() ??
        rawData['call_id']?.toString() ??
        rawData['id']?.toString();

    final token = rawData['token']?.toString() ??
        rawData['agoraToken']?.toString() ??
        rawData['agora_token']?.toString() ??
        rawData['rtcToken']?.toString() ??
        rawData['rtc_token']?.toString();

    final channelName = rawData['channelName']?.toString() ??
        rawData['channel_name']?.toString() ??
        rawData['channel']?.toString() ??
        sessionId;

    // Robust parsing of booking ID
    final idKeys = [
      'bookingId',
      'booking_id',
      'booking',
      'consultationId',
      'consultation_id',
      'consultation'
    ];
    String bookingId = '';
    for (var key in idKeys) {
      final val = rawData[key]?.toString();
      if (val != null && val.isNotEmpty) {
        bookingId = val;
        break;
      }
    }

    bool isValidName(String? n) {
      if (n == null) return false;
      final clean = n.trim().toLowerCase();
      return clean.isNotEmpty &&
          clean != 'a user' &&
          clean != 'user' &&
          clean != 'notification' &&
          clean != 'fixpair' &&
          clean != 'fixpair notification' &&
          clean != 'incoming call' &&
          clean != 'video call' &&
          clean != 'call' &&
          clean != 'consultant' &&
          clean != 'null' &&
          clean != 'undefined';
    }

    String callerName = '';
    String callerAvatar = '';

    // 1. Check direct keys
    final nameKeys = [
      'consultantName',
      'consultant_name',
      'senderName',
      'sender_name',
      'expertName',
      'expert_name',
      'callerName',
      'caller_name',
      'name',
      'displayName',
      'display_name',
      'userName',
      'user_name',
    ];
    for (var key in nameKeys) {
      final val = rawData[key]?.toString().trim();
      if (isValidName(val)) {
        callerName = val!;
        break;
      }
    }

    // 2. Check first name + last name
    if (callerName.isEmpty) {
      final fn = rawData['consultantFirstName'] ??
          rawData['consultant_first_name'] ??
          rawData['senderFirstName'] ??
          rawData['sender_first_name'] ??
          rawData['firstName'] ??
          rawData['first_name'];
      final ln = rawData['consultantLastName'] ??
          rawData['consultant_last_name'] ??
          rawData['senderLastName'] ??
          rawData['sender_last_name'] ??
          rawData['lastName'] ??
          rawData['last_name'];
      if (isValidName(fn?.toString())) {
        callerName = '$fn ${ln ?? ''}'.trim();
      }
    }

    // 3. Check nested JSON objects (consultant, sender, caller, booking, user, data)
    if (callerName.isEmpty) {
      for (var objKey in ['consultant', 'sender', 'caller', 'user', 'expert', 'booking']) {
        final raw = rawData[objKey];
        if (raw != null) {
          Map<String, dynamic>? map;
          if (raw is Map) {
            map = Map<String, dynamic>.from(raw);
          } else if (raw is String && raw.trim().startsWith('{')) {
            try {
              final dec = jsonDecode(raw);
              if (dec is Map) map = Map<String, dynamic>.from(dec);
            } catch (_) {}
          }
          if (map != null) {
            final n = map['name'] ??
                map['displayName'] ??
                map['consultantName'] ??
                map['senderName'] ??
                map['fullName'] ??
                map['full_name'];
            if (isValidName(n?.toString())) {
              callerName = n.toString().trim();
            } else {
              final f = map['firstName'] ?? map['first_name'];
              final l = map['lastName'] ?? map['last_name'];
              if (isValidName(f?.toString())) {
                callerName = '$f ${l ?? ''}'.trim();
              }
            }
            if (callerAvatar.isEmpty) {
              final av = map['avatar'] ??
                  map['image'] ??
                  map['photo'] ??
                  map['profilePic'] ??
                  map['avatarUrl'] ??
                  map['avatar_url'];
              if (av != null && av.toString().isNotEmpty && av.toString() != 'null') {
                callerAvatar = ApiConstants.getImageUrl(av.toString());
              }
            }
            if (callerName.isNotEmpty) break;
          }
        }
      }
    }

    // 4. Check notification body for caller name (e.g. "Dr. Alex is calling you")
    if (callerName.isEmpty) {
      final body = message.notification?.body?.trim();
      if (body != null && body.isNotEmpty) {
        final match = RegExp(
          r'^(.+?)\s+(is calling|calling|sent you a call)',
          caseSensitive: false,
        ).firstMatch(body);
        if (match != null) {
          final extracted = match.group(1)?.trim();
          if (isValidName(extracted)) {
            callerName = extracted!;
          }
        }
      }
    }

    // 5. Default fallback
    if (callerName.isEmpty) {
      callerName = 'Fixpair Consultant';
    }

    // Extract Avatar URL
    if (callerAvatar.isEmpty) {
      final avatarKeys = [
        'consultantAvatar',
        'consultant_avatar',
        'consultantImage',
        'consultant_image',
        'senderAvatar',
        'sender_avatar',
        'senderImage',
        'sender_image',
        'callerAvatar',
        'caller_avatar',
        'avatar',
        'image',
        'photo',
        'profilePic',
        'avatarUrl',
        'avatar_url',
      ];
      for (var key in avatarKeys) {
        final val = rawData[key]?.toString();
        if (val != null && val.isNotEmpty && val != 'null') {
          callerAvatar = ApiConstants.getImageUrl(val);
          break;
        }
      }
    }

    print('🔔 [BG CALL] Parsed → sessionId=$sessionId | callerName=$callerName | callerAvatar=$callerAvatar');

    if (sessionId != null && token != null) {
      final CallKitParams callKitParams = CallKitParams(
        id: sessionId,
        nameCaller: callerName,
        appName: 'Fixpair',
        avatar: callerAvatar.isNotEmpty ? callerAvatar : null,
        handle: 'Video Consultation',
        type: 1, // 0: audio, 1: video
        duration: 35000,
        extra: <String, dynamic>{
          'sessionId': sessionId,
          'token': token,
          'channelName': channelName,
          'callerName': callerName,
          'callerAvatar': callerAvatar,
          'bookingId': bookingId,
        },
        missedCallNotification: const NotificationParams(
          showNotification: false,
          isShowCallback: false,
        ),
        android: AndroidParams(
          isCustomNotification: true,
          backgroundColor: '#0F172A',
          incomingCallNotificationChannelName: "Incoming Call",
          isShowLogo: true,
          isShowFullLockedScreen: true,
          isImportant: true,
          ringtonePath: 'system_ringtone_default',
          textAccept: 'Accept',
          textDecline: 'Decline',
        ),
        ios: const IOSParams(handleType: 'generic', supportsVideo: true),
      );

      await FlutterCallkitIncoming.showCallkitIncoming(callKitParams);
    }
  }
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
