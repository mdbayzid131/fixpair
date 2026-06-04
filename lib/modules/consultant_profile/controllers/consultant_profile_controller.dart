import 'package:fixpair/core/utils/logger.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/models/review_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:get/get.dart';

class ConsultantProfileController extends GetxController {
  final UserRepository _userRepository = Get.find();
  final isAboutExpanded = false.obs;
  final isLoading = false.obs;
  final isLoadingReviews = false.obs;
  final Rxn<UserData> expert = Rxn<UserData>();

  final RxList<ReviewModel> consultantReviews = <ReviewModel>[].obs;
  final Rxn<ConsultantStats> stats = Rxn<ConsultantStats>();
  final RxInt totalConsultations = 0.obs;

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

      // Fetch reviews, stats, and total consultations in parallel
      await Future.wait([
        fetchReviews(id),
        fetchStats(id),
        fetchTotalConsultations(id),
      ]);
    } catch (e) {
      AppLogger.warning('Error fetching consultant details: ${e.toString()}');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchReviews(String id) async {
    try {
      isLoadingReviews.value = true;
      final response = await _userRepository.getConsultantReviews(
        id,
        page: 1,
        limit: 5,
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        consultantReviews.assignAll(
          data.map((e) => ReviewModel.fromJson(e)).toList(),
        );
      }
    } catch (e) {
      AppLogger.warning('Error fetching consultant reviews: ${e.toString()}');
    } finally {
      isLoadingReviews.value = false;
    }
  }

  Future<void> fetchStats(String id) async {
    try {
      final response = await _userRepository.getConsultantStats(id);
      if (response.statusCode == 200) {
        stats.value = ConsultantStats.fromJson(response.data['data']);
      }
    } catch (e) {
      AppLogger.warning('Error fetching consultant stats: ${e.toString()}');
    }
  }

  Future<void> fetchTotalConsultations(String id) async {
    try {
      final response = await _userRepository.getConsultantTotalConsultations(id);
      if (response.statusCode == 200) {
        final data = response.data['data'];
        totalConsultations.value = data['totalConsultations'] ?? 0;
      }
    } catch (e) {
      AppLogger.warning('Error fetching total consultations: ${e.toString()}');
    }
  }

  void toggleAboutExpansion() {
    isAboutExpanded.value = !isAboutExpanded.value;
  }
}
