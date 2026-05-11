import 'package:fixpair/config/themes/app_theme.dart';
import 'package:fixpair/core/widgets/custom_elevated_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fixpair/config/constants/api_constants.dart';

import '../controllers/personal_info_controller.dart';

class PersonalInfoView extends GetView<PersonalInfoController> {
  const PersonalInfoView({super.key});

  static const Color _backgroundColor = Color(0xFFF8FAFC);
  static const Color _textColor = Color(0xFF1D293D);
  static const Color _labelColor = Color(0xFF718096);
  static const Color _borderColor = Color(0xFFE5EAF0);
  static const Color _primaryColor = Color(0xFF0066FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          onPressed: Get.back,
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: _textColor,
            size: 20.sp,
          ),
        ),
        title: Text(
          'Personal Info',
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: _textColor,
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(24.w, 28.h, 24.w, 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: _buildPhotoPicker()),
              SizedBox(height: 35.h),
              Row(
                children: [
                  Expanded(
                    child: _ProfileInputField(
                      label: 'FIRST NAME',
                      controller: controller.firstNameController,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: _ProfileInputField(
                      label: 'LAST NAME',
                      controller: controller.lastNameController,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),
              _ProfileInputField(
                label: 'EMAIL ADDRESS',
                controller: controller.emailController,
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
        );
      }),
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.fromLTRB(24.w, 12.h, 24.w, 20.h),
        child: SizedBox(
          height: 56.h,
          width: double.infinity,
          child: CustomElevatedButton(
            label: 'Save Changes',
            onPressed: controller.saveChanges,
            backgroundColor: AppTheme.secondaryColor,
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoPicker() {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Obx(() {
              final rawUrl =
                  controller.user.value?.image ?? controller.user.value?.avatar;
              final imageUrl = ApiConstants.getImageUrl(rawUrl);
              final pickedFile = controller.pickedImage.value;

              return Container(
                width: 112.w,
                height: 112.w,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFF1F5F9),
                  image: pickedFile != null
                      ? DecorationImage(
                          image: FileImage(pickedFile),
                          fit: BoxFit.cover,
                        )
                      : imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  border: Border.all(color: Colors.white, width: 3.w),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.12),
                      blurRadius: 12,
                      offset: Offset(0, 7.h),
                    ),
                  ],
                ),
                child: (imageUrl.isEmpty && pickedFile == null)
                    ? Icon(Icons.person, size: 50.sp, color: _labelColor)
                    : null,
              );
            }),
            Positioned(
              right: 6.w,
              bottom: 5.h,
              child: GestureDetector(
                onTap: controller.changePhoto,
                child: Container(
                  width: 34.w,
                  height: 34.w,
                  decoration: const BoxDecoration(
                    color: _primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.camera_alt_outlined,
                    color: Colors.white,
                    size: 17.sp,
                  ),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 18.h),
        GestureDetector(
          onTap: controller.changePhoto,
          child: Text(
            'Change Photo',
            style: GoogleFonts.manrope(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: _primaryColor,
            ),
          ),
        ),
      ],
    );
  }
}

class _ProfileInputField extends StatelessWidget {
  const _ProfileInputField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13.sp,
            fontWeight: FontWeight.w800,
            letterSpacing: 0,
            color: PersonalInfoView._labelColor,
          ),
        ),
        SizedBox(height: 7.h),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: GoogleFonts.manrope(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: PersonalInfoView._textColor,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white,
            contentPadding: EdgeInsets.symmetric(
              horizontal: 17.w,
              vertical: 17.h,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(
                color: PersonalInfoView._borderColor,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(
                color: PersonalInfoView._borderColor,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14.r),
              borderSide: const BorderSide(
                color: PersonalInfoView._primaryColor,
                width: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
