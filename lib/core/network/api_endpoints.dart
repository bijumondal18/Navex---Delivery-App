class ApiEndpoints {

  static const baseUrl = "https://portal.navex.app/api";
  static const appVersion = "/v1";


  // ✅ AUTH API Endpoints
  static const String loginURL = '${baseUrl}${appVersion}/login';
  static const String forgotPasswordURL = '${baseUrl}${appVersion}/forgot-password';
  static const String resetPasswordURL = '${baseUrl}${appVersion}/password-reset';
  static const String fetchUserProfileURL = '${baseUrl}${appVersion}/driver/details';
  static const String uploadProfilePhotoURL = '/users/upload_profile_photo';

  // ✅ ROUTE API Endpoints
  static const String fetchUpcomingRoutesURL = '${baseUrl}${appVersion}/driver/upcoming-routes';
  static const String fetchAvailableRoutesURL = '/routes/available_routes';

}
