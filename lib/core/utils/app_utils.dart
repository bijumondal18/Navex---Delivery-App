import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
// import 'package:wechat_assets_picker/wechat_assets_picker.dart';

class AppUtils {
  static void showDebugLog(String tag, dynamic message) {
    if (kDebugMode) {
      if (message is Map || message is List) {
        log("[$tag] ${const JsonEncoder.withIndent('  ').convert(message)}");
      } else {
        log("[$tag] $message");
      }
    }
  }

  static String firstNonEmptyTitle(
    List<Object?> values, {
    String fallback = 'N/A',
  }) {
    for (final v in values) {
      final s = v?.toString().trim() ?? '';
      if (s.isNotEmpty) return toTitleCase(s);
    }
    return fallback;
  }

  // Handles words, hyphenated names (Mary-Jane), and O'Brien
  static String toTitleCase(String input) {
    return input
        .trim()
        .split(RegExp(r'\s+'))
        .map(
          (word) => word
              .split(RegExp(r"([-'])")) // keep separators
              .map((part) {
                if (part == '-' || part == "'") return part;
                if (part.isEmpty) return part;
                final lower = part.toLowerCase();
                return lower[0].toUpperCase() + lower.substring(1);
              })
              .join(''),
        )
        .join(' ');
  }

  static bool isVideoUrl(String url) {
    final path = Uri.parse(url).path.toLowerCase();
    const videoExt = ['.mp4', '.mov', '.webm', '.mkv', '.m4v', '.avi', '.m3u8'];
    return videoExt.any(path.endsWith);
  }

  /// Resolve a single AssetEntity to a local file path (or file:// URI).
  // static Future<String?> _assetToPath(AssetEntity a, {bool asUri = false}) async {
  //   // Fast path; falls back to the original (may trigger download from iCloud).
  //   File? f = await a.file;
  //   f ??= await a.originFile;
  //
  //   if (f == null) return null;
  //   return asUri ? f.uri.toString() : f.path;
  // }

  /// Convert a list of AssetEntity to a list of paths/URIs, preserving order.
  // static Future<List<String>> assetsToPaths(List<AssetEntity> assets, {bool asUri = false}) async {
  //   final results = await Future.wait(assets.map((a) => _assetToPath(a, asUri: asUri)));
  //   return results.whereType<String>().toList(growable: false);
  // }

}
