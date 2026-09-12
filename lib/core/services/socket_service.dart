import 'package:fixpair/config/constants/api_constants.dart';
import 'package:fixpair/config/constants/storage_constants.dart';
import 'package:fixpair/core/services/auth_service.dart';
import 'package:fixpair/core/services/push_notification_service.dart';
import 'package:fixpair/core/services/storage_service.dart';
import 'package:fixpair/core/utils/logger.dart';
import 'package:fixpair/modules/video_call/controllers/video_call_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// ===================== SOCKET SERVICE =====================
/// Manages real-time Socket.IO connection lifecycle, presence tracking,
/// call termination signaling, and messaging rooms across the application.
class SocketService extends GetxService {
  IO.Socket? _socket;

  /// Expose socket instance for direct event listening
  IO.Socket? get socket => _socket;

  /// Observable connection state
  final isConnected = false.obs;

  /// Callback for incoming notifications
  void Function(dynamic data)? onNotificationReceived;

  /// Callback for incoming messages
  void Function(dynamic data)? onMessageReceived;

  /// Callback for consultant online/offline status changes
  void Function(String consultantId, bool isOnline)? onConsultantStatusChanged;

  /// Observable for consultant status changes (Rx stream for GetX controllers)
  final consultantStatusUpdate = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    _initSocket();
  }

  @override
  void onClose() {
    disconnect();
    super.onClose();
  }

  // ──────────────────── INITIALIZATION ────────────────────

  Future<void> _initSocket() async {
    final token = await StorageService.getString(StorageConstants.bearerToken);
    final userId = await StorageService.getString(StorageConstants.userId);

    if (token.isEmpty) {
      AppLogger.warning('Socket initialization skipped: No auth token');
      return;
    }

    // Extract base server URL (strips '/api/v1' suffix)
    final baseUrl = ApiConstants.baseUrl.replaceAll('/api/v1', '');
    AppLogger.debug('Socket connecting to: $baseUrl');

    _socket = IO.io(
      baseUrl,
      IO.OptionBuilder()
          .setTransports(['websocket'])
          .setAuth({'token': token})
          .enableAutoConnect()
          .enableForceNew()
          .build(),
    );

    _setupListeners(userId);
  }

  void _setupListeners(String userId) {
    _socket?.onConnect((_) {
      AppLogger.info('Socket connected');
      isConnected.value = true;
      if (userId.isNotEmpty) registerUser(userId);
    });

    _socket?.onDisconnect((_) {
      AppLogger.info('Socket disconnected');
      isConnected.value = false;
    });

    _socket?.onConnectError((err) {
      AppLogger.debug('Socket connect error: $err');
      isConnected.value = false;
    });

    _socket?.onError((err) {
      AppLogger.debug('Socket error: $err');
    });

    // Default notification handler
    _socket?.on('new-notification', (data) {
      AppLogger.debug('New notification: $data');
      onNotificationReceived?.call(data);
    });

    // Default message handler
    _socket?.on('new-message', (data) {
      AppLogger.debug('New message: $data');
      onMessageReceived?.call(data);
    });

    // Global debug logger for socket events
    _socket?.onAny((event, data) {
      debugPrint(
        'ℹ️┌ 📡 SOCKET EVENT RECEIVED ══════════════════════════════════════\n'
        'ℹ️│ Event: $event\n'
        'ℹ️│ Data: $data\n'
        'ℹ️└ 📡 SOCKET EVENT RECEIVED ══════════════════════════════════════',
      );
    });

    // ── Incoming call handler via Socket ──
    void handleIncomingCall(dynamic data) {
      AppLogger.info('Incoming call event received via socket: $data');
      if (data is Map && Get.isRegistered<AuthService>()) {
        try {
          final payload = IncomingCallPayload.fromMap(
            Map<String, dynamic>.from(data),
            defaultType: 'INCOMING_CALL',
          );
          Get.find<AuthService>().handleIncomingCallPayload(payload);
        } catch (e) {
          AppLogger.warning('Error processing incoming call socket event: $e');
        }
      }
    }

    const incomingCallEvents = [
      'incoming-call',
      'incoming:call',
      'call-incoming',
      'call:incoming',
      'receive-call',
      'receive:call',
      'new-call',
      'new:call',
    ];
    for (final event in incomingCallEvents) {
      _socket?.on(event, handleIncomingCall);
    }

    // ── Call cancellation / ending handler ──
    void handleCallCancel(dynamic data) async {
      AppLogger.info('Call cancelled/ended event received via socket: $data');
      try {
        while (Get.isDialogOpen == true) {
          Get.back();
        }
        final String? sessionId = data is Map
            ? (data['sessionId'] ?? data['id'] ?? data['consultationId'] ?? data['bookingId'])?.toString()
            : null;
        if (sessionId != null && sessionId.isNotEmpty) {
          try {
            await FlutterCallkitIncoming.endCall(sessionId);
          } catch (_) {}
        }
        await FlutterCallkitIncoming.endAllCalls();

        if (Get.isRegistered<VideoCallController>()) {
          final controller = Get.find<VideoCallController>();
          if (!controller.hasConsultantJoined) {
            controller.handleCallRejected(reason: 'Call rejected by consultant'.tr);
          } else {
            controller.endCall();
          }
        }
      } catch (e) {
        AppLogger.warning('Error handling call-cancelled socket event: $e');
      }
    }

    // Register all call cancellation / termination event aliases
    const callCancelEvents = [
      'call-ended',
      'call:ended',
      'call-cancelled',
      'call:cancelled',
      'cancel-call',
      'cancel:call',
      'reject-call',
      'reject:call',
      'call-rejected',
      'call:rejected',
      'end-call',
      'end:call',
      'session-ended',
      'session:ended',
      'consultation-auto-ended',
      'consultation:auto-ended',
    ];
    for (final event in callCancelEvents) {
      _socket?.on(event, handleCallCancel);
    }

    // ── Consultant presence status handler ──
    void handleConsultantStatus(dynamic data) {
      AppLogger.info('Consultant status update event received via socket: $data');
      if (data is Map) {
        final String? consultantId = (data['consultantId'] ??
                data['userId'] ??
                data['id'] ??
                data['_id'])
            ?.toString();

        final dynamic statusVal = data['activeStatus'] ?? data['isOnline'] ?? data['status'];
        final bool isOnline = statusVal == true ||
            statusVal?.toString() == 'true' ||
            statusVal?.toString().toLowerCase() == 'online' ||
            statusVal?.toString().toLowerCase() == 'active';

        if (consultantId != null && consultantId.isNotEmpty) {
          consultantStatusUpdate.value = {
            'consultantId': consultantId,
            'isOnline': isOnline,
            'timestamp': DateTime.now().millisecondsSinceEpoch,
          };
          onConsultantStatusChanged?.call(consultantId, isOnline);
        }
      }
    }

    // Register all consultant presence event aliases
    const consultantStatusEvents = [
      'consultant:status-changed',
      'consultant-status-changed',
      'consultant:status-updated',
      'consultant-status-updated',
      'user:status-changed',
      'user-status-changed',
      'user:status-updated',
      'user-status-updated',
      'consultant:online-status',
      'consultant-online-status',
      'expert:status-changed',
      'expert-status-changed',
    ];
    for (final event in consultantStatusEvents) {
      _socket?.on(event, handleConsultantStatus);
    }
  }

  // ──────────────────── PUBLIC METHODS ────────────────────

  /// Connect or reconnect the socket
  void connect() {
    if (_socket == null) {
      _initSocket();
    } else if (!_socket!.connected) {
      AppLogger.debug('Manually reconnecting socket...');
      _socket?.connect();
    }
  }

  /// Disconnect and dispose socket
  void disconnect() {
    _socket?.disconnect();
    _socket?.dispose();
    _socket = null;
    isConnected.value = false;
  }

  /// Register user identity with the socket server
  void registerUser(String userId) {
    if (_socket?.connected ?? false) {
      emit('register', userId);
      AppLogger.debug('User registered with socket: $userId');
    } else {
      AppLogger.warning('Cannot register: Socket not connected');
    }
  }

  /// Join a consultation room for live signaling, billing & transcript
  void joinConsultation(String consultationId) {
    emit('join-consultation', consultationId);
    AppLogger.debug('Joined consultation room: $consultationId');
  }

  /// Join a chat/notification room
  void joinRoom(String roomId) {
    emit('join-room', roomId);
    AppLogger.debug('Joined room: $roomId');
  }

  /// Leave a room
  void leaveRoom(String roomId) {
    emit('leave-room', roomId);
    AppLogger.debug('Left room: $roomId');
  }

  /// Send a message to a room
  void sendMessage(String roomId, String senderId, String content) {
    if (!(_socket?.connected ?? false)) {
      AppLogger.warning('Cannot send message: Socket not connected');
      return;
    }

    final payload = {
      'roomId': roomId,
      'senderId': senderId,
      'content': content,
    };

    emit('send-message', payload);
  }

  /// Emit call cancellation signal to socket server
  void emitCancelCall(String sessionId) {
    final payload = {'sessionId': sessionId, 'id': sessionId};
    emit('cancel-call', payload);
    emit('call-cancelled', payload);
  }

  /// Emit call rejection signal to socket server
  void emitRejectCall(String sessionId) {
    final payload = {'sessionId': sessionId, 'id': sessionId};
    emit('reject-call', payload);
    emit('call-cancelled', payload);
  }

  /// Listen to a custom event
  void on(String event, Function(dynamic) callback) {
    AppLogger.debug('👂 [SOCKET LISTEN] Subscribed to event: $event');
    _socket?.on(event, callback);
  }

  /// Emit a custom event
  void emit(String event, dynamic data) {
    debugPrint(
      'ℹ️┌ ⚡ SOCKET EVENT EMITTED ══════════════════════════════════════\n'
      'ℹ️│ Event: $event\n'
      'ℹ️│ Data: $data\n'
      'ℹ️└ ⚡ SOCKET EVENT EMITTED ══════════════════════════════════════',
    );
    _socket?.emit(event, data);
  }
}
