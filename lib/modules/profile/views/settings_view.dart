import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/routes/app_pages.dart';
import '../controllers/profile_controller.dart';

class SettingsView extends GetView<ProfileController> {
  const SettingsView({super.key});

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
          'Settings'.tr,
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildMenuItem(
                    icon: Icons.lock_outline_rounded,
                    iconBg: const Color(0xFFE0EFFF),
                    iconColor: const Color(0xFF0066FF),
                    label: 'Change Password'.tr,
                    onTap: () => Get.toNamed(AppRoutes.CHANGE_PASSWORD),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFF1F5F9),
                    indent: 70,
                    endIndent: 20,
                  ),
                  _buildMenuItem(
                    icon: Icons.explore_outlined,
                    iconBg: const Color(0xFFEBE9FE),
                    iconColor: const Color(0xFF7C3AED),
                    label: 'App Guide & Tutorial'.tr,
                    onTap: () => Get.toNamed(
                      AppRoutes.ONBOARDING,
                      arguments: {'fromProfile': true},
                    ),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFF1F5F9),
                    indent: 70,
                    endIndent: 20,
                  ),
                  _buildMenuItem(
                    icon: Icons.language_rounded,
                    iconBg: const Color(0xFFE0F2FE),
                    iconColor: const Color(0xFF0284C7),
                    label: 'Language'.tr,
                    onTap: () => _showLanguageSelection(context),
                  ),
                  const Divider(
                    height: 1,
                    color: Color(0xFFF1F5F9),
                    indent: 70,
                    endIndent: 20,
                  ),
                  _buildMenuItem(
                    icon: Icons.delete_forever_outlined,
                    iconBg: const Color(0xFFFEF2F2),
                    iconColor: const Color(0xFFEF4444),
                    label: 'Delete Account'.tr,
                    onTap: () => _showDeleteConfirmation(context),
                    isLast: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: isLast
          ? BorderRadius.only(
              bottomLeft: Radius.circular(24.r),
              bottomRight: Radius.circular(24.r),
            )
          : null,
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(10.w),
              decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
              child: Icon(icon, color: iconColor, size: 22.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF1D293D),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFF94A3B8),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Container(
          padding: EdgeInsets.all(28.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF2F2), // Soft red bg
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFEF2F2).withOpacity(0.5),
                    width: 4,
                  ),
                ),
                child: Icon(
                  Icons.delete_forever_rounded,
                  color: const Color(0xFFEF4444),
                  size: 36.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Delete Account?'.tr,
                style: GoogleFonts.manrope(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1D293D),
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'Are you sure you want to delete your account? This action is permanent and cannot be undone.'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 28.h),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Get.back(),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Cancel'.tr,
                        style: GoogleFonts.manrope(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        controller.deleteAccount();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFEF4444),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Delete'.tr,
                        style: GoogleFonts.manrope(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  void _showLanguageSelection(BuildContext context) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 28.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28.r),
            topRight: Radius.circular(28.r),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Language'.tr,
              style: GoogleFonts.manrope(
                fontSize: 20.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF1D293D),
              ),
            ),
            SizedBox(height: 24.h),
            Obx(() => _buildLanguageOption(
                  title: 'English',
                  langCode: 'en',
                  isSelected: controller.currentLanguage.value == 'en',
                )),
            SizedBox(height: 16.h),
            Obx(() => _buildLanguageOption(
                  title: 'German'.tr,
                  langCode: 'de',
                  isSelected: controller.currentLanguage.value == 'de',
                )),
            SizedBox(height: 24.h),
          ],
        ),
      ),
      isDismissible: true,
      enableDrag: true,
    );
  }

  Widget _buildLanguageOption({
    required String title,
    required String langCode,
    required bool isSelected,
  }) {
    return InkWell(
      onTap: () {
        controller.setLanguage(langCode);
        Get.back();
      },
      borderRadius: BorderRadius.circular(16.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFEFF6FF) : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isSelected ? const Color(0xFF3B82F6) : Colors.transparent,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: GoogleFonts.manrope(
                fontSize: 16.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected ? const Color(0xFF1D293D) : const Color(0xFF64748B),
              ),
            ),
            if (isSelected)
              Icon(
                Icons.check_circle_rounded,
                color: const Color(0xFF3B82F6),
                size: 22.sp,
              )
            else
              Icon(
                Icons.circle_outlined,
                color: const Color(0xFFCBD5E1),
                size: 22.sp,
              ),
          ],
        ),
      ),
    );
  }
}
