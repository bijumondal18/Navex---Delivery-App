class ApiEndpoints {

  static const baseUrl = "https://portal.navex.app/api";
  static const appVersion = "/v1";


  // ✅ AUTH API Endpoints
  static const String loginURL = '${baseUrl}${appVersion}/login';
  static const String forgotPasswordURL = '/auth/forgot_password';
  static const String verifyAccountURL = '/auth/verify_account';
  static const String fetchUserProfileURL = '/users/profile';
  static const String uploadProfilePhotoURL = '/users/upload_profile_photo';

  // ✅ ROUTE API Endpoints
  static const String fetchAllRoutesURL = '/routes/all_routes';
  static const String fetchAvailableRoutesURL = '/routes/available_routes';

}
