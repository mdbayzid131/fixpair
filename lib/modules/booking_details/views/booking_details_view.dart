import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../config/constants/api_constants.dart';
import '../../../config/routes/app_pages.dart';
import '../../../data/models/user_model.dart';
import '../controllers/booking_details_controller.dart';

class BookingDetailsView extends GetView<BookingDetailsController> {
  const BookingDetailsView({super.key});

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
          'Booking Details',
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
      ),
      body: Obx(() {
        final booking = controller.booking.value;
        if (booking == null) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildStatusCard(booking),
              SizedBox(height: 24.h),
              _buildConsultantInfo(booking),
              SizedBox(height: 24.h),
              _buildBookingInfo(booking),
              SizedBox(height: 24.h),
              _buildPaymentInfo(booking),
              if (booking.notes != null && booking.notes!.isNotEmpty) ...[
                SizedBox(height: 24.h),
                _buildNotesSection(booking),
              ],
              SizedBox(height: 40.h),
              _buildActionButtons(booking),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildStatusCard(BookingModel booking) {
    Color statusColor;
    switch (booking.status?.toLowerCase()) {
      case 'pending':
        statusColor = const Color(0xFFF59E0B);
        break;
      case 'confirmed':
      case 'accepted':
        statusColor = const Color(0xFF0066FF);
        break;
      case 'completed':
        statusColor = const Color(0xFF10B981);
        break;
      case 'cancelled':
      case 'rejected':
        statusColor = const Color(0xFFEF4444);
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: statusColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: statusColor,
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getStatusIcon(booking.status),
              color: Colors.white,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Booking Status',
                style: GoogleFonts.manrope(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: statusColor,
                ),
              ),
              Text(
                booking.status?.toUpperCase() ?? 'PENDING',
                style: GoogleFonts.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: statusColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildConsultantInfo(BookingModel booking) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          SizedBox(
            width: 60.w,
            height: 60.w,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12.r),
              child: Image.network(
                ApiConstants.getImageUrl(booking.consultant?.image),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Image.network(
                  'https://i.ibb.co/z5YHLV9/profile.png',
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),

          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  booking.consultant?.name ?? 'Consultant',
                  style: GoogleFonts.manrope(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D293D),
                  ),
                ),
                Text(
                  booking.consultant?.tags ?? 'General Consultant',
                  style: GoogleFonts.manrope(
                    fontSize: 13.sp,
                    color: const Color(0xFF64748B),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Get.toNamed(
              AppRoutes.CONSULTANT_PROFILE,
              arguments: booking.consultant,
            ),
            icon: Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildBookingInfo(BookingModel booking) {
    String dateStr = 'N/A';
    if (booking.date != null) {
      dateStr = DateFormat('EEEE, MMM dd, yyyy').format(booking.date!);
    } else if (booking.createdAt != null) {
      dateStr = DateFormat('EEEE, MMM dd, yyyy').format(booking.createdAt!);
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
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
          _buildInfoRow(Icons.calendar_month_rounded, 'Date', dateStr),
          Divider(height: 24.h, color: const Color(0xFFF1F5F9)),
          _buildInfoRow(
            Icons.access_time_rounded,
            'Time',
            booking.startTime ?? 'N/A',
          ),
          Divider(height: 24.h, color: const Color(0xFFF1F5F9)),
          _buildInfoRow(Icons.timer_outlined, 'Duration', booking.durationText),
          Divider(height: 24.h, color: const Color(0xFFF1F5F9)),
          _buildInfoRow(
            Icons.videocam_outlined,
            'Type',
            booking.bookingType?.capitalizeFirst ?? 'Scheduled',
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentInfo(BookingModel booking) {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
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
          Text(
            'Payment Summary',
            style: GoogleFonts.manrope(
              fontSize: 16.sp,
              fontWeight: FontWeight.w700,
              color: const Color(0xFF1D293D),
            ),
          ),
          SizedBox(height: 16.h),
          _buildAmountRow('Consultation Fee', booking.totalAmount ?? 0),
          SizedBox(height: 12.h),
          _buildAmountRow('Platform Fee', 5.0), // Placeholder if not in model
          SizedBox(height: 12.h),
          const Divider(color: Color(0xFFF1F5F9)),
          SizedBox(height: 12.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Amount',
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1D293D),
                ),
              ),
              Text(
                '${(booking.totalAmount ?? 0) + 5}€',
                style: GoogleFonts.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF6B00),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection(BookingModel booking) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Booking Notes',
          style: GoogleFonts.manrope(
            fontSize: 16.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
        SizedBox(height: 12.h),
        Container(
          width: double.infinity,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: const Color(0xFFF1F5F9),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Text(
            booking.notes ?? '',
            style: GoogleFonts.manrope(
              fontSize: 14.sp,
              color: const Color(0xFF475569),
              height: 1.5,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BookingModel booking) {
    final status = booking.status?.toLowerCase();

    if (status == 'confirmed') {
      return _buildFullWidthButton(
        'Join Video Call',
        const Color(0xFF0066FF),
        Icons.videocam_rounded,
        () {},
      );
    } else if (status == 'accepted') {
      return Row(
        children: [
          Expanded(
            child: _buildSecondaryButton('Reschedule', () {
              Get.toNamed(
                AppRoutes.SCHEDULE_BOOKING,
                arguments: {
                  'expert': booking.consultant,
                  'bookingId': booking.id,
                  'isRescheduling': true,
                },
              );
            }),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: _buildDangerButton('Cancel Booking', () {
              // Should call the same dialog logic
            }),
          ),
        ],
      );
    } else if (status == 'pending') {
      return _buildDangerButton('Cancel Booking', () {});
    } else if (status == 'completed') {
      return _buildFullWidthButton(
        'Book Again',
        const Color(0xFF0066FF),
        Icons.refresh_rounded,
        () {
          Get.toNamed(
            AppRoutes.CONSULTANT_PROFILE,
            arguments: booking.consultant,
          );
        },
      );
    }

    return const SizedBox.shrink();
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: const Color(0xFF0066FF), size: 20.sp),
        SizedBox(width: 12.w),
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
      ],
    );
  }

  Widget _buildAmountRow(String label, num amount) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF64748B),
          ),
        ),
        Text(
          '${amount.toString().replaceAll('.', ',')}€',
          style: GoogleFonts.manrope(
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
      ],
    );
  }

  Widget _buildFullWidthButton(
    String label,
    Color color,
    IconData icon,
    VoidCallback onTap,
  ) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 20.sp),
              SizedBox(width: 8.w),
              Text(
                label,
                style: GoogleFonts.manrope(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSecondaryButton(String text, VoidCallback onTap) {
    return Container(
      height: 56.h,
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
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
      height: 56.h,
      decoration: BoxDecoration(
        color: const Color(0xFFFEF2F2),
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: const Color(0xFFFEE2E2)),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
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

  IconData _getStatusIcon(String? status) {
    switch (status?.toLowerCase()) {
      case 'completed':
        return Icons.check_circle_rounded;
      case 'cancelled':
      case 'rejected':
        return Icons.cancel_rounded;
      case 'pending':
        return Icons.schedule_rounded;
      default:
        return Icons.info_rounded;
    }
  }
}
