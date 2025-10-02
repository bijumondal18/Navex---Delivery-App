import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionCheckService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<Map<String, dynamic>?> getVersionInfo() async {
    try {
      DocumentSnapshot doc = await _firestore
          .collection('app_config')
          .doc('version_control')
          .get();
      return doc.data() as Map<String, dynamic>?;
    } catch (e) {
      debugPrint('Error fetching version info: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> checkForUpdate({
    required bool isAndroid,
  }) async {
    final info = await getVersionInfo();
    if (info == null) return null;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;

    final latestVersion = isAndroid
        ? info['latest_android_version']
        : info['latest_ios_version'];
    final minVersion = isAndroid
        ? info['min_android_version']
        : info['min_ios_version'];
    final updateUrl = isAndroid
        ? info['android_update_url']
        : info['ios_update_url'];

    return {
      "current": currentVersion,
      "latest": latestVersion,
      "min": minVersion,
      "url": updateUrl,
      "forceUpdate": _isVersionLower(currentVersion, minVersion),
      "optionalUpdate": _isVersionLower(currentVersion, latestVersion),
    };
  }

  bool _isVersionLower(String current, String target) {
    final currentParts = current.split('.').map(int.parse).toList();
    final targetParts = target.split('.').map(int.parse).toList();

    for (int i = 0; i < targetParts.length; i++) {
      if (i >= currentParts.length) return true;
      if (currentParts[i] < targetParts[i]) return true;
      if (currentParts[i] > targetParts[i]) return false;
    }
    return false;
  }
}

// This is firestore document format
/**
 * {
    "latest_android_version": "2.0.0",
    "min_android_version": "1.5.0",
    "latest_ios_version": "2.0.0",
    "min_ios_version": "1.5.0",
    "android_update_url": "https://play.google.com/store/apps/details?id=com.yourapp",
    "ios_update_url": "https://apps.apple.com/app/id123456789"
    }
 * */
