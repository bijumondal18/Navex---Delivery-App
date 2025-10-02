import 'dart:io';

import 'package:navex/core/network/api_endpoints.dart';

import '../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<dynamic> login(String email, String password, String pharmacyKey) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.loginURL,
      data: {
        'email': email,
        'password': password,
        'pharmacyKey': pharmacyKey,
      },
    );
    return response.data;
  }

  Future<dynamic> fetchUserProfile() async {
    final response = await _apiClient.getRequest(ApiEndpoints.fetchUserProfileURL);
    return response.data;
  }

  Future<dynamic> uploadProfilePhoto(File imageFile) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.uploadProfilePhotoURL,
      file: imageFile,
      fileField: 'profile_image',
    );
    return response.data;
  }

}