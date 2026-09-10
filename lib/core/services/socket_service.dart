import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:fixpair/config/constants/api_constants.dart';
import 'package:fixpair/config/constants/storage_constants.dart';
import 'package:fixpair/core/services/storage_service.dart';
import 'package:fixpair/core/utils/logger.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:fixpair/modules/video_call/controllers/video_call_controller.dart';
// ignore: library_prefixes
import 'package:socket_io_client/socket_io_client.dart' as IO;

/// ===================== SOCKET SERVICE =====================
/// Manages real-time Socket.IO connection lifecycle.
/// Handles: connection, registration, rooms, messaging, and reconnection.
/// Requires: socket_io_client
class SocketService extends GetxService {
  IO.Socket? _socket;

  /// Expose socket for direct event listening in controllers
  IO.Socket? get socket => _socket;

  /// Observable connection state
  final isConnected = false.obs;

  /// Callback for incoming notifications
  void Function(dynamic data)? onNotificationReceived;

  /// Callback for incoming messages
  void Function(dynamic data)? onMessageReceived;

  /// Callback for consultant online/offline status changes
  void Function(String consultantId, bool isOnline)? onConsultantStatusChanged;

  /// Observable for consultant status changes (Rx stream for controllers)
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

    // Extract base URL (remove /api/v1 suffix)
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

    // Global listener for ALL incoming socket events
    _socket?.onAny((event, data) {
      debugPrint(
        'ℹ️┌ 📡 SOCKET EVENT RECEIVED ══════════════════════════════════════\n'
        'ℹ️│ Event: $event\n'
        'ℹ️│ Data: $data\n'
        'ℹ️└ 📡 SOCKET EVENT RECEIVED ══════════════════════════════════════',
      );
    });

    // Call cancellation & ending socket handlers
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

    // Call cancellation & ending socket handlers
    _socket?.on('call-ended', handleCallCancel);
    _socket?.on('call:ended', handleCallCancel);
    _socket?.on('call-cancelled', handleCallCancel);
    _socket?.on('call:cancelled', handleCallCancel);
    _socket?.on('cancel-call', handleCallCancel);
    _socket?.on('cancel:call', handleCallCancel);
    _socket?.on('reject-call', handleCallCancel);
    _socket?.on('reject:call', handleCallCancel);
    _socket?.on('call-rejected', handleCallCancel);
    _socket?.on('call:rejected', handleCallCancel);
    _socket?.on('end-call', handleCallCancel);
    _socket?.on('end:call', handleCallCancel);
    _socket?.on('session-ended', handleCallCancel);
    _socket?.on('session:ended', handleCallCancel);
    _socket?.on('consultation-auto-ended', handleCallCancel);
    _socket?.on('consultation:auto-ended', handleCallCancel);

    // Consultant Online/Offline Status change handlers
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

    _socket?.on('consultant:status-changed', handleConsultantStatus);
    _socket?.on('consultant-status-changed', handleConsultantStatus);
    _socket?.on('consultant:status-updated', handleConsultantStatus);
    _socket?.on('consultant-status-updated', handleConsultantStatus);
    _socket?.on('user:status-changed', handleConsultantStatus);
    _socket?.on('user-status-changed', handleConsultantStatus);
    _socket?.on('user:status-updated', handleConsultantStatus);
    _socket?.on('user-status-updated', handleConsultantStatus);
    _socket?.on('consultant:online-status', handleConsultantStatus);
    _socket?.on('consultant-online-status', handleConsultantStatus);
    _socket?.on('expert:status-changed', handleConsultantStatus);
    _socket?.on('expert-status-changed', handleConsultantStatus);
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

  /// Disconnect the socket
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
      'ℹ️└ ⚡ SOCKET EVENT EMITTED ══════════════════════════════════════'
      '\n',
      
      
    );
    _socket?.emit(event, data);
  }
}
