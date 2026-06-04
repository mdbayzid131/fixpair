import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../data/models/notification_model.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends GetView<NotificationsController> {
  const NotificationsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.chevron_left_rounded, color: const Color(0xFF1D293D), size: 28.sp),
          onPressed: () => Get.back(),
        ),
        centerTitle: true,
        title: Text(
          'Notifications',
          style: GoogleFonts.manrope(
            fontSize: 18.sp,
            fontWeight: FontWeight.w700,
            color: const Color(0xFF1D293D),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => controller.markAllAsRead(),
            child: Text(
              'Read All',
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0066FF),
              ),
            ),
          ),
          SizedBox(width: 8.w),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Text(
              'No notifications found',
              style: GoogleFonts.manrope(
                fontSize: 14.sp,
                color: const Color(0xFF94A3B8),
                fontWeight: FontWeight.w500,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: controller.onRefresh,
          child: ListView.separated(
            controller: controller.scrollController,
            padding: EdgeInsets.all(20.w),
            itemCount: controller.notifications.length +
                (controller.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (context, index) => SizedBox(height: 16.h),
            itemBuilder: (context, index) {
              if (index == controller.notifications.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFFF6B00)),
                    ),
                  ),
                );
              }
              final notification = controller.notifications[index];
              return _buildNotificationCard(notification);
            },
          ),
        );
      }),
    );
  }

  Widget _buildNotificationCard(NotificationModel notification) {
    final bool isRead = notification.read;
    final String type = notification.type ?? '';

    Color iconBgColor;
    Color iconColor;
    IconData iconData;

    switch (type.toLowerCase()) {
      case 'consultation':
      case 'consultation_status':
        iconBgColor = const Color(0xFFFFF7ED);
        iconColor = const Color(0xFFF59E0B);
        iconData = Icons.calendar_today_outlined;
        break;
      case 'payment':
        iconBgColor = const Color(0xFFDCFCE7);
        iconColor = const Color(0xFF10B981);
        iconData = Icons.credit_card_outlined;
        break;
      case 'booking':
        iconBgColor = const Color(0xFFE0EFFF);
        iconColor = const Color(0xFF0066FF);
        iconData = Icons.check_circle_outline_rounded;
        break;
      default:
        iconBgColor = const Color(0xFFF1F5F9);
        iconColor = const Color(0xFF64748B);
        iconData = Icons.security_outlined;
        break;
    }

    String formatTime(String? timestamp) {
      if (timestamp == null) return '';
      try {
        final date = DateTime.parse(timestamp).toLocal();
        return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
      } catch (e) {
        return '';
      }
    }

    return GestureDetector(
      onTap: () {
        if (notification.id != null) {
          controller.markAsRead(notification.id!);
        }
      },
      child: Container(
        padding: EdgeInsets.all(20.w),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(24.r),
          border: Border.all(
            color: isRead ? Colors.transparent : const Color(0xFFCFE4FF),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(12.w),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(iconData, color: iconColor, size: 24.sp),
            ),
            SizedBox(width: 16.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title ?? '',
                          style: GoogleFonts.manrope(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF1D293D),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (!isRead)
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0066FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    notification.message ?? '',
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF64748B),
                      height: 1.5,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    formatTime(notification.createdAt),
                    style: GoogleFonts.manrope(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w800,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
