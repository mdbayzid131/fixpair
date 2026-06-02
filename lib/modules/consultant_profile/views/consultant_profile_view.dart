import 'package:fixpair/config/constants/api_constants.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/models/review_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/consultant_profile_controller.dart';
import 'see_all_reviews_view.dart';

class ConsultantProfileView extends GetView<ConsultantProfileController> {
  const ConsultantProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
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
          'Consultant Profile',
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
        actions: [
          Stack(
            alignment: Alignment.center,
            children: [
              IconButton(
                icon: Icon(
                  Icons.notifications_none_rounded,
                  color: const Color(0xFF1D293D),
                  size: 24.sp,
                ),
                onPressed: () {},
              ),
              Positioned(
                top: 14.h,
                right: 14.w,
                child: Container(
                  width: 8.w,
                  height: 8.w,
                  decoration: const BoxDecoration(
                    color: Color(0xFFFF6B00),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator());
        }

        final UserData? expert = controller.expert.value;
        if (expert == null) {
          return const Center(child: Text('Consultant not found'));
        }

        return SingleChildScrollView(
          padding: EdgeInsets.only(bottom: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              SizedBox(height: 24.h),
              _buildProfileHeader(expert),
              SizedBox(height: 24.h),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              _buildStatsRow(expert),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              SizedBox(height: 24.h),
              _buildAboutSection(expert),
              SizedBox(height: 24.h),
              const Divider(height: 1, color: Color(0xFFF1F5F9)),
              SizedBox(height: 24.h),
              _buildReviewsSection(),
            ],
          ),
        );
      }),
      bottomNavigationBar: Obx(() {
        final expert = controller.expert.value;
        if (expert == null) return const SizedBox.shrink();
        return _buildBottomAction(expert);
      }),
    );
  }

  Widget _buildProfileHeader(UserData expert) {
    final imageUrl = ApiConstants.getImageUrl(expert.image ?? expert.avatar);
    final isOnline = expert.activeStatus ?? false;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 100.w,
                height: 100.w,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24.r),
                  color: const Color(0xFFF1F5F9),
                  image: imageUrl.isNotEmpty
                      ? DecorationImage(
                          image: NetworkImage(imageUrl),
                          fit: BoxFit.cover,
                        )
                      : null,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: imageUrl.isEmpty
                    ? Icon(Icons.person, size: 40.sp, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 4.h,
                right: 4.w,
                child: Container(
                  width: 18.w,
                  height: 18.w,
                  decoration: BoxDecoration(
                    color: isOnline ? const Color(0xFF10B981) : Colors.grey,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(width: 20.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _buildBadge(
                      expert.consultancyType?.toString().toUpperCase() ??
                          'CONSULTANT',
                      const Color(0xFFE0EFFF),
                      const Color(0xFF0066FF),
                    ),
                    SizedBox(width: 8.w),
                    _buildBadge(
                      isOnline ? 'ONLINE' : 'OFFLINE',
                      isOnline
                          ? const Color(0xFFDCFCE7)
                          : const Color(0xFFF1F5F9),
                      isOnline
                          ? const Color(0xFF10B981)
                          : const Color(0xFF64748B),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        expert.name ?? 'No Name',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 22.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF1D293D),
                        ),
                      ),
                    ),
                    if (expert.verified == true) ...[
                      SizedBox(width: 8.w),
                      Icon(
                        Icons.verified_rounded,
                        color: const Color(0xFF0066FF),
                        size: 20.sp,
                      ),
                    ],
                  ],
                ),
                Text(
                  expert.tags ?? 'General Consultant',
                  style: GoogleFonts.manrope(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                  ),
                ),
                SizedBox(height: 12.h),
                Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 10.w,
                        vertical: 4.h,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFFF7ED),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: const Color(0xFFF59E0B),
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Obx(() {
                            final stats = controller.stats.value;
                            return Row(
                              children: [
                                Text(
                                  '${stats?.avgRating ?? expert.stats?.avgRating ?? 0.0} ',
                                  style: GoogleFonts.manrope(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w700,
                                    color: const Color(0xFF1D293D),
                                  ),
                                ),
                                Text(
                                  '(${stats?.totalReviews ?? expert.stats?.totalReviews ?? 0})',
                                  style: GoogleFonts.manrope(
                                    fontSize: 13.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            );
                          }),
                        ],
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Text(
                      '${expert.perMinuteRate ?? 0}€/min',
                      style: GoogleFonts.manrope(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D293D),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String label, Color bgColor, Color textColor) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(6.r),
      ),
      child: Text(
        label,
        style: GoogleFonts.manrope(
          fontSize: 10.sp,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  Widget _buildStatsRow(UserData expert) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              Icons.workspace_premium_outlined,
              'EXPERIENCE',
              expert.experience ?? 'N/A',
              const Color(0xFFE0EFFF),
              const Color(0xFF0066FF),
            ),
          ),
          Container(height: 40.h, width: 1, color: const Color(0xFFF1F5F9)),
          Expanded(
            child: Obx(() {
              final totalReviews =
                  controller.stats.value?.totalReviews ??
                  expert.stats?.totalReviews ??
                  0;
              return _buildStatItem(
                Icons.chat_bubble_outline_rounded,
                'CONSULTATIONS',
                '$totalReviews+',
                const Color(0xFFF5F3FF),
                const Color(0xFF7C3AED),
              );
            }),
          ),
          Container(height: 40.h, width: 1, color: const Color(0xFFF1F5F9)),
          Expanded(
            child: _buildStatItem(
              Icons.translate_rounded,
              'LANGUAGES',
              (expert.languages != null && expert.languages!.isNotEmpty)
                  ? (expert.languages!.length > 1
                        ? '${expert.languages!.first} +${expert.languages!.length - 1}'
                        : expert.languages!.first.toString())
                  : 'N/A',
              const Color(0xFFECFDF5),
              const Color(0xFF059669),
              onTap: (expert.languages != null && expert.languages!.length > 1)
                  ? () => _showLanguagesDialog(expert.languages!)
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(
    IconData icon,
    String label,
    String value,
    Color iconBg,
    Color iconColor, {
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(color: iconBg, shape: BoxShape.circle),
            child: Icon(icon, color: iconColor, size: 20.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            label,
            style: GoogleFonts.manrope(
              fontSize: 10.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF94A3B8),
              letterSpacing: 0.5,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            value,
            style: GoogleFonts.manrope(
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF334155),
            ),
          ),
        ],
      ),
    );
  }

  void _showLanguagesDialog(List<dynamic> languages) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(24.w),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Spoken Languages',
                style: GoogleFonts.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1D293D),
                ),
              ),
              SizedBox(height: 16.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: languages.map((lang) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 6.h,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F5F9),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Text(
                      lang.toString(),
                      style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF475569),
                      ),
                    ),
                  );
                }).toList(),
              ),
              SizedBox(height: 24.h),
              SizedBox(
                width: double.infinity,
                child: TextButton(
                  onPressed: () => Get.back(),
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    backgroundColor: const Color(0xFF0066FF),
                  ),
                  child: Text(
                    'Close',
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSection(UserData expert) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'About Expert',
            style: GoogleFonts.manrope(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1D293D),
            ),
          ),
          SizedBox(height: 16.h),
          Obx(() {
            final isExpanded = controller.isAboutExpanded.value;
            final aboutText =
                expert.expertise ??
                'No detailed information available for this consultant yet.';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  aboutText,
                  maxLines: isExpanded ? null : 3,
                  overflow: isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF64748B),
                    height: 1.6,
                  ),
                ),
                if (aboutText.length > 100) ...[
                  SizedBox(height: 8.h),
                  InkWell(
                    onTap: () => controller.toggleAboutExpansion(),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          isExpanded ? 'Read less' : 'Read more',
                          style: GoogleFonts.manrope(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0066FF),
                          ),
                        ),
                        Icon(
                          isExpanded
                              ? Icons.keyboard_arrow_up_rounded
                              : Icons.chevron_right_rounded,
                          color: const Color(0xFF0066FF),
                          size: 18.sp,
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildReviewsSection() {
    return Obx(() {
      final total = controller.stats.value?.totalReviews ?? 0;
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Reviews',
                  style: GoogleFonts.manrope(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D293D),
                  ),
                ),
                if (total > 0)
                  GestureDetector(
                    onTap: () => Get.to(
                      () => SeeAllReviewsView(
                        consultantId: controller.expert.value!.id!,
                      ),
                    ),
                    behavior: HitTestBehavior.opaque,
                    child: Text(
                      'See all $total',
                      style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF0066FF),
                      ),
                    ),
                  ),
              ],
            ),
            SizedBox(height: 16.h),

            if (controller.isLoadingReviews.value)
              const Center(child: CircularProgressIndicator())
            else if (controller.consultantReviews.isEmpty)
              Padding(
                padding: EdgeInsets.symmetric(vertical: 20.h),
                child: Center(
                  child: Text(
                    'No reviews yet',
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                ),
              )
            else
              Column(
                children: controller.consultantReviews
                    .take(3)
                    .map(
                      (review) => Padding(
                        padding: EdgeInsets.only(bottom: 12.h),
                        child: _buildReviewCard(review),
                      ),
                    )
                    .toList(),
              ),

            SizedBox(height: 40.h),
          ],
        ),
      );
    });
  }

  Widget _buildReviewCard(ReviewModel review) {
    final imageUrl = ApiConstants.getImageUrl(review.user?.image);
    final ratingCount = (review.rating ?? 5.0).toInt();

    String timeStr = 'Some time ago';
    if (review.createdAt != null) {
      final difference = DateTime.now().difference(review.createdAt!);
      if (difference.inDays == 0) {
        timeStr = 'Today';
      } else if (difference.inDays == 1) {
        timeStr = '1 day ago';
      } else if (difference.inDays < 7) {
        timeStr = '${difference.inDays} days ago';
      } else {
        timeStr = DateFormat('MMM dd, yyyy').format(review.createdAt!);
      }
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: const Color(0xFFE2E8F0),
                backgroundImage: imageUrl.isNotEmpty
                    ? NetworkImage(imageUrl)
                    : null,
                child: imageUrl.isEmpty
                    ? const Icon(Icons.person, color: Color(0xFF64748B))
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.user?.name ?? 'Anonymous User',
                      style: GoogleFonts.manrope(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF1D293D),
                      ),
                    ),
                    Text(
                      timeStr,
                      style: GoogleFonts.manrope(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                  5,
                  (index) => Icon(
                    Icons.star_rounded,
                    color: index < ratingCount
                        ? const Color(0xFFF59E0B)
                        : const Color(0xFFE2E8F0),
                    size: 16.sp,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            review.comment ?? 'No comment provided.',
            style: GoogleFonts.manrope(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF64748B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomAction(UserData expert) {
    final isOnline = expert.activeStatus ?? false;
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, -10),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 16.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 12.w,
                        height: 12.w,
                        decoration: BoxDecoration(
                          color: isOnline ? const Color(0xFF10B981) : Colors.grey,
                          shape: BoxShape.circle,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      Text(
                        isOnline
                            ? 'Available for instant call'
                            : 'Currently Offline',
                        style: GoogleFonts.manrope(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF475569),
                        ),
                      ),
                    ],
                  ),
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: '${expert.perMinuteRate ?? 0}€',
                          style: GoogleFonts.manrope(
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1D293D),
                          ),
                        ),
                        TextSpan(
                          text: '/min',
                          style: GoogleFonts.manrope(
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                height: 56.h,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isOnline
                        ? [const Color(0xFFFF6B00), const Color(0xFFFF8A00)]
                        : [Colors.grey.shade400, Colors.grey.shade500],
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: isOnline
                      ? [
                          BoxShadow(
                            color: const Color(0xFFFF6B00).withValues(alpha: 0.3),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ]
                      : [],
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: isOnline
                        ? () => Get.toNamed(
                            AppRoutes.CONSULTANT_BOOKING,
                            arguments: expert,
                          )
                        : null,
                    borderRadius: BorderRadius.circular(16.r),
                    child: Center(
                      child: Text(
                        isOnline ? 'Book Consultation' : 'Unavailable',
                        style: GoogleFonts.manrope(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
