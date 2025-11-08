class ApiConfig {
  static const String baseUrl = 'https://portal.navex.app/api';
  static const String apiVersion = 'v1'; // Change this when your backend updates

  static String get baseApiUrl => '$baseUrl/$apiVersion';
}