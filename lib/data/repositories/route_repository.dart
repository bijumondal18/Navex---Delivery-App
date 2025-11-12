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


}
