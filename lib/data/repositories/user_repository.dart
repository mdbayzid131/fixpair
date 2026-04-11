
import 'package:dio/dio.dart';
import '../../core/services/api_client.dart';
import '../../config/constants/api_constants.dart';
import 'package:get/get.dart' hide Response;

class UserRepository {
  final ApiClient _apiClient = Get.find();

  // Get user profile
  Future<Response> getProfile() async {
    return await _apiClient.getData(ApiConstants.profile);
  }
}
