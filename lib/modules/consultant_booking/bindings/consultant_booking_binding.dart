import 'package:get/get.dart';
import '../controllers/consultant_booking_controller.dart';

class ConsultantBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConsultantBookingController>(() => ConsultantBookingController());
  }
}
