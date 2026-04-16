import 'package:get/get.dart';

class ConsultantProfileController extends GetxController {
  final isAboutExpanded = false.obs;

  void toggleAboutExpansion() {
    isAboutExpanded.value = !isAboutExpanded.value;
  }

  final expertData = {
    'name': 'Sarah Müller',
    'role': 'Tax Consultation',
    'rating': '4.8',
    'reviewsCount': '89',
    'pricePerMin': '4.00€/min',
    'instantCallPrice': '3,20€/min',
    'experience': '8 Years',
    'consultations': '1k+',
    'languages': 'German',
    'about':
        'Certified Tax Advisor (Steuerberaterin) specializing in freelance and small business taxation in Germany. With over 8 years of experience, I help freelancers, startups, and small businesses navigate the complexities of German tax law, ensuring compliance while maximizing financial efficiency. My services include annual tax return preparation, VAT (Umsatzsteuer) optimization, payroll accounting, and strategic tax planning. I am committed to providing clear, actionable advice tailored to your specific business needs. Whether you are just starting out or looking to optimize your existing structure, I am here to support your financial success.',
    'isOnline': true,
    'isVerified': true,
  }.obs;

  final reviews = [
    {
      'name': 'Max M.',
      'date': '2 days ago',
      'rating': 5,
      'comment':
          'Very professional and knowledgeable. Solved my issue in just 15 minutes. Highly recommended for quick consultations!',
      'avatar': '', // Placeholder
    },
  ].obs;
}
