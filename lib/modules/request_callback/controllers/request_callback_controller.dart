import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestCallbackController extends GetxController {
  final selectedTimeOption = 0.obs; // 0: ASAP, 1: Today, 2: Tomorrow
  
  final phoneController = TextEditingController(text: '+49 151 23456789');
  final reasonController = TextEditingController();

  final timeOptions = [
    {
      'title': 'As soon as possible',
      'subtitle': 'Usually within 2 hours',
    },
    {
      'title': 'Sometime Today',
      'subtitle': 'Before 18:00 CET',
    },
    {
      'title': 'Tomorrow',
      'subtitle': 'Anytime during business hours',
    },
  ];

  void selectOption(int index) {
    selectedTimeOption.value = index;
  }

  @override
  void onClose() {
    phoneController.dispose();
    reasonController.dispose();
    super.onClose();
  }
}
