import 'package:fixpair/config/routes/app_pages.dart';
import 'package:get/get.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/helpers.dart';

class BottomNavBarController extends GetxController {
  final AuthService _authService = Get.find();

  final currentIndex = 0.obs;

  void changeTab(int index) {
    currentIndex.value = index;
  }

  void goToProfile() {
    Get.toNamed(AppRoutes.PROFILE);
  }

  Future<void> logout() async {
    Helpers.showLoadingDialog();

    await _authService.logout();

    Helpers.hideLoadingDialog();
    Helpers.showCustomSnackBar('Logged out successfully');

    Get.offAllNamed(AppRoutes.LOGIN);
  }
}
