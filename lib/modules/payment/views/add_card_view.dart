import 'package:fixpair/core/utils/helpers.dart';
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
      appBar: AppBar(
        title: Text(
          'Add Payment Method',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(24.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Credit or Debit Card',
              style: GoogleFonts.manrope(
                fontSize: 16.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF1D293D),
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              'Add a card to your account for secure payments.',
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                color: const Color(0xFF64748B),
              ),
            ),
            SizedBox(height: 32.h),
            
            // Stripe Card Field
            Container(
              padding: EdgeInsets.all(16.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
                border: Border.all(color: const Color(0xFFE2E8F0)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: CardField(
                onCardChanged: (card) {
                  // Handle card change if needed
                },
                decoration: InputDecoration(
                  border: InputBorder.none,
                ),
              ),
            ),
            
            SizedBox(height: 48.h),
            
            Obx(() => SizedBox(
              width: double.infinity,
              height: 56.h,
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
                          controller.handleAttachMethod(paymentMethod.id);
                        } catch (e) {
                          controller.isLoading.value = false;
                          Helpers.showDebugLog('Stripe Error: $e');
                          Get.snackbar(
                            'Payment Error', 
                            e.toString().contains('canceled') ? 'Card collection canceled' : 'Please check your card details',
                            snackPosition: SnackPosition.BOTTOM,
                            backgroundColor: Colors.red.withOpacity(0.8),
                            colorText: Colors.white,
                          );
                        }
                      },

                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0066FF),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16.r),
                  ),
                  elevation: 0,
                ),
                child: controller.isLoading.value
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(
                        'Save Card',
                        style: GoogleFonts.manrope(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
              ),
            )),
            
            SizedBox(height: 24.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.lock_outline_rounded, size: 16.sp, color: const Color(0xFF94A3B8)),
                SizedBox(width: 8.w),
                Text(
                  'Secured by Stripe',
                  style: GoogleFonts.manrope(
                    fontSize: 12.sp,
                    color: const Color(0xFF94A3B8),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
