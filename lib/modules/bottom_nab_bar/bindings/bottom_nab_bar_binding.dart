import 'package:get/get.dart';
import '../controllers/bottom_nab_bar.dart';
import '../../home/controllers/home_controller.dart';
import '../../search/controllers/search_controller.dart' as search_ctrl;
import '../../history/controllers/history_controller.dart';
import '../../profile/controllers/profile_controller.dart';

class BottomNavBarBinding extends Bindings {
  @override
  void dependencies() {
    Get.put(BottomNavBarController(), permanent: true);
    Get.put(HomeController(), permanent: true);
    Get.put(search_ctrl.SearchController(), permanent: true);
    Get.put(HistoryController(), permanent: true);
    Get.put(ProfileController(), permanent: true);
  }
}
