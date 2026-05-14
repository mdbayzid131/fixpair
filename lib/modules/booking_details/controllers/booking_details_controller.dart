import 'package:get/get.dart';
import '../../../data/models/user_model.dart';


class BookingDetailsController extends GetxController {

  
  final Rxn<BookingModel> booking = Rxn<BookingModel>();
  final isLoading = false.obs;  

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is BookingModel) {
      booking.value = Get.arguments as BookingModel;
    }
  }


}
