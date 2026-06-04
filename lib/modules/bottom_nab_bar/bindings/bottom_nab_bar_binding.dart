import 'package:get/get.dart';
import '../controllers/bottom_nab_bar.dart';
import '../../home/controllers/home_controller.dart';
import '../../search/controllers/search_controller.dart' as search_ctrl;
import '../../history/controllers/history_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class BottomNavBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BottomNavBarController());
    Get.put(HomeController());
    Get.put(search_ctrl.SearchController());
    Get.put(HistoryController());
    Get.put(ProfileController());
  }
}
