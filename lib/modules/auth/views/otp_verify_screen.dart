import 'package:fixpair/config/constants/image_paths.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fixpair/core/widgets/custom_elevated_button.dart';
import 'package:pinput/pinput.dart';
import '../controllers/oto_controller.dart';

class OtpVerifyScreen extends GetView<OtpController> {
  const OtpVerifyScreen({super.key});

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
                        'OTP Verification',
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 48.h),

                  // 2. Title Section
                  Text(
                    'Verify OTP',
                    style: GoogleFonts.manrope(
                      fontSize: 24.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1D293D),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Text(
                    "Enter the 6-digit code sent to your\n${controller.email}",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w400,
                      color: const Color(0xFF6B7280),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // 3. OTP Input
                  Pinput(
                    controller: controller.otpController,
                    length: 6,
                    separatorBuilder: (index) => SizedBox(width: 12.w),
                    defaultPinTheme: PinTheme(
                      width: 48.w,
                      height: 56.h,
                      textStyle: GoogleFonts.manrope(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D293D),
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF8FAFC),
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFE2E8F0)),
                      ),
                    ),
                    focusedPinTheme: PinTheme(
                      width: 48.w,
                      height: 56.h,
                      textStyle: GoogleFonts.manrope(
                        fontSize: 20.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D293D),
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12.r),
                        border: Border.all(color: const Color(0xFFFF6B00), width: 1.5),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFFFF6B00).withOpacity(0.1),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // 4. Verify Button
                  Obx(
                    () => CustomElevatedButton(
                      label: 'Verify',
                      onPressed: () => controller.verifyOtp(),
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
                  SizedBox(height: 32.h),

                  // 5. Timer & Resend
                  Text(
                    "Didn't receive the code?",
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      color: const Color(0xFF6B7280),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Obx(
                    () => controller.isResendEnabled.value
                        ? GestureDetector(
                            onTap: () => controller.resendOtp(),
                            child: Text(
                              'Resend Code',
                              style: GoogleFonts.manrope(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: const Color(0xFF0066FF),
                              ),
                            ),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Resend in ',
                                style: GoogleFonts.manrope(
                                  fontSize: 14.sp,
                                  color: const Color(0xFF9CA3AF),
                                ),
                              ),
                              Obx(() {
                                final minutes = (controller.remainingSeconds.value ~/ 60)
                                    .toString()
                                    .padLeft(2, '0');
                                final seconds = (controller.remainingSeconds.value % 60)
                                    .toString()
                                    .padLeft(2, '0');
                                return Text(
                                  '$minutes:$seconds',
                                  style: GoogleFonts.manrope(
                                    fontSize: 14.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFFFF6B00),
                                  ),
                                );
                              }),
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
    );
  }
}
