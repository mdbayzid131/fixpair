import 'package:fixpair/core/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class PersonalInfoController extends GetxController {
  final firstNameController = TextEditingController(text: 'Klaus');
  final lastNameController = TextEditingController(text: 'Muller');
  final emailController = TextEditingController(text: 'klaus.mueller@example.com');
  final phoneController = TextEditingController(text: '+49 151 23456789');

  void changePhoto() {
    Helpers.showCustomSnackBar('Photo update will be available soon', isError: false);
  }

  void saveChanges() {
    Helpers.showCustomSnackBar('Profile updated successfully', isError: false);
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.onClose();
  }
}
