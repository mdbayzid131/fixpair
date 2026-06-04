import 'package:get/get.dart';
import '../../../data/repositories/notification_repository.dart';
import '../controllers/notifications_controller.dart';

class NotificationsBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<NotificationRepo>(() => NotificationRepo(apiClient: Get.find()));
    Get.lazyPut<NotificationsController>(() => NotificationsController());
  }
}
