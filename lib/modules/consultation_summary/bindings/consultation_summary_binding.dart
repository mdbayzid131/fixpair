import 'package:get/get.dart';
import '../controllers/consultation_summary_controller.dart';

class ConsultationSummaryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ConsultationSummaryController>(
      () => ConsultationSummaryController(),
    );
  }
}
