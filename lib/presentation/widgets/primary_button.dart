// lib/widgets/primary_button.dart
import 'package:flutter/material.dart';
import 'package:navex/core/themes/app_colors.dart';
import 'package:navex/core/themes/app_sizes.dart';

enum ButtonSize { sm, md, lg }

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final ButtonSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;

  const PrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.size = ButtonSize.md,
    this.leadingIcon,
    this.trailingIcon,
  });

  double get _height {
    switch (size) {
      case ButtonSize.sm:
        return 44;
      case ButtonSize.md:
        return 52;
      case ButtonSize.lg:
        return 56;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case ButtonSize.sm:
        return const EdgeInsets.symmetric(horizontal: 14);
      case ButtonSize.md:
        return const EdgeInsets.symmetric(horizontal: 18);
      case ButtonSize.lg:
        return const EdgeInsets.symmetric(horizontal: 22);
    }
  }

  double get _fontSize {
    switch (size) {
      case ButtonSize.sm:
        return 14;
      case ButtonSize.md:
        return 16;
      case ButtonSize.lg:
        return 18;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = theme.primaryColor;
    final onColor = theme.colorScheme.onPrimary;

    final child = AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: isLoading
          ? SizedBox(
              key: const ValueKey('loader'),
              width: _fontSize + 4,
              height: _fontSize + 4,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                valueColor: AlwaysStoppedAnimation<Color>(onColor),
              ),
            )
          : Row(
              key: const ValueKey('label'),
              mainAxisSize: MainAxisSize.min,
              children: [
                if (leadingIcon != null) ...[
                  Icon(leadingIcon, size: _fontSize + 2),
                  const SizedBox(width: 8),
                ],
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: _fontSize,
                      fontWeight: FontWeight.w600,
                      color: AppColors.white,
                    ),
                  ),
                ),
                if (trailingIcon != null) ...[
                  const SizedBox(width: 8),
                  Icon(trailingIcon, size: _fontSize + 2),
                ],
              ],
            ),
    );

    final button = ElevatedButton(
      onPressed: (isLoading || onPressed == null) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        elevation: 0,
        minimumSize: Size(fullWidth ? double.infinity : 0, _height),
        padding: _padding,
        backgroundColor: color,
        foregroundColor: onColor,
        disabledBackgroundColor: color.withOpacity(0.45),
        disabledForegroundColor: onColor.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius)),
      ),
      child: child,
    );

    return fullWidth
        ? button
        : ConstrainedBox(
            constraints: BoxConstraints(minHeight: _height),
            child: button,
          );
  }
}
