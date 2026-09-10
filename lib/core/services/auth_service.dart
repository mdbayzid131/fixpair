import 'dart:io';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/modules/video_call/controllers/video_call_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:fixpair/config/constants/storage_constants.dart';
import 'package:fixpair/core/services/api_client.dart';
import 'package:fixpair/core/services/storage_service.dart';
import 'package:fixpair/core/services/push_notification_service.dart';
import 'package:fixpair/core/services/socket_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:fixpair/core/utils/logger.dart';
import 'package:fixpair/core/utils/helpers.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/auth_repository.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import 'package:fixpair/config/constants/api_constants.dart';

class AuthService extends GetxService {
  late AuthRepo _authRepo;
  late UserRepository _userRepository;

  // Reactive state
  final isLoggedIn = false.obs;
  final user = Rxn<UserData>();

  @override
  void onInit() {
    super.onInit();
    // Explicitly find ApiClient to ensure it's initialized before AuthRepo
    _authRepo = AuthRepo(apiClient: Get.put(ApiClient()));
    _userRepository = UserRepository();

    // Check initial login state
    _checkLoginStatus();

    // Initialize CallKit global event listener
    _initCallKit();
  }

  Future<void> _checkLoginStatus() async {
    final token = await StorageService.getString(StorageConstants.bearerToken);
    isLoggedIn.value = token.isNotEmpty;
    if (isLoggedIn.value) {
      await fetchProfile();
    }
  }

