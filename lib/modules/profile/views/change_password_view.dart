import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/widgets/custom_elevated_button.dart';
import '../../../core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  const ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: const Color(0xFF1D293D),
            size: 20.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Change Password',
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 12.h),
                Text(
                  'Set a new password',
                  style: GoogleFonts.manrope(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D293D),
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Ensure your account is secure by choosing a strong password with at least 6 characters.',
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    height: 1.5,
                  ),
                ),
                SizedBox(height: 32.h),

                // 1. Current Password
                Text(
                  'Current Password',
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(
                  () => CustomTextField(
                    controller: controller.currentPasswordController,
                    hintText: 'Enter current password',
                    obscureText: controller.obscureCurrentPassword.value,
                    isLabelVisible: false,
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.lock_open_rounded,
                      color: const Color(0xFF94A3B8),
                      size: 20.sp,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => controller.obscureCurrentPassword.toggle(),
                      child: Icon(
                        controller.obscureCurrentPassword.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 20.sp,
                      ),
                    ),
                    validator: (v) => Validators.required(
                      v,
                      message: 'Current password is required',
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // 2. New Password
                Text(
                  'New Password',
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(
                  () => CustomTextField(
                    controller: controller.newPasswordController,
                    hintText: 'Enter new password',
                    obscureText: controller.obscureNewPassword.value,
                    isLabelVisible: false,
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: const Color(0xFF94A3B8),
                      size: 20.sp,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => controller.obscureNewPassword.toggle(),
                      child: Icon(
                        controller.obscureNewPassword.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 20.sp,
                      ),
                    ),
                    validator: (v) => Validators.password(
                      v,
                      minLength: 8,
                      requireDigit: true,
                      requireUppercase: true,
                      requireLowercase: true,
                      requireSpecialChar: true,
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // 3. Confirm New Password
                Text(
                  'Confirm New Password',
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF475569),
                  ),
                ),
                SizedBox(height: 8.h),
                Obx(
                  () => CustomTextField(
                    controller: controller.confirmPasswordController,
                    hintText: 'Re-enter new password',
                    obscureText: controller.obscureConfirmPassword.value,
                    isLabelVisible: false,
                    fillColor: Colors.white,
                    prefixIcon: Icon(
                      Icons.lock_outline_rounded,
                      color: const Color(0xFF94A3B8),
                      size: 20.sp,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: () => controller.obscureConfirmPassword.toggle(),
                      child: Icon(
                        controller.obscureConfirmPassword.value
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: const Color(0xFF94A3B8),
                        size: 20.sp,
                      ),
                    ),
                    validator: (v) => Validators.confirmPassword(
                      v,
                      controller.newPasswordController.text,
                    ),
                  ),
                ),
                SizedBox(height: 40.h),

                // Change Password Button
                Obx(
                  () => CustomElevatedButton(
                    label: 'Change Password',
                    onPressed: controller.changePassword,
                    isLoading: controller.isLoading.value,
                    backgroundColor: const Color(0xFF0066FF),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
