import 'package:fixpair/config/constants/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fixpair/core/widgets/custom_elevated_button.dart';
import 'package:fixpair/core/widgets/custom_text_field.dart';
import '../controllers/set_new_pass_controller.dart';

class SetNewPasswordScreen extends GetView<SetNewPassController> {
  const SetNewPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Blue Gradient Header with Back Button
            Stack(
              children: [
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 30.h),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [Color(0xFF9799B4), Color(0xFF80A4DC)],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(40.r),
                      bottomRight: Radius.circular(40.r),
                    ),
                  ),
                  child: Column(
                    children: [
                      SizedBox(height: 20.h),
                      Image.asset(ImagePaths.appLogo, height: 80.h),
                      SizedBox(height: 12.h),
                      Text(
                        'Fixpair',
                        style: GoogleFonts.manrope(
                          fontSize: 32.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'Set New Password',
                        style: GoogleFonts.manrope(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFE0EFFF),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 10.h),
                    ],
                  ),
                ),
                Positioned(
                  top: 50.h,
                  left: 20.w,
                  child: GestureDetector(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(height: 40.h),

                  // 2. Title Section
                  Text(
                    'Create New Password',
                    style: GoogleFonts.manrope(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1D293D),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Choose a strong password to secure your account.",
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 32.h),

                  // 3. Password Fields
                  Obx(
                    () => CustomTextField(
                      controller: controller.newPasswordController,
                      hintText: 'New Password',
                      onChanged: controller.validatePasswordRules,
                      obscureText: !controller.isPasswordVisible.value,
                      fillColor: const Color(0xFFF8FAFC),
                      isLabelVisible: false,
                      label: '',
                      prefixIcon: Icon(
                        Icons.lock_outline_rounded,
                        color: const Color(0xFF9CA3AF),
                        size: 20.sp,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: controller.togglePasswordVisibility,
                        child: Icon(
                          controller.isPasswordVisible.value
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: const Color(0xFF9CA3AF),
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Obx(
                    () => CustomTextField(
                      controller: controller.confirmPasswordController,
                      hintText: 'Confirm Password',
                      obscureText: !controller.isConfirmPasswordVisible.value,
                      fillColor: const Color(0xFFF8FAFC),
                      isLabelVisible: false,
                      label: '',
                      prefixIcon: Icon(
                        Icons.lock_reset_rounded,
                        color: const Color(0xFF9CA3AF),
                        size: 20.sp,
                      ),
                      suffixIcon: GestureDetector(
                        onTap: controller.toggleConfirmPasswordVisibility,
                        child: Icon(
                          controller.isConfirmPasswordVisible.value
                              ? Icons.visibility_rounded
                              : Icons.visibility_off_rounded,
                          color: const Color(0xFF9CA3AF),
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // 4. Password Requirements
                  // Container(
                  //   width: double.infinity,
                  //   padding: EdgeInsets.all(16.w),
                  //   decoration: BoxDecoration(
                  //     color: const Color(0xFFF8FAFC),
                  //     borderRadius: BorderRadius.circular(12.r),
                  //     border: Border.all(color: const Color(0xFFE2E8F0)),
                  //   ),
                  //   child: Obx(() => Column(
                  //     crossAxisAlignment: CrossAxisAlignment.start,
                  //     children: [
                  //       Text(
                  //         'Password must contain:',
                  //         style: GoogleFonts.manrope(
                  //           fontSize: 13.sp,
                  //           fontWeight: FontWeight.w700,
                  //           color: const Color(0xFF1D293D),
                  //         ),
                  //       ),
                  //       SizedBox(height: 12.h),
                  //       _buildRequirementRow(controller.hasMinLength.value, 'At least 8 characters'),
                  //       SizedBox(height: 8.h),
                  //       _buildRequirementRow(controller.hasUppercase.value, 'One uppercase letter'),
                  //       SizedBox(height: 8.h),
                  //       _buildRequirementRow(
                  //         controller.hasNumberOrSpecial.value,
                  //         'One number or special character',
                  //       ),
                  //     ],
                  //   )),
                  // ),
                  // SizedBox(height: 40.h),

                  // 5. Save Button
                  Obx(
                    () => CustomElevatedButton(
                      label: 'Save Password',
                      onPressed: controller.submitNewPassword,
                      isLoading: controller.isLoading.value,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF6B00),
                        minimumSize: Size(double.infinity, 56.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 8,
                        shadowColor: const Color(0xFFFF6B00).withOpacity(0.4),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRequirementRow(bool isMet, String text) {
    return Row(
      children: [
        Icon(
          isMet
              ? Icons.check_circle_rounded
              : Icons.radio_button_unchecked_rounded,
          color: isMet ? const Color(0xFF10B981) : const Color(0xFF9CA3AF),
          size: 18.sp,
        ),
        SizedBox(width: 10.w),
        Text(
          text,
          style: GoogleFonts.manrope(
            fontSize: 13.sp,
            fontWeight: isMet ? FontWeight.w600 : FontWeight.w400,
            color: isMet ? const Color(0xFF10B981) : const Color(0xFF6B7280),
          ),
        ),
      ],
    );
  }
}
