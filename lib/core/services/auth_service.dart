import 'package:fixpair/config/constants/storage_constants.dart';
import 'package:fixpair/core/services/api_client.dart';
import 'package:fixpair/core/services/storage_service.dart';
import 'package:fixpair/data/models/user_model.dart';
import 'package:fixpair/data/repositories/auth_repository.dart';
import 'package:fixpair/data/repositories/user_repository.dart';
import 'package:dio/dio.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_rx/src/rx_types/rx_types.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_disposable.dart';

class AuthService extends GetxService {
  late AuthRepo _authRepo;
  late UserRepository _userRepository;

  // Reactive state
  final isLoggedIn = false.obs;
  final user = Rxn<UserData>();

  @override
  void onInit() {
    super.onInit();
    // Explicitly find ApiClient to ensure it's initialized before AuthRepo
    _authRepo = AuthRepo(apiClient: Get.put(ApiClient()));
    _userRepository = UserRepository();

    // Check initial login state
    _checkLoginStatus();
  }

  Future<void> _checkLoginStatus() async {
    final token = await StorageService.getString(StorageConstants.bearerToken);
    isLoggedIn.value = token.isNotEmpty;
    if (isLoggedIn.value) {
      await fetchProfile();
    }
  }

  Future<void> fetchProfile() async {
    try {
      final response = await _userRepository.getProfile();
      if (response.statusCode == 200) {
        final profileResponse = UserProfileResponseModel.fromJson(
          response.data,
        );
        user.value = profileResponse.data;
      }
    } catch (e) {
      // Silently fail
    }
  }

  Future<AuthService> init() async {
    return this;
  }

  /// ===================== SIGNUP =====================
  Future<Response> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authRepo.signup(
        name: name,
        email: email,
        password: password,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== LOGIN =====================
  Future<Response> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _authRepo.login(email: email, password: password);
      await handleAuthResponse(response);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== LOGOUT =====================
  Future<void> logout() async {
    try {
      await _authRepo.logout();
      await _clearLocalAuth();
    } catch (e) {
      await _clearLocalAuth();
    }
  }

  /// ===================== FORGOT PASSWORD =====================
  Future<Response> forgotPassword(String email) async {
    try {
      final response = await _authRepo.forgotPassword(email: email);
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== OTP VERIFY =====================
  Future<Response> verifyOtp({
    required String email,
    required int otp,
    bool isForgotPassword = false,
  }) async {
    try {
      final response = await _authRepo.otpVerify(
        email: email,
        otp: otp,
      );
      // If OTP verification logs the user in directly (but not for forgot password):
      if (!isForgotPassword) {
        await handleAuthResponse(response);
      }
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== RESEND OTP =====================
  Future<void> resendOtp(String email) async {
    try {
      await _authRepo.resentOtp(email: email);
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== RESET PASSWORD =====================
  Future<Response> resetPassword({
    required String resetToken,
    required String password,
  }) async {
    try {
      final response = await _authRepo.resetPassword(
        password: password,
        resetToken: resetToken,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== CHANGE PASSWORD =====================
  Future<Response> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    try {
      Response response = await _authRepo.changePassword(
        oldPassword: oldPassword,
        newPassword: newPassword,
      );
      return response;
    } catch (e) {
      rethrow;
    }
  }

  /// ===================== HELPER METHODS =====================

  /// Handles successful auth response (Login/Signup)
  Future<void> handleAuthResponse(Response response) async {
    final data = response.data;
    final authData = data['data'] ?? data;

    final String? accessToken = authData['accessToken'] ?? authData['token'];
    final String? refreshToken = authData['refreshToken'];

    if (accessToken != null) {
      await StorageService.setString(StorageConstants.bearerToken, accessToken);
      isLoggedIn.value = true;
      await fetchProfile(); // Fetch profile after login
    }

    if (refreshToken != null) {
      await StorageService.setString(
        StorageConstants.refreshToken,
        refreshToken,
      );
    }
  }

  /// Clears all local auth data
  Future<void> _clearLocalAuth() async {
    await StorageService.remove(StorageConstants.bearerToken);
    await StorageService.remove(StorageConstants.refreshToken);
    await StorageService.remove(StorageConstants.userData);

    isLoggedIn.value = false;
    user.value = null;
  }

  /// Check if user is authenticated
  bool get isAuthenticated => isLoggedIn.value;
}
