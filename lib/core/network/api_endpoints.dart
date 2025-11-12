class ApiEndpoints {

  static const baseUrl = "https://portal.navex.app/api";
  static const appVersion = "/v1";


  // ✅ AUTH API Endpoints
  static const String loginURL = '$baseUrl$appVersion/login';
  static const String forgotPasswordURL = '$baseUrl$appVersion/forgot-password';
  static const String resetPasswordURL = '$baseUrl$appVersion/password-reset';
  static const String fetchUserProfileURL = '$baseUrl$appVersion/driver/details';
  static const String updateUserProfileURL = '$baseUrl$appVersion/driver/profile/update';
  static const String updateOnlineOfflineStatusURL = '$baseUrl$appVersion/driver/live-status';


  // ✅ ROUTE API Endpoints
  static const String fetchUpcomingRoutesURL = '$baseUrl$appVersion/driver/upcoming-routes';
  static const String fetchAcceptedRoutesURL = '$baseUrl$appVersion/driver/accepted-routes';
  static const String fetchRouteDetailsURL = '$baseUrl$appVersion/driver/route-details';
  static const String acceptRouteURL = '$baseUrl$appVersion/driver/accept-route';
  static const String cancelRouteURL = '$baseUrl$appVersion/driver/accept-route-cancel';
  static const String loadVehicleURL = '$baseUrl$appVersion/driver/vehicle-load';
  static const String routeCheckInURL = '$baseUrl$appVersion/driver/route-checkin';
  static const String fetchRouteHistoryURL = '$baseUrl$appVersion/driver/route-history';
  static const String markDeliveryURL = '$baseUrl$appVersion/driver/mark-delivery';
  static const String completeTripURL = '$baseUrl$appVersion/driver/mark-route-complete';


  // ✅ ADDRESS API Endpoints
  static const String fetchStateListURL = '$baseUrl$appVersion/state-list';

}
