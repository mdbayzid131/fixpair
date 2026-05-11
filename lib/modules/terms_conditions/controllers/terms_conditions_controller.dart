import 'package:get/get.dart';
import '../../../data/models/legal_content_model.dart';
import '../../../data/repositories/legal_repository.dart';
import '../../../core/services/api_client.dart';
import '../../../core/utils/helpers.dart';

class TermsConditionsController extends GetxController {
  final LegalRepo _legalRepo = LegalRepo(apiClient: Get.find<ApiClient>());

  final termsConditionsItems = <LegalContentModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchTermsConditions();
  }

  Future<void> fetchTermsConditions() async {
    try {
      isLoading.value = true;
      final response = await _legalRepo.getTermsConditions();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        termsConditionsItems.value = data.map((json) => LegalContentModel.fromJson(json)).toList();
      }
    } catch (e) {
      Helpers.showError('Failed to load Terms & Conditions');
    } finally {
      isLoading.value = false;
    }
  }
}
