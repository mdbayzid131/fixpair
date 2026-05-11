import 'dart:io';
import 'package:fixpair/core/services/api_client.dart';
import 'package:fixpair/core/utils/helpers.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/modules/profile/controllers/profile_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class PersonalInfoController extends GetxController {
  final UserRepository _userRepository = UserRepository();
  final ImagePicker _picker = ImagePicker();

  final firstNameController = TextEditingController();
  final lastNameController = TextEditingController();
  final emailController = TextEditingController();

  final isLoading = false.obs;
  final user = Rxn<UserData>();
  final pickedImage = Rxn<File>();

  @override
  void onInit() {
    super.onInit();
    fetchProfile();
  }

  Future<void> fetchProfile() async {
    try {
      isLoading.value = true;
      final response = await _userRepository.getProfile();
      if (response.statusCode == 200) {
        final profileResponse = UserProfileResponseModel.fromJson(
          response.data,
        );
        user.value = profileResponse.data;
        if (user.value != null) {
          firstNameController.text = user.value!.firstName ?? '';
          lastNameController.text = user.value!.lastName ?? '';
          emailController.text = user.value!.email ?? '';
        }
      } else {
        Helpers.showCustomSnackBar(
          response.data['message'] ?? 'Failed to load profile',
        );
      }
    } catch (e) {
      Helpers.showCustomSnackBar(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        imageQuality: 80,
      );
      if (image != null) {
        pickedImage.value = File(image.path);
      }
    } catch (e) {
      Helpers.showCustomSnackBar('Error picking image: $e');
    }
  }

  Future<void> saveChanges() async {
    if (firstNameController.text.isEmpty) {
      Helpers.showError('First name cannot be empty');
      return;
    }

    try {
      isLoading.value = true;
      Helpers.showLoadingDialog();

      final fullName =
          '${firstNameController.text} ${lastNameController.text}'.trim();

      final Map<String, dynamic> body = {
        "name": fullName,
        "email": emailController.text,
      };

      List<MultipartBody>? multipartBody;
      if (pickedImage.value != null) {
        multipartBody = [MultipartBody('image', pickedImage.value!)];
      }

      final response = await _userRepository.updateProfile(
        body,
        multipartBody: multipartBody,
      );

      Helpers.hideLoadingDialog();

      if (response.statusCode == 200 || response.statusCode == 201) {
        Helpers.showSuccess('Profile updated successfully');
        pickedImage.value = null; // Clear picked image after success
        await fetchProfile(); // Refresh local profile
        
        // Refresh main profile screen if it's open
        if (Get.isRegistered<ProfileController>()) {
          Get.find<ProfileController>().fetchProfile();
        }
      } else {
        Helpers.showError(
          response.data['message'] ?? 'Failed to update profile',
        );
      }
    } catch (e) {
      Helpers.hideLoadingDialog();
      Helpers.showError(e.toString());
    } finally {
      isLoading.value = false;
    }
  }

  void changePhoto() {
    Get.bottomSheet(
      Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Image Source',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildSourceOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Get.back();
                    pickImage(ImageSource.camera);
                  },
                ),
                _buildSourceOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Get.back();
                    pickImage(ImageSource.gallery);
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.blue.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: Colors.blue, size: 30),
          ),
          const SizedBox(height: 8),
          Text(label),
        ],
      ),
    );
  }

  @override
  void onClose() {
    firstNameController.dispose();
    lastNameController.dispose();
    emailController.dispose();
    super.onClose();
  }
}
