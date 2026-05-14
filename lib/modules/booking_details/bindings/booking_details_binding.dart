import 'package:fixpair/modules/booking_details/controllers/booking_details_controller.dart';
import 'package:get/get.dart';

class BookingDetailsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<BookingDetailsController>(
      () => BookingDetailsController(),
    );
  }
}
