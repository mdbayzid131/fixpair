import 'package:fixpair/config/constants/api_constants.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/core/utils/helpers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../controllers/history_controller.dart';
import 'package:fixpair/data/models/user_model.dart';

class HistoryView extends StatefulWidget {
  const HistoryView({super.key});

  @override
  State<HistoryView> createState() => _HistoryViewState();
}

class _HistoryViewState extends State<HistoryView> {
  final HistoryController controller = Get.find<HistoryController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (controller.hasMore.value &&
          !controller.isLoadingMore.value &&
          !controller.isLoading.value) {
        controller.fetchMyBookings(isLoadMore: true);
      }
    }
  }

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
                            color: const Color(0x8094A3B8),
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
                  controller: _scrollController,
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
                      color: const Color(0x0D000000),
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
              color: const Color(0x0A000000),
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
                      SizedBox(
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
                              color: const Color(0x1A000000),
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
                                color: statusColor.withValues(alpha: 0.12),
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
            if (booking.status?.toLowerCase() == 'confirmed' ||
                booking.status?.toLowerCase() == 'accepted' ||
                booking.status?.toLowerCase() == 'pending' ||
                booking.status?.toLowerCase() == 'completed')
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
      return _buildPrimaryButton('Join', () {
        Get.toNamed(AppRoutes.CONSULTANT_CONFIRMATION, arguments: booking);
      });
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
      return _buildDangerButton('Cancel', () => _showCancelDialog(booking.id!));
    } else if (booking.status?.toLowerCase() == 'completed') {
      return Column(
        children: [
          Row(
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
          ),
          SizedBox(height: 12.h),
          _buildPrimaryButton('Leave Review', () => _showReviewDialog(booking)),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  void _showReviewDialog(BookingModel booking) {
    double selectedRating = 5.0;
    final TextEditingController commentController = TextEditingController();
    String? commentError;

    Get.dialog(
      StatefulBuilder(
        builder: (context, setState) {
          return Dialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(24.r),
            ),
            child: Container(
              padding: EdgeInsets.all(24.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24.r),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Leave a Review',
                    style: GoogleFonts.manrope(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF1D293D),
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    'Rate your consultation with ${booking.consultant?.name ?? "your expert"}',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                    ),
                  ),
                  SizedBox(height: 20.h),

                  // Stars selection
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(
                      5,
                      (index) => GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedRating = index + 1.0;
                          });
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 4.w),
                          child: Icon(
                            Icons.star_rounded,
                            color: index < selectedRating
                                ? const Color(0xFFF59E0B)
                                : const Color(0xFFE2E8F0),
                            size: 36.sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Comment box
                  TextField(
                    controller: commentController,
                    maxLines: 4,
                    onChanged: (value) {
                      if (commentError != null) {
                        setState(() {
                          commentError = null;
                        });
                      }
                    },
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF1D293D),
                    ),
                    decoration: InputDecoration(
                      hintText: 'Share your experience with this consultant...',
                      hintStyle: GoogleFonts.manrope(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w400,
                        color: const Color(0xFF94A3B8),
                      ),
                      errorText: commentError,
                      fillColor: const Color(0xFFF8FAFC),
                      filled: true,
                      contentPadding: EdgeInsets.all(16.w),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: Color(0xFF0066FF)),
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(color: Colors.red),
                      ),
                      focusedErrorBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16.r),
                        borderSide: const BorderSide(
                          color: Colors.red,
                          width: 1.5,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 24.h),

                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Get.back(),
                          style: OutlinedButton.styleFrom(
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            side: const BorderSide(color: Color(0xFFE2E8F0)),
                          ),
                          child: Text(
                            'Cancel',
                            style: GoogleFonts.manrope(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            final commentText = commentController.text.trim();
                            if (commentText.isEmpty) {
                              setState(() {
                                commentError = 'Please write a review comment';
                              });
                              return;
                            }
                            final success = await controller.submitReview(
                              consultationId: booking.id!,
                              rating: selectedRating,
                              comment: commentText,
                            );
                            if (success) {
                              Get.back();
                              Helpers.showSuccess(
                                'Review submitted successfully!',
                              );
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF6B00),
                            padding: EdgeInsets.symmetric(vertical: 14.h),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            elevation: 0,
                          ),
                          child: Text(
                            'Submit',
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
                ],
              ),
            ),
          );
        },
      ),
      barrierDismissible: false,
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
            color: const Color(0x4DFF6B00),
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
                  // ignore: deprecated_member_use
                  groupValue: selectedReason,
                  // ignore: deprecated_member_use
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
