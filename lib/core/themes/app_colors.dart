import 'dart:math';
import 'package:flutter/material.dart';

class AppColors {
  static const primaryDark = Color(0xFF213448);
  static const primaryLight = Color(0xFF213448);

  static const labelPrimary = Color(0xFF000000);
  static const labelSecondary = Color(0xFF616161);

  static const shadowDark = Color(0xFF181818);
  static const shadowLight = Color(0xE2E8E8E8);

  static const canvasLight = Color(0xFFECEFCA);
  static const canvasDark = Color(0xFFECEFCA);

  static const scaffoldBackgroundLight = Color(0xFFF3F7FD);
  static const scaffoldBackgroundDark = Color(0xFF22242A);

  static const textFieldLight = Color(0xFFECEFCA);

  static const white = Color(0xFFFFFFFF);
  static const black = Color(0xFF121212);

  static const darkGrey = Color(0xFF383838);
  static const grey = Color(0xFF696969);

  static const cardDark = Color(0xFFECEFCA);
  static const cardLight = Color(0xFFECEFCA);

  static const dividerLight = Color(0xFFBDBDBD);
  static const dividerDark = Color(0xFF4D4D4D);

  static const hintLight = Color(0xFF737373);
  static const hintDark = Color(0xFFA2A2A2);

  static const errorLight = Color(0xFFCB2B2B);
  static const errorDark = Color(0xFFC42240);

  static const red = Color(0xFFEA1B1B);

  static const greenLight = Color(0xFF24EA48);
  static const greenDark = Color(0xFF27931C);

  static const lightColor1 = Color(0xFFE5F1F3);
  static const lightColor2 = Color(0xFFEFE5F7);
  static const lightColor3 = Color(0xFFE7F0F8);

  static const darkColor1 = Color(0xFF2D3536);
  static const darkColor2 = Color(0xFF39313F);
  static const darkColor3 = Color(0xFF292D31);

  static const gradientOne = Color(0xFF0021FF);
  static const gradientThree = Color(0xFF8F6CF1);
  static const gradientTwo = Color(0xFF7342FF);

  static const primaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      gradientTwo,
      gradientOne,
    ],
  );

  static const secondaryGradient = LinearGradient(
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
    colors: [
      AppColors.hintLight,
      AppColors.hintDark,
    ],
  );

  static const errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [errorDark, errorLight],
  );

  static MaterialColor generateMaterialColor(Color color) {
    return MaterialColor(color.value, {
      50: tintColor(color, 0.9),
      100: tintColor(color, 0.8),
      200: tintColor(color, 0.6),
      300: tintColor(color, 0.4),
      400: tintColor(color, 0.2),
      500: color,
      600: shadeColor(color, 0.1),
      700: shadeColor(color, 0.2),
      800: shadeColor(color, 0.3),
      900: shadeColor(color, 0.4),
    });
  }

  static int tintValue(int value, double factor) =>
      max(0, min((value + ((255 - value) * factor)).round(), 255));

  static Color tintColor(Color color, double factor) => Color.fromRGBO(
    tintValue(color.red, factor),
    tintValue(color.green, factor),
    tintValue(color.blue, factor),
    1,
  );

  static int shadeValue(int value, double factor) =>
      max(0, min(value - (value * factor).round(), 255));

  static Color shadeColor(Color color, double factor) => Color.fromRGBO(
    shadeValue(color.red, factor),
    shadeValue(color.green, factor),
    shadeValue(color.blue, factor),
    1,
  );
}
