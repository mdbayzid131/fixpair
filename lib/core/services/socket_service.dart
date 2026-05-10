import 'package:get/get.dart';
import 'package:fixpair/config/constants/api_constants.dart';
import 'package:fixpair/config/constants/storage_constants.dart';
import 'package:fixpair/core/services/storage_service.dart';
import 'package:fixpair/core/utils/logger.dart';
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
      _socket?.emit('register', userId);
      AppLogger.debug('User registered with socket: $userId');
    } else {
      AppLogger.warning('Cannot register: Socket not connected');
    }
  }

  /// Join a chat/notification room
  void joinRoom(String roomId) {
    _socket?.emit('join-room', roomId);
    AppLogger.debug('Joined room: $roomId');
  }

  /// Leave a room
  void leaveRoom(String roomId) {
    _socket?.emit('leave-room', roomId);
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

    _socket?.emit('send-message', payload);
    AppLogger.debug('Message sent: $payload');
  }

  /// Listen to a custom event
  void on(String event, Function(dynamic) callback) {
    _socket?.on(event, callback);
  }

  /// Emit a custom event
  void emit(String event, dynamic data) {
    _socket?.emit(event, data);
  }
}
