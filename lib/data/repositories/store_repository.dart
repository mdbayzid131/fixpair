import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response;
import '../../core/services/api_client.dart';
import '../../config/constants/api_constants.dart';

class StoreRepository {
  final ApiClient _apiClient = Get.find<ApiClient>();

  Future<Response> getStoreDetails(String storeId, {double? lat, double? lng}) async {
    Map<String, dynamic> query = {};
    if (lat != null && lng != null) {
      query['userLat'] = lat;
      query['userLng'] = lng;
    }

    return await _apiClient.getData(
      ApiConstants.getStoreDetails.replaceAll(':id', storeId),
      query: query.isNotEmpty ? query : null,
    );
  }

  Future<Response> getStoreBundles(String storeId) async {
    return await _apiClient.getData(
      ApiConstants.getStoreBundleByStoreId.replaceAll(':storeId', storeId),
    );
  }
}
