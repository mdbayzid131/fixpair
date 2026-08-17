import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fixpair/core/services/api_checker.dart';
import 'package:fixpair/core/services/auth_service.dart';
import 'package:get/get.dart';
import '../../../data/models/user_model.dart';
import '../../../data/repositories/user_repository.dart';
import '../../../config/routes/app_pages.dart';

class ConsultantConfirmationController extends GetxController {
  final UserRepository _userRepository = Get.find();

  // Reactive fields
  final consultantNameRx = 'Sarah Müller'.obs;
  final consultantCategoryRx = 'Tax Consultation'.obs;
  final consultantImageRx = ''.obs;
  final consultantRateRx = '€4.00 / min'.obs;
  final consultantFeeLabelRx = 'Consultant Fee'.obs;
  final consultantFeeRx = '€75.00'.obs;
  final platformFeeRx = '€5.00'.obs;
  final vatRx = '€20.00'.obs;
  final totalHoldRx = '€100.00'.obs;

  final cardNumberRx = '**** 4242'.obs;
  final cardStatusRx = 'Ready to pay'.obs;

  // Getters for view compatibility
  String get consultantName => consultantNameRx.value;
  String get consultantCategory => consultantCategoryRx.value;
  String get consultantImage => consultantImageRx.value;
  String get consultantRate => consultantRateRx.value;
  String get consultantFeeLabel => consultantFeeLabelRx.value;
  String get consultantFee => consultantFeeRx.value;
  String get platformFee => platformFeeRx.value;
  String get vat => vatRx.value;
  String get totalHold => totalHoldRx.value;
  String get cardNumber => cardNumberRx.value;
  String get cardStatus => cardStatusRx.value;

  final hasCard = false.obs;
  final isLoading = false.obs;
  final Rxn<UserData> expert = Rxn<UserData>();
  BookingModel? booking;

  @override
  void onInit() {
    super.onInit();

    // Check for booking or expert in route arguments
    final args = Get.arguments;
    if (args is BookingModel) {
      booking = args;
      _loadBookingData(booking!);
    } else if (args is UserData) {
      expert.value = args;
      _loadExpertData(expert.value!);
    } else if (args is Map) {
      if (args['booking'] is BookingModel) {
        booking = args['booking'] as BookingModel;
        _loadBookingData(booking!);
      } else if (args['expert'] is UserData) {
        expert.value = args['expert'] as UserData;
        _loadExpertData(expert.value!);
      }
    }

    fetchPaymentMethods();
  }

  int _getBookingDurationInMinutes(BookingModel b) {
    if (b.startTime != null && b.endTime != null && b.startTime!.isNotEmpty && b.endTime!.isNotEmpty) {
      try {
        final startParts = b.startTime!.trim().split(':').map((e) => int.parse(e.trim())).toList();
        final endParts = b.endTime!.trim().split(':').map((e) => int.parse(e.trim())).toList();
        if (startParts.length >= 2 && endParts.length >= 2) {
          int startMins = startParts[0] * 60 + startParts[1];
          int endMins = endParts[0] * 60 + endParts[1];
          int diff = endMins - startMins;
          if (diff > 0) return diff;
        }
      } catch (_) {}
    }

    if (b.notes != null && b.notes!.trim().isNotEmpty) {
      final parsed = int.tryParse(b.notes!.trim());
      if (parsed != null && parsed > 0) return parsed;
    }

    if (b.bookingType?.toLowerCase() == 'instant') {
      return 15;
    }
    return 30;
  }

