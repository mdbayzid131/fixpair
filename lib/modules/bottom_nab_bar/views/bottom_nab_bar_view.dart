import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/bottom_nab_bar.dart';
import '../../home/views/home_view.dart';
import '../../search/views/search_view.dart';
import '../../history/views/history_view.dart';
import '../../profile/views/profile_view.dart';

class BottomNavBarView extends GetView<BottomNavBarController> {
  const BottomNavBarView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      extendBody: true,
      body: Obx(
        () => IndexedStack(
          index: controller.currentIndex.value,
          children: [
            const LaundryHomeScreen(),
            const SearchView(),
            const HistoryView(),
            const ProfileView(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: Container(
          color: Colors.transparent,
          margin: EdgeInsets.only(left: 16.w, right: 16.w, bottom: 4.h),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24.r),
              border: Border.all(color: const Color(0xFFE2E8F0), width: 1.2),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0F172A).withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: const Color(0xFF0066FF).withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Obx(
              () => Row(
                children: [
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    activeIcon: Icons.home_rounded,
                    label: 'Home'.tr,
                    index: 0,
                    currentIndex: controller.currentIndex.value,
                  ),
                  _buildNavItem(
                    icon: Icons.search_rounded,
                    activeIcon: Icons.search_rounded,
                    label: 'Search'.tr,
                    index: 1,
                    currentIndex: controller.currentIndex.value,
                  ),
                  _buildNavItem(
                    icon: Icons.calendar_month_outlined,
                    activeIcon: Icons.calendar_month_rounded,
                    label: 'Bookings'.tr,
                    index: 2,
                    currentIndex: controller.currentIndex.value,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline_rounded,
                    activeIcon: Icons.person_rounded,
                    label: 'Profile'.tr,
                    index: 3,
                    currentIndex: controller.currentIndex.value,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required IconData activeIcon,
    required String label,
    required int index,
    required int currentIndex,
  }) {
    final isSelected = index == currentIndex;

    return Expanded(
      child: GestureDetector(
        onTap: () => controller.changeTab(index),
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Fixed-dimension Capsule with Smooth Color Transition
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              curve: Curves.easeOutCubic,
              width: 50.w,
              height: 32.h,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF0066FF)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: const Color(0xFF0066FF).withOpacity(0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : [],
              ),
              child: Center(
                child: AnimatedScale(
                  scale: isSelected ? 1.05 : 1.0,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOutCubic,
                  child: Icon(
                    isSelected ? activeIcon : icon,
                    color: isSelected ? Colors.white : const Color(0xFF94A3B8),
                    size: 22.sp,
                  ),
                ),
              ),
            ),
            SizedBox(height: 4.h),

            // Label Text
            Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 11.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected
                    ? const Color(0xFF0066FF)
                    : const Color(0xFF64748B),
                letterSpacing: 0.2,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
