import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:get/get.dart';
import '../controllers/history_controller.dart';

class HistoryBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => UserRepository());
    Get.lazyPut<HistoryController>(() => HistoryController());
  }
}
