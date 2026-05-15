import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../config/routes/app_pages.dart';
import '../controllers/payment_controller.dart';

class PaymentMethodsView extends GetView<PaymentController> {
  const PaymentMethodsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(
          'Payment Methods',
          style: GoogleFonts.manrope(
            fontWeight: FontWeight.w700,
            fontSize: 18.sp,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.paymentMethods.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }

        return RefreshIndicator(
          onRefresh: controller.fetchPaymentMethods,
          child: ListView(
            padding: EdgeInsets.all(24.w),
            children: [
              Text(
                'Your saved cards',
                style: GoogleFonts.manrope(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF1D293D),
                ),
              ),
              SizedBox(height: 16.h),
              
              if (controller.paymentMethods.isEmpty)
                _buildEmptyState()
              else
                ...controller.paymentMethods.map((method) => _buildCardItem(method)),
              
              SizedBox(height: 32.h),
              
              _buildAddCardButton(),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildCardItem(dynamic method) {
    final String last4 = method['last4'] ?? '****';
    final String brand = (method['brand'] ?? 'card').toString().toUpperCase();
    final bool isDefault = method['isDefault'] ?? false;

    return Container(
      margin: EdgeInsets.only(bottom: 16.h),
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.r),
        border: Border.all(
          color: isDefault ? const Color(0xFF0066FF) : const Color(0xFFE2E8F0),
          width: isDefault ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 50.w,
            height: 50.w,
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.credit_card_rounded,
              color: const Color(0xFF1D293D),
              size: 24.sp,
            ),
          ),
          SizedBox(width: 16.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$brand **** $last4',
                  style: GoogleFonts.manrope(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF1D293D),
                  ),
                ),
                if (isDefault)
                  Text(
                    'Default Payment Method',
                    style: GoogleFonts.manrope(
                      fontSize: 12.sp,
                      color: const Color(0xFF0066FF),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
              ],
            ),
          ),
          if (isDefault)
            const Icon(Icons.check_circle_rounded, color: Color(0xFF0066FF)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 40.h),
      alignment: Alignment.center,
      child: Column(
        children: [
          Icon(Icons.credit_card_off_rounded, size: 64.sp, color: const Color(0xFFCBD5E1)),
          SizedBox(height: 16.h),
          Text(
            'No cards added yet',
            style: GoogleFonts.manrope(
              fontSize: 15.sp,
              color: const Color(0xFF64748B),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddCardButton() {
    return InkWell(
      onTap: () => Get.toNamed(AppRoutes.ADD_CARD),
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: const Color(0xFFF1F5F9),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: const Color(0xFFE2E8F0), style: BorderStyle.none),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.add_rounded, color: Color(0xFF0066FF)),
            SizedBox(width: 8.w),
            Text(
              'Add New Card',
              style: GoogleFonts.manrope(
                fontSize: 15.sp,
                color: const Color(0xFF0066FF),
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
