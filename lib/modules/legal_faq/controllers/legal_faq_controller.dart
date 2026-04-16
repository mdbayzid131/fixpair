import 'package:get/get.dart';

class LegalFAQController extends GetxController {
  // Use a List of bools to track expansion state of each item independently
  final expandedStates = <bool>[].obs;

  @override
  void onInit() {
    super.onInit();
    // Initialize all as collapsed (false), except the first one (true) to match screenshot
    expandedStates.value = List.generate(
      faqItems.length,
      (index) => index == 0,
    );
  }

  void toggleExpanded(int index) {
    expandedStates[index] = !expandedStates[index];
  }

  final faqItems = [
    {
      'question': 'How does the cost tracker work?',
      'answer':
          'The cost tracker calculates the price in real-time based on the consultant\'s hourly rate and the duration of your call. VAT is already included for German residents.',
    },
    {
      'question': 'Can I cancel a consultation?',
      'answer':
          'Yes, you can cancel up to 24 hours before the scheduled time without any fees. Cancellations within 24 hours will incur a 50% charge.',
    },
    {
      'question': 'How do I get an invoice?',
      'answer':
          'Invoices are automatically generated and sent to your email after every consultation. They include all necessary VAT details for your tax records.',
    },
    {
      'question': 'Are the consultants verified?',
      'answer':
          'Absolutely. We strictly verify all professionals on our platform to ensure the highest quality of service.',
    },
  ];
}
