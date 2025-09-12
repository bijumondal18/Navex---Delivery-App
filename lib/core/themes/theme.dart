import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';
import 'app_sizes.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      dividerColor: AppColors.dividerLight,
      primarySwatch: AppColors.generateMaterialColor(AppColors.primaryLight),
      brightness: Brightness.dark,
      cardColor: AppColors.white,
      primaryColor: AppColors.primaryLight,
      hintColor: AppColors.hintLight,
      disabledColor: AppColors.hintLight,
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
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: AppSizes.elevationSmall,
        backgroundColor: AppColors.primaryLight,
      ),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.white,
      ),
      appBarTheme: const AppBarTheme(
        iconTheme: IconThemeData(
          size: AppSizes.appBarIconSize,
          color: AppColors.white,
        ),
        backgroundColor: AppColors.primaryLight,
        elevation: 0.0,
        scrolledUnderElevation: 0.0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: AppSizes.titleMedium,
          fontWeight: FontWeight.w600,
        ),
        foregroundColor: AppColors.white,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.primaryLight,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.greenLight,
        unselectedItemColor: AppColors.white.withAlpha(200),
        selectedLabelStyle: GoogleFonts.lato(
          fontSize: AppSizes.bodySmall,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.lato(
          fontSize: AppSizes.bodySmall,
          fontWeight: FontWeight.w500,
        ),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.black,
        circularTrackColor: AppColors.scaffoldBackgroundLight,
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundLight,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      tabBarTheme:  TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        // indicator: FilledUnderlineIndicator(
        //   fillColor: AppColors.primaryLight.withAlpha(10), // background
        //   underlineColor: AppColors.primaryLight, // underline
        //   underlineHeight: 1.5,
        //   borderRadius: BorderRadius.circular(0),
        // ),
        dividerHeight: 0.0,
        indicatorAnimation: TabIndicatorAnimation.elastic,
        dividerColor: Colors.transparent,
        indicatorColor: AppColors.primaryLight,
        labelStyle: TextStyle(
          fontSize: AppSizes.bodyMedium,
          fontWeight: FontWeight.w600,
          color: AppColors.primaryLight,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppSizes.bodyMedium,
          fontWeight: FontWeight.w500,
          color: AppColors.hintLight,
        ),
      ),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.lato(
          color: AppColors.black,
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.displayLarge,
        ),
        displayMedium: GoogleFonts.lato(
          color: AppColors.black,
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.displayMedium,
        ),
        displaySmall: GoogleFonts.lato(
          color: AppColors.black,
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.displaySmall,
        ),
        headlineLarge: GoogleFonts.lato(
          color: AppColors.black,
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.headlineLarge,
        ),
        headlineMedium: GoogleFonts.lato(
          color: AppColors.black,
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.headlineMedium,
        ),
        headlineSmall: GoogleFonts.lato(
          color: AppColors.black,
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.headlineSmall,
        ),
        titleLarge: GoogleFonts.lato(
          color: AppColors.black,
          fontWeight: FontWeight.w600,
          fontSize: AppSizes.titleLarge,
        ),
        titleMedium: GoogleFonts.lato(
          color: AppColors.black,
          fontWeight: FontWeight.w500,
          fontSize: AppSizes.titleMedium,
        ),
        titleSmall: GoogleFonts.lato(
          color: AppColors.black,
          fontWeight: FontWeight.w400,
          fontSize: AppSizes.titleSmall,
        ),
        bodyLarge: GoogleFonts.lato(
          color: AppColors.black,
          fontSize: AppSizes.bodyLarge,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.lato(
          color: AppColors.black,
          fontWeight: FontWeight.w400,
          fontSize: AppSizes.bodyMedium,
        ),
        bodySmall: GoogleFonts.lato(
          color: AppColors.black,
          fontWeight: FontWeight.w300,
          fontSize: AppSizes.bodySmall,
        ),
        labelLarge: GoogleFonts.lato(
          color: AppColors.black,
          fontWeight: FontWeight.w400,
          fontSize: AppSizes.labelLarge,
        ),
        labelMedium: GoogleFonts.lato(
          color: AppColors.black,
          fontWeight: FontWeight.w400,
          fontSize: AppSizes.labelMedium,
        ),
        labelSmall: GoogleFonts.lato(
          color: AppColors.black,
          fontWeight: FontWeight.w300,
          fontSize: AppSizes.labelSmall,
        ),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      primarySwatch: AppColors.generateMaterialColor(AppColors.primaryDark),
      dividerColor: AppColors.dividerDark,
      brightness: Brightness.light,
      cardColor: AppColors.cardDark,
      primaryColor: AppColors.primaryDark,
      hintColor: AppColors.hintDark,
      disabledColor: AppColors.hintDark,
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
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        elevation: AppSizes.elevationSmall,
        backgroundColor: AppColors.primaryDark,
      ),
      appBarTheme: AppBarTheme(
        iconTheme: IconThemeData(
          size: AppSizes.appBarIconSize,
          color: AppColors.white,
        ),
        backgroundColor: AppColors.black,
        elevation: 0.0,
        scrolledUnderElevation: AppSizes.elevationSmall,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppColors.white,
          fontSize: AppSizes.titleMedium,
          fontWeight: FontWeight.w600,
        ),
        foregroundColor: AppColors.white,
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.primaryDark,
        circularTrackColor: AppColors.scaffoldBackgroundDark,
      ),
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.kDefaultPadding * 5),
        ),
      ),
      scaffoldBackgroundColor: AppColors.scaffoldBackgroundDark,
      visualDensity: VisualDensity.adaptivePlatformDensity,
      tabBarTheme:  TabBarThemeData(
        indicatorSize: TabBarIndicatorSize.tab,
        // indicator: FilledUnderlineIndicator(
        //   fillColor: AppColors.primaryDark.withAlpha(20), // background
        //   underlineColor: AppColors.primaryDark, // underline
        //   underlineHeight: 1.5,
        //   borderRadius: BorderRadius.circular(0),
        // ),
        dividerHeight: 0.0,
        indicatorAnimation: TabIndicatorAnimation.elastic,
        dividerColor: Colors.transparent,
        indicatorColor: AppColors.primaryDark.withAlpha(100),
        labelStyle: TextStyle(
          fontSize: AppSizes.bodyMedium,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: TextStyle(
          fontSize: AppSizes.bodyMedium,
          fontWeight: FontWeight.w500,
        ),
        labelColor: AppColors.primaryDark,
        unselectedLabelColor: AppColors.grey,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: AppColors.scaffoldBackgroundDark,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.white,
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
      drawerTheme: const DrawerThemeData(backgroundColor: AppColors.shadowDark),
      textTheme: TextTheme(
        displayLarge: GoogleFonts.lato(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
            fontSize: AppSizes.displayLarge
        ),
        displayMedium: GoogleFonts.lato(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.displayMedium
        ),
        displaySmall: GoogleFonts.lato(
          color: AppColors.white,
          fontWeight: FontWeight.w700,
          fontSize: AppSizes.displaySmall
        ),
        headlineLarge: GoogleFonts.lato(
          color: AppColors.white,
          fontSize: AppSizes.headlineLarge,
          fontWeight: FontWeight.w800,
        ),
        headlineMedium: GoogleFonts.lato(
          color: AppColors.white,
          fontSize: AppSizes.headlineMedium,
          fontWeight: FontWeight.w700,
        ),
        headlineSmall: GoogleFonts.lato(
          color: AppColors.white,
          fontSize: AppSizes.headlineSmall,
          fontWeight: FontWeight.w600,
        ),
        titleLarge: GoogleFonts.lato(
          color: AppColors.white,
          fontSize: AppSizes.titleLarge,
          fontWeight: FontWeight.w600,
        ),
        titleMedium: GoogleFonts.lato(
          color: AppColors.white,
          fontSize: AppSizes.titleMedium,
          fontWeight: FontWeight.w500,
        ),
        titleSmall: GoogleFonts.lato(
          color: AppColors.white,
          fontSize: AppSizes.titleSmall,
          fontWeight: FontWeight.w400,
        ),
        bodyLarge: GoogleFonts.lato(
          color: AppColors.white,
          fontSize: AppSizes.bodyLarge,
          fontWeight: FontWeight.w500,
        ),
        bodyMedium: GoogleFonts.lato(
          color: AppColors.white,
          fontSize: AppSizes.bodyMedium,
          fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.lato(
          color: AppColors.white,
          fontSize: AppSizes.bodySmall,
          fontWeight: FontWeight.w300,
        ),
        labelLarge: GoogleFonts.lato(
          color: AppColors.white,
          fontSize: AppSizes.labelLarge,
          fontWeight: FontWeight.w400,
        ),
        labelMedium: GoogleFonts.lato(
          color: AppColors.white,
          fontSize: AppSizes.labelMedium,
          fontWeight: FontWeight.w400,
        ),
        labelSmall: GoogleFonts.lato(
          color: AppColors.white,
          fontSize: AppSizes.labelSmall,
          fontWeight: FontWeight.w300,
        ),
      ),
    );
  }
}
