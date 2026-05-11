
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

  // Update user profile
  Future<Response> updateProfile(Map<String, dynamic> body,
      {List<MultipartBody>? multipartBody}) async {
    if (multipartBody != null && multipartBody.isNotEmpty) {
      return await _apiClient.patchMultipartData(
        ApiConstants.profile,
        body,
        multipartBody: multipartBody,
      );
    }
    return await _apiClient.patchData(ApiConstants.profile, body);
  }
}
