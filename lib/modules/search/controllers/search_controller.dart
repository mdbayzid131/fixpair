import 'package:flutter/material.dart';
import 'package:get/get.dart';

class SearchController extends GetxController {
  final searchController = TextEditingController();
  final selectedCategory = 'All'.obs;
  
  final categories = ['All', 'Lawyer', 'Advisor', 'Doctor'];

  void selectCategory(String category) {
    selectedCategory.value = category;
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }
}
