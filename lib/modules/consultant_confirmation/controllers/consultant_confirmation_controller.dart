import 'package:get/get.dart';

class ConsultantConfirmationController extends GetxController {
  // Mock billing data as per image
  final consultantName = 'Sarah Müller';
  final consultantCategory = 'Tax Consultation';
  final consultantRate = '€4.00 / min';
  final consultantFee = '€75.00';
  final platformFee = '€5.00';
  final vat = '€20.00';
  final totalHold = '€100.00';

  final cardNumber = '**** 4242';
  final cardStatus = 'Ready to pay';

  void authorizePayment() {
    Get.snackbar(
      'Payment Authorized',
      'Connecting to the consultant...',
      snackPosition: SnackPosition.BOTTOM,
    );
  }
}
