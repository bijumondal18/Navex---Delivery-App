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


}