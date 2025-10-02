class ApiConfig {
  static const String baseUrl = 'https://api.yourapp.com';
  static const String apiVersion = 'v1'; // Change this when your backend updates

  static String get baseApiUrl => '$baseUrl/$apiVersion';
}