  Future<void> fetchProfile() async {
    try {
      final response = await _userRepository.getProfile();
      if (response.statusCode == 200) {
        final profileResponse = UserProfileResponseModel.fromJson(
          response.data,
        );
        user.value = profileResponse.data;
        // Trigger push notification configuration
        setupPushNotifications();
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<AuthService> init() async {
    return this;
  }

  /// ===================== SIGNUP =====================
  Future<Response> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authRepo.signup(
        name: name,
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== LOGIN =====================
  Future<Response> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authRepo.login(email: email, password: password);
      await handleAuthResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== GOOGLE LOGIN =====================
  Future<Response> loginWithGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn(
        clientId: defaultTargetPlatform == TargetPlatform.iOS
            ? '827439833710-01cu8oed84nphjju12tcbgq0l7ml4frl.apps.googleusercontent.com'
            : null,
      );
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      if (googleUser == null) {
        return Response(
          requestOptions: RequestOptions(path: ApiConstants.socialLogin),
          statusCode: 400,
          data: {'message': 'Google Sign-In was cancelled.'},
        );
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final OAuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithCredential(credential);

      final String? idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to retrieve Firebase ID Token.');
      }

      final Response response = await _authRepo.socialLogin(
        idToken: idToken,
        provider: 'google',
      );

      await handleAuthResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== APPLE LOGIN =====================
  Future<Response> loginWithApple() async {
    try {
      // Native Apple Sign-In on iOS, Firebase Web Auth flow on Android
      final UserCredential userCredential = await FirebaseAuth.instance
          .signInWithProvider(AppleAuthProvider());

      final String? idToken = await userCredential.user?.getIdToken();
      if (idToken == null) {
        throw Exception('Failed to retrieve Firebase ID Token.');
      }

      final Response response = await _authRepo.socialLogin(
        idToken: idToken,
        provider: 'apple',
      );

      await handleAuthResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== LOGOUT =====================
  Future<void> logout() async {
    try {
      // 1. Get current device FCM token
      String deviceToken =
          await StorageService.getString(StorageConstants.deviceToken);
      if (deviceToken.isEmpty) {
        final fcmToken = await FirebaseNotificationService.getToken();
        if (fcmToken != null && fcmToken.isNotEmpty) {
          deviceToken = fcmToken;
        }
      }

      AppLogger.info(
        '🚪 [LOGOUT] Calling logout API with deviceToken: $deviceToken',
      );
      // 2. Call backend logout with deviceToken in body: { "deviceToken": "..." }
      await _authRepo.logout(deviceToken: deviceToken);
    } catch (e) {
      AppLogger.warning('Error calling backend logout: $e');
    } finally {
      if (Get.isRegistered<SocketService>()) {
        Get.find<SocketService>().disconnect();
      }
      await _clearLocalAuth();
    }
  }

  /// ===================== FORGOT PASSWORD =====================
  Future<Response> forgotPassword(String email) async {
    try {
      final response = await _authRepo.forgotPassword(email: email);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== OTP VERIFY =====================
  Future<Response> verifyOtp({
    required String email,
    required int otp,
    bool isForgotPassword = false,
  }) async {
    try {
      final response = await _authRepo.otpVerify(email: email, otp: otp);
      // If OTP verification logs the user in directly (but not for forgot password):
      if (!isForgotPassword) {
        await handleAuthResponse(response);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== RESEND OTP =====================
  Future<void> resendOtp(String email) async {
    try {
      await _authRepo.resentOtp(email: email);
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== RESET PASSWORD =====================
  Future<Response> resetPassword({
    required String resetToken,
    required String password,
  }) async {
    try {
      final response = await _authRepo.resetPassword(
        password: password,
        resetToken: resetToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== CHANGE PASSWORD =====================
  Future<Response> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      Response response = await _authRepo.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== HELPER METHODS =====================

  /// Handles successful auth response (Login/Signup)
  Future<void> handleAuthResponse(Response response) async {
    final data = response.data;
    final authData = data['data'] ?? data;

    final String? accessToken = authData['accessToken'] ?? authData['token'];
    final String? refreshToken = authData['refreshToken'];

    if (accessToken != null) {
      await StorageService.setString(StorageConstants.bearerToken, accessToken);
      isLoggedIn.value = true;
      await fetchProfile(); // Fetch profile after login
    }

    if (refreshToken != null) {
      await StorageService.setString(
        StorageConstants.refreshToken,
        refreshToken,
      );
    }
  }

  /// Clears all local auth data
  Future<void> _clearLocalAuth() async {
    await StorageService.remove(StorageConstants.bearerToken);
    await StorageService.remove(StorageConstants.refreshToken);
    await StorageService.remove(StorageConstants.userData);
    await StorageService.remove(StorageConstants.deviceToken);

    isLoggedIn.value = false;
    user.value = null;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => isLoggedIn.value;

  /// ===================== PUSH NOTIFICATIONS =====================

  Future<void> setupPushNotifications() async {
    try {
      // 1. Initialize FCM and obtain device token
      final String? token = await FirebaseNotificationService.initialize();
      print('🔥 [AUTH SERVICE] FCM TOKEN LOADED: $token');
      if (token != null && token.isNotEmpty) {
        await StorageService.setString(StorageConstants.deviceToken, token);
        // 2. Upload the token to the backend
        print('🔥 [AUTH SERVICE] UPLOADING FCM TOKEN TO BACKEND...');
        await _userRepository.saveDeviceToken(token);
        print('🔥 [AUTH SERVICE] FCM TOKEN UPLOAD COMPLETED SUCCESSFULLY!');
      }

      // 3. Listen for token refreshes dynamically
      FirebaseNotificationService.onTokenRefresh = (newToken) async {
        if (newToken.isNotEmpty) {
          await StorageService.setString(
            StorageConstants.deviceToken,
            newToken,
          );
        }
        if (isLoggedIn.value) {
          await _userRepository.saveDeviceToken(newToken);
        }
      };

      // 4. Register foreground and background/tap notification listeners
      FirebaseNotificationService.onForegroundMessage = (message) {
        _handleIncomingCall(message, isFromTap: false);
      };

      FirebaseNotificationService.onNotificationTap = (message) {
        _handleIncomingCall(message, isFromTap: true);
      };

      // 5. Request Android permissions for CallKit notifications & full-screen intents
      if (Platform.isAndroid) {
        try {
          await FlutterCallkitIncoming.requestNotificationPermission({
            "title": "Notification permission",
            "rationaleMessagePermission":
                "Notification permission is required to show incoming calls.",
            "postNotificationMessageRequired":
                "Please allow notification permission from settings.",
          });

          final bool canFullScreen =
              await FlutterCallkitIncoming.canUseFullScreenIntent();
          if (!canFullScreen) {
            await FlutterCallkitIncoming.requestFullIntentPermission();
          }
        } catch (pe) {
          AppLogger.debug('Error requesting CallKit permissions: $pe');
        }
      }
    } catch (e) {
      // Silently fail
    }
  }

  void _handleIncomingCall(RemoteMessage message, {bool isFromTap = false}) async {
    final payload = IncomingCallPayload.fromMessage(message);

    AppLogger.info('📞 [FCM CALL EVENT] Type: ${payload.type} | Status: ${payload.status}');

    // ── 1. Call cancellation / rejection from remote peer ──
    if (payload.isCancelOrReject) {
      AppLogger.info('🚫 [FCM CALL REJECTED/CANCELLED] Closing Call & CallKit UI');
      try {
        while (Get.isDialogOpen == true) {
          Get.back();
        }
        await FlutterCallkitIncoming.endAllCalls();
        if (Get.isRegistered<VideoCallController>()) {
          final controller = Get.find<VideoCallController>();
          if (!controller.hasConsultantJoined) {
            final String? reason = (message.data['body'] ?? message.notification?.body)?.toString();
            controller.handleCallRejected(
              reason: reason ?? 'Call rejected by consultant'.tr,
            );
          } else {
            await controller.endCall();
          }
        }
        if (!Get.isRegistered<VideoCallController>()) {
          Get.until((route) => Get.currentRoute != AppRoutes.VIDEO_CALL);
          if (Get.currentRoute == AppRoutes.VIDEO_CALL) {
            Get.back();
          }
        }
      } catch (e) {
        AppLogger.warning('Error handling CALL_REJECTED FCM notification: $e');
      }
      return;
    }

    // ── 2. Validate incoming call data ──
    if (!payload.isIncomingCall || payload.sessionId.isEmpty || payload.token.isEmpty) {
      return;
    }

    final bookingRx = BookingModel(
      id: payload.bookingId,
      consultant: UserData(name: payload.callerName, avatar: payload.callerAvatar),
    ).obs;

    if (payload.bookingId.isNotEmpty) {
      _userRepository.getBookingById(payload.bookingId).then((realBooking) {
        if (realBooking != null) {
          AppLogger.info('✅ [FCM BOOKING RESOLVED] Consultant: ${realBooking.consultant?.name} | ID: ${realBooking.id}');
          bookingRx.value = realBooking;
        }
      }).catchError((err) {
        AppLogger.debug('Error fetching booking details for FCM call: $err');
      });
    }

    if (isFromTap) {
      // Direct enter if tapped from OS system notification tray
      joinVideoCall(bookingRx.value, payload.sessionId, payload.token, payload.channelName);
    } else {
      // Unified Full-Screen CallKit Incoming UI with Accept & Decline buttons
      await FlutterCallkitIncoming.showCallkitIncoming(payload.toCallKitParams());
    }
  }

  void showPaymentRequiredDialog() {
    Get.dialog(
      barrierDismissible: true,
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: const Color(
              0xFF0F172A,
            ).withOpacity(0.95), // Premium Slate 900
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: const Color(
                0xFFEF4444,
              ).withOpacity(0.4), // Red border indicator
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFEF4444).withOpacity(0.1),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Warning Icon
              Container(
                width: 70,
                height: 70,
                decoration: BoxDecoration(
                  color: const Color(0xFFEF4444).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.account_balance_wallet_outlined,
                  color: Color(0xFFEF4444),
                  size: 36,
                ),
              ),
              const SizedBox(height: 24),
              // Title
              Text(
                'Insufficient Balance'.tr,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Description
              Text(
                'You do not have enough balance for this consultation. Please top up your wallet to join the call.'.tr,
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF94A3B8), // Slate 400
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              // Actions
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Cancel'.tr,
                        style: const TextStyle(
                          color: Color(0xFF94A3B8),
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back(); // Close Dialog
                        Get.toNamed(AppRoutes.PAYMENT_METHODS);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E), // Green 500
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Top Up'.tr,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _isJoiningCall = false;
  DateTime? _lastCallAcceptHandledTime;
  String? _lastAcceptedCallId;

  /// Joins video session with backend handshake, token resolution, and proper navigation
  Future<bool> joinVideoCall(
    BookingModel booking,
    String sessionId,
    String token,
    String channelName,
  ) async {
    final realSessionId = IncomingCallPayload.resolveSessionId(sessionId);
    if (realSessionId.isEmpty) return false;

    if (Get.currentRoute == AppRoutes.VIDEO_CALL) {
      AppLogger.info('⚠️ Already on video call screen, skipping duplicate joinVideoCall.');
      return true;
    }
    if (_isJoiningCall) {
      AppLogger.info('⚠️ Already joining a video call session, skipping duplicate call.');
      return false;
    }
    _isJoiningCall = true;

    // Show a loading indicator dialog if not already visible
    if (Get.isDialogOpen != true) {
      Get.dialog(
        const Center(child: CircularProgressIndicator(color: Color(0xFF22C55E))),
        barrierDismissible: false,
      );
    }

    try {
      final response = await _userRepository.joinVideoSession(realSessionId);

      // Close all open loading dialogs
      while (Get.isDialogOpen == true) {
        Get.back();
      }

      if (response.statusCode == 200) {
        final joinData = response.data['data'];
        final freshToken = (joinData is Map ? joinData['token'] : null) ?? token;
        final freshChannel = (joinData is Map ? joinData['channelName'] : null) ?? channelName;

        if (Get.currentRoute == AppRoutes.SPLASH) {
          Get.offAllNamed(
            AppRoutes.VIDEO_CALL,
            arguments: {
              'booking': booking,
              'sessionId': realSessionId,
              'token': freshToken,
              'channelName': freshChannel,
            },
          );
        } else {
          Get.toNamed(
            AppRoutes.VIDEO_CALL,
            arguments: {
              'booking': booking,
              'sessionId': realSessionId,
              'token': freshToken,
              'channelName': freshChannel,
            },
          );
        }
        return true;
      } else if (response.statusCode == 402) {
        try {
          await FlutterCallkitIncoming.endAllCalls();
        } catch (_) {}
        showPaymentRequiredDialog();
        return false;
      } else {
        try {
          await FlutterCallkitIncoming.endAllCalls();
        } catch (_) {}
        Helpers.showError(
          response.statusMessage ?? 'Failed to join video session'.tr,
        );
        return false;
      }
    } catch (e) {
      while (Get.isDialogOpen == true) {
        Get.back();
      }
      AppLogger.warning('Error joining video session: $e');
      try {
        await FlutterCallkitIncoming.endAllCalls();
      } catch (_) {}
      return false;
    } finally {
      Future.delayed(const Duration(seconds: 3), () {
        _isJoiningCall = false;
      });
    }
  }

  /// ===================== CALLKIT LIFECYCLE LISTENER =====================
  /// Listens to native CallKit actions (Accept, Decline, Timeout, Ended)
  /// and synchronizes state with Agora Video Call & Backend APIs across all app states.
  void _initCallKit() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event == null) return;
      AppLogger.info('📞 [CallKit Event] ${event.eventName}');

      switch (event) {
        // ── 1. USER ACCEPTS THE CALL ──
        case CallEventActionCallAccept(:final id):
          final now = DateTime.now();
          if (_lastCallAcceptHandledTime != null &&
              (_lastAcceptedCallId == id || now.difference(_lastCallAcceptHandledTime!) < const Duration(seconds: 4))) {
            AppLogger.info('⚠️ Skipping duplicate CallKit accept event within cooldown');
            break;
          }
          if (Get.currentRoute == AppRoutes.VIDEO_CALL) {
            AppLogger.info('⚠️ Already on video call screen, skipping CallKit accept event');
            break;
          }
          _lastCallAcceptHandledTime = now;
          _lastAcceptedCallId = id;

          if (id.isNotEmpty) {
            try {
              await FlutterCallkitIncoming.setCallConnected(id);
            } catch (e) {
              AppLogger.debug('Error setting CallKit connected: $e');
            }
          }

          Map<String, dynamic>? extra;
          final activeCalls = await FlutterCallkitIncoming.activeCalls();
          if (activeCalls.isNotEmpty) {
            CallKitParams? targetCall;
            for (var c in activeCalls) {
              if (c.id == id) {
                targetCall = c;
                break;
              }
            }
            targetCall ??= activeCalls.first;
            final rawExtra = targetCall.extra;
            if (rawExtra != null) {
              extra = Map<String, dynamic>.from(rawExtra);
            }
          }

          if (extra != null) {
            final booking = BookingModel(
              id: extra['bookingId'] ?? '',
              consultant: UserData(
                name: extra['callerName'] ?? 'Consultant',
                avatar: extra['callerAvatar'] ?? '',
              ),
            );
            await joinVideoCall(
              booking,
              extra['sessionId'] ?? id,
              extra['token'] ?? '',
              extra['channelName'] ?? '',
            );
          }
          break;

        // ── 2. USER DECLINES ──
        case CallEventActionCallDecline(:final id):
        // ── 3. CALL TIMEOUT ──
        case CallEventActionCallTimeout(:final id):
          while (Get.isDialogOpen == true) {
            Get.back();
          }

          if (Get.isRegistered<VideoCallController>()) {
            Get.find<VideoCallController>().endCall();
          } else {
            try {
              if (id.isNotEmpty) {
                final realSessionId = IncomingCallPayload.resolveSessionId(id);
                await _userRepository.actionVideoSession(realSessionId, 'REJECT');
                if (Get.isRegistered<SocketService>()) {
                  Get.find<SocketService>().emitRejectCall(realSessionId);
                }
              }
            } catch (e) {
              AppLogger.warning(
                'Error rejecting video session on CallKit event: $e',
              );
            }
          }

          try {
            await FlutterCallkitIncoming.endAllCalls();
          } catch (_) {}
          break;

        // ── 4. CALL ENDED ──
        case CallEventActionCallEnded():
          while (Get.isDialogOpen == true) {
            Get.back();
          }
          if (Get.isRegistered<VideoCallController>()) {
            Get.find<VideoCallController>().endCall();
          }
          try {
            await FlutterCallkitIncoming.endAllCalls();
          } catch (_) {}
          break;

        default:
          break;
      }
    }, onError: (err) {
      AppLogger.debug('CallKit event stream exception caught safely: $err');
    });
  }
}
