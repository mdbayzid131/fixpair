

import 'package:fixpair/config/constants/api_constants.dart';
import 'package:fixpair/core/services/api_client.dart';
import 'package:dio/dio.dart';



class AuthRepo {
  final ApiClient apiClient;
  AuthRepo({required this.apiClient});



  // Future<String> getDeviceId() async {
  //   final deviceInfo = DeviceInfoPlugin();
  //
  //   if (Platform.isAndroid) {
  //     final androidInfo = await deviceInfo.androidInfo;
  //     return androidInfo.id; // অথবা androidInfo.device, androidInfo.model
  //   } else if (Platform.isIOS) {
  //     final iosInfo = await deviceInfo.iosInfo;
  //     return iosInfo.identifierForVendor ?? "unknown";
  //   } else {
  //     return "unsupported";
  //   }
  // }



  /// ===================== SIGNUP =====================
  Future<Response> signup({
    required String name,
    required String email,
    required String password,
  }) async {
    return await apiClient.postData(ApiConstants.signup, {
      "name": name,
      "email": email,
      "password": password,
    });
  }

  /// ===================== LOGIN =====================
  Future<Response> login({
    required String email,
    required String password,
  }) async {
    return await apiClient.postData(ApiConstants.login, {
      "email": email,
      "password": password,
    });
  }

  /// ===================== SOCIAL LOGIN =====================
  Future<Response> socialLogin({
    required String idToken,
    required String provider,
  }) async {
    return await apiClient.postData(ApiConstants.socialLogin, {
      "idToken": idToken,
      "provider": provider,
    });
  }

  /// ===================== FORGOT PASSWORD =====================
  Future<Response> forgotPassword({required String email}) async {
    return await apiClient.postData(ApiConstants.forgotPassword, {
      "email": email,
    });
  }

  /// ===================== RESEND OTP =====================
  Future<Response> resentOtp({required String email}) async {
    return await apiClient.postData(ApiConstants.resendOtp, {
      "email": email,
    });
  }

  /// ===================== OTP VERIFY =====================
  Future<Response> otpVerify({
    required String email,
    required int otp,
  }) async {
    return await apiClient.postData(ApiConstants.verifyUser, {
      "email": email,
      "oneTimeCode": otp,
    });
  }

  /// ===================== RESET PASSWORD =====================
  Future<Response> resetPassword({
    required String password,
    required String resetToken,
  }) async {
    return await apiClient.postData(
      ApiConstants.resetPassword,
      {
        "newPassword": password,
        "confirmPassword": password
      },
      extraHeaders: {
        "Authorization": "Bearer $resetToken",
      },
    );
  }

  /// ===================== LOGOUT =====================
  Future<Response> logout() async {
    return await apiClient.postData(ApiConstants.logout, {});
  }

  /// ===================== REFRESH TOKEN =====================
  Future<Response> refreshToken(String refreshToken) async {
    return await apiClient.postData(ApiConstants.refreshToken, {
      "refreshToken": refreshToken,
    });
  }

  /// ===================== CHANGE PASSWORD =====================
  Future<Response> changePassword({
    required String oldPassword,
    required String newPassword,
  }) async {
    return await apiClient.postData(ApiConstants.changePassword, {
      "oldPassword": oldPassword,
      "newPassWord": newPassword,
      "confirmPassword": newPassword,
    });
  }


}
