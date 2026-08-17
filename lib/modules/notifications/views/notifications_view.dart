import 'package:fixpair/core/widgets/custom_appbar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../../../data/models/notification_model.dart';
import '../controllers/notifications_controller.dart';

class NotificationsView extends StatefulWidget {
  const NotificationsView({super.key});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> {
  NotificationsController get controller =>
      Get.find<NotificationsController>();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      if (controller.hasMore &&
          !controller.isLoadingMore.value &&
          !controller.isLoading.value) {
        controller.fetchNotifications(isLoadMore: true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: CustomAppBar.build(
        title: 'Notifications'.tr,
        showBackButton: true,
        actions: [
          TextButton(
            onPressed: () => controller.markAllAsRead(),
            child: Text(
              'Read All'.tr,
              style: GoogleFonts.manrope(
                fontSize: 13.sp,
                fontWeight: FontWeight.w700,
                color: const Color(0xFF0066FF),
              ),
            ),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.notifications.isEmpty) {
          return const Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF0066FF)),
            ),
          );
        }

        if (controller.notifications.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.notifications_none_rounded,
                  size: 48.sp,
                  color: const Color(0xFF94A3B8),
                ),
                SizedBox(height: 12.h),
                Text(
                  'No notifications found'.tr,
                  style: GoogleFonts.manrope(
                    fontSize: 14.sp,
                    color: const Color(0xFF64748B),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: const Color(0xFF0066FF),
          backgroundColor: Colors.white,
          onRefresh: controller.onRefresh,
          child: ListView.separated(
            controller: _scrollController,
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            itemCount:
                controller.notifications.length +
                (controller.isLoadingMore.value ? 1 : 0),
            separatorBuilder: (context, index) => SizedBox(height: 10.h),
            itemBuilder: (context, index) {
              if (index == controller.notifications.length) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFF0066FF),
                      ),
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
    final iconConfig = _getIconConfig(type);

    return GestureDetector(
      onTap: () {
        if (notification.id != null && !notification.read) {
          controller.markAsRead(notification.id!);
        }
        _showNotificationDetailDialog(context, notification);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: isRead ? Colors.white : const Color(0xFFF8FAFC),
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(
            color: isRead ? const Color(0xFFF1F5F9) : const Color(0xFFBFDBFE),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isRead ? 0.02 : 0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            // Left Icon Avatar
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconConfig.bgColor,
                shape: BoxShape.circle,
              ),
              child: Icon(
                iconConfig.icon,
                color: iconConfig.color,
                size: 20.sp,
              ),
            ),
            SizedBox(width: 12.w),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 13.5.sp,
                            fontWeight:
                                isRead ? FontWeight.w600 : FontWeight.w700,
                            color: const Color(0xFF1E293B),
                          ),
                        ),
                      ),
                      SizedBox(width: 6.w),
                      Text(
                        _formatShortTime(notification.createdAt),
                        style: GoogleFonts.manrope(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF94A3B8),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.message ?? '',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: GoogleFonts.manrope(
                            fontSize: 12.5.sp,
                            fontWeight: FontWeight.w500,
                            color: isRead
                                ? const Color(0xFF64748B)
                                : const Color(0xFF334155),
                          ),
                        ),
                      ),
                      if (!isRead) ...[
                        SizedBox(width: 6.w),
                        Container(
                          width: 8.w,
                          height: 8.w,
                          decoration: const BoxDecoration(
                            color: Color(0xFF0066FF),
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showNotificationDetailDialog(
    BuildContext context,
    NotificationModel notification,
  ) {
    final type = notification.type ?? '';
    final iconConfig = _getIconConfig(type);

    Get.dialog(
      Dialog(
        backgroundColor: Colors.white,
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24.r),
        ),
        child: Container(
          padding: EdgeInsets.all(24.w),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24.r),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Icon & Category Tag
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.all(12.w),
                    decoration: BoxDecoration(
                      color: iconConfig.bgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      iconConfig.icon,
                      color: iconConfig.color,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: iconConfig.bgColor,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Text(
                      type.isNotEmpty
                          ? type.replaceAll('_', ' ').toUpperCase()
                          : 'NOTIFICATION'.tr,
                      style: GoogleFonts.manrope(
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: iconConfig.color,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              // Title
              Text(
                notification.title ?? 'Notification'.tr,
                style: GoogleFonts.manrope(
                  fontSize: 17.sp,
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF1E293B),
                ),
              ),
              SizedBox(height: 6.h),

              // Timestamp
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 13.sp,
                    color: const Color(0xFF94A3B8),
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    _formatFullTime(notification.createdAt),
                    style: GoogleFonts.manrope(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF94A3B8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              const Divider(color: Color(0xFFF1F5F9), height: 1),
              SizedBox(height: 16.h),

              // Full Message Body
              ConstrainedBox(
                constraints: BoxConstraints(maxHeight: 250.h),
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Text(
                    notification.message ?? '',
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF334155),
                      height: 1.55,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // Close Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Get.back(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0066FF),
                    elevation: 0,
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14.r),
                    ),
                  ),
                  child: Text(
                    'Close'.tr,
                    style: GoogleFonts.manrope(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  String _formatShortTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '';
    try {
      final date = DateTime.parse(timestamp).toLocal();
      final now = DateTime.now();
      if (date.year == now.year &&
          date.month == now.month &&
          date.day == now.day) {
        return DateFormat('hh:mm a').format(date);
      }
      return DateFormat('MMM dd').format(date);
    } catch (_) {
      return '';
    }
  }

  String _formatFullTime(String? timestamp) {
    if (timestamp == null || timestamp.isEmpty) return '';
    try {
      final date = DateTime.parse(timestamp).toLocal();
      return DateFormat('MMM dd, yyyy - hh:mm a').format(date);
    } catch (_) {
      return '';
    }
  }

  _NotificationIconConfig _getIconConfig(String type) {
    switch (type.toLowerCase()) {
      case 'consultation':
      case 'consultation_status':
        return _NotificationIconConfig(
          bgColor: const Color(0xFFFFF7ED),
          color: const Color(0xFFF59E0B),
          icon: Icons.phone_callback_rounded,
        );
      case 'payment':
        return _NotificationIconConfig(
          bgColor: const Color(0xFFDCFCE7),
          color: const Color(0xFF10B981),
          icon: Icons.account_balance_wallet_rounded,
        );
      case 'booking':
        return _NotificationIconConfig(
          bgColor: const Color(0xFFE0EFFF),
          color: const Color(0xFF0066FF),
          icon: Icons.event_available_rounded,
        );
      default:
        return _NotificationIconConfig(
          bgColor: const Color(0xFFF1F5F9),
          color: const Color(0xFF64748B),
          icon: Icons.notifications_active_rounded,
        );
    }
  }
}

class _NotificationIconConfig {
  final Color bgColor;
  final Color color;
  final IconData icon;

  _NotificationIconConfig({
    required this.bgColor,
    required this.color,
    required this.icon,
  });
}
