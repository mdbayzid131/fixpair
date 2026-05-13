import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:get/get.dart';
import '../controllers/consultant_booking_controller.dart';

class ConsultantBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserRepository());
    Get.lazyPut<ConsultantBookingController>(() => ConsultantBookingController());
  }
}
