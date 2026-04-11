import 'package:get/get.dart';

class HistoryController extends GetxController {
  final selectedTab = 0.obs; // 0 for Upcoming, 1 for Past History

  void selectTab(int index) {
    selectedTab.value = index;
  }
}
