import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:get/get.dart';
import '../controllers/consultant_profile_controller.dart';

class ConsultantProfileBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<UserRepository>(() => UserRepository());
    Get.lazyPut<ConsultantProfileController>(() => ConsultantProfileController());
  }
}
