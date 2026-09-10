import 'dart:convert';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:fixpair/config/constants/api_constants.dart';
import 'package:fixpair/config/constants/storage_constants.dart';
import 'package:fixpair/core/services/storage_service.dart';
import 'package:fixpair/core/utils/logger.dart';
import 'package:fixpair/firebase_options.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// ===================== INCOMING CALL PAYLOAD =====================
/// Centralized, robust parser for incoming call push payloads.
/// Extracts caller identity, Agora credentials, and routing parameters uniformly.
class IncomingCallPayload {
  final String sessionId;
  final String token;
  final String channelName;
  final String bookingId;
  final String callerName;
  final String callerAvatar;
  final String type;
  final String status;
  final bool isCancelOrReject;
  final bool isIncomingCall;

  const IncomingCallPayload({
    required this.sessionId,
    required this.token,
    required this.channelName,
    required this.bookingId,
    required this.callerName,
    required this.callerAvatar,
    required this.type,
    required this.status,
    required this.isCancelOrReject,
    required this.isIncomingCall,
  });

  factory IncomingCallPayload.fromMessage(RemoteMessage message) {
    final Map<String, dynamic> rawData = Map<String, dynamic>.from(
      message.data,
    );
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

    final type =
        (rawData['type'] ?? rawData['callType'] ?? rawData['notificationType'])
            ?.toString()
            .toUpperCase() ??
        '';
    final status = rawData['status']?.toString().toLowerCase() ?? '';

    final bool isCancelOrReject =
        type == 'CALL_REJECTED' ||
        type == 'CALL_CANCELLED' ||
        type == 'CANCEL_CALL' ||
        type == 'REJECT_CALL' ||
        type == 'SESSION_ENDED' ||
        type == 'CALL_ENDED' ||
        status == 'rejected' ||
        status == 'cancelled' ||
        status == 'ended';

    final bool isIncomingCall =
        type == 'INCOMING_CALL' ||
        type == 'CALL' ||
        type == 'VIDEO_CALL' ||
        type == 'CALL_INCOMING';

    final sessionId =
        (rawData['sessionId'] ??
                rawData['session_id'] ??
                rawData['callId'] ??
                rawData['call_id'] ??
                rawData['id'])
            ?.toString() ??
        '';

    final token =
        (rawData['token'] ??
                rawData['agoraToken'] ??
                rawData['agora_token'] ??
                rawData['rtcToken'] ??
                rawData['rtc_token'])
            ?.toString() ??
        '';

    final channelName =
        (rawData['channelName'] ??
                rawData['channel_name'] ??
                rawData['channel'] ??
                sessionId)
            .toString();

    // ── 1. Booking ID extraction ──
    final idKeys = [
      'bookingId',
      'booking_id',
      'booking',
      'consultationId',
      'consultation_id',
      'consultation',
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

    // ── 2. Direct caller name keys ──
    final nameKeys = [
      'consultantName',
      'consultant_name',
      'senderName',
      'sender_name',
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

    // ── 3. First name + Last name ──
    if (callerName.isEmpty) {
      final fn =
          rawData['consultantFirstName'] ??
          rawData['consultant_first_name'] ??
          rawData['senderFirstName'] ??
          rawData['sender_first_name'] ??
          rawData['firstName'] ??
          rawData['first_name'];
      final ln =
          rawData['consultantLastName'] ??
          rawData['consultant_last_name'] ??
          rawData['senderLastName'] ??
          rawData['sender_last_name'] ??
          rawData['lastName'] ??
          rawData['last_name'];
      if (isValidName(fn?.toString())) {
        callerName = '$fn ${ln ?? ''}'.trim();
      }
    }

    // ── 4. Nested consultant / sender objects ──
    if (callerName.isEmpty) {
      for (var objKey in [
        'consultant',
        'sender',
        'caller',
        'user',
        'expert',
        'booking',
      ]) {
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
            final n =
                map['name'] ??
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
              final av =
                  map['avatar'] ??
                  map['image'] ??
                  map['photo'] ??
                  map['profilePic'] ??
                  map['avatarUrl'] ??
                  map['avatar_url'];
              if (av != null &&
                  av.toString().isNotEmpty &&
                  av.toString() != 'null') {
                callerAvatar = ApiConstants.getImageUrl(av.toString());
              }
            }
            break;
          }
        }
      }
    }

