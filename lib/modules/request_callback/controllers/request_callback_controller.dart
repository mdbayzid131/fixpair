import 'package:fixpair/core/services/api_checker.dart';
import 'package:fixpair/core/utils/helpers.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RequestCallbackController extends GetxController {
  final UserRepository _userRepository = Get.find();
  final Rxn<UserData> expert = Rxn<UserData>();
  final isLoading = false.obs;

  final selectedTimeOption = 0.obs; // 0: ASAP, 1: Today, 2: Tomorrow

  final phoneController = TextEditingController(text: '+49 151 23456789');
  final reasonController = TextEditingController();

  final timeOptions = [
    {
      'title': 'As soon as possible',
      'subtitle': 'Usually within 2 hours',
      'value': 'asap',
    },
    {
      'title': 'Sometime Today',
      'subtitle': 'Before 18:00 CET',
      'value': 'today',
    },
    {
      'title': 'Tomorrow',
      'subtitle': 'Anytime during business hours',
      'value': 'tomorrow',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is UserData) {
      expert.value = Get.arguments as UserData;
    }
  }

  void selectOption(int index) {
    selectedTimeOption.value = index;
  }

  Future<void> submitCallback() async {
    if (expert.value == null) return;

    try {
      isLoading.value = true;
      final body = {
        "consultantId": expert.value!.id,
        "bookingType": "callback",
        "preferredWindow": timeOptions[selectedTimeOption.value]['value'],
        "notes": reasonController.text,
      };

      final response = await _userRepository.bookConsultation(body);
      ApiChecker.checkWriteApi(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Helpers.showBookingSuccess();
        Get.offAllNamed('/bottom-nav-bar', arguments: 2);
      }
    } catch (e) {
      Helpers.showDebugLog('Callback request error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    phoneController.dispose();
    reasonController.dispose();
    super.onClose();
  }
}
