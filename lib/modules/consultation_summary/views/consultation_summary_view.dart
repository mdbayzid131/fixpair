import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
          icon: Icon(Icons.chevron_left_rounded, color: const Color(0xFF1D293D), size: 28.sp),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Consultation Summary',
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications_none_rounded, color: const Color(0xFF1D293D), size: 24.sp),
            onPressed: () {},
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20.w),
        child: Column(
          children: [
            _buildCompletedCard(),
            SizedBox(height: 24.h),
            _buildInvoiceDetails(),
            SizedBox(height: 24.h),
            _buildConsultantNotes(),
            SizedBox(height: 24.h),
            _buildDialogueTranscript(),
            SizedBox(height: 32.h),
            _buildRatingSection(),
            SizedBox(height: 32.h),
            _buildButtons(),
            SizedBox(height: 24.h),
          ],
        ),
      ),
    );
  }

  Widget _buildCompletedCard() {
    return Obx(() => Container(
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
            child: Icon(Icons.check_rounded, color: const Color(0xFF16A34A), size: 32.sp),
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
              color: const Color(0xFF166534).withOpacity(0.7),
              height: 1.5,
            ),
          ),
        ],
      ),
    ));
  }

  Widget _buildInvoiceDetails() {
    return Obx(() => Container(
      padding: EdgeInsets.all(24.w),
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
          _buildDetailRow('Date', controller.date.value),
          SizedBox(height: 16.h),
          _buildDetailRow('Duration', controller.duration.value),
          SizedBox(height: 16.h),
          _buildDetailRow('Rate', controller.rate.value),
          SizedBox(height: 16.h),
          _buildDetailRow('VAT (19%)', controller.vat.value),
          SizedBox(height: 20.h),
          Divider(color: Colors.grey.withOpacity(0.1), thickness: 1),
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
            onPressed: () {},
            icon: Icon(Icons.file_download_outlined, size: 20.sp, color: const Color(0xFF0066FF)),
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
    ));
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

  Widget _buildConsultantNotes() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Consultant's Notes",
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF1D293D),
          ),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(20.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(color: const Color(0xFF0066FF), width: 1.5),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '"Thank you for the consultation today. Based on our discussion, I recommend proceeding with the reviewed documentation. Please find the finalized template attached below."',
                style: GoogleFonts.manrope(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFF64748B),
                  fontStyle: FontStyle.italic,
                  height: 1.6,
                ),
              ),
              SizedBox(height: 20.h),
              Container(
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16.r),
                ),
                child: Row(
                  children: [
                    Icon(Icons.description_rounded, color: const Color(0xFF0066FF), size: 30.sp),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Legal_Template_v2.pdf',
                            style: GoogleFonts.manrope(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1D293D),
                            ),
                          ),
                          Text(
                            '1.2 MB',
                            style: GoogleFonts.manrope(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF94A3B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.file_download_outlined, color: const Color(0xFF64748B), size: 24.sp),
                  ],
                ),
              ),
              SizedBox(height: 16.h),
              Container(
                width: double.infinity,
                height: 48.h,
                decoration: BoxDecoration(
                  border: Border.all(color: const Color(0xFF0066FF).withOpacity(0.5), style: BorderStyle.solid),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Center(
                  child: Text(
                    '+ Add Link or File',
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF0066FF),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRatingSection() {
    return Column(
      children: [
        Text(
          'How was your experience?',
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
            return Obx(() => IconButton(
                  onPressed: () => controller.setRating(index + 1),
                  icon: Icon(
                    index < controller.rating.value ? Icons.star_rounded : Icons.star_outline_rounded,
                    color: index < controller.rating.value ? const Color(0xFFFFC107) : const Color(0xFFE2E8F0),
                    size: 32.sp,
                  ),
                ));
          }),
        ),
        SizedBox(height: 24.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: const Color(0xFF3B82F6).withOpacity(0.5)),
          ),
          child: TextField(
            controller: controller.reviewController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'What did you like or dislike about working with this consultation?',
              hintStyle: GoogleFonts.manrope(fontSize: 13.sp, color: const Color(0xFF94A3B8)),
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
          label: 'Submit Review',
          color: const Color(0xFF0066FF),
          onTap: () => controller.submitReview(),
        ),
        SizedBox(height: 16.h),
        _buildActionButton(
          label: 'Back to Home',
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
            color: color.withOpacity(0.3),
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

  Widget _buildDialogueTranscript() {
    return Obx(() {
      return Container(
        padding: EdgeInsets.all(24.w),
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Dialogue Transcript',
                  style: GoogleFonts.manrope(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D293D),
                  ),
                ),
                if (controller.transcript.isNotEmpty)
                  IconButton(
                    icon: Icon(Icons.copy_rounded, color: const Color(0xFF0066FF), size: 20.sp),
                    onPressed: () {
                      final fullText = controller.transcript.map((msg) => '${msg.speakerName}: ${msg.text}').join('\n');
                      Clipboard.setData(ClipboardData(text: fullText));
                      Get.snackbar(
                        'Success',
                        'Transcript copied to clipboard',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    },
                  ),
              ],
            ),
            SizedBox(height: 12.h),
            Text(
              'Real-time text transcript generated during the video session.',
              style: GoogleFonts.manrope(
                fontSize: 13.sp,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
            SizedBox(height: 20.h),
            if (controller.transcript.isEmpty)
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 24.h),
                alignment: Alignment.center,
                child: Text(
                  'No transcripts recorded for this session.',
                  style: GoogleFonts.manrope(
                    color: const Color(0xFF64748B),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Container(
                constraints: BoxConstraints(maxHeight: 250.h),
                padding: EdgeInsets.all(16.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFF8FAFC),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: controller.transcript.length,
                  itemBuilder: (context, index) {
                    final msg = controller.transcript[index];
                    final isUser = msg.speakerRole == 'user';
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                msg.speakerName,
                                style: GoogleFonts.manrope(
                                  color: isUser ? const Color(0xFF0066FF) : const Color(0xFF10B981),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                '${msg.timestamp.hour.toString().padLeft(2, '0')}:${msg.timestamp.minute.toString().padLeft(2, '0')}',
                                style: GoogleFonts.manrope(
                                  color: const Color(0xFF94A3B8),
                                  fontSize: 10.sp,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            msg.text,
                            style: GoogleFonts.manrope(
                              color: const Color(0xFF334155),
                              fontSize: 13.sp,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
          ],
        ),
      );
    });
  }
}
