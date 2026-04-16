import 'package:get/get.dart';
import '../controllers/legal_faq_controller.dart';

class LegalFAQBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LegalFAQController>(() => LegalFAQController());
  }
}
