import 'dart:convert';
import 'dart:io';

import 'package:dio/dio.dart';

import '../../core/network/api_client.dart';
import '../../core/network/api_endpoints.dart';

class RouteRepository {
  final ApiClient _apiClient = ApiClient();

  Future<dynamic> fetchUpcomingRoutes(String date) async {
    final response = await _apiClient.getRequest(
      ApiEndpoints.fetchUpcomingRoutesURL,
      queryParams: {'date': date},
    );
    return response.data;
  }

  Future<dynamic> fetchAcceptedRoutes(String date) async {
    final response = await _apiClient.getRequest(
      ApiEndpoints.fetchAcceptedRoutesURL,
      queryParams: {'date': date},
    );
    return response.data;
  }

  Future<dynamic> fetchRouteHistory() async {
    final response = await _apiClient.getRequest(
      ApiEndpoints.fetchRouteHistoryURL,
    );
    return response.data;
  }

  Future<dynamic> fetchRouteDetails(String routeId) async {
    final response = await _apiClient.getRequest(
      '${ApiEndpoints.fetchRouteDetailsURL}/$routeId',
    );
    return response.data;
  }

  Future<dynamic> acceptRoute(String routeId) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.acceptRouteURL,
      data: {'route_id': routeId},
    );
    return response.data;
  }

  Future<dynamic> cancelRoute(String routeId) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.cancelRouteURL,
      data: {'route_id': routeId},
    );
    return response.data;
  }

  Future<dynamic> loadVehicle({
    required String routeId,
    required double currentLat,
    required double currentLng,
  }) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.loadVehicleURL,
      data: {
        'route_id': routeId,
        'lat': currentLat,
        'long': currentLng,
      },
    );
    return response.data;
  }

  Future<dynamic> checkInRoute(String routeId) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.routeCheckInURL,
      data: {'route_id': routeId},
    );
    return response.data;
  }

  Future<dynamic> markDelivery({
    required String deliveryRouteId,
    required String deliveryWaypointId,
    required double lat,
    required double long,
    required int deliveryType,
    required String deliveryDate,
    required String deliveryTime,
    required List<File> deliveryImages,
    File? signature,
    String? notes,
        String? reason,
    String? recipientName,
    int? deliverTo,
  }) async {
    try {
      // Create FormData for multipart request with multiple files
      final formData = FormData.fromMap({
        'delivery_route_id': deliveryRouteId,
        'delivery_waypoint_id': deliveryWaypointId,
        'lat': lat,
        'long': long,
        'delivery_type': deliveryType,
        'delivery_date': deliveryDate,
        'delivery_time': deliveryTime,
      });

      // Add optional fields
      if (notes != null && notes.isNotEmpty) {
        formData.fields.add(MapEntry('notes', notes));
      }
      if (reason != null && reason.isNotEmpty) {
        formData.fields.add(MapEntry('reason', reason));
      }
      if (recipientName != null && recipientName.isNotEmpty) {
        formData.fields.add(MapEntry('recipient_name', recipientName));
      }
      if (deliverTo != null) {
        formData.fields.add(MapEntry('deliver_to', deliverTo.toString()));
      }

      // Separate signature from delivery images
      final List<File> imagesOnly = [];
      File? signatureFile = signature;

      for (var image in deliveryImages) {
        // Check if it's a signature (contains 'signature_' in path)
        if (image.path.contains('signature_')) {
          signatureFile = image;
        } else {
          imagesOnly.add(image);
        }
      }

      // Add delivery images
      for (var image in imagesOnly) {
        formData.files.add(MapEntry(
          'delivery_image[]',
          await MultipartFile.fromFile(image.path),
        ));
      }

      // Add signature as base64-encoded string if provided
      if (signatureFile != null) {
        final signatureBytes = await signatureFile.readAsBytes();
        final signatureBase64 = base64Encode(signatureBytes);
        formData.fields.add(MapEntry('signature', signatureBase64));
      }

      // Use dio directly for multipart with multiple files
      // Following existing architecture pattern - errors are caught and rethrown
      final response = await _apiClient.dio.post(
        ApiEndpoints.markDeliveryURL,
        data: formData,
      );
      return response.data;
    } on DioException catch (e) {
      // Handle DioException similar to ApiClient's _handleError pattern
      if (e.response != null) {
        final errorMessage = e.response?.data['message'] ??
            e.response?.statusMessage ??
            'Unknown server error';
        throw Exception(errorMessage);
      } else {
        throw Exception('Network error: ${e.message ?? 'Unknown error'}');
      }
    } catch (e) {
      // Handle any other exceptions
      throw Exception('Failed to mark delivery: ${e.toString()}');
    }
  }

  Future<dynamic> completeTrip({
    required String routeId,
    required String completeDate,
    required String completeTime,
  }) async {
    final response = await _apiClient.postRequest(
      ApiEndpoints.completeTripURL,
      data: {
        'route_id': routeId,
        'complete_date': completeDate,
        'complete_time': completeTime,
      },
    );
    return response.data;
  }
}
