import 'package:fixpair/config/constants/image_paths.dart';
import 'package:fixpair/config/constants/storage_constants.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/core/services/auth_service.dart';
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
        final extra = call.extra;
        if (extra != null) {
          final sessionId = (extra['sessionId'] ?? call.id ?? '').toString();
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
            // Properly join the video session with backend handshake & session activation
            await _authService.joinVideoCall(
              booking,
              sessionId,
              token,
              channelName,
            );
            return;
          }
        }
      }
    } catch (_) {
      // Proceed to normal navigation on any error
    }

    // ── 2. Standard splash transition delay ──
    await Future.delayed(const Duration(seconds: 3));

    // ── 3. Onboarding & Authentication routing ──
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
