import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/config/constants/api_constants.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/consultant_confirmation_controller.dart';

class ConsultantConfirmationView
    extends GetView<ConsultantConfirmationController> {
  const ConsultantConfirmationView({super.key});

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
          'Confirm Your Consultation',
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
      ),
      body: Obx(() {
        if (controller.isLoading.value &&
            controller.consultantNameRx.value == 'Sarah Müller') {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
            ),
          );
        }

        return SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.all(20.w),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildConsultantCard(),
                SizedBox(height: 24.h),
                _buildBillingSummary(),
                SizedBox(height: 24.h),
                Text(
                  'PAYMENT METHOD',
                  style: GoogleFonts.manrope(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF64748B),
                    letterSpacing: 0.5,
                  ),
                ),
                SizedBox(height: 12.h),
                _buildPaymentMethod(),
                SizedBox(height: 24.h),
                _buildSecurePaymentInfo(),
                SizedBox(height: 32.h),
                _buildConfirmButton(),
              ],
            ),
          ),
        );
      }),
    );
  }

  Widget _buildConsultantCard() {
    final imageUrl = ApiConstants.getImageUrl(controller.consultantImage);

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFF3B82F6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF3B82F6).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 56.w,
            height: 56.w,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16.r),
              image: imageUrl.isNotEmpty
                  ? DecorationImage(
                      image: NetworkImage(imageUrl),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: imageUrl.isEmpty
                ? const Icon(Icons.person, color: Color(0xFF94A3B8))
                : null,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.consultantName,
                  style: GoogleFonts.manrope(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D293D),
                  ),
                ),
                Text(
                  controller.consultantCategory,
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: const Color(0xFF3B82F6),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBillingSummary() {
    return Container(
      padding: EdgeInsets.all(24.w),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Billing Summary',
            style: GoogleFonts.manrope(
              fontSize: 18.sp,
              fontWeight: FontWeight.w800,
              color: const Color(0xFF1D293D),
            ),
          ),
          SizedBox(height: 24.h),
          _buildSummaryRow(
            'Consultant Rate',
            controller.consultantRate,
            isPrice: true,
          ),
          SizedBox(height: 16.h),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1),
          SizedBox(height: 16.h),
          _buildSummaryRow('Consultant Fee', controller.consultantFee),
          SizedBox(height: 12.h),
          _buildSummaryRow('Platform Service Fee', controller.platformFee),
          SizedBox(height: 12.h),
          _buildSummaryRow('VAT (19%)', controller.vat),
          SizedBox(height: 20.h),
          const Divider(color: Color(0xFFF1F5F9), thickness: 1),
          SizedBox(height: 20.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'PRE-AUTHORIZED HOLD',
                style: GoogleFonts.manrope(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFFFF6B00),
                ),
              ),
              Text(
                controller.totalHold,
                style: GoogleFonts.manrope(
                  fontSize: 24.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF0066FF),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isPrice = false}) {
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
          value,
          style: GoogleFonts.manrope(
            fontSize: 16.sp,
            fontWeight: isPrice ? FontWeight.w800 : FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
      ],
    );
  }

  Widget _buildPaymentMethod() {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFF1F5F9)),
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(10.w),
            decoration: BoxDecoration(
              color: const Color(0xFFEFF6FF),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.credit_card_rounded,
              color: const Color(0xFF3B82F6),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  controller.cardNumber,
                  style: GoogleFonts.manrope(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF1D293D),
                  ),
                ),
                Row(
                  children: [
                    Icon(
                      controller.hasCard.value
                          ? Icons.check_circle_rounded
                          : Icons.warning_amber_rounded,
                      color: controller.hasCard.value
                          ? const Color(0xFF22C55E)
                          : const Color(0xFFEF4444),
                      size: 14.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      controller.cardStatus,
                      style: GoogleFonts.manrope(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: controller.hasCard.value
                            ? const Color(0xFF22C55E)
                            : const Color(0xFFEF4444),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: () async {
              await Get.toNamed(AppRoutes.PAYMENT_METHODS);
              controller.fetchPaymentMethods();
            },
            child: Text(
              controller.hasCard.value ? 'Change' : 'Add Card',
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF3B82F6),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurePaymentInfo() {
    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: const Color(0xFFEFF6FF),
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(color: const Color(0xFFBFDBFE)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.verified_user_outlined,
            color: const Color(0xFF2563EB),
            size: 24.sp,
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: GoogleFonts.manrope(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w500,
                  color: const Color(0xFF1E40AF),
                  height: 1.5,
                ),
                children: [
                  WidgetSpan(
                    child: Padding(
                      padding: EdgeInsets.only(right: 6.w),
                      child: Icon(
                        Icons.lock_outline_rounded,
                        color: const Color(0xFF2563EB),
                        size: 14.sp,
                      ),
                    ),
                  ),
                  const TextSpan(
                    text: 'Secure Payment\n',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF2563EB),
                    ),
                  ),
                  const TextSpan(text: 'You will '),
                  const TextSpan(
                    text: 'only be charged for the actual minutes used',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                  const TextSpan(
                    text:
                        '. The total amount is a temporary hold on your card.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    final isEnabled = controller.hasCard.value && !controller.isLoading.value;

    return Container(
      width: double.infinity,
      height: 60.h,
      decoration: BoxDecoration(
        gradient: isEnabled
            ? const LinearGradient(
                colors: [Color(0xFFFF6B00), Color(0xFFFF8A00)],
              )
            : null,
        color: isEnabled ? null : const Color(0xFFCBD5E1),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: isEnabled
            ? [
                BoxShadow(
                  color: const Color(0xFFFF6B00).withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ]
            : [],
      ),

      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled ? () => controller.startVideoCall() : null,
          borderRadius: BorderRadius.circular(20.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.lock_rounded,
                color: isEnabled ? Colors.white : const Color(0xFF94A3B8),
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Text(
                'Authorize Payment & Start Call',
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: isEnabled ? Colors.white : const Color(0xFF94A3B8),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
