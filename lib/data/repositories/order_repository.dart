import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../../core/services/api_client.dart';
import '../../config/constants/api_constants.dart';

class OrderRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<Response> checkout(Map<String, dynamic> body) async {
    return await _apiClient.postData(
      ApiConstants.checkout,
      body,
    );
  }

  Future<Response> getMyOrders({int page = 1, int limit = 10}) async {
    return await _apiClient.getData(ApiConstants.myOrders, query: {'page': page, 'limit': limit},);
  }
}
