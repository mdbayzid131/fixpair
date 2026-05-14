import 'package:fixpair/core/utils/helpers.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  final UserRepository _userRepository = Get.find();

  final selectedTab = 0.obs; // 0 for Upcoming, 1 for Past History
  final isLoading = false.obs;

  final RxList<BookingModel> upcomingBookings = <BookingModel>[].obs;
  final RxList<BookingModel> pastBookings = <BookingModel>[].obs;

  final scrollController = ScrollController();
  final currentPage = 1.obs;
  final hasMore = true.obs;
  final isLoadingMore = false.obs;

  @override
  void onInit() {
    super.onInit();
    fetchMyBookings();

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (hasMore.value && !isLoadingMore.value && !isLoading.value) {
          fetchMyBookings(isLoadMore: true);
        }
      }
    });
  }

  @override
  void onClose() {
    scrollController.dispose();
    super.onClose();
  }

  Future<void> fetchMyBookings({bool isLoadMore = false}) async {
    try {
      if (isLoadMore) {
        isLoadingMore.value = true;
        currentPage.value++;
      } else {
        isLoading.value = true;
        currentPage.value = 1;
        hasMore.value = true;
        upcomingBookings.clear();
        pastBookings.clear();
      }

      final response = await _userRepository.getMyBookings(
        page: currentPage.value,
        limit: 10,
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final List<BookingModel> allBookings = data
            .map((e) => BookingModel.fromJson(e))
            .toList();

        final upcoming = allBookings
            .where(
              (b) =>
                  b.status == 'pending' ||
                  b.status == 'confirmed' ||
                  b.status == 'accepted',
            )
            .toList();

        final past = allBookings
            .where(
              (b) =>
                  b.status == 'completed' ||
                  b.status == 'cancelled' ||
                  b.status == 'expired' ||
                  b.status == 'rejected',
            )
            .toList();

        if (isLoadMore) {
          upcomingBookings.addAll(upcoming);
          pastBookings.addAll(past);
        } else {
          upcomingBookings.assignAll(upcoming);
          pastBookings.assignAll(past);
        }

        // Pagination metadata check
        if (response.data['pagination'] != null) {
          final pagination = response.data['pagination'];
          final totalPage = pagination['totalPage'] ?? 1;
          hasMore.value = currentPage.value < totalPage;
        } else {
          hasMore.value = false;
        }
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching bookings: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void selectTab(int index) {
    selectedTab.value = index;
  }

  Future<void> cancelBooking(String id, {String? reason}) async {
    try {
      isLoading.value = true;
      final response = await _userRepository.cancelBooking(id, reason: reason);

      if (response.statusCode == 200) {
        Helpers.showSuccess('Booking cancelled successfully');
        await fetchMyBookings(); // Refresh the list
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
}
