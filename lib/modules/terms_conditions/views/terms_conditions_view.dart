import 'package:fixpair/core/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/terms_conditions_controller.dart';

class TermsConditionsView extends GetView<TermsConditionsController> {
  const TermsConditionsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar.build(
        title: 'Terms & Conditions'.tr,
        showBackButton: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }
        if (controller.termsConditionsItems.isEmpty) {
          return Center(
            child: Text(
              'No Terms & Conditions available'.tr,
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
            ),
          );
        }
        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          child: Container(
            padding: EdgeInsets.all(24.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ...controller.termsConditionsItems.map(
                  (item) => _buildSection(item.title ?? '', item.content ?? ''),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Last updated: '.tr + '${controller.termsConditionsItems.first.updatedAt != null ? controller.termsConditionsItems.first.updatedAt!.substring(0, 10) : 'April 1, 2026'}',
                  style: GoogleFonts.manrope(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF94A3B8),
                  ),
                ),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: GoogleFonts.manrope(
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1D293D),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            content,
            style: GoogleFonts.manrope(
              fontSize: 14.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}
