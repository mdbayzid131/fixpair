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
  Future<Response> updateProfile(
    Map<String, dynamic> body, {
    List<MultipartBody>? multipartBody,
  }) async {
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
  Future<Response> getMyBookings({int page = 1, int limit = 10}) async {
    return await _apiClient.getData(
      ApiConstants.myBookings,
      query: {"page": page, "limit": limit},
    );
  }

  // Get bookings with custom status URL query
  Future<Response> getBookingsWithUrl(String url) async {
    return await _apiClient.getData(url);
  }

  // Get recommended consultants
  Future<Response> getRecommendedConsultants({
    String? consultancyType,
    String? name,
  }) async {
    final query = {
      if (consultancyType != null && consultancyType != 'All')
        'consultancyType': consultancyType.toLowerCase(),
      if (name != null && name.isNotEmpty) 'name': name,
    };
    return await _apiClient.getData(
      ApiConstants.recommended,
      query: query,
    );
  }

  // Cancel a booking
  Future<Response> cancelBooking(String id, {String? reason}) async {
    return await _apiClient.patchData(ApiConstants.cancelBooking(id), {
      'cancelReason': reason ?? 'User cancelled the booking',
    });
  }

  // Reschedule a booking
  Future<Response> rescheduleBooking(String id, String newSlotId) async {
    return await _apiClient.patchData(ApiConstants.rescheduleBooking(id), {
      'newSlotId': newSlotId,
    });
  }

  // Delete user account
  Future<Response> deleteAccount() async {
    return await _apiClient.deleteData(ApiConstants.profile);
  }

  // --- Video Session Methods ---

  // Create or get a video session for a consultation
  Future<Response> createVideoSession(String consultationId) async {
    return await _apiClient.postData(ApiConstants.videoSession, {
      'consultationId': consultationId,
    });
  }

  // Get current session details
  Future<Response> getVideoSession(String consultationId) async {
    return await _apiClient.getData(ApiConstants.videoSession, query: {
      'consultationId': consultationId,
    });
  }

  // Join a video session
  Future<Response> joinVideoSession(String sessionId) async {
    return await _apiClient.postData(ApiConstants.joinVideoSession, {
      'sessionId': sessionId,
    });
  }

  // End a video session
  Future<Response> endVideoSession(String sessionId) async {
    return await _apiClient.postData(ApiConstants.endVideoSession, {
      'sessionId': sessionId,
    });
  }

  // --- Payment Methods ---

  // Create Stripe customer
  Future<Response> createStripeCustomer() async {
    return await _apiClient.postData(ApiConstants.createCustomer, {});
  }

  // Attach payment method
  Future<Response> attachPaymentMethod(String paymentMethodId) async {
    return await _apiClient.postData(ApiConstants.attachPaymentMethod, {
      'paymentMethodId': paymentMethodId,
    });
  }

  // Get saved payment methods
  Future<Response> getPaymentMethods() async {
    return await _apiClient.getData(ApiConstants.paymentMethods);
  }

  // --- Reviews ---

  // Post a review for a consultation
  Future<Response> postReview({
    required String consultationId,
    required double rating,
    required String comment,
  }) async {
    return await _apiClient.postData(ApiConstants.review, {
      'consultationId': consultationId,
      'rating': rating,
      'comment': comment,
    });
  }

  // Get reviews of a consultant
  Future<Response> getConsultantReviews(
    String consultantId, {
    int page = 1,
    int limit = 10,
  }) async {
    return await _apiClient.getData(
      ApiConstants.consultantReviews(consultantId),
      query: {'page': page, 'limit': limit},
    );
  }

  // Get statistics/average rating of a consultant
  Future<Response> getConsultantStats(String consultantId) async {
    return await _apiClient.getData(
      ApiConstants.consultantStats(consultantId),
    );
  }
}



