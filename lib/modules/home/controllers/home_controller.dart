import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/utils/helpers.dart';

class HomeController extends GetxController {
  final UserRepository _userRepository = Get.find();
  
  final RxList<BookingModel> confirmedBookings = <BookingModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUpcomingBookings();
  }

  Future<void> fetchUpcomingBookings() async {
    try {
      isLoading.value = true;
      final response = await _userRepository.getMyBookings(limit: 5);
      
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final List<BookingModel> allBookings = data
            .map((e) => BookingModel.fromJson(e))
            .toList();

        // Filter only confirmed bookings
        confirmedBookings.value = allBookings
            .where((b) => b.status?.toLowerCase() == 'confirmed')
            .toList();
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching upcoming bookings: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
