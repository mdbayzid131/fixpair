import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fixpair/modules/consultation_summary/controllers/consultation_summary_controller.dart';

class ConsultationReportView extends GetView<ConsultationSummaryController> {
  const ConsultationReportView({super.key});

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
          'Consultation Report',
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
      ),
      body: SafeArea(
        child: Obx(() {
          if (controller.isLoadingInvoice.value &&
              controller.invoiceData.value == null) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
              ),
            );
          }

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              children: [
                _buildCompletedCard(),
                SizedBox(height: 24.h),
                _buildInvoiceDetails(),
                SizedBox(height: 40.h),

                // No Report Found Section
                Center(
                  child: Container(
                    width: 120.w,
                    height: 120.w,
                    decoration: BoxDecoration(
                      color: const Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: const Color(
                            0xFF3B82F6,
                          ).withValues(alpha: 0.15),
                          blurRadius: 30,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: Center(
                      child: Container(
                        width: 80.w,
                        height: 80.w,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.description_outlined,
                          color: const Color(0xFF3B82F6),
                          size: 38.sp,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 24.h),

                // Title
                Text(
                  'No Report Found',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.manrope(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D293D),
                    letterSpacing: -0.5,
                  ),
                ),
                SizedBox(height: 12.h),

                // Description Text
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Text(
                    'The consultant has not submitted the summary report yet. Please wait until the consultant sends the report.',
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                ),
                SizedBox(height: 40.h),

                // Back Button
                Container(
                  width: double.infinity,
                  height: 56.h,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0066FF),
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFF0066FF).withValues(alpha: 0.25),
                        blurRadius: 15,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      onTap: () => Get.back(),
                      borderRadius: BorderRadius.circular(16.r),
                      child: Center(
                        child: Text(
                          'Go Back',
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
          );
        }),
      ),
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
            'Consultation Completed',
            style: GoogleFonts.manrope(
              fontSize: 22.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF166534),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'Your session with ${controller.consultantName.value}\nwas successful.',
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
                'Invoice Details',
                style: GoogleFonts.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1D293D),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFDCFCE7),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Text(
                  'Paid',
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
          _buildDetailRow('Invoice No', controller.invoiceNo.value),
          SizedBox(height: 16.h),
          _buildDetailRow('Date', controller.date.value),
          SizedBox(height: 16.h),
          _buildDetailRow('Duration', controller.duration.value),
          SizedBox(height: 16.h),
          _buildDetailRow('Rate', controller.rate.value),
          SizedBox(height: 16.h),
          _buildDetailRow('Subtotal', controller.subtotal.value),
          SizedBox(height: 16.h),
          _buildDetailRow('Platform Fee', controller.platformFee.value),
          SizedBox(height: 16.h),
          _buildDetailRow('VAT (19%)', controller.vat.value),
          SizedBox(height: 20.h),
          Divider(color: Colors.grey.withValues(alpha: 0.1), thickness: 1),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Total Charged',
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
              'Download PDF Invoice',
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
}
