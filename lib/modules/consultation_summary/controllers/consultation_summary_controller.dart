import 'package:get/get.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/models/transcript_message.dart';

class ConsultationSummaryController extends GetxController {
  final rating = 0.obs;
  final reviewController = TextEditingController();
  
  BookingModel? booking;
  final consultantName = ''.obs;
  final date = ''.obs;
  final duration = ''.obs;
  final rate = ''.obs;
  final vat = ''.obs;
  final totalCharged = ''.obs;
  final transcript = <TranscriptMessage>[].obs;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments;
    if (args != null) {
      final bookingArg = args['booking'];
      if (bookingArg != null && bookingArg is BookingModel) {
        booking = bookingArg;
        consultantName.value = booking?.consultant?.name ?? 'Consultant';
        date.value = booking?.date != null
            ? DateFormat('dd.MM.yyyy').format(booking!.date!)
            : DateFormat('dd.MM.yyyy').format(DateTime.now());
        
        final double rateVal = booking?.perMinuteRate?.toDouble() ?? 4.0;
        rate.value = '${rateVal.toStringAsFixed(2)}€ / min';
      }

      final int durationSecs = args['duration'] ?? 0;
      int minutes = durationSecs ~/ 60;
      int seconds = durationSecs % 60;
      duration.value = minutes > 0 ? '$minutes min $seconds sec' : '$seconds sec';

      final double costVal = args['cost'] ?? 0.0;
      totalCharged.value = '${costVal.toStringAsFixed(2)}€';
      final double vatVal = costVal * 0.19;
      vat.value = '${vatVal.toStringAsFixed(2)}€';

      final transcriptArg = args['transcript'];
      if (transcriptArg != null && transcriptArg is List<TranscriptMessage>) {
        transcript.assignAll(transcriptArg);
      }
    }
  }

  void setRating(int value) => rating.value = value;

  void submitReview() {
    Get.snackbar(
      'Success',
      'Thank you for your feedback!',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  @override
  void onClose() {
    reviewController.dispose();
    super.onClose();
  }
}