  void _loadExpertData(UserData expertData) {
    expert.value = expertData;
    consultantNameRx.value = expertData.name ?? 'Consultant';
    consultantCategoryRx.value =
        expertData.expertise ?? expertData.consultancyType ?? 'Expert';
    consultantImageRx.value = expertData.image ?? expertData.avatar ?? '';

    final rate = (expertData.perMinuteRate != null && expertData.perMinuteRate != 0)
        ? expertData.perMinuteRate!
        : 4;
    consultantRateRx.value = '€${rate.toDouble().toStringAsFixed(2)} / min';

    final rateNum = rate.toDouble();
    final duration = 15; // 15-minute initial hold for instant call pre-authorization
    final fee = rateNum * duration.toDouble();
    final platFee = 5.0;
    final holdSubtotal = fee + platFee;
    final vatAmount = holdSubtotal * 0.19;
    final total = holdSubtotal + vatAmount;

    consultantFeeLabelRx.value = '${'Consultant Fee'.tr} ($duration min)';
    consultantFeeRx.value = '€${fee.toStringAsFixed(2)}';
    platformFeeRx.value = '€${platFee.toStringAsFixed(2)}';
    vatRx.value = '€${vatAmount.toStringAsFixed(2)}';
    totalHoldRx.value = '€${total.toStringAsFixed(2)}';
  }

  void _loadBookingData(BookingModel bookingData) {
    booking = bookingData;
    final consultant = bookingData.consultant;
    if (consultant != null) {
      expert.value = consultant;
      consultantNameRx.value = consultant.name ?? 'Consultant';
      consultantCategoryRx.value =
          consultant.expertise ?? consultant.consultancyType ?? 'Expert';
      consultantImageRx.value = consultant.image ?? consultant.avatar ?? '';

      final rate = (bookingData.perMinuteRate != null && bookingData.perMinuteRate != 0)
          ? bookingData.perMinuteRate!
          : (consultant.perMinuteRate != null && consultant.perMinuteRate != 0)
          ? consultant.perMinuteRate!
          : 4;
      consultantRateRx.value = '€${rate.toDouble().toStringAsFixed(2)} / min';

      final rateNum = rate.toDouble();
      final duration = _getBookingDurationInMinutes(bookingData);
      final fee = rateNum * duration.toDouble();
      final platFee = 5.0;
      final holdSubtotal = fee + platFee;
      final vatAmount = holdSubtotal * 0.19;
      final total = holdSubtotal + vatAmount;

      String durationText = '$duration min';
      if (duration == 60) durationText = '1 hr';
      if (duration == 120) durationText = '2 hrs';

      consultantFeeLabelRx.value = '${'Consultant Fee'.tr} ($durationText)';
      consultantFeeRx.value = '€${fee.toStringAsFixed(2)}';
      platformFeeRx.value = '€${platFee.toStringAsFixed(2)}';
      vatRx.value = '€${vatAmount.toStringAsFixed(2)}';
      totalHoldRx.value = '€${total.toStringAsFixed(2)}';
    }
  }

