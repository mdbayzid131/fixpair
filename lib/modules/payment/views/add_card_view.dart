import 'package:fixpair/core/utils/helpers.dart';
import 'package:fixpair/core/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../controllers/payment_controller.dart';

class AddCardView extends GetView<PaymentController> {
  const AddCardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar.build(
        title: 'Add Credit Card'.tr,
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visual Card Preview Header
            _buildVisualCardPreview(),

            SizedBox(height: 28.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Card Details',
                  style: GoogleFonts.manrope(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF0F172A),
                  ),
                ),
                // Accepted Providers mini badge row
                Row(
                  children: [
                    _buildProviderPill('VISA'),
                    SizedBox(width: 4.w),
                    _buildProviderPill('MC'),
                    SizedBox(width: 4.w),
                    _buildProviderPill('AMEX'),
                    SizedBox(width: 4.w),
                    _buildProviderPill('DISC'),
                  ],
                ),
              ],
            ),
            SizedBox(height: 6.h),
            Text(
              'Enter your credit or debit card details below. We accept Visa, Mastercard, American Express, and Discover.',
              style: GoogleFonts.manrope(
                fontSize: 13.sp,
                color: const Color(0xFF64748B),
                height: 1.4,
              ),
            ),

            SizedBox(height: 20.h),

            // Stripe Card Form Container
            Container(
              padding: EdgeInsets.all(18.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF0F172A).withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Column(
                children: [
                  CardField(
                    onCardChanged: (card) {
                      // Stripe Card Field callback
                    },
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: const Color(0xFF0F172A),
                      fontFamily: GoogleFonts.manrope().fontFamily,
                    ),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintStyle: GoogleFonts.manrope(
                        color: const Color(0xFF94A3B8),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 36.h),

            // Save Card Action Button
            Obx(
              () => SizedBox(
                width: double.infinity,
                height: 54.h,
                child: ElevatedButton(
                  onPressed: controller.isLoading.value
                      ? null
                      : () async {
                          try {
                            controller.isLoading.value = true;
                            final paymentMethod = await Stripe.instance.createPaymentMethod(
                              params: const PaymentMethodParams.card(
                                paymentMethodData: PaymentMethodData(),
                              ),
                            );
                            await controller.handleAttachMethod(paymentMethod.id);
                          } catch (e) {
                            controller.isLoading.value = false;
                            Helpers.showDebugLog('Stripe Error: $e');
                            Get.snackbar(
                              'Card Validation Error'.tr,
                              e.toString().contains('canceled')
                                  ? 'Card creation canceled'.tr
                                  : 'Please check your card details and try again'.tr,
                              snackPosition: SnackPosition.BOTTOM,
                              backgroundColor: Colors.red.withValues(alpha: 0.9),
                              colorText: Colors.white,
                              margin: const EdgeInsets.all(16),
                              borderRadius: 12,
                            );
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2563EB),
                    disabledBackgroundColor: const Color(0xFF93C5FD),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16.r),
                    ),
                    elevation: 4,
                    shadowColor: const Color(0xFF2563EB).withValues(alpha: 0.3),
                  ),
                  child: controller.isLoading.value
                      ? SizedBox(
                          width: 24.w,
                          height: 24.w,
                          child: const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2.5,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.lock_rounded, size: 18.sp, color: Colors.white),
                            SizedBox(width: 8.w),
                            Text(
                              'Save & Link Card',
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
            ),

            SizedBox(height: 24.h),

            // Security Footer
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
                decoration: BoxDecoration(
                  color: const Color(0xFFF1F5F9),
                  borderRadius: BorderRadius.circular(30.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified_user_rounded,
                      size: 16.sp,
                      color: const Color(0xFF10B981),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      '256-Bit SSL Encrypted • PCI-DSS Compliant',
                      style: GoogleFonts.manrope(
                        fontSize: 12.sp,
                        color: const Color(0xFF475569),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisualCardPreview() {
    return AspectRatio(
      aspectRatio: 1.586,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20.r),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0A192F),
              Color(0xFF112240),
              Color(0xFF1E3A8A),
              Color(0xFF0F172A),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.35),
              blurRadius: 18,
              offset: const Offset(0, 9),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20.r),
          child: Stack(
            children: [
              // Glossy Glare Sheen Overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.white.withValues(alpha: 0.25),
                        Colors.white.withValues(alpha: 0.05),
                        Colors.transparent,
                        Colors.white.withValues(alpha: 0.1),
                      ],
                      stops: const [0.0, 0.35, 0.65, 1.0],
                    ),
                  ),
                ),
              ),

              Padding(
                padding: EdgeInsets.all(22.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Top Row: EMV Chip, Contactless & Brand Badge
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            // EMV Chip
                            Container(
                              width: 42.w,
                              height: 30.h,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFFF6D365),
                                    Color(0xFFFDA085),
                                    Color(0xFFD4AF37),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6.r),
                                border: Border.all(color: const Color(0xFFB8860B), width: 0.8),
                              ),
                              child: Stack(
                                children: [
                                  Positioned(
                                    top: 13.h,
                                    left: 0,
                                    right: 0,
                                    child: Container(height: 1, color: Colors.black38),
                                  ),
                                  Positioned(
                                    left: 14.w,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(width: 1, color: Colors.black38),
                                  ),
                                  Positioned(
                                    left: 28.w,
                                    top: 0,
                                    bottom: 0,
                                    child: Container(width: 1, color: Colors.black38),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Icon(
                              Icons.wifi_tethering_rounded,
                              color: Colors.white.withValues(alpha: 0.8),
                              size: 22.sp,
                            ),
                          ],
                        ),

                        // Holographic Foil & Card Brand Logo
                        Row(
                          children: [
                            Container(
                              width: 24.w,
                              height: 24.w,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: const SweepGradient(
                                  colors: [
                                    Colors.red,
                                    Colors.yellow,
                                    Colors.green,
                                    Colors.cyan,
                                    Colors.blue,
                                    Colors.purple,
                                    Colors.red,
                                  ],
                                ),
                                border: Border.all(color: Colors.white38, width: 1),
                              ),
                            ),
                            SizedBox(width: 10.w),
                            Container(
                              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 3.h),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(6.r),
                              ),
                              child: Text(
                                'CARD',
                                style: GoogleFonts.poppins(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w900,
                                  fontStyle: FontStyle.italic,
                                  color: const Color(0xFF1A1F71),
                                  letterSpacing: 1.2,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    // Masked Number with 3D Embossed Effect
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildEmbossedText('••••'),
                        _buildEmbossedText('••••'),
                        _buildEmbossedText('••••'),
                        _buildEmbossedText('••••'),
                      ],
                    ),

                    // Footer Details: Name & Expiry
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'CARD HOLDER',
                              style: GoogleFonts.manrope(
                                fontSize: 8.sp,
                                color: Colors.white54,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'YOUR NAME HERE',
                              style: GoogleFonts.manrope(
                                fontSize: 11.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'VALID THRU',
                              style: GoogleFonts.manrope(
                                fontSize: 8.sp,
                                color: Colors.white54,
                                fontWeight: FontWeight.w600,
                                letterSpacing: 1,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'MM/YY',
                              style: GoogleFonts.shareTechMono(
                                fontSize: 12.sp,
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmbossedText(String text) {
    return Text(
      text,
      style: GoogleFonts.shareTechMono(
        fontSize: 19.sp,
        color: Colors.white,
        fontWeight: FontWeight.w700,
        letterSpacing: 2,
        shadows: const [
          Shadow(
            offset: Offset(1, 1),
            blurRadius: 1,
            color: Colors.black54,
          ),
          Shadow(
            offset: Offset(-0.5, -0.5),
            blurRadius: 1,
            color: Colors.white24,
          ),
        ],
      ),
    );
  }

  Widget _buildProviderPill(String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: const Color(0xFFF1F5F9),
        borderRadius: BorderRadius.circular(4.r),
        border: Border.all(color: const Color(0xFFCBD5E1)),
      ),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          fontSize: 9.sp,
          fontWeight: FontWeight.w800,
          color: const Color(0xFF475569),
        ),
      ),
    );
  }
}
