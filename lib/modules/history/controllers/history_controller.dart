import 'package:fixpair/core/utils/helpers.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:fixpair/config/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HistoryController extends GetxController {
  final UserRepository _userRepository = Get.find();

  final selectedTab = 0.obs; // 0 for Upcoming, 1 for Past History
  final isLoading = false.obs;

  final RxList<BookingModel> upcomingBookings = <BookingModel>[].obs;
  final RxList<BookingModel> pastBookings = <BookingModel>[].obs;

  final scrollController = ScrollController();

  // Independent pagination states for each tab
  final upcomingPage = 1.obs;
  final pastPage = 1.obs;
  final upcomingHasMore = true.obs;
  final pastHasMore = true.obs;
  final upcomingLoadingMore = false.obs;
  final pastLoadingMore = false.obs;

  // Reactively forward properties to preserve view bindings
  RxBool get hasMore => selectedTab.value == 0 ? upcomingHasMore : pastHasMore;
  RxBool get isLoadingMore =>
      selectedTab.value == 0 ? upcomingLoadingMore : pastLoadingMore;

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
    final tab = selectedTab.value;

    // Determine target pagination state
    RxInt pageVar = tab == 0 ? upcomingPage : pastPage;
    RxBool hasMoreVar = tab == 0 ? upcomingHasMore : pastHasMore;
    RxBool loadMoreVar = tab == 0 ? upcomingLoadingMore : pastLoadingMore;
    RxList<BookingModel> listVar = tab == 0 ? upcomingBookings : pastBookings;

    try {
      if (isLoadMore) {
        if (!hasMoreVar.value) return;
        loadMoreVar.value = true;
        pageVar.value++;
      } else {
        isLoading.value = true;
        pageVar.value = 1;
        hasMoreVar.value = true;
        listVar.clear();
      }

      // Build specific query path based on tab as requested by the user:
      // Tab 0 (Upcoming): status=pending&status=accepted&status=confirmed
      // Tab 1 (Past): status=completed&status=rejected&status=cancelled&status=expired
      final String statusQuery = tab == 0
          ? 'status=pending&status=accepted&status=confirmed'
          : 'status=completed&status=rejected&status=cancelled&status=expired';

      final String 
      uri =
          '${ApiConstants.myBookings}?$statusQuery&page=${pageVar.value}&limit=10';

      final response = await _userRepository.getBookingsWithUrl(uri);

      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'];
        final List<BookingModel> fetchedBookings = data
            .map((e) => BookingModel.fromJson(e))
            .toList();

        if (isLoadMore) {
          listVar.addAll(fetchedBookings);
        } else {
          listVar.assignAll(fetchedBookings);
        }

        // Pagination metadata check
        if (response.data['pagination'] != null) {
          final pagination = response.data['pagination'];
          final totalPage = pagination['totalPage'] ?? 1;
          hasMoreVar.value = pageVar.value < totalPage;
        } else {
          hasMoreVar.value = false;
        }
      }
    } catch (e) {
      Helpers.showDebugLog('Error fetching bookings for tab $tab: $e');
    } finally {
      isLoading.value = false;
      loadMoreVar.value = false;
    }
  }

  void selectTab(int index) {
    selectedTab.value = index;
    // Load tab-specific bookings if empty
    if (index == 0 && upcomingBookings.isEmpty) {
      fetchMyBookings();
    } else if (index == 1 && pastBookings.isEmpty) {
      fetchMyBookings();
    }
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

  Future<bool> submitReview({
    required String consultationId,
    required double rating,
    required String comment,
  }) async {
    try {
      isLoading.value = true;
      final response = await _userRepository.postReview(
        consultationId: consultationId,
        rating: rating,
        comment: comment,
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        Helpers.showSuccess('Review submitted successfully!');
        fetchMyBookings(); // Refresh the list
        return true;
      } else {
        Helpers.showError(
          response.data['message'] ?? 'Failed to submit review',
        );
        return false;
      }
    } catch (e) {
      Helpers.showDebugLog('Error submitting review: $e');
      Helpers.showError('An unexpected error occurred while posting review');
      return false;
    } finally {
      isLoading.value = false;
    }
  }
}
