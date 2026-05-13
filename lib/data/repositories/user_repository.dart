
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

  // Get consultants list with filters and pagination
  Future<Response> getConsultants({
    String? consultancyType,
    String? name,
    int page = 1,
    int limit = 10,
  }) async {
    final query = {
      if (consultancyType != null && consultancyType != 'All')
        'consultancyType': consultancyType.toLowerCase(),
      if (name != null && name.isNotEmpty) 'name': name,
      'page': page,
      'limit': limit,
    };
    return await _apiClient.getData(ApiConstants.consultants, query: query);
  }

  // Get consultant details by ID
  Future<Response> getConsultantById(String id) async {
    return await _apiClient.getData(ApiConstants.userById(id));
  }

  // Get available slots for a consultant
  Future<Response> getAvailableSlots(String id) async {
    return await _apiClient.getData(ApiConstants.availableSlots(id));
  }

  // Book a consultation
  Future<Response> bookConsultation(Map<String, dynamic> body) async {
    return await _apiClient.postData(ApiConstants.bookConsultation, body);
  }

  // Get user's bookings
  Future<Response> getMyBookings() async {
    return await _apiClient.getData(ApiConstants.myBookings);
  }
}
