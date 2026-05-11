import 'package:get/get.dart';
import '../../../data/models/legal_content_model.dart';
import '../../../data/repositories/legal_repository.dart';
import '../../../core/services/api_client.dart';
import '../../../core/utils/helpers.dart';

class PrivacyPolicyController extends GetxController {
  final LegalRepo _legalRepo = LegalRepo(apiClient: Get.find<ApiClient>());

  final privacyPolicyItems = <LegalContentModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchPrivacyPolicy();
  }

  Future<void> fetchPrivacyPolicy() async {
    try {
      isLoading.value = true;
      final response = await _legalRepo.getPrivacyPolicy();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        privacyPolicyItems.value = data.map((json) => LegalContentModel.fromJson(json)).toList();
      }
    } catch (e) {
      Helpers.showError('Failed to load Privacy Policy');
    } finally {
      isLoading.value = false;
    }
  }
}
