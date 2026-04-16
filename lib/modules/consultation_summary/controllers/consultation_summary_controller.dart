import 'package:get/get.dart';
import 'package:flutter/material.dart';

class ConsultationSummaryController extends GetxController {
  final rating = 0.obs;
  final reviewController = TextEditingController();
  
  // Data from previous session (mocked for now)
  final consultantName = 'Sarah Müller';
  final date = '02.04.2026';
  final duration = '2 minutes';
  final rate = '4.00€ / min';
  final vat = '20.00€';
  final totalCharged = '28.00€';

  void setRating(int value) => rating.value = value;

  void submitReview() {
    Get.snackbar(
      'Success',
      'Thank you for your feedback!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
