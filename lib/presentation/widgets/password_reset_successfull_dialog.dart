import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:navex/core/resources/app_images.dart';
import 'package:navex/core/themes/app_sizes.dart';

class PasswordResetSuccessfullDialog extends StatelessWidget {
  const PasswordResetSuccessfullDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadiusGeometry.circular(AppSizes.cardCornerRadius),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSizes.kDefaultPadding,
          vertical: AppSizes.kDefaultPadding * 2,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          spacing: AppSizes.kDefaultPadding,
          children: [
            SvgPicture.asset(AppImages.checkGreen),
            Text('Successfull', style: Theme.of(context).textTheme.titleMedium),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSizes.kDefaultPadding * 2,
              ),
              child: Text(
                'Your password has been successfully reset! You can now log in with your new password.',
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.labelLarge!.copyWith(
                  color: Theme.of(context).hintColor,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
