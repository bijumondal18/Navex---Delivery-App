
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

class AppTheme {
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryLight,
      brightness: Brightness.light,
    );

    final textTheme = GoogleFonts.latoTextTheme().apply(
      bodyColor: AppColors.black,
      displayColor: AppColors.black,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.light,
      primaryColor: colorScheme.primary,
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundLight,
      dividerColor: AppColors.dividerLight,
      cardColor: AppColors.white,
      canvasColor: AppColors.canvasLight,
      shadowColor: AppColors.shadowLight,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      dividerTheme: DividerThemeData(
        thickness: 0.5,
        color: AppColors.black.withAlpha(100),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: AppSizes.elevationSmall,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.white),
      switchTheme: SwitchThemeData(
        trackColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.greenLight;
          }
          return AppColors.dividerLight;
        }),
        thumbColor: MaterialStateProperty.resolveWith<Color?>((states) {
          return AppColors.white;
        }),
        trackOutlineWidth: MaterialStateProperty.all(0.0),
      ),
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(
          size: AppSizes.appBarIconSize,
          color: colorScheme.onPrimary,
        ),
        backgroundColor: colorScheme.primary,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        foregroundColor: colorScheme.onPrimary,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colorScheme.primary,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.secondaryContainer,
        unselectedItemColor: colorScheme.onPrimary.withOpacity(0.6),
        selectedLabelStyle: GoogleFonts.lato(
          fontSize: AppSizes.bodySmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.lato(
          fontSize: AppSizes.bodySmall,
          fontWeight: FontWeight.w500,
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        circularTrackColor: AppColors.scaffoldBackgroundLight,
      ),
      visualDensity: VisualDensity.adaptivePlatformDensity,
      tabBarTheme: TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0.0,
        indicatorAnimation: TabIndicatorAnimation.elastic,
        dividerColor: Colors.transparent,
        indicatorColor: colorScheme.primary,
        labelStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.primary,
        ),
        unselectedLabelStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.hintLight,
        ),
      ),
      textTheme: textTheme,
    );
  }

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primaryDark,
      brightness: Brightness.dark,
    );

    final textTheme = GoogleFonts.latoTextTheme().apply(
      bodyColor: AppColors.white,
      displayColor: AppColors.white,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      brightness: Brightness.dark,
      primaryColor: colorScheme.primary,
      dividerColor: AppColors.dividerDark,
      cardColor: AppColors.cardDark,
      canvasColor: AppColors.canvasDark,
      shadowColor: AppColors.shadowDark,
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.transparent,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: AppSizes.elevationSmall,
        backgroundColor: colorScheme.primary,
        foregroundColor: colorScheme.onPrimary,
      ),
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(
          size: AppSizes.appBarIconSize,
          color: colorScheme.onPrimary,
        ),
        backgroundColor: colorScheme.primary,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        centerTitle: true,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w600,
        ),
        foregroundColor: colorScheme.onPrimary,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: colorScheme.primary,
        circularTrackColor: AppColors.scaffoldBackgroundDark,
      ),
      switchTheme: SwitchThemeData(
        trackColor: MaterialStateProperty.resolveWith<Color?>((states) {
          if (states.contains(MaterialState.selected)) {
            return AppColors.greenDark;
          }
          return AppColors.hintDark;
        }),
        thumbColor: MaterialStateProperty.resolveWith<Color?>((states) {
          return AppColors.white;
        }),
        trackOutlineWidth: MaterialStateProperty.all(0.0),
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.kDefaultPadding * 5),
        ),
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundDark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      tabBarTheme: TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0.0,
        indicatorAnimation: TabIndicatorAnimation.elastic,
        dividerColor: Colors.transparent,
        indicatorColor: colorScheme.primary.withOpacity(0.6),
        labelStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: AppColors.hintDark,
        ),
        labelColor: colorScheme.primary,
        unselectedLabelColor: AppColors.grey,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: colorScheme.onSurface,
        unselectedItemColor: AppColors.hintDark,
        selectedLabelStyle: GoogleFonts.lato(
          fontSize: AppSizes.bodySmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.lato(
          fontSize: AppSizes.bodySmall,
          fontWeight: FontWeight.w500,
        ),
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.shadowDark,
      ),
      textTheme: textTheme,
    );
  }
}
