import 'package:fixpair/config/constants/image_paths.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:get/get.dart';
import 'package:fixpair/core/widgets/custom_elevated_button.dart';

class SuccessView extends StatelessWidget {
  const SuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 1. Blue Gradient Header
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
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      'Expert advice across Germany.\nWhenever you need it.',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.manrope(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFE0EFFF),
                        height: 1.4,
                      ),
                    ),
                  ),
                  SizedBox(height: 10.h),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                children: [
                  SizedBox(height: 60.h),

                  // 2. Success Icon
                  Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: const Color(0xFFFF6B00),
                        width: 2.5,
                      ),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.check_rounded,
                        size: 60.sp,
                        color: const Color(0xFFFF6B00),
                      ),
                    ),
                  ),
                  SizedBox(height: 40.h),

                  // 3. Success Text
                  Text(
                    'Success!',
                    style: GoogleFonts.manrope(
                      fontSize: 28.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1D293D),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'Congratulations! You have been\nsuccessfully authenticated',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF62748E),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 60.h),

                  // 4. Back to Login Button
                  CustomElevatedButton(
                    label: 'Back to login',
                    onPressed: () => Get.offAllNamed(AppRoutes.LOGIN),
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
                  SizedBox(height: 40.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
