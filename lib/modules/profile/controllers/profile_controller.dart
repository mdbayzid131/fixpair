import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/core/services/auth_service.dart';
import 'package:fixpair/core/utils/helpers.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find();

  Future<void> logout() async {
    Helpers.showLoadingDialog();
    try {
      // await _authService.logout();
      Helpers.hideLoadingDialog();
      Helpers.showCustomSnackBar('Logged out successfully', isError: false);
      Get.offAllNamed(AppRoutes.LOGIN);
    } catch (e) {
      Helpers.hideLoadingDialog();
      Helpers.showCustomSnackBar(e.toString());
    }
  }
}
