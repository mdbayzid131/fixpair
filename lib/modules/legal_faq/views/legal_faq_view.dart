import 'package:fixpair/config/routes/app_pages.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/legal_faq_controller.dart';

class LegalFAQView extends GetView<LegalFAQController> {
  const LegalFAQView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            Icons.chevron_left_rounded,
            color: const Color(0xFF1D293D),
            size: 28.sp,
          ),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Legal & FAQ',
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('FREQUENTLY ASKED QUESTIONS'),
            SizedBox(height: 16.h),
            _buildFAQCard(),
            SizedBox(height: 32.h),
            _buildSectionHeader('LEGAL'),
            SizedBox(height: 16.h),
            _buildLegalCard(),
            SizedBox(height: 24.h),
            _buildActionCard(
              icon: Icons.support_agent_rounded,
              label: 'Contact Support',
              onTap: () {},
            ),
            SizedBox(height: 16.h),
            _buildActionCard(
              icon: Icons.delete_outline_rounded,
              label: 'Delete Account',
              labelColor: const Color(0xFFEF4444),
              iconBg: const Color(0xFFFEF2F2),
              iconColor: const Color(0xFFEF4444),
              onTap: () {},
            ),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 13.sp,
        fontWeight: FontWeight.w800,
        letterSpacing: 0.5,
        color: const Color(0xFF1D293D),
      ),
    );
  }

  Widget _buildFAQCard() {
    return Obx(() {
      if (controller.isLoading.value) {
        return const Center(child: CircularProgressIndicator());
      }
      if (controller.faqItems.isEmpty) {
        return Center(
          child: Padding(
            padding: EdgeInsets.all(20.w),
            child: Text(
              'No FAQs available',
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
            ),
          ),
        );
      }
      return Container(
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
          children: List.generate(controller.faqItems.length, (index) {
            final item = controller.faqItems[index];
            final isExpanded = controller.expandedStates[index];
            final isLast = index == controller.faqItems.length - 1;

            return Column(
              children: [
                Theme(
                  data: Theme.of(
                    Get.context!,
                  ).copyWith(dividerColor: Colors.transparent),
                  child: ExpansionTile(
                    onExpansionChanged: (expanded) =>
                        controller.toggleExpanded(index),
                    initiallyExpanded: isExpanded,
                    key: PageStorageKey(
                      'faq_${item.id}',
                    ), // Use item.id to maintain state correctly
                    maintainState: true,
                    title: Text(
                      item.question ?? '',
                      style: GoogleFonts.manrope(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D293D),
                      ),
                    ),
                    trailing: AnimatedRotation(
                      duration: const Duration(milliseconds: 200),
                      turns: isExpanded ? 0.25 : 0,
                      child: Icon(
                        Icons.chevron_right_rounded,
                        color: const Color(0xFF94A3B8),
                        size: 24.sp,
                      ),
                    ),
                    children: [
                      Padding(
                        padding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 20.h),
                        child: Text(
                          item.answer ?? '',
                          style: GoogleFonts.manrope(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF64748B),
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isLast)
                  const Divider(
                    height: 1,
                    color: Color(0xFFF1F5F9),
                    indent: 16,
                    endIndent: 16,
                  ),
              ],
            );
          }),
        ),
      );
    });
  }

  Widget _buildLegalCard() {
    return Container(
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
        children: [
          _buildLegalItem(
            icon: Icons.description_outlined,
            label: 'Terms and Conditions',
            onTap: () => Get.toNamed(AppRoutes.TERMS_CONDITIONS),
          ),
          const Divider(
            height: 1,
            color: Color(0xFFF1F5F9),
            indent: 64,
            endIndent: 20,
          ),
          _buildLegalItem(
            icon: Icons.description_outlined,
            label: 'Privacy Policy (GDPR)',
            onTap: () => Get.toNamed(AppRoutes.PRIVACY_POLICY),
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildLegalItem({
    required IconData icon,
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
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF64748B), size: 22.sp),
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF334155),
                ),
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: const Color(0xFFCBD5E1),
              size: 24.sp,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? labelColor,
    Color? iconColor,
    Color? iconBg,
  }) {
    return Container(
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
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.r),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 18.h),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(10.w),
                decoration: BoxDecoration(
                  color: iconBg ?? const Color(0xFFF8FAFC),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  icon,
                  color: iconColor ?? const Color(0xFF64748B),
                  size: 22.sp,
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Text(
                  label,
                  style: GoogleFonts.manrope(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: labelColor ?? const Color(0xFF1D293D),
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: const Color(0xFFCBD5E1),
                size: 24.sp,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
