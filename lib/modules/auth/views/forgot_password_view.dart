import 'package:fixpair/config/constants/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:fixpair/core/widgets/custom_elevated_button.dart';
import 'package:fixpair/core/widgets/custom_text_field.dart';
import '../../../core/utils/validators.dart';
import '../controllers/forgot_password_controller.dart';

class ForgotPasswordView extends GetView<ForgotPasswordController> {
  const ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Form(
          key: controller.formKey,
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
                          'Password Recovery',
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
                    SizedBox(height: 48.h),

                    // 2. Title Section
                    Text(
                      'Forgot password?',
                      style: GoogleFonts.manrope(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D293D),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      'Enter your email address to get a reset link.',
                      style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF6B7280),
                      ),
                    ),
                    SizedBox(height: 32.h),

                    SizedBox(height: 32.h),

                    // 4. Input Field
                    CustomTextField(
                      controller: controller.emailController,
                      hintText: 'name@example.com',
                      keyboardType: TextInputType.emailAddress,
                      validator: Validators.email,
                      label: '',
                      isLabelVisible: false,
                      fillColior: const Color(0xFFF8FAFC),
                      prefixIcon: Icon(
                        Icons.mail_outline_rounded,
                        color: const Color(0xFF9CA3AF),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(height: 48.h),

                    // 5. Send Button
                    Obx(
                      () => CustomElevatedButton(
                        label: 'Send Reset Link',
                        onPressed: controller.sendResetLink,
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
                    SizedBox(height: 48.h),

                    // 6. Login Link
                    Center(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Remember your password? ",
                            style: GoogleFonts.manrope(
                              fontSize: 14.sp,
                              color: const Color(0xFF4B5563),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Get.back(),
                            child: Text(
                              'Log in',
                              style: GoogleFonts.manrope(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0066FF),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 32.h),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
