import 'package:get/get.dart';
import '../controllers/consultant_confirmation_controller.dart';

class ConsultantConfirmationBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConsultantConfirmationController>(
      () => ConsultantConfirmationController(),
    );
  }
}
