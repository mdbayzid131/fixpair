import 'package:get/get.dart';
import '../../../data/models/faq_model.dart';
import '../../../data/repositories/legal_repository.dart';
import '../../../core/services/api_client.dart';
import '../../../core/utils/helpers.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../config/routes/app_pages.dart';
import '../../../core/services/storage_service.dart';

class LegalFAQController extends GetxController {
  final LegalRepo _legalRepo = LegalRepo(apiClient: Get.find<ApiClient>());
  final UserRepository _userRepository = Get.find<UserRepository>();

  // Use a List of bools to track expansion state of each item independently
  final expandedStates = <bool>[].obs;
  final faqItems = <FAQModel>[].obs;
  final isLoading = false.obs;

  final supportEmail = ''.obs;
  final supportPhone = ''.obs;
  final isLoadingSupport = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchFAQs();
  }

  Future<void> fetchFAQs() async {
    try {
      isLoading.value = true;
      final response = await _legalRepo.getFAQs();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        faqItems.value = data.map((json) => FAQModel.fromJson(json)).toList();

        // Initialize all as collapsed (false)
        expandedStates.value = List.generate(faqItems.length, (index) => false);
      }
    } catch (e) {
      Helpers.showError('Failed to load FAQs');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleExpanded(int index) {
    expandedStates[index] = !expandedStates[index];
  }

  Future<void> deleteAccount() async {
    try {
      isLoading.value = true;
      final response = await _userRepository.deleteAccount();
      if (response.statusCode == 200) {
        Helpers.showSuccess('Account deleted successfully');
        // Clear storage and go to splash/login
        StorageService.clearAll();

        Get.offAllNamed(AppRoutes.LOGIN);
      } else {
        Helpers.showError(
          response.data['message'] ?? 'Failed to delete account',
        );
      }
    } catch (e) {
      Helpers.showDebugLog('Error deleting account: $e');
      Helpers.showError('Something went wrong');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchCustomerSupport() async {
    try {
      isLoadingSupport.value = true;
      final response = await _legalRepo.getCustomerSupport();

      if (response.statusCode == 200) {
        final data = response.data['data'];
        supportEmail.value = data['email'] ?? 'support@fixpair.com';
        supportPhone.value = data['phoneNumber'] ?? '+1234567890';
      } else {
        Helpers.showError(
          response.data['message'] ?? 'Failed to load support information',
        );
      }
    } catch (e) {
      Helpers.showDebugLog('Error loading support: $e');
      Helpers.showError('Something went wrong');
    } finally {
      isLoadingSupport.value = false;
    }
  }
}
