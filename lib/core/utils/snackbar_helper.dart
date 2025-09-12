import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../themes/app_colors.dart';
import '../themes/app_sizes.dart';

class SnackBarHelper {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  static void show(String message) {
    final messenger = messengerKey.currentState;
    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        SnackBar(
          backgroundColor: AppColors.red,
          elevation: 0.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
          ),
          content: Text(
            message,
            style: GoogleFonts.lato(
              fontSize: AppSizes.titleSmall,
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }
}
