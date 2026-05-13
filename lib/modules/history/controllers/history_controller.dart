import 'package:fixpair/core/utils/helpers.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  final UserRepository _userRepository = Get.find();

  final selectedTab = 0.obs; // 0 for Upcoming, 1 for Past History
  final isLoading = false.obs;

  final RxList<BookingModel> upcomingBookings = <BookingModel>[].obs;
  final RxList<BookingModel> pastBookings = <BookingModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyBookings();
  }

  Future<void> fetchMyBookings() async {
    try {
      isLoading.value = true;
      final response = await _userRepository.getMyBookings();

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final List<BookingModel> allBookings = data
            .map((e) => BookingModel.fromJson(e))
            .toList();

        upcomingBookings.value = allBookings
            .where((b) => b.status == 'pending' || b.status == 'confirmed')
            .toList();

        pastBookings.value = allBookings
            .where(
              (b) =>
                  b.status == 'completed' ||
                  b.status == 'cancelled' ||
                  b.status == 'expired' ||
                  b.status == 'rejected',
            )
            .toList();
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching bookings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }
}
