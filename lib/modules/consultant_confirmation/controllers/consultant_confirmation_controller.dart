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
  String get consultantFee => consultantFeeRx.value;
  String get platformFee => platformFeeRx.value;
  String get vat => vatRx.value;
  String get totalHold => totalHoldRx.value;
  String get cardNumber => cardNumberRx.value;
  String get cardStatus => cardStatusRx.value;

  final hasCard = false.obs;
  final isLoading = false.obs;
  BookingModel? booking;

  @override
  void onInit() {
    super.onInit();

    // Check for booking in route arguments
    if (Get.arguments is BookingModel) {
      booking = Get.arguments as BookingModel;
      _loadBookingData(booking!);
    } else if (Get.arguments is Map &&
        Get.arguments['booking'] is BookingModel) {
      booking = Get.arguments['booking'] as BookingModel;
      _loadBookingData(booking!);
    }

    fetchPaymentMethods();
  }

  void _loadBookingData(BookingModel booking) {
    final consultant = booking.consultant;
    if (consultant != null) {
      consultantNameRx.value = consultant.name ?? 'Consultant';
      consultantCategoryRx.value =
          consultant.expertise ?? consultant.consultancyType ?? 'Expert';
      consultantImageRx.value = consultant.image ?? '';

      final rate = consultant.perMinuteRate ?? 4;
      consultantRateRx.value = '€${rate.toStringAsFixed(2)} / min';

      // Calculate billing details (e.g. assume a standard 30 min hold structure)
      final rateNum = rate.toDouble();
      final fee = rateNum * 30.0; // standard hold calculation base
      final platFee = 5.0;
      final holdSubtotal = fee + platFee;
      final vatAmount = holdSubtotal * 0.19; // 19% VAT
      final total = holdSubtotal + vatAmount;

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
    if (booking == null) {
      Get.snackbar('Error', 'Invalid booking details');
      return;
    }

    try {
      isLoading.value = true;
      Get.snackbar(
        'Payment Authorized',
        'Connecting to the consultant...',
        snackPosition: SnackPosition.BOTTOM,
        showProgressIndicator: true,
      );

      // 1. Create or get session
      final sessionResponse = await _userRepository.createVideoSession(
        booking!.id!,
      );

      if (sessionResponse.statusCode == 200 ||
          sessionResponse.statusCode == 201) {
        final sessionData = sessionResponse.data['data'];
        final sessionId = sessionData['_id'];

        // 2. Join session to get token/channel
        final joinResponse = await _userRepository.joinVideoSession(sessionId);

        if (joinResponse.statusCode == 200) {
          final joinData = joinResponse.data['data'];

          Get.offNamed(
            AppRoutes.VIDEO_CALL,
            arguments: {
              'booking': booking,
              'sessionId': sessionId,
              'token': joinData['token'],
              'channelName': joinData['channelName'] ?? sessionId,
            },
          );
        } else if (joinResponse.statusCode == 402) {
          Get.find<AuthService>().showPaymentRequiredDialog();
        } else {
          Get.snackbar(
            'Error',
            joinResponse.statusMessage ?? 'Failed to join video call',
          );
        }
      }
    } catch (e) {
      Get.snackbar('Error', 'Could not start video call. Please try again.');
    } finally {
      isLoading.value = false;
    }
  }
}
