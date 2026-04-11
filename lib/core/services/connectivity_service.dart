import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import '../controllers/internet_controller.dart';

class ConnectivityService {
  static void init() {
    final internet = Get.find<InternetController>();

    Connectivity().onConnectivityChanged.listen((result) {
      if (result == ConnectivityResult.none) {
        internet.setOffline();
      } else {
        internet.setOnline();
      }
    });
  }
}
