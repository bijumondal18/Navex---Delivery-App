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
    String? bio,
    String? address,
    String? city,
    String? zipcode,
    String? stateId, {
    File? profileImage,
  }) async {
    final Map<String, dynamic> data = {};
    if (name != null && name.isNotEmpty) data['legal_name'] = name;
    if (email != null && email.isNotEmpty) data['email'] = email;
    if (phone != null && phone.isNotEmpty) data['phone'] = phone;
    if (bio != null && bio.isNotEmpty) data['bio'] = bio;
    if (address != null && address.isNotEmpty) data['address'] = address;
    if (city != null && city.isNotEmpty) data['city'] = city;
    if (zipcode != null && zipcode.isNotEmpty) data['zip'] = zipcode;
    if (stateId != null && stateId.isNotEmpty) data['state'] = stateId;

    final response = await _apiClient.postRequest(
      ApiEndpoints.updateUserProfileURL,
      data: data.isNotEmpty ? data : null,
      file: profileImage,
      fileField: 'profile_image',
    );
    return response.data;
  }

  Future<dynamic> fetchStateList() async {
    final response = await _apiClient.getRequest(
      ApiEndpoints.fetchStateListURL,
    );
    return response.data;
  }

  Future<dynamic> updateOnlineOfflineStatus(bool isOnline) async {
    // Send as string: "1" for online, "0" for offline
    // Some APIs expect string values to avoid type truncation issues
    final String isOnlineValue = isOnline ? '1' : '0';
    final response = await _apiClient.postRequest(
      ApiEndpoints.updateOnlineOfflineStatusURL,
      data: {'is_online': isOnlineValue},
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
