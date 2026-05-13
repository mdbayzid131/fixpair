import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:get/get.dart';
import '../controllers/schedule_booking_controller.dart';

class ScheduleBookingBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserRepository());
    Get.lazyPut<ScheduleBookingController>(() => ScheduleBookingController());
  }
}
