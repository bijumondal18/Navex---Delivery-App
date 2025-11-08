import 'package:flutter/material.dart';

import '../themes/app_colors.dart';
import '../themes/app_sizes.dart';

Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  bool barrierDismissible = false,
}) {
  return showDatePicker(
    context: context,
    initialDate: initialDate,
    firstDate: firstDate,
    lastDate: lastDate,
    barrierDismissible: barrierDismissible,
    builder: (ctx, child) {
      if (child == null) {
        return const SizedBox.shrink();
      }

      final theme = Theme.of(ctx);
      final colorScheme = theme.colorScheme;
      final onSurfaceColor =
          theme.textTheme.bodyLarge?.color ?? colorScheme.onSurface;

      return Theme(
        data: theme.copyWith(
          colorScheme: colorScheme.copyWith(
            primary: theme.primaryColor,
            onPrimary: AppColors.white,
            surface: theme.cardColor,
            onSurface: onSurfaceColor,
          ),
          dialogTheme: theme.dialogTheme.copyWith(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: theme.primaryColor,
              textStyle: theme.textTheme.labelLarge,
            ),
          ),
          datePickerTheme: DatePickerThemeData(
            backgroundColor: theme.cardColor,
            headerBackgroundColor: theme.primaryColor,
            headerForegroundColor: AppColors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
            ),
            todayBorder: BorderSide(color: theme.primaryColor),
            dayForegroundColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.white;
              }
              if (states.contains(WidgetState.disabled)) {
                return onSurfaceColor.withValues(alpha: 0.35);
              }
              return onSurfaceColor;
            }),
            yearForegroundColor: WidgetStateColor.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.white;
              }
              if (states.contains(WidgetState.disabled)) {
                return onSurfaceColor.withValues(alpha: 0.4);
              }
              return onSurfaceColor;
            }),
            weekdayStyle: theme.textTheme.labelSmall?.copyWith(
              color: onSurfaceColor.withValues(alpha: 0.75),
            ),
          ),
        ),
        child: child,
      );
    },
  );
}

