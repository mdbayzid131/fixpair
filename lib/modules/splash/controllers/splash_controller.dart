import 'dart:convert';
import 'package:fixpair/config/constants/image_paths.dart';
import 'package:fixpair/config/constants/storage_constants.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/core/services/auth_service.dart';
import 'package:fixpair/core/services/push_notification_service.dart';
import 'package:fixpair/core/services/storage_service.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_callkit_incoming/entities/entities.dart';
import 'package:flutter_callkit_incoming/flutter_callkit_incoming.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:fixpair/core/utils/helpers.dart';

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
    Helpers.clearAppBadge();
    _requestInitialPermissions();
    navigate();
  }

  Future<void> _requestInitialPermissions() async {
    try {
      await [
        Permission.microphone,
        Permission.camera,
        Permission.notification,
      ].request();
    } catch (_) {}
  }

  Future<void> navigate() async {
    // ── 1. Check if app was launched via CallKit (accepted call in terminated state) ──
    // We only attempt this if the user is already logged in, otherwise the join API will fail.
    try {
      if (_authService.isLoggedIn.value) {
        final activeCalls = await FlutterCallkitIncoming.activeCalls();
        final isPendingAccept =
            await StorageService.getBool(StorageConstants.callAcceptedPending) ?? false;
        final acceptedCallId =
            await StorageService.getString(StorageConstants.callAcceptedId);

        CallKitParams? explicitlyAcceptedCall;
        for (final call in activeCalls) {
          if (call.isAccepted == true) {
            explicitlyAcceptedCall = call;
            break;
          }
        }

        final bool hasExplicitlyAccepted =
            (isPendingAccept && acceptedCallId.isNotEmpty) ||
            (explicitlyAcceptedCall != null);

        if (hasExplicitlyAccepted) {
          await StorageService.setBool(StorageConstants.callAcceptedPending, false);
          Map<String, dynamic>? extra;
          String? targetId = acceptedCallId.isNotEmpty ? acceptedCallId : explicitlyAcceptedCall?.id;

          if (explicitlyAcceptedCall?.extra != null && explicitlyAcceptedCall!.extra!.isNotEmpty) {
            extra = Map<String, dynamic>.from(explicitlyAcceptedCall.extra!);
          }

          if (extra == null || (extra['sessionId']?.toString().isEmpty ?? true)) {
            final storedCallStr =
                await StorageService.getString(StorageConstants.latestCallPayload, reload: true);
            if (storedCallStr.isNotEmpty) {
              try {
                final Map<String, dynamic> storedMap = jsonDecode(storedCallStr);
                final ts = storedMap['timestamp'] as int? ?? 0;
                if (DateTime.now().millisecondsSinceEpoch - ts < 180000) {
                  extra = storedMap;
                }
              } catch (_) {}
            }
          }

          final sessionId = (extra?['sessionId']?.toString().isNotEmpty ?? false)
              ? extra!['sessionId'].toString()
              : (targetId != null ? IncomingCallPayload.resolveSessionId(targetId) : '');
          final token = (extra?['token'] ?? '').toString();
          final channelName = (extra?['channelName'] ?? '').toString();
          final bookingId = (extra?['bookingId'] ?? '').toString();
          final callerName = (extra?['callerName'] ?? 'Consultant').toString();
          final callerAvatar = (extra?['callerAvatar'] ?? '').toString();

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
    } catch (_) {
      // Proceed to normal navigation on any error
    }

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
