import 'package:flutter/material.dart';
import 'package:navex/core/navigation/app_router.dart';
import 'package:navex/core/themes/app_colors.dart';
import 'package:navex/core/themes/app_sizes.dart';

Future<void> showLogoutDialog(
  BuildContext context,
  VoidCallback onConfirm,
) async {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
        ),
        backgroundColor: Theme.of(context).cardColor,
        title: Text("Logout", style: Theme.of(context).textTheme.titleLarge),
        content: Text(
          "Are you sure you want to log out from this device?",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => appRouter.pop(), // Close dialog
            child: Text(
              "Cancel",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              appRouter.pop(); // Close dialog first
              onConfirm(); // Perform logout
            },
            child: Text(
              "Logout",
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: AppColors.errorDark,
              ),
            ),
          ),
        ],
      );
    },
  );
}
