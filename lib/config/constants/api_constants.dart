class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://10.10.7.106:5000/api/v1';
  static const String serverUrl = 'http://10.10.7.106:5000';

  static String getImageUrl(String? url) {
    const String placeholder = 'https://i.ibb.co/z5YHLV9/profile.png';
    if (url == null || url.isEmpty || url == 'null' || url == '/') {
      return placeholder;
    }
    if (url.startsWith('http')) return url;
    if (url.startsWith('/')) return '$serverUrl$url';
    return '$serverUrl/$url';
  }

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String socialLogin = '/auth/social-login';
  static const String signup = '/user';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forget-password';
  static const String resendOtp = '/auth/resend-otp';
  static const String verifyUser = '/auth/verify-email';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // User Profile Endpoints
  static const String profile = '/user/profile';
  static const String consultants = '/user/consultants';
  static String userById(String id) => '/user/$id';
  static String totalConsultations(String id) =>
      '/consultation/consultants/$id/total-consultations';
  static String availableSlots(String id) =>
      '/consultation/available-slots/$id';
  static const String bookConsultation = '/consultation/book';
  static const String myBookings = '/consultation/my-bookings';
  static const String recommended = '/recommendation/recommended';
  static String cancelBooking(String id) => '/consultation/cancel/$id';
  static String rescheduleBooking(String id) => '/consultation/reschedule/$id';

  // Legal & FAQ Endpoints
  static const String privacyPolicy = '/privacy';
  static const String termsConditions = '/terms';
  static const String faq = '/faq';
  static const String customerSupport = '/customer-support';

  // Video Session Endpoints
  static const String videoSession = '/video-session/create';
  static const String joinVideoSession = '/video-session/join';
  static const String endVideoSession = '/video-session/end';
  static const String actionVideoSession = '/video-session/action';
  static String startTranscription(String consultationId) =>
      '/consultations/$consultationId/transcription/start';
  static String stopTranscription(String consultationId) =>
      '/consultations/$consultationId/transcription/stop';

  // Payment Endpoints
  static const String createCustomer = '/payment/create-customer';
  static const String attachPaymentMethod = '/payment/attach-method';
  static const String paymentMethods = '/payment/methods';

  // Review Endpoints
  static const String review = '/review';
  static String consultantReviews(String id) => '/review/consultant/$id';
  static String consultantStats(String id) => '/review/stats/$id';

  // Notification Endpoints
  static const String notifications = '/notification';
  static String markNotificationRead(String id) => '/notification/$id';
  static const String markAllNotificationsRead = '/notification/mark-all-read';

  // Agora Config
  static const String agoraAppId = '1ab0566716c44d22bc8afc15a6d62205';
}
