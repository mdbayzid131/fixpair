import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/core/services/socket_service.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:get/get.dart';

class ConsultantBookingController extends GetxController {
  final Rxn<UserData> expert = Rxn<UserData>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    _listenToConsultantStatusChanges();
    if (Get.arguments is UserData) {
      expert.value = Get.arguments as UserData;
    }
  }

  void _listenToConsultantStatusChanges() {
    if (Get.isRegistered<SocketService>()) {
      final socketService = Get.find<SocketService>();
      ever(socketService.consultantStatusUpdate, (statusData) {
        if (statusData != null) {
          final String? consultantId = statusData['consultantId']?.toString();
          final bool? isOnline = statusData['isOnline'] as bool?;
          if (consultantId != null &&
              isOnline != null &&
              expert.value?.id == consultantId) {
            expert.value = expert.value?.copyWith(activeStatus: isOnline);
          }
        }
      });
    }
  }

  void bookInstant() {
    if (expert.value == null) return;
    Get.toNamed(AppRoutes.CONSULTANT_CONFIRMATION, arguments: expert.value);
  }
}