    // ── 5. Direct avatar keys ──
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

    // ── 6. Check notification body ──
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

    if (callerName.isEmpty) {
      callerName = 'Fixpair Consultant';
    }

    return IncomingCallPayload(
      sessionId: sessionId,
      token: token,
      channelName: channelName,
      bookingId: bookingId,
      callerName: callerName,
      callerAvatar: callerAvatar,
      type: type,
      status: status,
      isCancelOrReject: isCancelOrReject,
      isIncomingCall: isIncomingCall,
    );
  }

  static String formatToUuid(String id) {
    if (id.isEmpty) return '00000000-0000-0000-0000-000000000000';
    final uuidRegex = RegExp(r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$');
    if (uuidRegex.hasMatch(id)) return id;

    final clean = id.replaceAll(RegExp(r'[^0-9a-fA-F]'), '');
    final padded = (clean + '00000000000000000000000000000000').substring(0, 32);
    return '${padded.substring(0, 8)}-${padded.substring(8, 12)}-${padded.substring(12, 16)}-${padded.substring(16, 20)}-${padded.substring(20, 32)}';
  }

  static String resolveSessionId(String id, [Map<String, dynamic>? extra]) {
    if (extra != null && extra['sessionId'] != null && extra['sessionId'].toString().isNotEmpty) {
      return extra['sessionId'].toString();
    }
    final clean = id.replaceAll('-', '');
    if (clean.length == 32 && clean.endsWith('00000000')) {
      return clean.substring(0, 24);
    }
    return id;
  }

  String get callKitUuid => formatToUuid(sessionId);

  /// Creates standard FlutterCallkitIncoming parameters with full-screen intent
  CallKitParams toCallKitParams() {
    return CallKitParams(
      id: callKitUuid,
      nameCaller: callerName.isNotEmpty ? callerName : 'Consultant',
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
      android: const AndroidParams(
        isCustomNotification: false,
        isShowLogo: false,
        isShowFullLockedScreen: true,
        isImportant: true,
        ringtonePath: 'system_ringtone_default',
        incomingCallNotificationChannelName: 'Incoming Call',
        backgroundColor: '#0F172A',
        textAccept: 'Accept',
        textDecline: 'Decline',
      ),
      ios: const IOSParams(
        handleType: 'generic',
        supportsVideo: true,
        maximumCallGroups: 2,
        maximumCallsPerCallGroup: 1,
        audioSessionMode: 'videoChat',
        audioSessionActive: true,
        audioSessionPreferredSampleRate: 44100.0,
        audioSessionPreferredIOBufferDuration: 0.005,
        supportsDTMF: true,
        supportsHolding: true,
        supportsGrouping: false,
        supportsUngrouping: false,
        ringtonePath: '',
      ),
    );
  }
}

/// ===================== FIREBASE NOTIFICATION SERVICE =====================
/// Handles Firebase Cloud Messaging (FCM) push notifications.
/// Coordinates background call presentation and token lifecycle.

