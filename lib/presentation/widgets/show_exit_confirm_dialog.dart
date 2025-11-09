import 'package:flutter/material.dart';
import 'package:navex/core/themes/app_sizes.dart';
import '../../core/themes/app_colors.dart';

Future<bool?> showExitConfirmDialog(BuildContext context) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
        ),
        backgroundColor: Theme.of(context).cardColor,
        title: Text("Exit", style: Theme.of(context).textTheme.titleLarge),
        content: Text(
          "Are you sure you want to exit from the application?",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false);
            },
            child: Text(
              "No, Stay",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                    color: Theme.of(context)
                        .colorScheme
                        .onSurface
                        .withOpacity(0.7),
                  ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(true);
            },
            child: Text(
              "Yes, Exit",
              style: Theme.of(
                context,
              ).textTheme.bodyLarge!.copyWith(color: AppColors.errorDark),
            ),
          ),
        ],
      );
    },
  );
}
