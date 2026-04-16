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
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: const Color(0xFF1D293D), size: 28.sp),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Terms & Conditions',
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
      ),
      body: SingleChildScrollView(
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
              _buildSection(
                '1. General Overview',
                'Welcome to Consultly. These Terms and Conditions govern your use of our real-time consultation marketplace platform, tailored for clients in Germany. By using our app, you agree to these terms.',
              ),
              _buildSection(
                '2. Real-Time Billing & Costs',
                'Consultations are billed per minute based on the consultant\'s hourly rate. The running cost tracker will display estimated costs during the live video call. All displayed prices include the applicable statutory Value Added Tax (VAT) in Germany.',
              ),
              _buildSection(
                '3. Timezone',
                'All scheduled consultations are based on Central European Time (CET/CEST), applicable to Germany. Please ensure your availability according to this timezone.',
              ),
              _buildSection(
                '4. Cancellations',
                'You may cancel a scheduled consultation free of charge up to 24 hours before the appointment. Cancellations made within 24 hours of the start time will incur a 50% cancellation fee based on the scheduled duration.',
              ),
              _buildSection(
                '5. Liability & Dispute',
                'Consultly serves as a platform to connect clients with independent consultants. We do not hold liability for the specific advice provided by the consultants. Any disputes shall be governed by the laws of the Federal Republic of Germany.',
              ),
              SizedBox(height: 32.h),
              Text(
                'Last updated: April 1, 2026',
                style: GoogleFonts.manrope(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
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
