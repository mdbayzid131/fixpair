import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';

class SearchController extends GetxController {
  final UserRepository _userRepository = Get.find();

  final searchController = TextEditingController();
  final scrollController = ScrollController();

  final selectedCategory = 'All'.obs;
  final categories = ['All', 'Lawyer', 'Advisor', 'Doctor'];
  final searchQuery = ''.obs;

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

    scrollController.addListener(() {
      if (scrollController.position.pixels >=
          scrollController.position.maxScrollExtent - 200) {
        if (_hasMore && !isLoadingMore.value && !isLoading.value) {
          fetchConsultants(isLoadMore: true);
        }
      }
    });

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
    searchController.dispose();
    scrollController.dispose();
    _debounce?.cancel();
    super.onClose();
  }
}
