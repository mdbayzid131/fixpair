import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/core/services/auth_service.dart';
import 'package:fixpair/core/utils/helpers.dart';
import 'package:fixpair/core/utils/logger.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:get/get.dart';

class ProfileController extends GetxController {
  final AuthService _authService = Get.find();
  final UserRepository _userRepository = UserRepository();

  final isLoading = false.obs;
  final user = Rxn<UserData>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await _userRepository.getProfile();
      if (response.statusCode == 200) {
        final profileResponse = UserProfileResponseModel.fromJson(
          response.data,
        );
        user.value = profileResponse.data;
      }
    } catch (e) {
      AppLogger.debug('Error fetching profile: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> logout() async {
    Helpers.showLoadingDialog();
    try {
      await _authService.logout();
      Get.offAllNamed(AppRoutes.LOGIN);
      Helpers.showCustomSnackBar('Logged out successfully');
    } catch (e) {
      Helpers.hideLoadingDialog();
      Helpers.showCustomSnackBar(e.toString());
    }
  }

  Future<void> deleteAccount() async {
    Helpers.showLoadingDialog();
    try {
      final response = await _userRepository.deleteAccount();
      if (response.statusCode == 200) {
        await _authService.logout();
        Get.offAllNamed(AppRoutes.LOGIN);
        Helpers.showCustomSnackBar('Account deleted successfully');
      } else {
        Helpers.hideLoadingDialog();
        Helpers.showCustomSnackBar(
          response.data['message'] ?? 'Failed to delete account',
        );
      }
    } catch (e) {
      Helpers.hideLoadingDialog();
      AppLogger.debug('Error deleting account: $e');
      Helpers.showCustomSnackBar('Something went wrong');
    }
  }
}
