import 'package:fixpair/config/constants/image_paths.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../core/services/auth_service.dart';

class SplashController extends GetxController {
  final AuthService _authService = Get.find();
  final Color bgColor = const Color(0xFF81A5DC);
  final String image = ImagePaths.appLogo;

  @override
  void onInit() {
    super.onInit();
    navigate();
  }

  Future<void> navigate() async {
    // Basic delay to ensure we don't skip too fast (3 seconds)
    await Future.delayed(const Duration(seconds: 3));

    if (_authService.isLoggedIn.value) {
      Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR);
    } else {
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
