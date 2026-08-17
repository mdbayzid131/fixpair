import 'package:fixpair/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import 'package:fixpair/modules/home/controllers/home_controller.dart';
import 'package:fixpair/core/services/auth_service.dart';
import 'package:fixpair/config/constants/api_constants.dart';
import '../../../config/routes/app_pages.dart';
import 'package:fixpair/modules/bottom_nab_bar/controllers/bottom_nab_bar.dart';

import 'package:flutter/services.dart';

class LaundryHomeScreen extends GetView<HomeController> {
  const LaundryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        body: Column(
          children: [
            // 1. Branded Gradient Header (Fixed at top, protecting the status bar)
            _buildHeader(context),

            // 2. Scrollable Body Content
            Expanded(
              child: RefreshIndicator(
                onRefresh: controller.onRefresh,
                color: const Color(0xFF0066FF),
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 16.h),

                        // 2. Upcoming Booking (if any)
                        Obx(() {
                          if (controller.confirmedBookings.isEmpty) {
                            return const SizedBox.shrink();
                          }
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionTitle('Upcoming Booking'.tr),
                              SizedBox(height: 12.h),
                              SizedBox(
                                height: 190.h,
                                child: ListView.builder(
                                  scrollDirection: Axis.horizontal,
                                  itemCount:
                                      controller.confirmedBookings.length,
                                  itemBuilder: (context, index) {
                                    final booking =
                                        controller.confirmedBookings[index];
                                    return Padding(
                                      padding: EdgeInsets.only(right: 16.w),
                                      child: SizedBox(
                                        width: 320.w,
                                        child: _buildUpcomingBooking(booking),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: 24.h),
                            ],
                          );
                        }),

                        // 3. Recommended Consultants Header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildSectionTitle(
                                  'Recommended Consultants'.tr,
                                ),
                                SizedBox(height: 2.h),
                                Text(
                                  'Top verified experts for your needs'.tr,
                                  style: GoogleFonts.manrope(
                                    fontSize: 12.sp,
                                    fontWeight: FontWeight.w500,
                                    color: const Color(0xFF64748B),
                                  ),
                                ),
                              ],
                            ),
                            GestureDetector(
                              onTap: () {
                                Get.find<BottomNavBarController>().changeTab(1);
                              },
                              child: Text(
                                'See All'.tr,
                                style: GoogleFonts.manrope(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF0066FF),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 13.h),

                        // 4. Consultants List
                        Obx(() {
                          if (controller.isLoading.value &&
                              controller.recommendedConsultants.isEmpty) {
                            return SizedBox(
                              height: 200.h,
                              child: const Center(
                                child: CircularProgressIndicator(
                                  color: Color(0xFF0066FF),
                                ),
                              ),
                            );
                          }

                          if (controller.recommendedConsultants.isEmpty) {
                            return Padding(
                              padding: EdgeInsets.symmetric(vertical: 40.h),
                              child: Center(
                                child: Column(
                                  children: [
                                    Icon(
                                      Icons.person_search_outlined,
                                      size: 48.sp,
                                      color: const Color(0xFF94A3B8),
                                    ),
                                    SizedBox(height: 12.h),
                                    Text(
                                      'No recommended consultants found'.tr,
                                      style: GoogleFonts.manrope(
                                        fontSize: 14.sp,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFF64748B),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }

                          return ListView.builder(
                            padding: EdgeInsets.zero,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: controller.recommendedConsultants.length,
                            itemBuilder: (context, index) {
                              final consultant =
                                  controller.recommendedConsultants[index];
                              return Padding(
                                padding: EdgeInsets.only(bottom: 16.h),
                                child: _buildExpertCard(consultant),
                              );
                            },
                          );
                        }),
                        SizedBox(height: 100.h), // Spacing for navbar
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(
        top: topPadding > 0 ? topPadding + 8.h : 44.h,
        bottom: 16.h,
        left: 16.w,
        right: 16.w,
      ),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0066FF), Color(0xFF0052D1)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(24.r),
          bottomRight: Radius.circular(24.r),
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0x260066FF),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: White Badge Logo + Brand Name & Notification
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(7.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.08),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Image.asset(
                      'assets/logos/app_logo_without_bg.png',
                      height: 26.h,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Text(
                    'Fixpair',
                    style: GoogleFonts.manrope(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),

              // Notification Action
              Obx(
                () => Stack(
                  clipBehavior: Clip.none,
                  children: [
                    InkWell(
                      onTap: () =>
                          Get.toNamed(AppRoutes.NOTIFICATIONS)?.then((_) {
                            controller.checkUnreadNotifications();
                          }),
                      borderRadius: BorderRadius.circular(24.r),
                      child: Container(
                        padding: EdgeInsets.all(9.w),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withOpacity(0.25),
                            width: 1,
                          ),
                        ),
                        child: Icon(
                          Icons.notifications_none_rounded,
                          color: Colors.white,
                          size: 22.sp,
                        ),
                      ),
                    ),
                    if (controller.hasUnreadNotifications.value)
                      Positioned(
                        top: 2.h,
                        right: 2.w,
                        child: Container(
                          width: 10.w,
                          height: 10.w,
                          decoration: BoxDecoration(
                            color: const Color(0xFFEF4444),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white,
                              width: 1.5.w,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 14.h),

          // Subtitle Banner: Expert Advice
          Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.12),
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: Colors.white.withOpacity(0.15),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_rounded,
                  color: const Color(0xFFFFB800),
                  size: 20.sp,
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    'Expert advice across Germany. Whenever you need it.'.tr,
                    style: GoogleFonts.manrope(
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFFF1F5F9),
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.manrope(
        fontSize: 18.sp,
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1D293D),
      ),
    );
  }
}

Widget _buildUpcomingBooking(BookingModel booking) {
  final expert = booking.consultant;
  final imageUrl = ApiConstants.getImageUrl(expert?.image);

  // Format date and time
  String timeStr = 'N/A';
  if (booking.bookingType?.toLowerCase() == 'instant') {
    timeStr = 'Instant'.tr;
  } else if (booking.date != null && booking.startTime != null) {
    final now = DateTime.now();
    final date = booking.date!;
    final isToday =
        date.year == now.year && date.month == now.month && date.day == now.day;

    if (isToday) {
      timeStr = '${'Today'.tr}, ${booking.startTime}';
    } else {
      timeStr = '${DateFormat('MMM dd').format(date)}, ${booking.startTime}';
    }
  } else if (booking.startTime != null) {
    timeStr = '${'Today'.tr}, ${booking.startTime}';
  }

  return Container(
    padding: EdgeInsets.all(20.w),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF0066FF), Color(0xFF0052CC)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(24.r),
      boxShadow: [
        BoxShadow(
          color: const Color(0x330066FF),
          blurRadius: 20,
          offset: const Offset(0, 10),
        ),
      ],
    ),
    child: Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 48.w,
                  height: 48.w,
                  decoration: const BoxDecoration(
                    color: Color(0x33FFFFFF),
                    shape: BoxShape.circle,
                  ),
                  child: ClipOval(
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            ),
                            errorWidget: (context, url, error) =>
                                const Icon(Icons.person, color: Colors.white),
                          )
                        : const Icon(Icons.person, color: Colors.white),
                  ),
                ),
                SizedBox(width: 12.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expert?.name ?? 'Consultant',
                      style: GoogleFonts.manrope(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      expert?.tags ?? 'Expert Consultation',
                      style: GoogleFonts.manrope(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xCCFFFFFF),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: EdgeInsets.all(8.w),
              decoration: BoxDecoration(
                color: const Color(0x33FFFFFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.videocam_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
            ),
          ],
        ),
        SizedBox(height: 20.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: const Color(0x1AFFFFFF),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time_filled_rounded,
                    color: const Color(0xFFFF6B00),
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    timeStr,
                    style: GoogleFonts.manrope(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              GestureDetector(
                onTap: () {
                  Get.toNamed(
                    AppRoutes.CONSULTANT_CONFIRMATION,
                    arguments: booking,
                  );
                },

                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF6B00),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: Text(
                    'Join'.tr,
                    style: GoogleFonts.manrope(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildExpertCard(UserData consultant) {
  final isOnline = consultant.activeStatus ?? false;
  final imageUrl = ApiConstants.getImageUrl(
    consultant.image ?? consultant.avatar,
  );

  final consultancyType =
      (consultant.consultancyType != null &&
          consultant.consultancyType!.isNotEmpty)
      ? (consultant.consultancyType![0].toUpperCase() +
            consultant.consultancyType!.substring(1))
      : null;

  final experience =
      (consultant.experience != null &&
          consultant.experience!.trim().isNotEmpty)
      ? (consultant.experience!.toLowerCase().contains("exp")
            ? consultant.experience!
            : (consultant.experience!.toLowerCase().contains("year") ||
                      consultant.experience!.toLowerCase().contains("month")
                  ? "${consultant.experience!} exp."
                  : "${consultant.experience!}+ years exp."))
      : null;

  final infoText = [
    if (consultancyType != null) consultancyType,
    if (experience != null) experience,
  ].join('  •  ');

  return GestureDetector(
    onTap: () =>
        Get.toNamed(AppRoutes.CONSULTANT_PROFILE, arguments: consultant),
    child: Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF0F172A).withOpacity(0.04),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            // Left: Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(24.r),
                    bottomLeft: Radius.circular(24.r),
                  ),
                  child: Container(
                    width: 110.w,
                    constraints: BoxConstraints(minHeight: 110.h),
                    child: imageUrl.isNotEmpty
                        ? CachedNetworkImage(
                            imageUrl: imageUrl,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: const Color(0xFFF1F5F9),
                              child: const Center(
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              ),
                            ),
                            errorWidget: (context, url, error) => Container(
                              color: const Color(0xFFF1F5F9),
                              child: Icon(
                                Icons.person_rounded,
                                size: 40.sp,
                                color: const Color(0xFF94A3B8),
                              ),
                            ),
                          )
                        : Container(
                            color: const Color(0xFFF1F5F9),
                            child: Icon(
                              Icons.person_rounded,
                              size: 40.sp,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                  ),
                ),

                Positioned(
                  bottom: 10.h,
                  left: 10.w,
                  right: 10.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.6),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star_rounded,
                          color: const Color(0xFFFF6B00),
                          size: 14.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          '${consultant.stats?.avgRating ?? 0.0} (${consultant.stats?.totalReviews ?? 0})',
                          style: GoogleFonts.manrope(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Right: Info
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            consultant.name ?? 'No Name',
                            style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1E293B),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (consultant.activeTag != null &&
                            consultant.activeTag!.isNotEmpty) ...[
                          SizedBox(width: 8.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFFFFF3EB),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              consultant.activeTag!.toUpperCase(),
                              style: GoogleFonts.manrope(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFFFF6B00),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    if (infoText.isNotEmpty) ...[
                      SizedBox(height: 4.h),
                      Text(
                        infoText,
                        style: GoogleFonts.manrope(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                    SizedBox(height: 10.h),
                    _buildExpertiseChips(consultant.expertiseList),
                    const Spacer(),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        RichText(
                          text: TextSpan(
                            style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF0F172A),
                            ),
                            children: [
                              TextSpan(
                                text: '${consultant.perMinuteRate ?? 0}€',
                                style: const TextStyle(
                                  color: Color(0xFF0066FF),
                                ),
                              ),
                              TextSpan(
                                text: '/min',
                                style: TextStyle(
                                  fontSize: 12.sp,
                                  color: const Color(0xFF94A3B8),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: isOnline
                                ? const Color(0xFFDCFCE7)
                                : const Color(0xFFF1F5F9),
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Text(
                            isOnline ? 'Available'.tr : 'Offline'.tr,
                            style: GoogleFonts.manrope(
                              fontSize: 11.sp,
                              fontWeight: FontWeight.w800,
                              color: isOnline
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

Widget _buildExpertiseChips(List<String>? expertiseList) {
  if (expertiseList == null || expertiseList.isEmpty) {
    return const SizedBox.shrink();
  }

  final items = expertiseList.where((e) => e.trim().isNotEmpty).toList();
  if (items.isEmpty) return const SizedBox.shrink();

  const int maxChips = 2;
  final showMore = items.length > maxChips;
  final displayItems = showMore ? items.take(maxChips).toList() : items;

  return Wrap(
    spacing: 6.w,
    runSpacing: 4.h,
    children: [
      ...displayItems.map(
        (item) => Container(
          padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            item,
            style: GoogleFonts.manrope(
              fontSize: 11.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF475569),
            ),
          ),
        ),
      ),
      if (showMore)
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Text(
            '+${items.length - maxChips}',
            style: GoogleFonts.manrope(
              fontSize: 11.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF0066FF),
            ),
          ),
        ),
    ],
  );
}
