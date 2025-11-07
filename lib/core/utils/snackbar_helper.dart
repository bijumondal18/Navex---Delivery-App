import 'package:flutter/material.dart';

import '../themes/app_colors.dart';
import '../themes/app_sizes.dart';

enum SnackBarType {
  success,
  error,
  info,
  warning,
}

class SnackBarHelper {
  static final GlobalKey<ScaffoldMessengerState> messengerKey =
      GlobalKey<ScaffoldMessengerState>();

  /// Show a snackbar with the specified message and type
  static void show(
    String message, {
    SnackBarType type = SnackBarType.info,
    BuildContext? context,
  }) {
    final messenger = context != null
        ? ScaffoldMessenger.of(context)
        : messengerKey.currentState;
    
    if (messenger != null) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(
        _buildSnackBar(message, type, context),
      );
    }
  }

  /// Show success snackbar
  static void showSuccess(String message, {BuildContext? context}) {
    show(message, type: SnackBarType.success, context: context);
  }

  /// Show error snackbar
  static void showError(String message, {BuildContext? context}) {
    show(message, type: SnackBarType.error, context: context);
  }

  /// Show info snackbar
  static void showInfo(String message, {BuildContext? context}) {
    show(message, type: SnackBarType.info, context: context);
  }

  /// Show warning snackbar
  static void showWarning(String message, {BuildContext? context}) {
    show(message, type: SnackBarType.warning, context: context);
  }

  static SnackBar _buildSnackBar(
    String message,
    SnackBarType type,
    BuildContext? context,
  ) {
    Color backgroundColor;
    
    if (context != null) {
      // Use theme colors when context is available
      switch (type) {
        case SnackBarType.success:
          backgroundColor = Theme.of(context).colorScheme.surfaceContainer;
          break;
        case SnackBarType.error:
          backgroundColor = AppColors.errorLight.withValues(alpha: 0.9);
          break;
        case SnackBarType.info:
          backgroundColor = Theme.of(context).primaryColor;
          break;
        case SnackBarType.warning:
          backgroundColor = Colors.orange.withValues(alpha: 0.9);
          break;
      }
    } else {
      // Fallback colors when context is not available
      switch (type) {
        case SnackBarType.success:
          backgroundColor = AppColors.greenDark;
          break;
        case SnackBarType.error:
          backgroundColor = AppColors.errorLight;
          break;
        case SnackBarType.info:
          backgroundColor = AppColors.primaryDark;
          break;
        case SnackBarType.warning:
          backgroundColor = Colors.orange;
          break;
      }
    }

    return SnackBar(
      content: Text(
        message,
        style: context != null
            ? Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w500,
                )
            : const TextStyle(
                color: AppColors.white,
                fontSize: AppSizes.labelLarge,
                fontWeight: FontWeight.w500,
              ),
      ),
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
      ),
      margin: const EdgeInsets.all(AppSizes.kDefaultPadding),
      elevation: 4,
      duration: const Duration(seconds: 3),
    );
  }
}
