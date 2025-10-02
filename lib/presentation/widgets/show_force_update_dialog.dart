
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

void showUpdateDialog(BuildContext context, {
  required bool forceUpdate,
  required String updateUrl,
}) {
  showDialog(
    barrierDismissible: !forceUpdate,
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Update Available'),
      content: Text(forceUpdate
          ? 'A new version of the app is required to continue.'
          : 'A new version of the app is available. Would you like to update?'),
      actions: [
        if (!forceUpdate)
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Later'),
          ),
        TextButton(
          onPressed: () async {
            final uri = Uri.parse(updateUrl);
            if (await canLaunchUrl(uri)) {
              await launchUrl(uri, mode: LaunchMode.externalApplication);
            }
          },
          child: const Text('Update'),
        ),
      ],
    ),
  );
}