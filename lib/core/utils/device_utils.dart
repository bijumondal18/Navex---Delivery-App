import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';

class DeviceUtils {
  static Future<String> getDeviceName() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      return "${androidInfo.manufacturer} ${androidInfo.model}";
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      return iosInfo.name ?? "Unknown iOS Device";
    } else {
      return "Unknown Device";
    }
  }

  static Future<String?> getDeviceId() async {
    DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      // ANDROID_ID is a 64-bit number that is reset on factory reset
      return androidInfo
          .id; // or androidInfo.androidId (deprecated on some versions)
    } else if (Platform.isIOS) {
      IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      // identifierForVendor changes if all apps from the vendor are uninstalled/reinstalled
      return iosInfo.identifierForVendor;
    } else {
      return null;
    }
  }
}
