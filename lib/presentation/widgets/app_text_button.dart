// lib/widgets/app_text_button.dart
import 'package:flutter/material.dart';
import 'package:navex/presentation/widgets/themed_activity_indicator.dart';

enum TextBtnVariant { primary, secondary, danger, neutral, link }
enum TextBtnSize { sm, md, lg }

class AppTextButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool fullWidth;
  final TextBtnVariant variant;
  final TextBtnSize size;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final bool uppercase;
  final bool underlineWhenLink;

  const AppTextButton({
    super.key,
    required this.label,
    this.onPressed,
    this.isLoading = false,
    this.fullWidth = false,
    this.variant = TextBtnVariant.primary,
    this.size = TextBtnSize.md,
    this.leadingIcon,
    this.trailingIcon,
    this.uppercase = false,
    this.underlineWhenLink = true,
  });

  double get _fontSize {
    switch (size) {
      case TextBtnSize.sm: return 13;
      case TextBtnSize.md: return 15;
      case TextBtnSize.lg: return 17;
    }
  }

  EdgeInsets get _padding {
    switch (size) {
      case TextBtnSize.sm: return const EdgeInsets.symmetric(horizontal: 8, vertical: 8);
      case TextBtnSize.md: return const EdgeInsets.symmetric(horizontal: 10, vertical: 10);
      case TextBtnSize.lg: return const EdgeInsets.symmetric(horizontal: 12, vertical: 12);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    Color fg;
    switch (variant) {
      case TextBtnVariant.primary:   fg = cs.primary; break;
      case TextBtnVariant.secondary: fg = cs.secondary; break;
      case TextBtnVariant.danger:    fg = cs.error; break;
      case TextBtnVariant.neutral:   fg = cs.onSurfaceVariant; break;
      case TextBtnVariant.link:      fg = cs.primary; break;
    }

    final effectiveOnPressed = (isLoading || onPressed == null) ? null : onPressed;

    final style = TextButton.styleFrom(
      foregroundColor: fg,
      padding: _padding,
      minimumSize: Size(fullWidth ? double.infinity : 0, 0),
      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      textStyle: TextStyle(
        fontSize: _fontSize,
        fontWeight: FontWeight.w600,
        decoration: (variant == TextBtnVariant.link && underlineWhenLink)
            ? TextDecoration.underline
            : TextDecoration.none,
      ),
      // overlayColor: MaterialStateProperty.resolveWith((states) {
      //   if (states.contains(MaterialState.pressed)) {
      //     return fg.withOpacity(0.08);
      //   }
      //   return null;
      // }),
    );

    final child = AnimatedSwitcher(
      duration: const Duration(milliseconds: 150),
      child: isLoading
          ? SizedBox(
        key: const ValueKey('loader'),
        width: _fontSize + 4,
        height: _fontSize + 4,
        child: ThemedActivityIndicator(
          radius: (_fontSize + 4) / 3,
        ),
      )
          : Row(
        key: const ValueKey('label'),
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (leadingIcon != null) ...[
            Icon(leadingIcon, size: _fontSize + 2),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              uppercase ? label.toUpperCase() : label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (trailingIcon != null) ...[
            const SizedBox(width: 6),
            Icon(trailingIcon, size: _fontSize + 2),
          ],
        ],
      ),
    );

    final button = TextButton(
      onPressed: effectiveOnPressed,
      style: style,
      child: child,
    );

    // Make button expand horizontally when fullWidth
    return fullWidth
        ? SizedBox(width: double.infinity, child: button)
        : button;
  }
}
