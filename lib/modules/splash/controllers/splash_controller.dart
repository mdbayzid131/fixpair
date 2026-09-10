import 'package:fixpair/config/constants/image_paths.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:fixpair/data/models/user_model.dart';

import '../../../core/services/auth_service.dart';
import '../../../core/services/storage_service.dart';
import '../../../config/constants/storage_constants.dart';

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
    // Check if app was launched via CallKit (accepted call in terminated state)
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
    } catch (e) {
      // Proceed to normal navigation on error
    }

    // Basic delay to ensure we don't skip too fast (3 seconds)
    await Future.delayed(const Duration(seconds: 3));

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