/// 🔥 Background handler — must be a top-level function
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  try {
    await dotenv.load(fileName: '.env');
  } catch (_) {
    // Fallback to ApiConstants defaults
  }

  AppLogger.debug('Background Message: ${message.messageId}');
  AppLogger.debug('Background Data: ${message.data}');

  final payload = IncomingCallPayload.fromMessage(message);

  // ── [1. CALL CANCELLATION / REJECTION IN BACKGROUND / TERMINATED STATE] ──
  if (payload.isCancelOrReject) {
    try {
      if (payload.sessionId.isNotEmpty) {
        await FlutterCallkitIncoming.endCall(payload.sessionId);
      }
    } catch (_) {}
    try {
      await FlutterCallkitIncoming.endAllCalls();
    } catch (_) {}
    return;
  }

  // ── [2. INCOMING CALL IN BACKGROUND / TERMINATED STATE] ──
  if (payload.isIncomingCall &&
      payload.sessionId.isNotEmpty &&
      payload.token.isNotEmpty) {
    await FlutterCallkitIncoming.showCallkitIncoming(payload.toCallKitParams());

    // Listen for CallKit actions in background isolate (Decline / Timeout)
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event == null) return;
      switch (event) {
        case CallEventActionCallDecline(:final id):
        case CallEventActionCallTimeout(:final id):
          if (id.isNotEmpty) {
            try {
              final realSessionId = IncomingCallPayload.resolveSessionId(id);
              final token = await StorageService.getString(
                StorageConstants.bearerToken,
              );
              final dio = Dio(
                BaseOptions(
                  baseUrl: ApiConstants.baseUrl,
                  headers: {
                    'Content-Type': 'application/json',
                    if (token.isNotEmpty) 'Authorization': 'Bearer $token',
                  },
                ),
              );
              await dio.post(
                ApiConstants.actionVideoSession,
                data: {'sessionId': realSessionId, 'action': 'REJECT'},
              );
              AppLogger.info(
                '🔔 [BG CALL] Successfully notified backend of rejected call $realSessionId',
              );
            } catch (e) {
              AppLogger.warning(
                '🔔 [BG CALL] Error notifying backend of rejection in BG: $e',
              );
            }
          }
          break;
        default:
          break;
      }
    }, onError: (err) {
      AppLogger.debug('BG CallKit event stream exception handled: $err');
    });
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

    // Get APNS token and VoIP token for iOS reliability
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

        try {
          final voipToken = await FlutterCallkitIncoming.getDevicePushTokenVoIP();
          AppLogger.info('📱 [iOS VoIP Token]: $voipToken');
        } catch (e) {
          AppLogger.debug('Error fetching iOS VoIP token: $e');
        }
      }
    } catch (e) {
      AppLogger.debug('Error fetching APNS Token: $e');
    }

    // Get FCM token
    final token = await _messaging.getToken();
    AppLogger.info('🔥 FCM Token Loaded: $token');

    // Listen for token refresh
    _messaging.onTokenRefresh.listen((newToken) {
      AppLogger.debug('FCM Token refreshed: $newToken');
      onTokenRefresh?.call(newToken);
    });

    // Foreground message listener
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final title =
          message.notification?.title ??
          message.data['title'] ??
          message.data['type'] ??
          'Push Notification';
      final type =
          message.data['type'] ?? message.data['status'] ?? 'NOTIFICATION';
      AppLogger.info(
        '🔔 [FCM PUSH RECEIVED] Title: $title | Type: $type | Data: ${message.data}',
      );
      onForegroundMessage?.call(message);
    });

    // Notification tap (app in background)
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      final title =
          message.notification?.title ??
          message.data['title'] ??
          'Notification';
      AppLogger.info(
        '👆 [FCM PUSH CLICKED] Title: $title | Data: ${message.data}',
      );
      onNotificationTap?.call(message);
    });

    // App opened from terminated state
    final initialMessage = await _messaging.getInitialMessage();
    if (initialMessage != null) {
      final title =
          initialMessage.notification?.title ??
          initialMessage.data['title'] ??
          'Notification';
      AppLogger.info(
        '🚀 [FCM TERMINATED OPEN] Title: $title | Data: ${initialMessage.data}',
      );
      onNotificationTap?.call(initialMessage);
    }

    // Register background handler
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    return token;
  }

  /// Get current FCM Token
  static Future<String?> getToken() async {
    try {
      return await _messaging.getToken();
    } catch (e) {
      AppLogger.debug('Error fetching FCM token: $e');
      return null;
    }
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
