import 'package:flutter/material.dart';

import '../../core/navigation/app_router.dart';
import '../../core/themes/app_colors.dart';
import '../../core/themes/app_sizes.dart';

Future<void> showDeleteAccountDialog(
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
        title: Text(
          "Delete Account",
          style: Theme.of(context).textTheme.titleLarge,
        ),
        content: Text(
          "Are you sure you want to delete your account? This will permanently delete your account and you can not login with this account.",
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        actions: [
          TextButton(
            onPressed: () => appRouter.pop(), // Close dialog
            child: Text(
              "Cancel",
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
              appRouter.pop(); // Close dialog first
              onConfirm(); // Perform logout
            },
            child: Text(
              "Delete account",
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
