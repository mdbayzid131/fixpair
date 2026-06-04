import 'package:dio/dio.dart';
import 'package:fixpair/config/constants/api_constants.dart';
import 'package:fixpair/core/services/api_client.dart';

class NotificationRepo {
  final ApiClient apiClient;
  NotificationRepo({required this.apiClient});

  Future<Response> getNotifications({required int page, required int limit}) async {
    return await apiClient.getData(
      ApiConstants.notifications,
      query: {
        'page': page,
        'limit': limit,
      },
    );
  }

  Future<Response> markAsRead(String id) async {
    return await apiClient.patchData(
      ApiConstants.markNotificationRead(id),
      {},
    );
  }

  Future<Response> markAllAsRead() async {
    return await apiClient.postData(
      ApiConstants.markAllNotificationsRead,
      {},
    );
  }
}
