/// ===================== IMAGE PATHS =====================
/// Centralized asset path constants for icons, images, and logos.
/// Always use these constants instead of hardcoding paths.
class ImagePaths {
  ImagePaths._();

  // ─── Base Paths ───
  static const String _icons = 'assets/icons';
  static const String _images = 'assets/images';
  static const String _logos = 'assets/logos';
  static const String _dummy = 'assets/dummy_image';

  // ─── Icons ───
  static const String deleteIcon = '$_icons/delete_icon.svg';
  static const String searchIcon = '$_icons/search_icon.svg';
  static const String googleIcon = '$_icons/googleIcon.svg';
  static const String appleIcon = '$_icons/apple_icon.svg';
  static const String chosePlanIcon = '$_icons/chose_plan_icon.svg';
  static const String homeIcon = '$_icons/home icon.svg';
  static const String calenderIcon = '$_icons/calender.svg';
  static const String libraryIcon = '$_icons/library.svg';

  // ─── Images ───
  static const String onboardingImage1 = '$_images/onbordingImage1.png';
  static const String onboardingImage2 = '$_images/onbordingImage2.png';
  static const String onboardingImage3 = '$_images/onbordingImage3.png';

  // ─── Logos ───
  static const String appLogo = '$_logos/app_logo.png';

  // ─── Dummy / Placeholders ───
  static const String profileIcon = '$_dummy/profilePic.png';
}
