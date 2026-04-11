import 'package:get/get.dart';
import '../controllers/search_controller.dart' as custom;

class SearchBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<custom.SearchController>(() => custom.SearchController());
  }
}
