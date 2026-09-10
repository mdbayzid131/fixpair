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
    } catch (e) {
      Helpers.showDebugLog('Error adding payment method: $e');
      Helpers.showError('${'Failed to add card'.tr}: $e');
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
        Helpers.showSuccess('Card added successfully'.tr);
      }
    } catch (e) {
      Helpers.showDebugLog('Error attaching method: $e');
      Helpers.showError('Failed to link card to profile'.tr);
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
        Helpers.showSuccess('Default payment method updated'.tr);
        fetchPaymentMethods();
      }
    } catch (e) {
      Helpers.showDebugLog('Error setting default card: $e');
      Helpers.showError('Failed to update default card'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> deleteCard(String paymentMethodId) async {
    try {
      isLoading.value = true;
      final response = await _userRepository.deletePaymentMethod(paymentMethodId);
      if (response.statusCode == 200 || response.statusCode == 204) {
        Helpers.showSuccess('Card removed successfully'.tr);
        await fetchPaymentMethods();
      } else {
        Helpers.showError(response.statusMessage ?? 'Failed to delete card'.tr);
      }
    } catch (e) {
      Helpers.showDebugLog('Error deleting payment method: $e');
      Helpers.showError('Failed to remove card'.tr);
    } finally {
      isLoading.value = false;
    }
  }
}
