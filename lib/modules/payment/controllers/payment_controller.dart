import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/utils/helpers.dart';

class PaymentController extends GetxController {
  final UserRepository _userRepository = Get.find();

  final isLoading = false.obs;
  final paymentMethods = <dynamic>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchPaymentMethods();
  }

  Future<void> fetchPaymentMethods() async {
    try {
      isLoading.value = true;
      final response = await _userRepository.getPaymentMethods();
      if (response.statusCode == 200) {
        paymentMethods.value = response.data['data'] ?? [];
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching payment methods: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> addPaymentMethod() async {
    try {
      isLoading.value = true;

      // 1. Create Stripe Customer if needed (optional check depending on backend)
      await _userRepository.createStripeCustomer();

      Get.snackbar(
        'Processing',
        'Adding your card...',
        showProgressIndicator: true,
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Helpers.showDebugLog('Error adding payment method: $e');
      Get.snackbar('Error', 'Failed to add card: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> handleAttachMethod(String paymentMethodId) async {
    try {
      isLoading.value = true;
      final response = await _userRepository.attachPaymentMethod(
        paymentMethodId,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchPaymentMethods();
        Get.back(); // Navigate back from AddCardView screen first
        Get.snackbar(
          'Success',
          'Card added successfully',
          snackPosition: SnackPosition.BOTTOM,
          margin: const EdgeInsets.all(16),
          borderRadius: 12,
          backgroundColor: const Color(0xFF10B981),
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Helpers.showDebugLog('Error attaching method: $e');
      Get.snackbar('Error', 'Failed to link card to profile');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> setDefaultCard(String paymentMethodId) async {
    try {
      isLoading.value = true;
      final response = await _userRepository.setDefaultPaymentMethod(
        paymentMethodId,
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        Get.snackbar('Success', 'Default payment method updated');
        fetchPaymentMethods();
      }
    } catch (e) {
      Helpers.showDebugLog('Error setting default card: $e');
      Get.snackbar('Error', 'Failed to update default card');
    } finally {
      isLoading.value = false;
    }
  }
}
