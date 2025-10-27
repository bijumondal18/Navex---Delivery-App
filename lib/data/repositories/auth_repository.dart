import 'dart:io';

import 'package:navex/core/network/api_endpoints.dart';

import '../../core/network/api_client.dart';

class AuthRepository {
  final ApiClient _apiClient = ApiClient();

  Future<dynamic> login(
    String email,
    String password,
    String pharmacyKey,
  ) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.loginURL,
      data: {'email': email, 'password': password, 'pharmacy_key': pharmacyKey},
    );
    return response.data;
  }

  Future<dynamic> fetchUserProfile() async {
    final response = await _apiClient.getRequest(
      ApiEndpoints.fetchUserProfileURL,
    );
    return response.data;
  }

  Future<dynamic> forgotPassword(String email) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.forgotPasswordURL,
      data: {'email': email},
    );
    return response.data;
  }

  Future<dynamic> resetPassword(
    String email,
    String otp,
    String password,
    String confirmPassword,
  ) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.resetPasswordURL,
      data: {
        'email': email,
        'otp': otp,
        'password': password,
        'password_confirmation': confirmPassword,
      },
    );
    return response.data;
  }

  Future<dynamic> updateUserProfile(
    String? name,
    String? email,
    String? phone,
    String? address,
    String? bio,
    String? city,
    String? zipcode,
  ) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.updateUserProfileURL,
      data: {
        'legal_name': name,
        'email': email,
        'phone': phone,
        'bio': bio,
        'address': address,
        'city': city,
        'zip': zipcode,
      }
    );
    return response.data;
  }

  // Future<dynamic> uploadProfilePhoto(File imageFile) async {
  //   final response = await _apiClient.postRequest(
  //     ApiEndpoints.updateUserProfileURL,
  //     file: imageFile,
  //     fileField: 'profile_image',
  //   );
  //   return response.data;
  // }
}
