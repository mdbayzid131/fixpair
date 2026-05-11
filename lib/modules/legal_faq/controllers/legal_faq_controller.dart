import 'package:get/get.dart';
import '../../../data/models/faq_model.dart';
import '../../../data/repositories/legal_repository.dart';
import '../../../core/services/api_client.dart';
import '../../../core/utils/helpers.dart';

class LegalFAQController extends GetxController {
  final LegalRepo _legalRepo = LegalRepo(apiClient: Get.find<ApiClient>());

  // Use a List of bools to track expansion state of each item independently
  final expandedStates = <bool>[].obs;
  final faqItems = <FAQModel>[].obs;
  final isLoading = false.obs;

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
        expandedStates.value = List.generate(
          faqItems.length,
          (index) => false,
        );
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
}
