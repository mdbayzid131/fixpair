import 'package:fixpair/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routes/app_pages.dart';
import '../../../data/models/user_model.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../core/utils/helpers.dart';
import '../../../config/constants/api_constants.dart';
import '../../../core/services/socket_service.dart';

class HomeController extends GetxController {
  final UserRepository _userRepository = Get.find();
  final NotificationRepo _notificationRepo = NotificationRepo(
    apiClient: Get.find(),
  );

  final RxList<BookingModel> confirmedBookings = <BookingModel>[].obs;
  final RxList<UserData> recommendedConsultants = <UserData>[].obs;
  final selectedCategory = 'All'.obs;
  final categories = <String>['All'].obs;
  final isLoading = false.obs;
  final hasUnreadNotifications = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchCategories();
    fetchUpcomingBookings();
    fetchRecommendedConsultants();
    checkUnreadNotifications();
    _listenToConsultantStatusChanges();
  }

  Future<void> fetchCategories() async {
    try {
      final response = await _userRepository.getConsultancyTypes();
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final fetchedCategories = <String>['All'];
        for (var item in data) {
          if (item is Map && item['name'] != null) {
            final String rawName = item['name'].toString().trim();
            if (rawName.isNotEmpty) {
              final formattedName =
                  rawName[0].toUpperCase() + rawName.substring(1);
              if (!fetchedCategories.contains(formattedName)) {
                fetchedCategories.add(formattedName);
              }
            }
          }
        }
        categories.assignAll(fetchedCategories);
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching consultancy types on home: $e');
    }
  }

  Future<void> checkUnreadNotifications() async {
    try {
      final response = await _notificationRepo.getNotifications(
        page: 1,
        limit: 10,
      );
      if (response.statusCode == 200) {
        final notificationResponse = NotificationResponseModel.fromJson(
          response.data,
        );
        final unread =
            notificationResponse.data?.any((element) => !element.read) ?? false;
        hasUnreadNotifications.value = unread;
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> startVideoCall(BookingModel booking) async {
    final authService = Get.find<AuthService>();
    final user = authService.user.value;

    // Check for payment method
    if (user?.paymentMethods == null || user!.paymentMethods!.isEmpty) {
      _showPaymentRequiredDialog();
      return;
    }

    try {
      isLoading.value = true;

      // 1. Create or get session
      final sessionResponse = await _userRepository.createVideoSession(
        booking.id!,
      );

      if (sessionResponse.statusCode == 200 ||
          sessionResponse.statusCode == 201) {
        final sessionData = sessionResponse.data['data'];
        final sessionId = sessionData['_id'];

        // 2. Join session to get token/channel
        final joinResponse = await _userRepository.joinVideoSession(sessionId);

        if (joinResponse.statusCode == 200) {
          final joinData = joinResponse.data['data'];

          Get.toNamed(
            AppRoutes.VIDEO_CALL,
            arguments: {
              'booking': booking,
              'sessionId': sessionId,
              'token': joinData['token'],
              'channelName': joinData['channelName'] ?? sessionId,
            },
          );
        } else if (joinResponse.statusCode == 402) {
          Get.find<AuthService>().showPaymentRequiredDialog();
        } else {
          Helpers.showError(
            joinResponse.statusMessage ?? 'Failed to join video call'.tr,
          );
        }
      }
    } catch (e) {
      Helpers.showDebugLog('Error starting video call: $e');
      Helpers.showError('Could not start video call. Please try again.'.tr);
    } finally {
      isLoading.value = false;
    }
  }

  void _showPaymentRequiredDialog() {
    Get.dialog(
      AlertDialog(
        title: Text('Payment Method Required'.tr),
        content: Text(
          'You need to add a payment method before you can start a video consultation.'.tr,
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Navigate to Payment Setup
              Get.toNamed(AppRoutes.ADD_CARD);
            },
            child: Text('Add Card'.tr),
          ),
        ],
      ),
    );
  }

  Future<void> fetchUpcomingBookings() async {
    try {
      isLoading.value = true;
      final response = await _userRepository.getBookingsWithUrl(
        '${ApiConstants.myBookings}?status=confirmed&limit=5',
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final List<BookingModel> allBookings = data
            .map((e) => BookingModel.fromJson(e))
            .toList();

        // Filter only confirmed bookings
        confirmedBookings.value = allBookings
            .where((b) => b.status?.toLowerCase() == 'confirmed')
            .toList();
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching upcoming bookings: $e');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> fetchRecommendedConsultants({bool isRefresh = false}) async {
    try {
      if (!isRefresh && recommendedConsultants.isEmpty) {
        isLoading.value = true;
      }
      final response = await _userRepository.getConsultants(
        consultancyType: selectedCategory.value,
        sort: '-averageRating',
        limit: 50,
      );

      if (response.statusCode == 200) {
        final consultantResponse = ConsultantResponseModel.fromJson(
          response.data,
        );
        if (consultantResponse.data != null) {
          recommendedConsultants.value = consultantResponse.data!;
        } else {
          // Fallback if data is in a different format
          final List<dynamic> dataList = response.data['data'] is List
              ? response.data['data']
              : [];
          final List<UserData> parsed = [];
          for (var item in dataList) {
            if (item is Map<String, dynamic>) {
              parsed.add(UserData.fromJson(item));
            }
          }
          recommendedConsultants.value = parsed;
        }
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching all consultants: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void selectCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    fetchRecommendedConsultants();
  }

  Future<void> onRefresh() async {
    await Future.wait([
      fetchCategories(),
      fetchUpcomingBookings(),
      fetchRecommendedConsultants(isRefresh: true),
      checkUnreadNotifications(),
    ]);
  }

  void _listenToConsultantStatusChanges() {
    if (Get.isRegistered<SocketService>()) {
      final socketService = Get.find<SocketService>();
      ever(socketService.consultantStatusUpdate, (statusData) {
        if (statusData != null) {
          final String? consultantId = statusData['consultantId']?.toString();
          final bool? isOnline = statusData['isOnline'] as bool?;
          if (consultantId != null && isOnline != null) {
            final index = recommendedConsultants.indexWhere((c) => c.id == consultantId);
            if (index != -1) {
              recommendedConsultants[index] = recommendedConsultants[index].copyWith(activeStatus: isOnline);
              recommendedConsultants.refresh();
              Helpers.showDebugLog('Real-time updated consultant $consultantId activeStatus: $isOnline on Home');
            }
          }
        }
      });
    }
  }
}
