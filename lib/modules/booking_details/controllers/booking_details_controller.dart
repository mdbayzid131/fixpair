import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/utils/helpers.dart';
import '../../../config/routes/app_pages.dart';
import 'package:flutter/material.dart';

class BookingDetailsController extends GetxController {
  final UserRepository _userRepository = Get.find();

  final Rxn<BookingModel> booking = Rxn<BookingModel>();
  final isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is BookingModel) {
      booking.value = Get.arguments as BookingModel;
    }
  }

  Future<void> cancelBooking(String id, {String? reason}) async {
    try {
      isLoading.value = true;
      final response = await _userRepository.cancelBooking(id, reason: reason);

      if (response.statusCode == 200) {
        Helpers.showSuccess('Booking cancelled successfully');
        if (booking.value != null) {
          // Re-create the booking model with updated status to trigger Obx refresh
          booking.value = BookingModel(
            id: booking.value!.id,
            user: booking.value!.user,
            consultant: booking.value!.consultant,
            bookingType: booking.value!.bookingType,
            notes: booking.value!.notes,
            perMinuteRate: booking.value!.perMinuteRate,
            platformFee: booking.value!.platformFee,
            totalAmount: booking.value!.totalAmount,
            status: 'cancelled',
            paymentStatus: booking.value!.paymentStatus,
            createdAt: booking.value!.createdAt,
            date: booking.value!.date,
            startTime: booking.value!.startTime,
            endTime: booking.value!.endTime,
            preferredWindow: booking.value!.preferredWindow,
          );
        }
      } else {
        Helpers.showError(
          response.data['message'] ?? 'Failed to cancel booking',
        );
      }
    } catch (e) {
      Helpers.showDebugLog('Error cancelling booking: $e');
      Helpers.showError('An unexpected error occurred');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startVideoCall(BookingModel bookingData) async {
    final authService = Get.find<AuthService>();
    final user = authService.user.value;

    // Check for payment method
    if (user?.paymentMethods == null || user!.paymentMethods!.isEmpty) {
      _showPaymentRequiredDialog();
      return;
    }

    try {
      isLoading.value = true;
      Helpers.showLoadingDialog(message: 'Initializing video call...');

      // 1. Create or get session
      final sessionResponse = await _userRepository.createVideoSession(
        bookingData.id!,
      );

      if (sessionResponse.statusCode == 200 ||
          sessionResponse.statusCode == 201) {
        final sessionData = sessionResponse.data['data'];
        final sessionId = sessionData['_id'];

        // 2. Join session to get token/channel
        final joinResponse = await _userRepository.joinVideoSession(sessionId);

        if (joinResponse.statusCode == 200) {
          final joinData = joinResponse.data['data'];

          Get.offNamed(
            AppRoutes.VIDEO_CALL,
            arguments: {
              'booking': bookingData,
              'sessionId': sessionId,
              'token': joinData['token'],
              'channelName': joinData['channelName'] ?? sessionId,
            },
          );
        } else if (joinResponse.statusCode == 402) {
          Helpers.hideLoadingDialog();
          Get.find<AuthService>().showPaymentRequiredDialog();
        } else {
          Helpers.hideLoadingDialog();
          Helpers.showError(joinResponse.statusMessage ?? 'Failed to join video call');
        }
      } else {
        Helpers.hideLoadingDialog();
        Helpers.showError('Failed to create video session');
      }
    } catch (e) {
      Helpers.hideLoadingDialog();
      Helpers.showDebugLog('Error starting video call: $e');
      Helpers.showError('Could not start video call. Please try again.');
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
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Get.back();
              Get.toNamed(AppRoutes.ADD_CARD);
            },
            child: const Text('Add Card'),
          ),
        ],
      ),
    );
  }
}
