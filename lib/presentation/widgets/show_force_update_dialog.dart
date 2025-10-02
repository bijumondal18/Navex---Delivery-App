import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/themes/app_colors.dart';
import '../../core/themes/app_sizes.dart';

void showUpdateDialog(
  BuildContext context, {
  required bool forceUpdate,
  required String updateUrl,
}) {
  showDialog(
    barrierDismissible: !forceUpdate,
    context: context,
    builder: (context) => AlertDialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
      ),
      backgroundColor: Theme.of(context).cardColor,
      title: Text(
        'Update Available',
        style: Theme.of(context).textTheme.titleLarge,
      ),
      content: Text(
        forceUpdate
            ? 'A new version of the app is required to continue.'
            : 'A new version of the app is available. Would you like to update?',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: [
        if (!forceUpdate)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Later',
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                color: Theme.of(context).colorScheme.surfaceContainer,
              ),
            ),
          ),
        TextButton(
          onPressed: () async {
            final uri = Uri.parse(updateUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: Text(
            'Update',
            style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              color: Theme.of(context).primaryColor,
            ),
          ),
        ),
      ],
    ),
  );
}
