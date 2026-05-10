import 'package:fixpair/config/themes/app_theme.dart';
import 'package:fixpair/core/controllers/internet_controller.dart';
import 'package:fixpair/core/widgets/custom_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

/// ===================== NO INTERNET SCREEN =====================
/// Fullscreen overlay shown when the device loses connectivity.
/// Attempts to reconnect and navigate back on retry.
class NoInternetScreen extends StatelessWidget {
  const NoInternetScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final internet = Get.find<InternetController>();

    return Scaffold(
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 80.sp,
                color: AppTheme.primaryColor,
              ),
              SizedBox(height: 24.h),
              Text(
                'No Internet Connection',
                style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8.h),
              Text(
                'Please check your internet\nconnection and try again',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: Colors.grey.shade600,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 32.h),
              SizedBox(
                width: 200.w,
                child: CustomButton(
                  text: 'Retry',
                  onPressed: () {
                    if (internet.hasInternet.value) {
                      internet.setOnline();
                      Get.back();
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
