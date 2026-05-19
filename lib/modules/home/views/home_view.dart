import 'package:fixpair/data/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:fixpair/modules/home/controllers/home_controller.dart';
import 'package:fixpair/core/services/auth_service.dart';
import 'package:fixpair/config/constants/api_constants.dart';
import '../../../config/routes/app_pages.dart';
import 'package:fixpair/modules/bottom_nab_bar/controllers/bottom_nab_bar.dart';

class LaundryHomeScreen extends GetView<HomeController> {
  const LaundryHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: RefreshIndicator(
        onRefresh: controller.onRefresh,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 1. Blue Header Section
              _buildHeader(),

              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 32.h),

                    // 2. Categories Section
                    _buildSectionTitle('Categories'),
                    SizedBox(height: 12.h),
                    _buildCategories(),

                    SizedBox(height: 32.h),

                    // 3. Upcoming Booking
                    Obx(() {
                      if (controller.confirmedBookings.isEmpty) {
                        return const SizedBox.shrink();
                      }
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildSectionTitle('Upcoming Booking'),
                          SizedBox(height: 12.h),
                          SizedBox(
                            height: 190.h,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: controller.confirmedBookings.length,
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
                          SizedBox(height: 32.h),
                        ],
                      );
                    }),

                    // 4. Recommended Experts
                    _buildSectionTitle('Recommended Experts'),
                    SizedBox(height: 12.h),
                    Obx(() {
                      if (controller.isLoading.value &&
                          controller.recommendedConsultants.isEmpty) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 24),
                            child: CircularProgressIndicator(
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Color(0xFFFF6B00),
                              ),
                            ),
                          ),
                        );
                      }

                      if (controller.recommendedConsultants.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: EdgeInsets.symmetric(vertical: 32.h),
                            child: Text(
                              'No recommended consultants found',
                              style: GoogleFonts.manrope(
                                fontSize: 14.sp,
                                color: const Color(0xFF94A3B8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        );
                      }

                      return ListView.builder(
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
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.only(top: 60.h, bottom: 30.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF0066FF), Color(0xFF0052D1)],
        ),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(40.r),
          bottomRight: Radius.circular(40.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Obx(() {
                      final authService = Get.find<AuthService>();
                      final rawUrl =
                          authService.user.value?.image ??
                          authService.user.value?.avatar;
                      final imageUrl = ApiConstants.getImageUrl(rawUrl);

                      return Container(
                        width: 48.w,
                        height: 48.w,
                        decoration: BoxDecoration(
                          color: const Color(0x4DFFFFFF),
                          shape: BoxShape.circle,
                          image: imageUrl.isNotEmpty
                              ? DecorationImage(
                                  image: NetworkImage(imageUrl),
                                  fit: BoxFit.cover,
                                )
                              : null,
                        ),
                        child: imageUrl.isEmpty
                            ? Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 28.sp,
                              )
                            : null,
                      );
                    }),
                    SizedBox(width: 12.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Guten Morgen,',
                          style: GoogleFonts.manrope(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xCCFFFFFF),
                          ),
                        ),
                        Obx(() {
                          final authService = Get.find<AuthService>();
                          final name =
                              authService.user.value?.name ??
                              authService.user.value?.firstName ??
                              'User';
                          return Text(
                            name,
                            style: GoogleFonts.manrope(
                              fontSize: 18.sp,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          );
                        }),
                      ],
                    ),
                  ],
                ),
                InkWell(
                  onTap: () => Get.toNamed(AppRoutes.NOTIFICATIONS),
                  borderRadius: BorderRadius.circular(24.r),
                  child: Container(
                    padding: EdgeInsets.all(10.w),
                    decoration: BoxDecoration(
                      color: const Color(0x33FFFFFF),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.notifications_none_rounded,
                      color: Colors.white,
                      size: 22.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 30.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Text(
              'Find your expert\nconsultation today.',
              style: GoogleFonts.manrope(
                fontSize: 28.sp,
                fontWeight: FontWeight.w800,
                color: Colors.white,
                height: 1.2,
              ),
            ),
          ),
          SizedBox(height: 30.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 24.w),
            child: Container(
              height: 56.h,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x0D000000),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                readOnly: true,
                onTap: () {
                  Get.find<BottomNavBarController>().changeTab(1);
                },
                decoration: InputDecoration(
                  hintText: 'Search for doctors, lawyers...',
                  hintStyle: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  prefixIcon: Icon(
                    Icons.search_rounded,
                    color: const Color(0xFF94A3B8),
                    size: 20.sp,
                  ),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 18.h),
                ),
              ),
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

  Widget _buildCategories() {
    final categories = ['Lawyer', 'Advisor', 'Doctor'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: categories.map((cat) {
          return Container(
            margin: EdgeInsets.only(right: 12.w),
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: const Color(0xFFE2E8F0)),
            ),
            child: Text(
              cat,
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1D293D),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildUpcomingBooking(BookingModel booking) {
    final expert = booking.consultant;
    final imageUrl = ApiConstants.getImageUrl(expert?.image);

    // Format date and time
    String timeStr = 'N/A';
    if (booking.date != null && booking.startTime != null) {
      final now = DateTime.now();
      final date = booking.date!;
      final isToday =
          date.year == now.year &&
          date.month == now.month &&
          date.day == now.day;

      if (isToday) {
        timeStr = 'Today, ${booking.startTime}';
      } else {
        timeStr = '${DateFormat('MMM dd').format(date)}, ${booking.startTime}';
      }
    } else if (booking.startTime != null) {
      timeStr = 'Today, ${booking.startTime}';
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
                  CircleAvatar(
                    radius: 24.r,
                    backgroundColor: const Color(0x33FFFFFF),
                    backgroundImage: imageUrl.isNotEmpty
                        ? NetworkImage(imageUrl)
                        : null,
                    child: imageUrl.isEmpty
                        ? const Icon(Icons.person, color: Colors.white)
                        : null,
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
                    Get.toNamed(AppRoutes.CONSULTANT_CONFIRMATION, arguments: booking);
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
                      'Join',
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
    final name = consultant.name ?? 'Consultant';
    final role = consultant.expertise ?? consultant.consultancyType ?? 'Expert';
    final category = (consultant.consultancyType ?? 'Expert').toUpperCase();
    final averageRating = consultant.stats?.avgRating ?? 0.0;
    final rating = averageRating > 0 ? averageRating.toStringAsFixed(1) : 'New';
    final price = '${consultant.perMinuteRate ?? 0}.00€/min';
    final status = consultant.activeStatus == true ? 'Immediate' : 'Offline';
    final image = ApiConstants.getImageUrl(consultant.image);

    return GestureDetector(
      onTap: () {
        Get.toNamed(AppRoutes.CONSULTANT_PROFILE, arguments: consultant);
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: [
            BoxShadow(
              color: const Color(0x0A000000),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Stack(
              children: [
                Container(
                  width: 70.w,
                  height: 70.w,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    image: DecorationImage(
                      image: NetworkImage(image),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 4.h,
                  right: 4.w,
                  child: Container(
                    width: 12.w,
                    height: 12.w,
                    decoration: BoxDecoration(
                      color: consultant.activeStatus == true
                          ? const Color(0xFF10B981)
                          : const Color(0xFF94A3B8),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0EFFF),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          category,
                          style: GoogleFonts.manrope(
                            fontSize: 10.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF0066FF),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            color: const Color(0xFFFF6B00),
                            size: 16.sp,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            rating,
                            style: GoogleFonts.manrope(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF1D293D),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    name,
                    style: GoogleFonts.manrope(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF1D293D),
                    ),
                  ),
                  Text(
                    role,
                    style: GoogleFonts.manrope(
                      fontSize: 12.sp,
                      color: const Color(0xFF94A3B8),
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        price,
                        style: GoogleFonts.manrope(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1D293D),
                        ),
                      ),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE0EFFF),
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          status,
                          style: GoogleFonts.manrope(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF0066FF),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
