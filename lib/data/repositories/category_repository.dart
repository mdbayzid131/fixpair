import 'package:dio/dio.dart';
import 'package:get/get.dart' hide Response; // Hide GetX Response
import '../../core/services/api_client.dart';
import '../../config/constants/api_constants.dart';

class CategoryRepository {
  final ApiClient _apiClient = Get.find();

  Future<Response> getCategories() async {
    return await _apiClient.getData(ApiConstants.category);
  }

  Future<Response> getOperatorCategories(String operatorId) async {
    return await _apiClient.getData(
      ApiConstants.getOperatorCategory.replaceAll(':id', operatorId),
    );
  }
}
