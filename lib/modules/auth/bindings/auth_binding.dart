import 'package:get/get.dart';
import '../controllers/login_controller.dart';
import '../controllers/register_controller.dart';
import '../controllers/forgot_password_controller.dart';
import '../controllers/oto_controller.dart';
import '../controllers/set_new_pass_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => LoginController());
    Get.lazyPut(() => RegisterController());
    Get.lazyPut(() => ForgotPasswordController());
    Get.lazyPut(() => OtpController());
    Get.lazyPut(() => SetNewPassController());
  }
}
