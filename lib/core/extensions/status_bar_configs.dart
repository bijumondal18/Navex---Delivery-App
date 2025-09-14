import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../themes/app_colors.dart';

void statusBarConfig({required BuildContext context}) {
  final isDarkMode = Theme.of(context).brightness == Brightness.dark;

  SystemChrome.setSystemUIOverlayStyle(
    !isDarkMode
        ? const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.dark,
            // iOS: white text
            statusBarIconBrightness: Brightness.light,
            // Android: white icons
            systemNavigationBarColor: AppColors.scaffoldBackgroundDark,
            systemNavigationBarIconBrightness: Brightness.light,
          )
        : const SystemUiOverlayStyle(
            statusBarColor: Colors.transparent,
            statusBarBrightness: Brightness.light,
            // iOS: dark text
            statusBarIconBrightness: Brightness.dark,
            // Android: black icons ✅
            systemNavigationBarColor: AppColors.scaffoldBackgroundLight,
            systemNavigationBarIconBrightness: Brightness.dark,
          ),
  );
}
