import 'package:fixpair/core/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../config/routes/app_pages.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/utils/helpers.dart';

class HomeController extends GetxController {
  final UserRepository _userRepository = Get.find();
  
  final RxList<BookingModel> confirmedBookings = <BookingModel>[].obs;
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchUpcomingBookings();
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
      final sessionResponse = await _userRepository.createVideoSession(booking.id!);
      
      if (sessionResponse.statusCode == 200 || sessionResponse.statusCode == 201) {
        final sessionData = sessionResponse.data['data'];
        final sessionId = sessionData['_id'];

        // 2. Join session to get token/channel
        final joinResponse = await _userRepository.joinVideoSession(sessionId);
        
        if (joinResponse.statusCode == 200) {
          final joinData = joinResponse.data['data'];
          
          Get.toNamed(AppRoutes.VIDEO_CALL, arguments: {
            'booking': booking,
            'sessionId': sessionId,
            'token': joinData['token'],
            'channelName': joinData['channelName'] ?? sessionId,
          });
        }
      }
    } catch (e) {
      Helpers.showDebugLog('Error starting video call: $e');
      Get.snackbar('Error', 'Could not start video call. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }

  void _showPaymentRequiredDialog() {
    Get.dialog(
      AlertDialog(
        title: const Text('Payment Method Required'),
        content: const Text(
          'You need to add a payment method before you can start a video consultation.',
        ),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              // Navigate to Payment Setup
              Get.toNamed(AppRoutes.ADD_CARD);
            },
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }


  Future<void> fetchUpcomingBookings() async {

    try {
      isLoading.value = true;
      final response = await _userRepository.getMyBookings(limit: 5);
      
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
}
