import 'package:fixpair/config/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/history_controller.dart';
import 'package:fixpair/data/models/user_model.dart';

class HistoryView extends GetView<HistoryController> {
  const HistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Text(
          'Consultations',
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              Icons.search_rounded,
              color: const Color(0xFF64748B),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Column(
        children: [
          // 1. Toggle Tab Section
          Container(
            color: Colors.white,
            padding: EdgeInsets.only(bottom: 20.h, top: 10.h),
            child: Center(
              child: Container(
                width: 327.w,
                padding: EdgeInsets.all(4.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Obx(
                  () => Row(
                    children: [
                      _buildTabItem('Upcoming', 0),
                      _buildTabItem('Past History', 1),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // 2. Main Content
          Expanded(
            child: Obx(() {
              if (controller.isLoading.value) {
                return const Center(child: CircularProgressIndicator());
              }

              final bookings = controller.selectedTab.value == 0
                  ? controller.upcomingBookings
                  : controller.pastBookings;

              if (bookings.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 64.sp,
                        color: Colors.grey,
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'No bookings found',
                        style: GoogleFonts.manrope(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w600,
                          color: const Color(0xFF64748B),
                        ),
                      ),
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: controller.fetchMyBookings,
                child: ListView.separated(
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
                  itemCount: bookings.length,
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    final booking = bookings[index];
                    return _buildBookingCard(booking);
                  },
                ),
              );
            }),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem(String label, int index) {
    final isSelected = controller.selectedTab.value == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => controller.selectTab(index),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12.h),
          decoration: BoxDecoration(
            color: isSelected ? Colors.white : Colors.transparent,
            borderRadius: BorderRadius.circular(10.r),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                color: isSelected
                    ? const Color(0xFF0066FF)
                    : const Color(0xFF64748B),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBookingCard(BookingModel booking) {
    Color statusColor;
    switch (booking.status?.toLowerCase()) {
      case 'confirmed':
        statusColor = const Color(0xFF0066FF);
        break;
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'completed':
        statusColor = const Color(0xFF10B981);
        break;
      case 'cancelled':
      case 'expired':
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = const Color(0xFF64748B);
    }

    IconData typeIcon;
    switch (booking.bookingType?.toLowerCase()) {
      case 'instant':
        typeIcon = Icons.bolt_rounded;
        break;
      case 'callback':
        typeIcon = Icons.phone_callback_rounded;
        break;
      case 'scheduled':
      default:
        typeIcon = Icons.videocam_rounded;
    }

    String displayDate = '';
    if (booking.bookingType == 'scheduled' && booking.date != null) {
      displayDate =
          '${DateFormat('MMM dd').format(booking.date!)}, ${booking.startTime}';
    } else if (booking.createdAt != null) {
      displayDate = DateFormat('MMM dd, HH:mm').format(booking.createdAt!);
    }

    return Container(
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
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                // Image
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    Container(
                      width: 70.w,
                      height: 70.w,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16.r),
                        image: DecorationImage(
                          image: NetworkImage(
                            ApiConstants.getImageUrl(
                              booking.consultant?.image ?? '',
                            ),
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                      child: Icon(
                        typeIcon,
                        color: const Color(0xFFFF6B00),
                        size: 14.sp,
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 10.w,
                              vertical: 4.h,
                            ),
                            decoration: BoxDecoration(
                              color: statusColor.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                            child: Text(
                              (booking.status ?? 'PENDING').toUpperCase(),
                              style: GoogleFonts.manrope(
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w800,
                                color: statusColor,
                              ),
                            ),
                          ),
                          if (booking.totalAmount != null &&
                              booking.totalAmount! > 0)
                            Text(
                              '${booking.totalAmount!.toString().replaceAll('.', ',')}€',
                              style: GoogleFonts.manrope(
                                fontSize: 16.sp,
                                fontWeight: FontWeight.w800,
                                color: const Color(0xFF1D293D),
                              ),
                            ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        booking.consultant?.name ?? 'Unknown Consultant',
                        style: GoogleFonts.manrope(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1D293D),
                        ),
                      ),
                      Text(
                        booking.consultant?.tags ?? "General consultant",
                        style: GoogleFonts.manrope(
                          fontSize: 13.sp,
                          color: const Color(0xFF64748B),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Date & Time Box
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.calendar_month_rounded,
                    color: const Color(0xFF0066FF),
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    displayDate,
                    style: GoogleFonts.manrope(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF1D293D),
                    ),
                  ),
                  if (booking.bookingType == 'scheduled') ...[
                    const Spacer(),
                    Container(
                      width: 1.w,
                      height: 14.h,
                      color: const Color(0xFFE2E8F0),
                    ),
                    const Spacer(),
                    Icon(
                      Icons.videocam_rounded,
                      color: const Color(0xFF0066FF),
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '30 min', // Ideally this comes from backend duration
                      style: GoogleFonts.manrope(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1D293D),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),

          // Actions Section
          if (booking.status?.toLowerCase() == 'confirmed')
            Padding(
              padding: EdgeInsets.all(16.w),
              child: _buildPrimaryButton('Join Call', () {}),
            )
          else if (booking.status?.toLowerCase() == 'pending')
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Expanded(child: _buildSecondaryButton('Reschedule', () {})),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildSecondaryButton('Cancel', () {})),
                ],
              ),
            )
          else if (booking.status?.toLowerCase() == 'completed')
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Expanded(child: _buildSecondaryButton('Book Again', () {})),
                  SizedBox(width: 12.w),
                  Expanded(child: _buildLightButton('View Report', () {})),
                ],
              ),
            )
          else
            SizedBox(height: 16.h),
        ],
      ),
    );
  }

  Widget _buildPrimaryButton(String text, VoidCallback onTap) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF6B00), Color(0xFFFF8A00)],
        ),
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF6B00).withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onTap) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF475569),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLightButton(String text, VoidCallback onTap) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Center(
            child: Text(
              text,
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0066FF),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
