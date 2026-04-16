import 'package:fixpair/modules/bottom_nab_bar/bindings/bottom_nab_bar_binding.dart';
import 'package:fixpair/modules/bottom_nab_bar/views/bottom_nab_bar_view.dart';
import 'package:get/get_navigation/src/routes/get_route.dart';

import '../../modules/auth/bindings/auth_binding.dart';
import '../../modules/auth/views/login_view.dart';
import '../../modules/auth/views/register_view.dart';
import '../../modules/auth/views/forgot_password_view.dart';
import '../../modules/auth/views/otp_verify_screen.dart';
import '../../modules/auth/views/set_net_passwqord.dart';
import '../../modules/auth/views/success_view.dart';
import '../../modules/history/bindings/history_binding.dart';
import '../../modules/history/views/history_view.dart';
import '../../modules/profile/bindings/profile_binding.dart';
import '../../modules/profile/views/profile_view.dart';
import '../../modules/personal_info/bindings/personal_info_binding.dart';
import '../../modules/personal_info/views/personal_info_view.dart';
import '../../modules/legal_faq/bindings/legal_faq_binding.dart';
import '../../modules/legal_faq/views/legal_faq_view.dart';
import '../../modules/terms_conditions/bindings/terms_conditions_binding.dart';
import '../../modules/terms_conditions/views/terms_conditions_view.dart';
import '../../modules/privacy_policy/bindings/privacy_policy_binding.dart';
import '../../modules/privacy_policy/views/privacy_policy_view.dart';

import '../../modules/consultant_profile/bindings/consultant_profile_binding.dart';
import '../../modules/consultant_profile/views/consultant_profile_view.dart';
import '../../modules/consultant_booking/bindings/consultant_booking_binding.dart';
import '../../modules/consultant_booking/views/consultant_booking_view.dart';
import '../../modules/consultant_booking/views/consultant_booking_view.dart';
import '../../modules/schedule_booking/bindings/schedule_booking_binding.dart';
import '../../modules/schedule_booking/views/schedule_booking_view.dart';
import '../../modules/notifications/bindings/notifications_binding.dart';
import '../../modules/notifications/views/notifications_view.dart';

import '../../modules/splash/bindings/splash_binding.dart';
import '../../modules/splash/views/splash_view.dart';

class AppRoutes {
  static const String SPLASH = '/splash';
  static const String LOGIN = '/login';
  static const String REGISTER = '/register';
  static const String FORGOT_PASSWORD = '/forgot-password';
  static const String HOME = '/home';
  static const String PROFILE = '/profile';
  static const String PERSONAL_INFO = '/personal-info';
  static const String BOTTOM_NAV_BAR = '/bottom-nav-bar';
  static const String MAP = '/map';
  static const String CART = '/cart';
  static const String CHECKOUT = '/checkout';
  static const String NO_INTERNET = '/no-internet';
  static const String ONBOARDING = '/onboarding';
  static const String OTP = '/otp';
  static const String SET_NEW_PASSWORD = '/set-new-password';
  static const String HELP_SUPPORT = '/help-support';
  static const String CONTACT_SUPPORT = '/contact-support';
  static const String PHONE_SUPPORT = '/phone-support';
  static const String LIVE_CHAT = '/live-chat';
  static const String FAVORITE = '/favorite';
  static const String ORDER_TRACKING = '/order-tracking';
  static const String ORDER_ACKNOWLEDGMENT = '/order-acknowledgment';
  static const String PAYMENT_METHOD = '/payment-method';
  static const String CARD_PAYMENT = '/card-payment';
  static const String ORDER_HISTORY = '/order-history';
  static const String ORDER_ISSUE = '/order-issue';
  static const String ORDER_STATUS = '/order-status';
  static const String PICKUP_ADDRESS = '/pickup-address';
  static const String PRIVACY_SECURITY = '/privacy-security';
  static const String PRIVACY_POLICY = '/privacy-policy';
  static const String TERMS_CONDITIONS = '/terms-conditions';
  static const String NOTIFICATIONS = '/notifications';
  static const String LAUNDRY_DETAILS = '/laundry-details';
  static const String PRODUCT_DETAILS = '/product-details';
  static const String MEMBERSHIP = '/membership';
  static const String OTP_FORM_REGISTER = '/otp-form-register';
  static const String CHANGE_PASSWORD = '/change-password';
  static const String LOCK = '/lock';
  static const String TRACK_ORDER = '/track-order';
  static const String SUCCESS = '/success';
  static const String HISTORY = '/history';
  static const String LEGAL_FAQ = '/legal-faq';
  static const String CONSULTANT_PROFILE = '/consultant-profile';
  static const String CONSULTANT_BOOKING = '/consultant-booking';
  static const String SCHEDULE_BOOKING = '/schedule-booking';
}

final pages = [
  GetPage(
    name: AppRoutes.SPLASH,
    page: () => const SplashView(),
    binding: SplashBinding(),
  ),
  GetPage(
    name: AppRoutes.LOGIN,
    page: () => const LoginView(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: AppRoutes.REGISTER,
    page: () => const RegisterView(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: AppRoutes.FORGOT_PASSWORD,
    page: () => const ForgotPasswordView(),
    binding: AuthBinding(),
  ),
  
  GetPage(
    name: AppRoutes.OTP,
    page: () => const OtpVerifyScreen(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: AppRoutes.SET_NEW_PASSWORD,
    page: () => const SetNewPasswordScreen(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: AppRoutes.OTP_FORM_REGISTER,
    page: () => const OtpVerifyScreen(),
    binding: AuthBinding(),
  ),
  GetPage(
    name: AppRoutes.SUCCESS,
    page: () => const SuccessView(),
  ),
  GetPage(
    name: AppRoutes.BOTTOM_NAV_BAR,
    page: () => const BottomNavBarView(),
    binding: BottomNavBarBinding(),
  ),
  GetPage(
    name: AppRoutes.HISTORY,
    page: () => const HistoryView(),
    binding: HistoryBinding(),
  ),
  GetPage(
    name: AppRoutes.PROFILE,
    page: () => const ProfileView(),
    binding: ProfileBinding(),
  ),
  GetPage(
    name: AppRoutes.PERSONAL_INFO,
    page: () => const PersonalInfoView(),
    binding: PersonalInfoBinding(),
  ),
  GetPage(
    name: AppRoutes.LEGAL_FAQ,
    page: () => const LegalFAQView(),
    binding: LegalFAQBinding(),
  ),
  GetPage(
    name: AppRoutes.TERMS_CONDITIONS,
    page: () => const TermsConditionsView(),
    binding: TermsConditionsBinding(),
  ),
  GetPage(
    name: AppRoutes.PRIVACY_POLICY,
    page: () => const PrivacyPolicyView(),
    binding: PrivacyPolicyBinding(),
  ),
  GetPage(
    name: AppRoutes.NOTIFICATIONS,
    page: () => const NotificationsView(),
    binding: NotificationsBinding(),
  ),
  GetPage(
    name: AppRoutes.CONSULTANT_PROFILE,
    page: () => const ConsultantProfileView(),
    binding: ConsultantProfileBinding(),
  ),
  GetPage(
    name: AppRoutes.CONSULTANT_BOOKING,
    page: () => const ConsultantBookingView(),
    binding: ConsultantBookingBinding(),
  ),
  GetPage(
    name: AppRoutes.SCHEDULE_BOOKING,
    page: () => const ScheduleBookingView(),
    binding: ScheduleBookingBinding(),
  ),
];
