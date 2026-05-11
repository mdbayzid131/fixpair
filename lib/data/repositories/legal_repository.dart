import 'package:dio/dio.dart';
import 'package:fixpair/config/constants/api_constants.dart';
import 'package:fixpair/core/services/api_client.dart';

class LegalRepo {
  final ApiClient apiClient;
  LegalRepo({required this.apiClient});

  Future<Response> getPrivacyPolicy() async {
    return await apiClient.getData(ApiConstants.privacyPolicy);
  }

  Future<Response> getTermsConditions() async {
    return await apiClient.getData(ApiConstants.termsConditions);
  }

  Future<Response> getFAQs() async {
    return await apiClient.getData(ApiConstants.faq);
  }
}
