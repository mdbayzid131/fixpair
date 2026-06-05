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
      final response = await _userRepository.getConsultants(
        consultancyType: selectedCategory.value,
        name: searchController.text,
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