  Future<void> fetchPaymentMethods() async {
    try {
      isLoading.value = true;
      final response = await _userRepository.getPaymentMethods();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final List<dynamic> data = response.data['data'] ?? [];
        if (data.isNotEmpty) {
          hasCard.value = true;
          final card = data.first;
          final last4 = card['last4'] ?? '4242';
          final brand = card['brand'] ?? 'card';
          cardNumberRx.value = '${brand.toString().toUpperCase()} **** $last4';
          cardStatusRx.value = 'Ready to pay';
        } else {
          hasCard.value = false;
          cardNumberRx.value = 'No saved card';
          cardStatusRx.value = 'Please add a payment card';
        }
      } else {
        hasCard.value = false;
        cardNumberRx.value = 'No saved card';
        cardStatusRx.value = 'Please add a payment card';
      }
    } catch (e) {
      hasCard.value = false;
      cardNumberRx.value = 'No saved card';
      cardStatusRx.value = 'Error loading payment methods';
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> startVideoCall() async {
    try {
      isLoading.value = true;

      BookingModel? targetBooking = booking;
      String? channelName;
      String? token;
      String? sessionId;

      if (targetBooking == null && expert.value != null) {
        // Create instant consultation booking
        final body = {
          "consultantId": expert.value!.id,
          "bookingType": "instant",
        };

        final response = await _userRepository.bookConsultation(body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          final resData = response.data['data'];
          Map<String, dynamic> consultationJson = {};
          if (resData is Map) {
            if (resData.containsKey('consultation') &&
                resData['consultation'] is Map) {
              consultationJson =
                  Map<String, dynamic>.from(resData['consultation']);
            } else {
              consultationJson = Map<String, dynamic>.from(resData);
            }

            if (resData.containsKey('session') && resData['session'] is Map) {
              final sessionMap = resData['session'];
              channelName = sessionMap['channelName']?.toString();
              token = sessionMap['token']?.toString();
              sessionId = sessionMap['_id']?.toString() ??
                  sessionMap['id']?.toString() ??
                  sessionMap['consultation']?.toString();
            }
          }

          targetBooking = BookingModel.fromJson(consultationJson);
          if (targetBooking.consultant == null ||
              targetBooking.consultant?.name == null) {
            targetBooking = targetBooking.copyWith(consultant: expert.value);
          }
        } else if (response.statusCode == 409) {
          showConsultantBusyDialog();
          return;
        } else if (response.statusCode == 402) {
          Get.find<AuthService>().showPaymentRequiredDialog();
          return;
        } else {
          ApiChecker.checkWriteApi(response);
          return;
        }
      }

      if (targetBooking == null) {
        Get.snackbar('Error'.tr, 'Invalid booking details'.tr);
        return;
      }

      // If token/channelName was not directly present in instant booking response, fetch session via standard video-session APIs
      if (channelName == null || token == null || sessionId == null) {
        final sessionResponse = await _userRepository.createVideoSession(
          targetBooking.id!,
        );

        if (sessionResponse.statusCode == 200 ||
            sessionResponse.statusCode == 201) {
          final sessionData = sessionResponse.data['data'];
          sessionId = sessionData['_id'] ?? sessionData['id'];

          final joinResponse =
              await _userRepository.joinVideoSession(sessionId!);

          if (joinResponse.statusCode == 200) {
            final joinData = joinResponse.data['data'];
            token = joinData['token'];
            channelName = joinData['channelName'] ?? sessionId;
          } else if (joinResponse.statusCode == 402) {
            Get.find<AuthService>().showPaymentRequiredDialog();
            return;
          } else {
            Get.snackbar(
              'Error'.tr,
              joinResponse.statusMessage ?? 'Failed to join video call'.tr,
            );
            return;
          }
        } else {
          ApiChecker.checkWriteApi(sessionResponse);
          return;
        }
      }

      isLoading.value = false;
      Future.microtask(() {
        Get.offNamed(
          AppRoutes.VIDEO_CALL,
          arguments: {
            'booking': targetBooking,
            'sessionId': sessionId,
            'token': token,
            'channelName': channelName,
          },
        );
      });
      return;
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Could not start video call. Please try again.'.tr,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void showConsultantBusyDialog() {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(28.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(28.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(20.w),
                decoration: BoxDecoration(
                  color: const Color(0xFFFEF3C7), // Soft amber bg
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFFFEF3C7).withOpacity(0.5),
                    width: 4,
                  ),
                ),
                child: Icon(
                  Icons.phone_callback_rounded,
                  color: const Color(0xFFD97706), // Amber color
                  size: 36.sp,
                ),
              ),
              SizedBox(height: 24.h),
              Text(
                'Consultant on Another Call'.tr,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.manrope(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1D293D),
                  letterSpacing: 0.2,
                ),
              ),
              SizedBox(height: 12.h),
              Text(
                'This consultant is currently busy on another call. Would you like to request a callback or schedule a booking instead.'.tr,
                textAlign: TextAlign.center,
                style: GoogleFonts.manrope(
                  fontSize: 15.sp,
                  color: const Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 28.h),
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed(
                          AppRoutes.REQUEST_CALLBACK,
                          arguments: expert.value,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0066FF),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Request Callback'.tr,
                        style: GoogleFonts.manrope(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () {
                        Get.back();
                        Get.toNamed(
                          AppRoutes.SCHEDULE_BOOKING,
                          arguments: expert.value,
                        );
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFE2E8F0)),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                      ),
                      child: Text(
                        'Schedule a Booking'.tr,
                        style: GoogleFonts.manrope(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF1D293D),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextButton(
                    onPressed: () => Get.back(),
                    child: Text(
                      'Cancel'.tr,
                      style: GoogleFonts.manrope(
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF64748B),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }
}
