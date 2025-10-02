import 'package:shared_preferences/shared_preferences.dart';

class AppPreference {

  /// Initialize Singleton
  static final AppPreference _singleton = AppPreference._internal();

  /// All Key's
  static const String token = 'AUTH_TOKEN';
  static const String userId = 'USER_ID';
  static const String userType = 'USER_TYPE';
  static const String companyId = 'COMPANY_ID';
  static const String currentLat = 'CURRENT_LAT';
  static const String currentLong = 'CURRENT_LNG';
  static const String firstName = 'FIRST_NAME';
  static const String lastName = 'LAST_NAME';
  static const String fullName = 'FULL_NAME';
  static const String email = 'EMAIL';
  static const String profilePicture = 'PROFILE_PICTURE';
  static const String password = 'PASSWORD';
  static const String mobileNo = 'MOBILE_NUMBER';
  static const String countryCode = 'COUNTRY_CODE';
  static const String currency = 'CURRENCY';
  static const String school = 'SCHOOL';
  static const String standard = 'STANDARD';
  static const String isOnline = 'IS_ONLINE';
  static const String isLoggedIn = 'IS_LOGGED_IN';
  static const String isRegistered = 'IS_REGISTERED';
  static const String isOtpVerified = 'IS_OTP_VERIFIED';
  static const String isFirstTimeAppLoaded = 'IS_FIRST_TIME_APP_LOADED';
  static const String languageCode = 'LANGUAGE_CODE';

  /// Create factory constructor
  factory AppPreference() {
    return _singleton;
  }

  AppPreference._internal();

  /// All the functions to set and get data in local storage
  static Future<void> setString(String key, String value) async {
    if (value == null) {
      return;
    }
    final SharedPreferences sharedPreference =
    await SharedPreferences.getInstance();
    sharedPreference.setString(key, value);
    return;
  }

  static Future<String?> getString(String key) async {
    final SharedPreferences sharedPreference =
    await SharedPreferences.getInstance();
    return sharedPreference.getString(key) ?? '';
  }

  static Future<void> setBool(String key, bool value) async {
    if (value == null) {
      return;
    }
    final SharedPreferences sharedPreference =
    await SharedPreferences.getInstance();
    sharedPreference.setBool(key, value);
    return;
  }

  static Future<bool?> getBool(String key) async {
    final SharedPreferences sharedPreference =
    await SharedPreferences.getInstance();
    return sharedPreference.getBool(key) ?? false;
  }

  static Future<void> setDouble(String key, double value) async {
    if (value == null) {
      return;
    }
    final SharedPreferences sharedPreference =
    await SharedPreferences.getInstance();
    sharedPreference.setDouble(key, value);
    return;
  }

  static Future<double?> getDouble(String key) async {
    final SharedPreferences sharedPreference =
    await SharedPreferences.getInstance();
    return sharedPreference.getDouble(key) ?? 0.0;
  }

  static Future<void> setInt(String key, int value) async {
    if (value == null) {
      return;
    }
    final SharedPreferences sharedPreference =
    await SharedPreferences.getInstance();
    sharedPreference.setInt(key, value);
    return;
  }

  static Future<int?> getInt(String key) async {
    final SharedPreferences sharedPreference =
    await SharedPreferences.getInstance();
    return sharedPreference.getInt(key) ?? 0;
  }

  static Future<bool> removeKey(String key) async {
    final SharedPreferences sharedPreference =
    await SharedPreferences.getInstance();
    return await sharedPreference.remove(key);
  }

  static Future<void> clearPreference() async {
    final SharedPreferences sharedPreference =
    await SharedPreferences.getInstance();
    await sharedPreference.clear();
  }
}
