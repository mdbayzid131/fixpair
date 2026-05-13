import 'package:fixpair/core/services/api_checker.dart';
import 'package:fixpair/core/utils/helpers.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:fixpair/modules/bottom_nab_bar/controllers/bottom_nab_bar.dart';
import 'package:get/get.dart';

class ConsultantBookingController extends GetxController {
  final UserRepository _userRepository = Get.find();
  final Rxn<UserData> expert = Rxn<UserData>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is UserData) {
      expert.value = Get.arguments as UserData;
    }
  }

  Future<void> bookInstant() async {
    if (expert.value == null) return;

    try {
      isLoading.value = true;
      final body = {"consultantId": expert.value!.id, "bookingType": "instant"};

      final response = await _userRepository.bookConsultation(body);
      if (response.statusCode == 200 || response.statusCode == 201) {
        Helpers.showBookingSuccess();
        Get.offAllNamed('/bottom-nav-bar', arguments: 2);
      }
      ApiChecker.checkWriteApi(response);
    } catch (e) {
      Helpers.showDebugLog('Instant booking error: $e');
    } finally {
      isLoading.value = false;
    }
  }
}
