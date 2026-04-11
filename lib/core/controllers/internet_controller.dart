import 'package:get/get.dart';

class InternetController extends GetxController {
  final hasInternet = true.obs;
  final isShowingNoInternet = false.obs;

  void setOffline() {
    hasInternet.value = false;
    isShowingNoInternet.value = true;
  }

  void setOnline() {
    hasInternet.value = true;
    isShowingNoInternet.value = false;
  }
}
