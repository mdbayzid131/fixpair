import 'package:fixpair/core/utils/logger.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:get/get.dart';

class ConsultantProfileController extends GetxController {
  final UserRepository _userRepository = Get.find();
  final isAboutExpanded = false.obs;
  final isLoading = false.obs;
  final Rxn<UserData> expert = Rxn<UserData>();

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is UserData) {
      expert.value = Get.arguments as UserData;
      // Fetch fresh data to get full bio/details
      fetchConsultantDetails(expert.value!.id!);
    }
  }

  Future<void> fetchConsultantDetails(String id) async {
    try {
      isLoading.value = true;
      final response = await _userRepository.getConsultantById(id);
      if (response.statusCode == 200) {
        final userData = UserData.fromJson(response.data['data']);
        expert.value = userData;
      }
    } catch (e) {
      AppLogger.warning('Error fetching consultant details: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  void toggleAboutExpansion() {
    isAboutExpanded.value = !isAboutExpanded.value;
  }

  final reviews = [
    {
      'name': 'Max M.',
      'date': '2 days ago',
      'rating': 5,
      'comment':
          'Very professional and knowledgeable. Solved my issue in just 15 minutes. Highly recommended for quick consultations!',
      'avatar': '', // Placeholder
    },
  ].obs;
}
