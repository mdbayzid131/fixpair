class ApiConstants {
  // Base URLs
  static const String baseUrl = 'http://10.10.7.111:5000/api/v1';
  // static const String apiVersion = '/api/v1';

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String signup = '/auth/register';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';
  static const String forgotPassword = '/auth/forget-password-otp';
  static const String resendOtp = '/auth/resend-otp';
  static const String verifyUser = '/auth/verify-user';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';

  // User Profile Endpoints
  static const String profile = '/user/get-me';
  // Category Endpoints
  static const String category = '/category';
  static const String getOperatorCategory = '/operatorcategory/:id';
  // Banner Endpoints
  static const String banner = '/banner';

  // Service Endpoints
  static const String getStoreService = '/storeservice';
  static const String getStoreServiceDetails = '/storeservice/:storeServiceId';

  // Address Endpoints
  static const String getAddresses = '/address/my-addresses';
  static const String updateAddress = '/address';
  static const String setDefaultAddress = '/address/:addressId/set-default';

  // Cart Endpoints
  static const String addToCart = '/cart/add';
  static const String getMyCart = '/cart/my-cart';
  static const String updateCartQuantity = '/cart/update-quantity/:cartItemId';
  static const String deleteCartItem = '/cart/item/:cartItemId';

  // Order Endpoints
  static const String myOrders = '/order/my-orders';
  static const String checkout = '/order/checkout';

  // Store Endpoints
  static const String getStoreDetails = '/store/:id';
  static const String getStoreServiceByStoreId = '/storeservice/store/:storeId';
  static const String getStoreBundleByStoreId = '/storebundle/store/:storeId';
}
