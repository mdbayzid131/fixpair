import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/constants/storage_constants.dart';
import '../../../config/routes/app_pages.dart';
import '../../../core/services/storage_service.dart';

class OnboardingController extends GetxController {
  final pageController = PageController();
  final currentPage = 0.obs;

  bool get isLastPage => currentPage.value == 4; // 5 pages total (0 to 4)
  bool get fromProfile => Get.arguments != null && Get.arguments['fromProfile'] == true;

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (isLastPage) {
      completeOnboarding();
    } else {
      pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void skipOnboarding() {
    completeOnboarding();
  }

  Future<void> completeOnboarding() async {
    if (fromProfile) {
      Get.back();
    } else {
      await StorageService.setBool(StorageConstants.onboardingSeen, true);
      Get.offAllNamed(AppRoutes.LOGIN);
    }
  }
}
