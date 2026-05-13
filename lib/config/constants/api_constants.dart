class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://10.10.7.106:5000/api/v1';
  static const String serverUrl = 'http://10.10.7.106:5000';

  static String getImageUrl(String? url) {
    if (url == null || url.isEmpty || url == 'null') return '';
    if (url.startsWith('http')) return url;
    if (url.startsWith('/')) return '$serverUrl$url';
    return '$serverUrl/$url';
  }

  // Auth Endpoints
  static const String login = '/auth/login';
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
  static String availableSlots(String id) => '/consultation/available-slots/$id';
  static const String bookConsultation = '/consultation/book';
  static const String myBookings = '/consultation/my-bookings';
  // Legal & FAQ Endpoints
  static const String privacyPolicy = '/privacy';
  static const String termsConditions = '/terms';
  static const String faq = '/faq';
}
