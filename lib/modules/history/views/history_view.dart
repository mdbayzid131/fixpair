import 'package:fixpair/config/constants/api_constants.dart';
import 'package:fixpair/config/routes/app_pages.dart';
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
          SizedBox(
            width: 24.w,
          ), // Added some padding to balance the title if needed, or just leave empty
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

          Expanded(
            child: RefreshIndicator(
              onRefresh: controller.fetchMyBookings,
              child: Obx(() {
                if (controller.isLoading.value &&
                    controller.upcomingBookings.isEmpty &&
                    controller.pastBookings.isEmpty) {
                  return const Center(child: CircularProgressIndicator());
                }

                final bookings = controller.selectedTab.value == 0
                    ? controller.upcomingBookings
                    : controller.pastBookings;

                if (bookings.isEmpty) {
                  return SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Container(
                      height: 500.h, // Sufficient height to allow scrolling
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.calendar_today_outlined,
                            size: 64.sp,
                            color: Colors.grey.withOpacity(0.5),
                          ),
                          SizedBox(height: 16.h),
                          Text(
                            controller.selectedTab.value == 0
                                ? 'No upcoming bookings found'
                                : 'No past bookings found',
                            style: GoogleFonts.manrope(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  );
                }

                return ListView.separated(
                  controller: controller.scrollController,
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.symmetric(
                    horizontal: 24.w,
                    vertical: 20.h,
                  ),
                  itemCount:
                      bookings.length +
                      (controller.isLoadingMore.value ? 1 : 0),
                  separatorBuilder: (context, index) => SizedBox(height: 16.h),
                  itemBuilder: (context, index) {
                    if (index >= bookings.length) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    final booking = bookings[index];
                    return _buildBookingCard(booking);
                  },
                );
              }),
            ),
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
      case 'accepted':
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

    return GestureDetector(
      onTap: () => Get.toNamed(AppRoutes.BOOKING_DETAILS, arguments: booking),

      child: Container(
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
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Row(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Container(
                        width: 70.w,
                        height: 70.w,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16.r),
                          child: Image.network(
                            ApiConstants.getImageUrl(booking.consultant?.image),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Image.network(
                                  'https://i.ibb.co/z5YHLV9/profile.png',
                                  fit: BoxFit.cover,
                                ),
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
                        booking.durationText,
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
            Padding(
              padding: EdgeInsets.all(16.w),
              child: _renderActionButtons(booking),
            ),
          ],
        ),
      ),
    );
  }

  Widget _renderActionButtons(BookingModel booking) {
    if (booking.status?.toLowerCase() == 'confirmed') {
      return _buildPrimaryButton('Join Call', () {});
    } else if (booking.status?.toLowerCase() == 'accepted') {
      return Row(
        children: [
          Expanded(
            child: _buildLightButton(
              'Reschedule',
              () => Get.toNamed(
                AppRoutes.SCHEDULE_BOOKING,
                arguments: {
                  'expert': booking.consultant,
                  'bookingId': booking.id,
                  'isRescheduling': true,
                },
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: _buildDangerButton(
              'Cancel',
              () => _showCancelDialog(booking.id!),
            ),
          ),
        ],
      );
    } else if (booking.status?.toLowerCase() == 'pending') {
      return _buildDangerButton(
        'Cancel Booking',
        () => _showCancelDialog(booking.id!),
      );
    } else if (booking.status?.toLowerCase() == 'completed') {
      return Row(
        children: [
          Expanded(
            child: _buildSecondaryButton(
              'Book Again',
              () => Get.toNamed(
                AppRoutes.CONSULTANT_PROFILE,
                arguments: booking.consultant,
              ),
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(child: _buildLightButton('View Report', () {})),
        ],
      );
    }
    return const SizedBox.shrink();
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

  Widget _buildDangerButton(String text, VoidCallback onTap) {
    return Container(
      height: 48.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFFEE2E2)),
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
                color: const Color(0xFFEF4444),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showCancelDialog(String bookingId) {
    String selectedReason = "Change of plans";
    final reasons = [
      "Change of plans",
      "Consultant not available",
      "Found another option",
      "Technical issues",
      "Others",
    ];

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            title: Text(
              "Reason for cancellation",
              style: GoogleFonts.manrope(
                fontSize: 18.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1D293D),
              ),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: reasons.map((reason) {
                return RadioListTile<String>(
                  title: Text(
                    reason,
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF475569),
                    ),
                  ),
                  value: reason,
                  groupValue: selectedReason,
                  onChanged: (value) {
                    setState(() => selectedReason = value!);
                  },
                  activeColor: const Color(0xFFFF6B00),
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                );
              }).toList(),
            ),
            actions: [
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "Close",
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 12.h,
                  ),
                ),
                onPressed: () {
                  Get.back();
                  String finalReason = selectedReason == "Others"
                      ? "User cancelled the booking"
                      : selectedReason;
                  controller.cancelBooking(bookingId, reason: finalReason);
                },
                child: Text(
                  "Confirm",
                  style: GoogleFonts.manrope(
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
