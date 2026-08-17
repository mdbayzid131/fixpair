import 'package:dio/dio.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:flutter/material.dart';
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
    String? searchTerm,
    double? minPrice,
    double? maxPrice,
    double? minRating,
    String? sort,
    int page = 1,
    int limit = 10,
  }) async {
    final query = {
      if (consultancyType != null && consultancyType != 'All')
        'consultancyType': consultancyType.toLowerCase(),
      if (searchTerm != null && searchTerm.isNotEmpty) 'searchTerm': searchTerm,
      if (minPrice != null) 'minPrice': minPrice.round(),
      if (maxPrice != null) 'maxPrice': maxPrice.round(),
      if (minRating != null) 'minRating': minRating,
      if (sort != null && sort.isNotEmpty) 'sort': sort,
      'page': page,
      'limit': limit,
    };
    return await _apiClient.getData(ApiConstants.consultants, query: query);
  }

  // Get consultancy types list
  Future<Response> getConsultancyTypes() async {
    return await _apiClient.getData(ApiConstants.consultancyType);
  }

  // Get consultant details by ID
  Future<Response> getConsultantById(String id) async {
    return await _apiClient.getData(ApiConstants.userById(id));
  }

  // Get available slots for a consultant
  Future<Response> getAvailableSlots(String id, {String? date}) async {
    return await _apiClient.getData(
      ApiConstants.availableSlots(id),
      query: date != null ? {'date': date} : null,
    );
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
      // query: query,
    );
  }

  // Cancel a booking
  Future<Response> cancelBooking(String id, {String? reason}) async {
    return await _apiClient.patchData(ApiConstants.cancelBooking(id), {
      'cancelReason': reason ?? 'User cancelled the booking',
    });
  }

  // Reschedule a booking
  Future<Response> rescheduleBooking({
    required String id,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    return await _apiClient.patchData(ApiConstants.rescheduleBooking(id), {
      'date': date,
      'startTime': startTime,
      'endTime': endTime,
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
    return await _apiClient.getData(
      ApiConstants.videoSession,
      query: {'consultationId': consultationId},
    );
  }

  // Join a video session
  Future<Response> joinVideoSession(String sessionId) async {
    return await _apiClient.postData(ApiConstants.joinVideoSession, {
      'sessionId': sessionId,
    });
  }

  // Reject/Action a video session (e.g., REJECT)
  Future<Response> actionVideoSession(String sessionId, String action) async {
    return await _apiClient.postData(ApiConstants.actionVideoSession, {
      'sessionId': sessionId,
      'action': action,
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

  // Set default payment method
  Future<Response> setDefaultPaymentMethod(String paymentMethodId) async {
    return await _apiClient.postData(ApiConstants.setDefaultPaymentMethod, {
      'paymentMethodId': paymentMethodId,
    });
  }

  // Get invoice details
  Future<Response> getInvoice(String consultationId) async {
    return await _apiClient.getData(ApiConstants.getInvoice(consultationId));
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
    return await _apiClient.getData(ApiConstants.consultantStats(consultantId));
  }

  // Get total consultations of a consultant
  Future<Response> getConsultantTotalConsultations(String consultantId) async {
    return await _apiClient.getData(
      ApiConstants.totalConsultations(consultantId),
    );
  }

  // Save FCM device token for push notifications
  Future<Response> saveDeviceToken(String deviceToken) async {
    return await _apiClient.postData('/user/device-token', {
      'deviceToken': deviceToken,
      'deviceType': GetPlatform.isIOS ? 'ios' : 'android',
      "action": "add",
    });
  }

  // Get a specific booking by ID from the active bookings list, with a fallback to the first active booking
  Future<BookingModel?> getBookingById(String bookingId) async {
    try {
      final response = await getBookingsWithUrl(
        '${ApiConstants.myBookings}?status=pending&status=accepted&status=confirmed&status=ongoing&limit=20',
      );
      if (response.statusCode == 200) {
        final List<dynamic> data = response.data['data'] ?? [];
        final List<BookingModel> bookings = data.map((e) => BookingModel.fromJson(e)).toList();

        // 1. Try to find the exact booking by ID
        if (bookingId.isNotEmpty) {
          for (var b in bookings) {
            if (b.id == bookingId) {
              return b;
            }
          }
        }

        // 2. Fallback: return the first active booking, prioritizing pending callback requests
        if (bookings.isNotEmpty) {
          for (var b in bookings) {
            if (b.bookingType == 'callback' && b.status == 'pending') {
              return b;
            }
          }
          return bookings.first;
        }
      }
    } catch (e) {
      debugPrint('Error getting booking by ID: $e');
    }
    return null;
  }
}
