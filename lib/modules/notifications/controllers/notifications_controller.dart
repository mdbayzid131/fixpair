import 'package:flutter/material.dart';
import 'package:get/get.dart';

class NotificationsController extends GetxController {
  final todayNotifications = [
    NotificationModel(
      title: 'Order Picked Up',
      content:
          'Your laundry has been picked up and is on its way to our facility. Order #LN2847',
      time: '2 min ago',
      category: 'Order Update',
      icon: Icons.inventory_2_outlined,
      categoryColor: const Color(0xff4A90E2),
    ),
    NotificationModel(
      title: 'Special Offer Just for You!',
      content:
          'Get 25% off on your next order. Use code CLEAN25 at checkout. Valid until Friday.',
      time: '1 hour ago',
      category: 'Promotion',
      icon: Icons.percent,
      categoryColor: const Color(0xff10B981),
    ),
  ].obs;

  final yesterdayNotifications = [
    NotificationModel(
      title: 'Out for Delivery',
      content:
          'Your clean laundry is out for delivery. Expected arrival: 4-6 PM. Order #LN2839',
      time: 'Yesterday',
      category: 'Order Update',
      icon: Icons.local_shipping_outlined,
      categoryColor: const Color(0xff4A90E2),
    ),
    NotificationModel(
      title: 'Payment Confirmed',
      content:
          'Payment of \$34.50 received successfully for order #LN2839. Receipt sent to your email.',
      time: 'Yesterday',
      category: 'System Alert',
      icon: Icons.notifications_none,
      categoryColor: Colors.black45,
    ),
  ].obs;
}

class NotificationModel {
  final String title;
  final String content;
  final String time;
  final String category;
  final IconData icon;
  final Color categoryColor;

  NotificationModel({
    required this.title,
    required this.content,
    required this.time,
    required this.category,
    required this.icon,
    required this.categoryColor,
  });
}
