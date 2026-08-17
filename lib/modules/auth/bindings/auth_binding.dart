import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';
import '../controllers/forgot_password_controller.dart';
import '../controllers/oto_controller.dart';
import '../controllers/set_new_pass_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    if (Get.isRegistered<LoginController>()) {
      Get.delete<LoginController>(force: true);
    }
    if (Get.isRegistered<RegisterController>()) {
      Get.delete<RegisterController>(force: true);
    }
    if (Get.isRegistered<ForgotPasswordController>()) {
      Get.delete<ForgotPasswordController>(force: true);
    }
    if (Get.isRegistered<OtpController>()) {
      Get.delete<OtpController>(force: true);
    }
    if (Get.isRegistered<SetNewPassController>()) {
      Get.delete<SetNewPassController>(force: true);
    }

    Get.lazyPut(() => LoginController(), fenix: true);
    Get.lazyPut(() => RegisterController(), fenix: true);
    Get.lazyPut(() => ForgotPasswordController(), fenix: true);
    Get.lazyPut(() => OtpController(), fenix: true);
    Get.lazyPut(() => SetNewPassController(), fenix: true);
  }
}
