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


}
