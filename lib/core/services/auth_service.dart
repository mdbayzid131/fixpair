import 'dart:io';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/modules/video_call/controllers/video_call_controller.dart';
import 'package:flutter/material.dart';
import 'package:fixpair/config/constants/storage_constants.dart';
import 'package:fixpair/core/services/api_client.dart';
import 'package:fixpair/core/services/storage_service.dart';
import 'package:fixpair/core/services/push_notification_service.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_calendar_carousel/classes/event.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:fixpair/core/utils/logger.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/auth_repository.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;

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
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        throw Exception('Google Sign-In was cancelled.');
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
      await _authRepo.logout();
      await _clearLocalAuth();
    } catch (e) {
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
      if (token != null) {
        // 2. Upload the token to the backend
        print('🔥 [AUTH SERVICE] UPLOADING FCM TOKEN TO BACKEND...');
        await _userRepository.saveDeviceToken(token);
        print('🔥 [AUTH SERVICE] FCM TOKEN UPLOAD COMPLETED SUCCESSFULLY!');
      }

      // 3. Listen for token refreshes dynamically
      FirebaseNotificationService.onTokenRefresh = (newToken) async {
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

  void _handleIncomingCall(RemoteMessage message, {bool isFromTap = false}) {
    if (message.data['type'] != 'INCOMING_CALL') return;

    final sessionId = message.data['sessionId'];
    final token = message.data['token'];
    final channelName = message.data['channelName'] ?? sessionId;
    final callerName = message.data['callerName'] ?? 'Consultant';
    final callerAvatar = message.data['callerAvatar'] ?? '';
    final bookingId = message.data['bookingId'] ?? '';

    if (sessionId == null || token == null) return;

    final booking = BookingModel(
      id: bookingId,
      consultant: UserData(name: callerName, avatar: callerAvatar),
    );

    if (isFromTap) {
      // Tapped from background -> go directly to video call screen
      _joinVideoCall(booking, sessionId, token, channelName);
    } else {
      // Received in foreground -> show premium interactive ringing dialog
      _showIncomingCallDialog(booking, sessionId, token, channelName);
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
              const Text(
                'Insufficient Balance',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // Description
              const Text(
                'You do not have enough balance for this consultation. Please top up your wallet to join the call.',
                style: TextStyle(
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
                      child: const Text(
                        'Cancel',
                        style: TextStyle(
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
                      child: const Text(
                        'Top Up',
                        style: TextStyle(
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

  Future<void> _joinVideoCall(
    BookingModel booking,
    String sessionId,
    String token,
    String channelName,
  ) async {
    // Show a loading indicator dialog
    Get.dialog(
      const Center(child: CircularProgressIndicator(color: Color(0xFF22C55E))),
      barrierDismissible: false,
    );

    try {
      final response = await _userRepository.joinVideoSession(sessionId);

      // Close the loading dialog
      if (Get.isDialogOpen == true) {
        Get.back();
      }

      if (response.statusCode == 200) {
        final joinData = response.data['data'];
        final freshToken = joinData['token'] ?? token;
        final freshChannel = joinData['channelName'] ?? channelName;

        Get.toNamed(
          AppRoutes.VIDEO_CALL,
          arguments: {
            'booking': booking,
            'sessionId': sessionId,
            'token': freshToken,
            'channelName': freshChannel,
          },
        );
      } else if (response.statusCode == 402) {
        showPaymentRequiredDialog();
      } else {
        Get.snackbar(
          'Error',
          response.statusMessage ?? 'Failed to join video session',
          backgroundColor: const Color(0xFF0F172A).withOpacity(0.9),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      if (Get.isDialogOpen == true) {
        Get.back();
      }
      AppLogger.warning('Error joining video session: $e');
      // Fallback: join anyway using notification token
      Get.toNamed(
        AppRoutes.VIDEO_CALL,
        arguments: {
          'booking': booking,
          'sessionId': sessionId,
          'token': token,
          'channelName': channelName,
        },
      );
    }
  }

  void _showIncomingCallDialog(
    BookingModel booking,
    String sessionId,
    String token,
    String channelName,
  ) {
    Get.dialog(
      barrierDismissible: false,
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
              color: const Color(0xFF334155).withOpacity(0.5), // Slate 700
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF22C55E).withOpacity(0.15), // Green glow
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Glowing Ring Indicator with Caller Avatar
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFF22C55E).withOpacity(0.8),
                        width: 2,
                      ),
                    ),
                  ),
                  CircleAvatar(
                    radius: 48,
                    backgroundColor: const Color(0xFF1E293B),
                    backgroundImage:
                        booking.consultant?.avatar != null &&
                            booking.consultant!.avatar!.isNotEmpty
                        ? NetworkImage(booking.consultant!.avatar!)
                        : null,
                    child:
                        booking.consultant?.avatar == null ||
                            booking.consultant!.avatar!.isEmpty
                        ? Text(
                            booking.consultant?.name
                                    ?.substring(0, 1)
                                    .toUpperCase() ??
                                'C',
                            style: const TextStyle(
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF22C55E),
                            ),
                          )
                        : null,
                  ),
                ],
              ),
              const SizedBox(height: 24),
              // Caller Name
              Text(
                booking.consultant?.name ?? 'Consultant',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              // Call Subtitle
              const Text(
                'Incoming Video Consultation...',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF94A3B8), // Slate 400
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 36),
              // Action Buttons
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Decline Button
                  GestureDetector(
                    onTap: () async {
                      Get.back(); // Close Dialog
                      try {
                        await _userRepository.actionVideoSession(
                          sessionId,
                          'REJECT',
                        );
                      } catch (e) {
                        AppLogger.warning(
                          'Error notifying backend of rejected call: $e',
                        );
                      }
                      try {
                        await FlutterCallkitIncoming.endCall(sessionId);
                        await FlutterCallkitIncoming.endAllCalls();
                      } catch (e) {
                        AppLogger.debug(
                          'Error ending call on foreground decline: $e',
                        );
                      }
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFFEF4444), // Red 500
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFFEF4444),
                                blurRadius: 15,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.call_end,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Decline',
                          style: TextStyle(
                            color: Color(0xFFEF4444),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Accept Button
                  GestureDetector(
                    onTap: () async {
                      Get.back(); // Close Dialog

                      // Register call with CallKit as accepted to show ongoing notification
                      try {
                        final CallKitParams callKitParams = CallKitParams(
                          id: sessionId,
                          nameCaller: booking.consultant?.name ?? 'Consultant',
                          appName: 'Fixpair',
                          avatar: booking.consultant?.avatar ?? '',
                          handle: 'Incoming Video Consultation',
                          type: 1, // 0: audio, 1: video
                          duration: 30000,
                          android: const AndroidParams(
                            isCustomNotification: true,
                            backgroundColor: '#0F172A',
                            incomingCallNotificationChannelName:
                                "Incoming Call",
                            isShowLogo: true,
                            ringtonePath: 'system_ringtone_default',
                            textAccept: 'Accept',
                            textDecline: 'Decline',
                          ),
                          ios: const IOSParams(
                            handleType: 'generic',
                            supportsVideo: true,
                          ),
                        );
                        await FlutterCallkitIncoming.showCallkitIncoming(
                          callKitParams,
                        );
                        await Future.delayed(const Duration(milliseconds: 300));
                        await FlutterCallkitIncoming.setCallConnected(
                          sessionId,
                        );
                      } catch (e) {
                        AppLogger.debug(
                          'Error starting CallKit from foreground accept: $e',
                        );
                      }

                      _joinVideoCall(booking, sessionId, token, channelName);
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            color: Color(0xFF22C55E), // Green 500
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Color(0xFF22C55E),
                                blurRadius: 15,
                                offset: Offset(0, 4),
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.videocam,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Accept',
                          style: TextStyle(
                            color: Color(0xFF22C55E),
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
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

  void _initCallKit() {
    FlutterCallkitIncoming.onEvent.listen((CallEvent? event) async {
      if (event == null) return;

      switch (event) {
        case CallEventActionCallAccept():
          // Mark call as connected in CallKit (updates notification to ongoing)
          try {
            await FlutterCallkitIncoming.setCallConnected(event.id);
          } catch (e) {
            AppLogger.debug('Error setting CallKit connected: $e');
          }
          final activeCalls = await FlutterCallkitIncoming.activeCalls();
          if (activeCalls.isNotEmpty) {
            CallKitParams? targetCall;
            for (var c in activeCalls) {
              if (c.id == event.id) {
                targetCall = c;
                break;
              }
            }
            targetCall ??= activeCalls.first;
            final extra = targetCall.extra;
            if (extra != null) {
              final booking = BookingModel(
                id: extra['bookingId'] ?? '',
                consultant: UserData(
                  name: extra['callerName'] ?? 'Consultant',
                  avatar: extra['callerAvatar'] ?? '',
                ),
              );
              _joinVideoCall(
                booking,
                extra['sessionId'] ?? '',
                extra['token'] ?? '',
                extra['channelName'] ?? '',
              );
            }
          }
          break;
        case CallEventActionCallDecline():
        case CallEventActionCallTimeout():
          final callId = event is CallEventActionCallDecline
              ? event.id
              : (event as CallEventActionCallTimeout).id;
          if (Get.isDialogOpen == true) {
            Get.back();
          }
          if (Get.isRegistered<VideoCallController>()) {
            Get.find<VideoCallController>().endCall();
          } else {
            try {
              await _userRepository.actionVideoSession(callId, 'REJECT');
            } catch (e) {
              AppLogger.warning(
                'Error rejecting video session on CallKit event: $e',
              );
            }
          }
          break;
        case CallEventActionCallEnded():
          if (Get.isDialogOpen == true) {
            Get.back();
          }
          if (Get.isRegistered<VideoCallController>()) {
            Get.find<VideoCallController>().endCall();
          }
          break;
        default:
          break;
      }
    });
  }
}
