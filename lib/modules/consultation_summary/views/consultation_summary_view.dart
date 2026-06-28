import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fixpair/config/routes/app_pages.dart';
import '../controllers/consultation_summary_controller.dart';

class ConsultationSummaryView extends GetView<ConsultationSummaryController> {
  const ConsultationSummaryView({super.key});

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
          'Consultation Summary'.tr,
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoadingInvoice.value &&
            controller.invoiceData.value == null) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
            ),
          );
        }

        return SingleChildScrollView(
          padding: EdgeInsets.all(20.w),
          child: Column(
            children: [
              _buildCompletedCard(),
              SizedBox(height: 24.h),
              _buildInvoiceDetails(),
              SizedBox(height: 32.h),
              _buildRatingSection(),
              SizedBox(height: 32.h),
              _buildButtons(),
              SizedBox(height: 24.h),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCompletedCard() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 32.h, horizontal: 20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF0FDF4),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFDCFCE7), width: 1.5),
      ),
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: const BoxDecoration(
              color: Color(0xFFBBF7D0),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              color: const Color(0xFF16A34A),
              size: 32.sp,
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'Consultation Completed'.tr,
            style: GoogleFonts.manrope(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF166534),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your session with'.tr + ' ${controller.consultantName.value}\n' + 'was successful.'.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 15.sp,
              fontWeight: FontWeight.w600,
              color: const Color(0xFF166534).withValues(alpha: 0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInvoiceDetails() {
    return Container(
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Invoice Details'.tr,
                style: GoogleFonts.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1D293D),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(
                  horizontal: 10.w,
                  vertical: 4.h,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Paid'.tr,
                  style: GoogleFonts.manrope(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF16A34A),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          _buildDetailRow('Invoice No'.tr, controller.invoiceNo.value),
          SizedBox(height: 16.h),
          _buildDetailRow('Date'.tr, controller.date.value),
          SizedBox(height: 16.h),
          _buildDetailRow('Duration'.tr, controller.duration.value),
          SizedBox(height: 16.h),
          _buildDetailRow('Rate'.tr, controller.rate.value),
          SizedBox(height: 16.h),
          _buildDetailRow('Subtotal'.tr, controller.subtotal.value),
          SizedBox(height: 16.h),
          _buildDetailRow('Platform Fee'.tr, controller.platformFee.value),
          SizedBox(height: 16.h),
          _buildDetailRow('VAT (19%)'.tr, controller.vat.value),
          SizedBox(height: 20.h),
          Divider(color: Colors.grey.withValues(alpha: 0.1), thickness: 1),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Charged'.tr,
                style: GoogleFonts.manrope(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1D293D),
                ),
              ),
              Text(
                controller.totalCharged.value,
                style: GoogleFonts.manrope(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF6B00),
                ),
              ),
            ],
          ),
          SizedBox(height: 24.h),
          TextButton.icon(
            onPressed: () => controller.downloadPdfInvoice(),
            icon: Icon(
              Icons.file_download_outlined,
              size: 20.sp,
              color: const Color(0xFF0066FF),
            ),
            label: Text(
              'Download PDF Invoice'.tr,
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0066FF),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 14.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
        Text(
          value,
          style: GoogleFonts.manrope(
            fontSize: 15.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      children: [
        Text(
          'How was your experience?'.tr,
          style: GoogleFonts.manrope(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1D293D),
          ),
        ),
        SizedBox(height: 16.h),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(5, (index) {
            return Obx(
              () => IconButton(
                onPressed: () => controller.setRating(index + 1),
                icon: Icon(
                  index < controller.rating.value
                      ? Icons.star_rounded
                      : Icons.star_outline_rounded,
                  color: index < controller.rating.value
                      ? const Color(0xFFFFC107)
                      : const Color(0xFFE2E8F0),
                  size: 32.sp,
                ),
              ),
            );
          }),
        ),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(
              color: const Color(0xFF3B82F6).withValues(alpha: 0.5),
            ),
          ),
          child: TextField(
            controller: controller.reviewController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText:
                  'What did you like or dislike about working with this consultation?'.tr,
              hintStyle: GoogleFonts.manrope(
                fontSize: 13.sp,
                color: const Color(0xFF94A3B8),
              ),
              border: InputBorder.none,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildButtons() {
    return Column(
      children: [
        _buildActionButton(
          label: 'Submit Review'.tr,
          color: const Color(0xFF0066FF),
          onTap: () => controller.submitReview(),
        ),
        SizedBox(height: 16.h),
        _buildActionButton(
          label: 'Back to Home'.tr,
          color: const Color(0xFFFF6B00),
          onTap: () => Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR),
        ),
      ],
    );
  }

  Widget _buildActionButton({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Container(
      width: double.infinity,
      height: 56.h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16.r),
          child: Center(
            child: Text(
              label,
              style: GoogleFonts.manrope(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
