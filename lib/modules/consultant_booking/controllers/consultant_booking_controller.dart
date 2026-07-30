import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:get/get.dart';

class ConsultantBookingController extends GetxController {
  final Rxn<UserData> expert = Rxn<UserData>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is UserData) {
      expert.value = Get.arguments as UserData;
    }
  }

  void bookInstant() {
    if (expert.value == null) return;
    Get.toNamed(AppRoutes.CONSULTANT_CONFIRMATION, arguments: expert.value);
  }
}
