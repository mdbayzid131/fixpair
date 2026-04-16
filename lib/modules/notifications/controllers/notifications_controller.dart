import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final notifications = <Map<String, dynamic>>[
    {
      'title': 'Consultation Tomorrow',
      'description':
          'Your call with Dr. Schmidt is scheduled for tomorrow at 14:00 CET.',
      'time': '2 HOURS AGO',
      'type': 'consultation',
      'isRead': false,
    },
    {
      'title': 'Payment Successful',
      'description':
          'Your payment of €120.00 (incl. VAT) was processed successfully.',
      'time': '1 DAY AGO',
      'type': 'payment',
      'isRead': false,
    },
    {
      'title': 'Booking Confirmed',
      'description':
          'Dr. Müller confirmed your requested consultation for Legal Advice.',
      'time': '3 DAYS AGO',
      'type': 'booking',
      'isRead': true,
    },
    {
      'title': 'New Feature Available',
      'description':
          'You can now download PDF invoices directly from the History tab.',
      'time': '1 WEEK AGO',
      'type': 'feature',
      'isRead': true,
    },
  ].obs;

  void markAllAsRead() {
    for (var notification in notifications) {
      notification['isRead'] = true;
    }
    notifications.refresh();
  }
}
