import 'package:fixpair/config/constants/image_paths.dart';
import 'package:fixpair/config/constants/storage_constants.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/core/services/auth_service.dart';
import 'package:fixpair/core/services/push_notification_service.dart';
import 'package:fixpair/core/services/storage_service.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';

/// ===================== SPLASH CONTROLLER =====================
/// Entry-point controller that orchestrates cold-start app navigation,
/// onboarding verification, and CallKit terminated call acceptance.
class SplashController extends GetxController {
  final AuthService _authService = Get.find();
  final Color bgColor = const Color(0xFF090E1A);
  final String image = ImagePaths.appLogoWithoutBg;

  @override
  void onInit() {
    super.onInit();
    navigate();
  }

  Future<void> navigate() async {
    // ── 1. Check if app was launched via CallKit (accepted call in terminated state) ──
    try {
      final activeCalls = await FlutterCallkitIncoming.activeCalls();
      if (activeCalls.isNotEmpty) {
        final call = activeCalls.first;
        // Only join if the user explicitly answered/accepted the call from lock screen
        if (call.isAccepted == true) {
          final extra = call.extra;
          if (extra != null) {
            final sessionId = IncomingCallPayload.resolveSessionId(
              (extra['sessionId'] ?? call.id ?? '').toString(),
              extra,
            );
            final token = (extra['token'] ?? '').toString();
            final channelName = (extra['channelName'] ?? '').toString();
            final bookingId = (extra['bookingId'] ?? '').toString();
            final callerName = (extra['callerName'] ?? 'Consultant').toString();
            final callerAvatar = (extra['callerAvatar'] ?? '').toString();

            if (sessionId.isNotEmpty) {
              final booking = BookingModel(
                id: bookingId,
                consultant: UserData(
                  name: callerName,
                  avatar: callerAvatar,
                ),
              );
              final bool joined = await _authService.joinVideoCall(
                booking,
                sessionId,
                token,
                channelName,
              );
              if (joined) return;
            }
          }
        }
      }
    } catch (_) {
      // Proceed to normal navigation on any error
    }

    // Clean up any old / stale active calls from native memory
    try {
      await FlutterCallkitIncoming.endAllCalls();
    } catch (_) {}

    // ── 2. Standard splash transition delay ──
    await Future.delayed(const Duration(seconds: 2));

    // ── 3. Onboarding & Authentication routing ──
    await _proceedNormalRouting();
  }

  Future<void> _proceedNormalRouting() async {
    if (Get.currentRoute != AppRoutes.SPLASH) return;
    final bool hasSeenOnboarding =
        await StorageService.getBool(StorageConstants.onboardingSeen) ?? false;
    if (!hasSeenOnboarding) {
      Get.offAllNamed(AppRoutes.ONBOARDING);
    } else {
      if (_authService.isLoggedIn.value) {
        Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
      } else {
        Get.offAllNamed(AppRoutes.LOGIN);
      }
    }
  }
}
