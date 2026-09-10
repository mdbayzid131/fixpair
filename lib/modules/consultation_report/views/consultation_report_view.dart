import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:fixpair/config/constants/api_constants.dart';
import 'package:fixpair/core/utils/helpers.dart';
import 'package:fixpair/core/widgets/custom_appbar.dart';
import 'package:fixpair/data/models/report_model.dart';
import 'package:fixpair/modules/consultation_summary/controllers/consultation_summary_controller.dart';

class ConsultationReportView extends GetView<ConsultationSummaryController> {
  const ConsultationReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar.build(
        title: 'Consultation Report'.tr,
        showBackButton: true,
      ),
      body: SafeArea(
        child: Obx(() {
          if ((controller.isLoadingInvoice.value &&
                  controller.invoiceData.value == null) ||
              (controller.isLoadingReport.value &&
                  controller.reportData.value == null)) {
            return const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
              ),
            );
          }

          final report = controller.reportData.value;

          return SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sleek Collapsible Invoice Card
                _buildCollapsibleInvoiceCard(),
                SizedBox(height: 20.h),

                if (report == null)
                  _buildNoReportFoundUI()
                else ...[
                  // Report Section Title Header
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.all(10.w),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEFF6FF),
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        child: Icon(
                          Icons.assignment_rounded,
                          color: const Color(0xFF0066FF),
                          size: 24.sp,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Consultation Report'.tr,
                            style: GoogleFonts.manrope(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFF1D293D),
                            ),
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Detailed summary & recommendations'.tr,
                            style: GoogleFonts.manrope(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(height: 16.h),

                  // Main Report Content Container
                  Container(
                    padding: EdgeInsets.all(20.w),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24.r),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 20,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildReportHeader(report),
                        SizedBox(height: 24.h),
                        _buildAdvisorOverviewCard(report),
                        SizedBox(height: 24.h),
                        _buildGeminiAiSummaryCard(report),
                        SizedBox(height: 28.h),
                        if (report.stepsTaken.isNotEmpty) ...[
                          _buildStepsTakenSection(report),
                          SizedBox(height: 28.h),
                        ],
                        if (report.recommendedProducts.isNotEmpty) ...[
                          _buildRecommendedProductsSection(report),
                          SizedBox(height: 28.h),
                        ],
                        if (report.links.isNotEmpty) ...[
                          _buildHelpfulLinksSection(report),
                          SizedBox(height: 28.h),
                        ],
                        if (report.images.isNotEmpty) ...[
                          _buildAttachedPhotosSection(context, report),
                          SizedBox(height: 28.h),
                        ],
                        if (report.pdfUrl != null &&
                            report.pdfUrl!.isNotEmpty) ...[
                          _buildPdfDownloadButton(report),
                          SizedBox(height: 16.h),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          );
        }),
      ),
    );
  }

  // Collapsible Invoice & Session Completed Accordion Card
  Widget _buildCollapsibleInvoiceCard() {
    return Obx(() {
      final isExpanded = controller.isInvoiceExpanded.value;
      return Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          border: Border.all(color: const Color(0xFFE2E8F0)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            // Header Bar (Tappable)
            InkWell(
              onTap: () => controller.toggleInvoiceExpanded(),
              borderRadius: BorderRadius.circular(20.r),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: const BoxDecoration(
                        color: Color(0xFFDCFCE7),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.check_circle_rounded,
                        color: const Color(0xFF16A34A),
                        size: 20.sp,
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Session Completed'.tr,
                                style: GoogleFonts.manrope(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF0F172A),
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8.w,
                                  vertical: 2.h,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFDCFCE7),
                                  borderRadius: BorderRadius.circular(6.r),
                                ),
                                child: Text(
                                  'Paid'.tr,
                                  style: GoogleFonts.manrope(
                                    fontSize: 10.sp,
                                    fontWeight: FontWeight.w800,
                                    color: const Color(0xFF16A34A),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 2.h),
                          Text(
                            'Invoice: ${controller.invoiceNo.value.isNotEmpty ? controller.invoiceNo.value : "N/A"} • ${controller.totalCharged.value}',
                            style: GoogleFonts.manrope(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: const Color(0xFF64748B),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.all(4.w),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F5F9),
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Icon(
                        isExpanded
                            ? Icons.keyboard_arrow_up_rounded
                            : Icons.keyboard_arrow_down_rounded,
                        color: const Color(0xFF475569),
                        size: 22.sp,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Collapsible Expanded Content
            if (isExpanded) ...[
              Divider(height: 1, color: const Color(0xFFE2E8F0)),
              Padding(
                padding: EdgeInsets.all(20.w),
                child: Column(
                  children: [
                    _buildDetailRow(
                      'Invoice No'.tr,
                      controller.invoiceNo.value,
                    ),
                    SizedBox(height: 12.h),
                    _buildDetailRow('Date'.tr, controller.date.value),
                    SizedBox(height: 12.h),
                    _buildDetailRow('Duration'.tr, controller.duration.value),
                    SizedBox(height: 12.h),
                    _buildDetailRow('Rate'.tr, controller.rate.value),
                    SizedBox(height: 12.h),
                    _buildDetailRow('Subtotal'.tr, controller.subtotal.value),
                    SizedBox(height: 12.h),
                    _buildDetailRow(
                      'Platform Fee'.tr,
                      controller.platformFee.value,
                    ),
                    SizedBox(height: 12.h),
                    _buildDetailRow('VAT (19%)'.tr, controller.vat.value),
                    SizedBox(height: 16.h),
                    Divider(
                      color: Colors.grey.withValues(alpha: 0.15),
                      thickness: 1,
                    ),
                    SizedBox(height: 16.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Charged'.tr,
                          style: GoogleFonts.manrope(
                            fontSize: 15.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFF1D293D),
                          ),
                        ),
                        Text(
                          controller.totalCharged.value,
                          style: GoogleFonts.manrope(
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFF6B00),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16.h),
                    TextButton.icon(
                      onPressed: () => controller.downloadPdfInvoice(),
                      icon: Icon(
                        Icons.file_download_outlined,
                        size: 18.sp,
                        color: const Color(0xFF0066FF),
                      ),
                      label: Text(
                        'Download PDF Invoice'.tr,
                        style: GoogleFonts.manrope(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF0066FF),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      );
    });
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: const Color(0xFF94A3B8),
          ),
        ),
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

  // Header section with Fixpair logo & Service log ID
  Widget _buildReportHeader(ReportModel report) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Fixpair',
              style: GoogleFonts.manrope(
                fontSize: 24.sp,
                fontWeight: FontWeight.w900,
                color: const Color(0xFF0F172A),
                letterSpacing: -0.5,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'YOUR PROFESSIONAL IN YOUR POCKET',
              style: GoogleFonts.manrope(
                fontSize: 9.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF2563EB),
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              'Service log',
              style: GoogleFonts.manrope(
                fontSize: 15.sp,
                fontWeight: FontWeight.w800,
                color: const Color(0xFF0F172A),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              'ID: ${report.id != null ? 'rep_call_${report.id!.substring(0, report.id!.length > 8 ? 8 : report.id!.length)}' : 'N/A'}',
              style: GoogleFonts.manrope(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF94A3B8),
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              'Date: ${report.formattedDate}',
              style: GoogleFonts.manrope(
                fontSize: 11.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Advisor Overview 4-grid Card
  Widget _buildAdvisorOverviewCard(ReportModel report) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF8FAFC),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFE2E8F0), width: 1),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildInfoGridItem(
                  'CATEGORY',
                  report.consultation?.bookingType ?? 'instant',
                  isCapitalized: true,
                ),
              ),
              Expanded(
                child: _buildInfoGridItem(
                  'ADVISOR',
                  report.consultant?.name ?? 'Advisor',
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(
                child: _buildInfoGridItem(
                  'CONVERSATION DURATION',
                  report.formattedDuration,
                ),
              ),
              Expanded(
                child: _buildInfoGridItem(
                  'STATUS',
                  'Successfully completed',
                  textColor: const Color(0xFF10B981),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoGridItem(
    String label,
    String value, {
    Color? textColor,
    bool isCapitalized = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.manrope(
            fontSize: 10.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF94A3B8),
            letterSpacing: 0.5,
          ),
        ),
        SizedBox(height: 4.h),
        Text(
          isCapitalized ? value.toUpperCase() : value,
          style: GoogleFonts.manrope(
            fontSize: 14.sp,
            fontWeight: FontWeight.w800,
            color: textColor ?? const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // Gemini AI Summary Card (Purple gradient style box)
  Widget _buildGeminiAiSummaryCard(ReportModel report) {
    final aiSummary = report.aiSummary;
    final summaryText =
        report.summary ??
        aiSummary?.overview ??
        'No transcript recorded for this consultation.';
    final keyPointsList = report.keyPoints.isNotEmpty
        ? report.keyPoints
        : (aiSummary?.keyPoints ?? []);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F3FF),
        borderRadius: BorderRadius.circular(24.r),
        border: Border.all(color: const Color(0xFFDDD6FE), width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Clean AI Summary Header
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(8.w),
                decoration: const BoxDecoration(
                  color: Color(0xFF7C3AED),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.auto_awesome_rounded,
                  color: Colors.white,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Summary',
                      style: GoogleFonts.manrope(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFF0F172A),
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'Auto-generated intelligence from live transcription',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.manrope(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),

          // Executive Summary Section
          Row(
            children: [
              Icon(
                Icons.article_outlined,
                size: 16.sp,
                color: const Color(0xFF6D28D9),
              ),
              SizedBox(width: 6.w),
              Text(
                'Executive Summary',
                style: GoogleFonts.manrope(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Text(
              summaryText,
              style: GoogleFonts.manrope(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF334155),
                height: 1.5,
              ),
            ),
          ),
          SizedBox(height: 16.h),

          // Key Discussion Points Section
          Row(
            children: [
              Icon(
                Icons.check_circle_outline_rounded,
                size: 16.sp,
                color: const Color(0xFF10B981),
              ),
              SizedBox(width: 6.w),
              Text(
                'Key Discussion Points',
                style: GoogleFonts.manrope(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF475569),
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Container(
            width: double.infinity,
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16.r),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: keyPointsList.map((point) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 6.h),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '• ',
                        style: GoogleFonts.manrope(
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w900,
                          color: const Color(0xFF10B981),
                        ),
                      ),
                      Expanded(
                        child: Text(
                          point,
                          style: GoogleFonts.manrope(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFF334155),
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // Steps Taken Section
  Widget _buildStepsTakenSection(ReportModel report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Steps taken', const Color(0xFF2563EB)),
        SizedBox(height: 12.h),
        Column(
          children: List.generate(report.stepsTaken.length, (index) {
            final step = report.stepsTaken[index];
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28.w,
                    height: 28.w,
                    decoration: const BoxDecoration(
                      color: Color(0xFFEFF6FF),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: GoogleFonts.manrope(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Text(
                      step,
                      style: GoogleFonts.manrope(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF334155),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ),
      ],
    );
  }

  // Recommended Products & Tools Section
  Widget _buildRecommendedProductsSection(ReportModel report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle(
          'Recommended Products & Tools',
          const Color(0xFF10B981),
        ),
        SizedBox(height: 12.h),
        SizedBox(
          height: 140.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: report.recommendedProducts.length,
            separatorBuilder: (context, index) => SizedBox(width: 12.w),
            itemBuilder: (context, index) {
              final item = report.recommendedProducts[index];
              return Container(
                width: 220.w,
                padding: EdgeInsets.all(12.w),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFE2E8F0)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12.r),
                      child: Image.network(
                        ApiConstants.getImageUrl(item.image),
                        width: 60.w,
                        height: 60.w,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          width: 60.w,
                          height: 60.w,
                          color: const Color(0xFFF1F5F9),
                          child: Icon(
                            Icons.build_rounded,
                            color: const Color(0xFF94A3B8),
                            size: 24.sp,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.name ?? 'Product',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.manrope(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF0F172A),
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                item.price != null ? '€${item.price}' : '',
                                style: GoogleFonts.manrope(
                                  fontSize: 13.sp,
                                  fontWeight: FontWeight.w800,
                                  color: const Color(0xFF2563EB),
                                ),
                              ),
                              if (item.link != null && item.link!.isNotEmpty)
                                InkWell(
                                  onTap: () => _launchExternalUrl(item.link!),
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8.w,
                                      vertical: 4.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF1F5F9),
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    child: Text(
                                      'Buy ->',
                                      style: GoogleFonts.manrope(
                                        fontSize: 10.sp,
                                        fontWeight: FontWeight.w700,
                                        color: const Color(0xFF334155),
                                      ),
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
              );
            },
          ),
        ),
      ],
    );
  }

  // Helpful Links Section
  Widget _buildHelpfulLinksSection(ReportModel report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Helpful Links', const Color(0xFF2563EB)),
        SizedBox(height: 12.h),
        Column(
          children: report.links.map((linkUrl) {
            return InkWell(
              onTap: () => _launchExternalUrl(linkUrl),
              borderRadius: BorderRadius.circular(16.r),
              child: Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFEFF6FF),
                  borderRadius: BorderRadius.circular(16.r),
                  border: Border.all(color: const Color(0xFFBFDBFE)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.link_rounded,
                      color: const Color(0xFF2563EB),
                      size: 20.sp,
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        linkUrl,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.manrope(
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF2563EB),
                        ),
                      ),
                    ),
                    Icon(
                      Icons.open_in_new_rounded,
                      color: const Color(0xFF2563EB),
                      size: 16.sp,
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // Attached Photos Section
  Widget _buildAttachedPhotosSection(BuildContext context, ReportModel report) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Attached Photos', const Color(0xFFF97316)),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 12.w,
          runSpacing: 12.h,
          children: report.images.map((imgUrl) {
            final fullUrl = ApiConstants.getImageUrl(imgUrl);
            return GestureDetector(
              onTap: () => _showImagePreviewModal(context, fullUrl),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16.r),
                child: Container(
                  width: 100.w,
                  height: 100.w,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF1F5F9),
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  child: Image.network(
                    fullUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        color: Colors.grey,
                        size: 24.sp,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // PDF Download Button
  Widget _buildPdfDownloadButton(ReportModel report) {
    return Container(
      width: double.infinity,
      height: 54.h,
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
          onTap: () => _launchExternalUrl(report.fullPdfUrl),
          borderRadius: BorderRadius.circular(16.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.picture_as_pdf_rounded,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(width: 8.w),
              Text(
                'Download Full PDF Report'.tr,
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
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

  // Section Title with Colored Left Bar
  Widget _buildSectionTitle(String title, Color barColor) {
    return Row(
      children: [
        Container(
          width: 4.w,
          height: 18.h,
          decoration: BoxDecoration(
            color: barColor,
            borderRadius: BorderRadius.circular(4.r),
          ),
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: GoogleFonts.manrope(
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: const Color(0xFF0F172A),
          ),
        ),
      ],
    );
  }

  // Fallback UI when report is null
  Widget _buildNoReportFoundUI() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.r),
      ),
      child: Column(
        children: [
          SizedBox(height: 20.h),
          Center(
            child: Container(
              width: 100.w,
              height: 100.w,
              decoration: const BoxDecoration(
                color: Color(0xFFEFF6FF),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Icon(
                  Icons.description_outlined,
                  color: const Color(0xFF3B82F6),
                  size: 40.sp,
                ),
              ),
            ),
          ),
          SizedBox(height: 20.h),
          Text(
            'No Report Found'.tr,
            style: GoogleFonts.manrope(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1D293D),
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'The consultant has not submitted the summary report yet.'.tr,
            textAlign: TextAlign.center,
            style: GoogleFonts.manrope(
              fontSize: 13.sp,
              color: const Color(0xFF64748B),
            ),
          ),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }

  // Open Image Fullscreen Preview Modal
  void _showImagePreviewModal(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          insetPadding: EdgeInsets.all(16.w),
          child: Stack(
            alignment: Alignment.topRight,
            children: [
              InteractiveViewer(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.r),
                  child: Image.network(imageUrl, fit: BoxFit.contain),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Container(
                    padding: EdgeInsets.all(6.w),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.close, color: Colors.white, size: 20.sp),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Launch external URL safely
  Future<void> _launchExternalUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      Helpers.showError('Could not launch URL: $url', title: 'Error'.tr);
    }
  }
}
