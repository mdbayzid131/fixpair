import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/privacy_policy_controller.dart';

class PrivacyPolicyView extends GetView<PrivacyPolicyController> {
  const PrivacyPolicyView({super.key});

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
          'Privacy Policy (GDPR)',
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
                '1. Data Collection',
                'We collect personal information such as your name, email, and payment details to provide our consultation services. We ensure your data is processed securely and in accordance with GDPR regulations.',
              ),
              _buildSection(
                '2. Use of Information',
                'Your data is used to facilitate live video calls, process payments, and improve our services. We do not sell your personal data to third parties for marketing purposes.',
              ),
              _buildSection(
                '3. Data Storage & Security',
                'All personal data is encrypted and stored on secure servers located within the European Union. We implement strict technical and organizational measures to protect your information against unauthorized access.',
              ),
              _buildSection(
                '4. Your Rights (GDPR)',
                'Under GDPR, you have the right to access, rectify, or delete your personal data. You can also request a copy of your data or object to certain processing activities by contacting our support team.',
              ),
              _buildSection(
                '5. Cookies & Tracking',
                'We use essential cookies to maintain your session and ensure the platform works correctly. Any analytics tracking is performed anonymously and requires your explicit consent.',
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
