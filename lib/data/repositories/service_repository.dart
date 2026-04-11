import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response; // Hide GetX Response
import '../../core/services/api_client.dart';
import '../../config/constants/api_constants.dart';

class ServiceRepository {
  final ApiClient _apiClient = Get.find();

  Future<Response> getStoreServiceDetails(String storeServiceId) async {
    return await _apiClient.getData(ApiConstants.getStoreServiceDetails.replaceAll(':storeServiceId', storeServiceId));
  }

  Future<Response> getStoreServices(
    double lat,
    double lng,
    String categoryId,
    String searchTerm, {
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiClient.getData(
      ApiConstants.getStoreService,
      query: {
        'userLat': lat,
        'userLng': lng,
        'categoryId': categoryId,
        'searchTerm': searchTerm,
        'page': page,
        'limit': limit,
      },
    );
  }

  Future<Response> getStoreServicesByStoreId(String storeId, {Map<String, dynamic>? query}) async {
    return await _apiClient.getData(
      ApiConstants.getStoreServiceByStoreId.replaceAll(':storeId', storeId),
      query: query,
    );
  }
}
