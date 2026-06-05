import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/notification_model.dart';
import '../../../data/repositories/notification_repository.dart';
import '../../../core/utils/helpers.dart';
import '../../home/controllers/home_controller.dart';

class NotificationsController extends GetxController {
  final NotificationRepo _notificationRepo = Get.find();
  final notifications = <NotificationModel>[].obs;
  final isLoading = false.obs;
  final isLoadingMore = false.obs;

  int _currentPage = 1;
  bool _hasMore = true;
  final int _limit = 10;

  bool get hasMore => _hasMore;

  @override
  void onInit() {
    super.onInit();
    fetchNotifications();
  }

  Future<void> onRefresh() async {
    await fetchNotifications();
  }

  Future<void> fetchNotifications({bool isLoadMore = false}) async {
    if (isLoadMore) {
      if (!_hasMore || isLoadingMore.value) return;
      isLoadingMore.value = true;
      _currentPage++;
    } else {
      isLoading.value = true;
      _currentPage = 1;
      _hasMore = true;
    }

    try {
      final response = await _notificationRepo.getNotifications(
        page: _currentPage,
        limit: _limit,
      );

      if (response.statusCode == 200) {
        final notificationResponse = NotificationResponseModel.fromJson(
          response.data,
        );
        final newItems = notificationResponse.data ?? [];

        if (!isLoadMore) {
          notifications.assignAll(newItems);
        } else {
          notifications.addAll(newItems);
        }

        if (notificationResponse.pagination != null) {
          _hasMore = _currentPage <
              (notificationResponse.pagination!.totalPage ?? 1);
        } else {
          _hasMore = false;
        }
        _updateHomeUnreadStatus();
      } else {
        Helpers.showError(response.statusMessage ?? 'Failed to load notifications');
      }
    } catch (e) {
      Helpers.showDebugLog(e.toString());
      Helpers.showError('An error occurred while loading notifications');
    } finally {
      isLoading.value = false;
      isLoadingMore.value = false;
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      // Optimistic local UI update for instantaneous responsiveness
      final index = notifications.indexWhere((element) => element.id == id);
      if (index != -1 && !notifications[index].read) {
        final oldVal = notifications[index];
        notifications[index] = NotificationModel(
          id: oldVal.id,
          user: oldVal.user,
          title: oldVal.title,
          message: oldVal.message,
          type: oldVal.type,
          relatedBooking: oldVal.relatedBooking,
          read: true,
          metadata: oldVal.metadata,
          createdAt: oldVal.createdAt,
          updatedAt: oldVal.updatedAt,
        );
        notifications.refresh();
        _updateHomeUnreadStatus();
      }

      await _notificationRepo.markAsRead(id);
    } catch (e) {
      // Silently fail
    }
  }

  Future<void> markAllAsRead() async {
    try {
      // Optimistic local UI update
      for (int i = 0; i < notifications.length; i++) {
        if (!notifications[i].read) {
          final oldVal = notifications[i];
          notifications[i] = NotificationModel(
            id: oldVal.id,
            user: oldVal.user,
            title: oldVal.title,
            message: oldVal.message,
            type: oldVal.type,
            relatedBooking: oldVal.relatedBooking,
            read: true,
            metadata: oldVal.metadata,
            createdAt: oldVal.createdAt,
            updatedAt: oldVal.updatedAt,
          );
        }
      }
      notifications.refresh();
      _updateHomeUnreadStatus();

      final response = await _notificationRepo.markAllAsRead();
      if (response.statusCode != 200) {
        fetchNotifications();
      }
    } catch (e) {
      fetchNotifications();
    }
  }

  void _updateHomeUnreadStatus() {
    if (Get.isRegistered<HomeController>()) {
      final hasUnread = notifications.any((element) => !element.read);
      Get.find<HomeController>().hasUnreadNotifications.value = hasUnread;
    }
  }

  @override
  void onClose() {
    super.onClose();
  }
}
