
import 'package:dio/dio.dart';
import '../../core/services/api_client.dart';
import '../../config/constants/api_constants.dart';
import 'package:get/get.dart' hide Response;

class AddressRepository {
  final ApiClient _apiClient = Get.find();

  // Get addresses
  Future<Response> getAddresses() async {
    return await _apiClient.getData(ApiConstants.getAddresses);
  }

  // Update address
  Future<Response> updateAddress(String id, Map<String, dynamic> data) async {
    return await _apiClient.patchData('${ApiConstants.updateAddress}/$id', data);
  }

  // Create address
  Future<Response> createAddress(Map<String, dynamic> data) async {
    return await _apiClient.postData(ApiConstants.updateAddress, data);
  }

  // Delete address
  Future<Response> deleteAddress(String id) async {
    return await _apiClient.deleteData('${ApiConstants.updateAddress}/$id');
  }

  // Set default address
  Future<Response> setDefaultAddress(String id) async {
    return await _apiClient.patchData(ApiConstants.setDefaultAddress.replaceFirst(':addressId', id), {});
  }
}
