import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

class SearchController extends GetxController {
  final UserRepository _userRepository = Get.find();

  final searchController = TextEditingController();

  final selectedCategory = 'All'.obs;
  final categories = ['All', 'Lawyer', 'Advisor', 'Doctor'];
  final searchQuery = ''.obs;

  bool get hasMore => _hasMore;

  final consultants = <UserData>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;

  int _currentPage = 1;
  bool _hasMore = true;
  Timer? _debounce;

  @override
  void onInit() {
    super.onInit();
    fetchConsultants();

    searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    searchQuery.value = searchController.text;
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      fetchConsultants();
    });
  }

  // Filter & Sort state
  final sortBy = 'none'
      .obs; // 'none', 'price_low_to_high', 'price_high_to_low', 'rating_high_to_low'
  final rateRange = const RangeValues(0, 100).obs;
  final minRating = 0.0.obs; // 0.0, 4.0, 4.5
  final isFilterApplied = false.obs;

  void applyFilters() {
    isFilterApplied.value =
        sortBy.value != 'none' ||
        rateRange.value.start > 0 ||
        rateRange.value.end < 100 ||
        minRating.value > 0.0;
    fetchConsultants();
  }

  void resetFilters() {
    sortBy.value = 'none';
    rateRange.value = const RangeValues(0, 100);
    minRating.value = 0.0;
    isFilterApplied.value = false;
    fetchConsultants();
  }

  Future<void> fetchConsultants({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (!_hasMore) return;
      isLoadingMore.value = true;
      _currentPage++;
    } else {
      isLoading.value = true;
      _currentPage = 1;
      _hasMore = true;
      consultants.clear();
    }

    try {
      String? apiSort;
      if (sortBy.value == 'price_low_to_high') {
        apiSort = 'perMinuteRate';
      } else if (sortBy.value == 'price_high_to_low') {
        apiSort = '-perMinuteRate';
      } else if (sortBy.value == 'rating_high_to_low') {
        apiSort = '-averageRating';
      }

      final response = await _userRepository.getConsultants(
        consultancyType: selectedCategory.value,
        searchTerm: searchController.text,
        minPrice: rateRange.value.start,
        maxPrice: rateRange.value.end,
        minRating: minRating.value > 0.0 ? minRating.value : null,
        sort: apiSort,
        page: _currentPage,
      );

      if (response.statusCode == 200) {
        final consultantResponse = ConsultantResponseModel.fromJson(
          response.data,
        );
        final newItems = consultantResponse.data ?? [];

        if (!isLoadMore) {
          consultants.assignAll(newItems);
        } else {
          consultants.addAll(newItems);
        }

        if (consultantResponse.pagination != null) {
          _hasMore =
              _currentPage < (consultantResponse.pagination!.totalPage ?? 1);
        } else {
          _hasMore = false;
        }
      }
    } catch (e) {
      debugPrint('Error fetching consultants: $e');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  void selectCategory(String category) {
    if (selectedCategory.value == category) return;
    selectedCategory.value = category;
    fetchConsultants();
  }

  @override
  void onClose() {
    searchController.removeListener(_onSearchChanged);
    _debounce?.cancel();

    // Safely dispose of UI controllers after widget unmount
    Future.delayed(const Duration(milliseconds: 500), () {
      try {
        searchController.dispose();
      } catch (_) {}
    });

    super.onClose();
  }
}
