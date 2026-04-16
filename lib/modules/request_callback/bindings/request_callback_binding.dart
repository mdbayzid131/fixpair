import 'package:get/get.dart';
import '../controllers/request_callback_controller.dart';

class RequestCallbackBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RequestCallbackController>(
      () => RequestCallbackController(),
    );
  }
}
