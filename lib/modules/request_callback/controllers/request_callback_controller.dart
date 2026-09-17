import 'package:fixpair/config/routes/app_pages.dart';
import 'package:fixpair/core/services/api_checker.dart';
import 'package:fixpair/core/utils/helpers.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';

class RequestCallbackController extends GetxController {
  final UserRepository _userRepository = Get.find();
  final Rxn<UserData> expert = Rxn<UserData>();
  final isLoading = false.obs;

  final selectedTimeOption = 0.obs; // 0: ASAP, 1: Today, 2: Tomorrow

  final phoneController = TextEditingController(text: '+49 151 23456789');
  final reasonController = TextEditingController();

  final timeOptions = [
    {
      'title': 'As soon as possible',
      'subtitle': 'Usually within 2 hours',
      'value': 'asap',
    },
    {
      'title': 'Sometime Today',
      'subtitle': 'Before 18:00 CET',
      'value': 'today',
    },
    {
      'title': 'Tomorrow',
      'subtitle': 'Anytime during business hours',
      'value': 'tomorrow',
    },
  ];

  @override
  void onInit() {
    super.onInit();
    if (Get.arguments is UserData) {
      expert.value = Get.arguments as UserData;
    }
  }

  void selectOption(int index) {
    selectedTimeOption.value = index;
  }

  Future<void> submitCallback() async {
    if (expert.value == null) return;

    try {
      isLoading.value = true;

      // 1. Check if user has added a payment card
      final paymentRes = await _userRepository.getPaymentMethods();
      final List<dynamic> cards =
          (paymentRes.statusCode == 200 || paymentRes.statusCode == 201)
              ? (paymentRes.data['data'] ?? [])
              : [];

      if (cards.isEmpty) {
        isLoading.value = false;
        showAddCardRequiredDialog();
        return;
      }

      // 2. Submit callback booking
      final body = {
        "consultantId": expert.value!.id,
        "bookingType": "callback",
        "preferredWindow": timeOptions[selectedTimeOption.value]['value'],
        "notes": reasonController.text,
      };

      final response = await _userRepository.bookConsultation(body);
      ApiChecker.checkWriteApi(response);
      if (response.statusCode == 200 || response.statusCode == 201) {
        isLoading.value = false;
        Helpers.showBookingSuccess();
        Future.microtask(() {
          Get.offAllNamed(AppRoutes.BOTTOM_NAV_BAR, arguments: 2);
        });
        return;
      }
    } catch (e) {
      Helpers.showDebugLog('Callback request error: $e');
    } finally {
      isLoading.value = false;
    }
  }

  void showAddCardRequiredDialog() {
    Get.dialog(
      barrierDismissible: true,
      Dialog(
        backgroundColor: Colors.transparent,
        elevation: 0,
        insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Container(
          width: double.infinity,
          constraints: BoxConstraints(maxWidth: 380.w),
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.96),
            borderRadius: BorderRadius.circular(24.r),
            border: Border.all(
              color: const Color(0xFF0066FF).withValues(alpha: 0.4),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF0066FF).withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64.w,
                height: 64.w,
                decoration: BoxDecoration(
                  color: const Color(0xFF0066FF).withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.credit_card_rounded,
                  color: const Color(0xFF0066FF),
                  size: 32.sp,
                ),
              ),
              SizedBox(height: 18.h),
              Text(
                'Payment Method Required'.tr,
                style: GoogleFonts.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 10.h),
              Text(
                'Please add a credit or debit card before requesting a callback consultation.'.tr,
                style: GoogleFonts.manrope(
                  fontSize: 13.5.sp,
                  fontWeight: FontWeight.w400,
                  color: const Color(0xFF94A3B8),
                  height: 1.45,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: SizedBox(
                      height: 46.h,
                      child: OutlinedButton(
                        onPressed: () => Get.back(),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFF334155)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Cancel'.tr,
                            style: GoogleFonts.manrope(
                              color: const Color(0xFF94A3B8),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: SizedBox(
                      height: 46.h,
                      child: ElevatedButton(
                        onPressed: () {
                          Get.back();
                          Get.toNamed(AppRoutes.PAYMENT_METHODS);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0066FF),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 8.w),
                        ),
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'Add Card'.tr,
                            style: GoogleFonts.manrope(
                              color: Colors.white,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void onClose() {
    phoneController.dispose();
    reasonController.dispose();
    super.onClose();
  }
}
