import 'package:flutter/material.dart';
import 'package:navex/core/themes/app_colors.dart';
import 'package:navex/core/themes/app_sizes.dart';

/// A reusable dropdown that visually matches AppTextField
class AppDropdownButton<T> extends StatelessWidget {
  final String? label;
  final String? hint;
  final List<T> items;
  final T? selectedItem;
  final ValueChanged<T?> onChanged;
  final String Function(T) getLabel;
  final bool required;
  final bool enabled;
  final FormFieldValidator<T>? validator;

  const AppDropdownButton({
    super.key,
    required this.items,
    required this.getLabel,
    required this.onChanged,
    this.selectedItem,
    this.label,
    this.hint,
    this.required = false,
    this.enabled = true,
    this.validator,
  });

  String? _defaultValidator(T? value) {
    if (required && value == null) {
      return '${label ?? hint ?? 'This field'} is required';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final baseBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
      borderSide: BorderSide(color: theme.dividerColor, width: 0.2),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
      borderSide: BorderSide(color: theme.primaryColor, width: 0.2),
    );

    return DropdownButtonFormField<T>(
      value: selectedItem,
      validator: validator ?? _defaultValidator,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        filled: true,
        fillColor: AppColors.textFieldLight,
        hintStyle: theme.textTheme.bodyMedium!.copyWith(
          color: Theme.of(context).hintColor,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: baseBorder,
        enabledBorder: baseBorder,
        focusedBorder: focusedBorder,
        errorBorder: baseBorder.copyWith(
          borderSide: BorderSide(color: AppColors.errorLight),
        ),
        focusedErrorBorder: focusedBorder.copyWith(
          borderSide: BorderSide(color: AppColors.errorLight),
        ),
        errorStyle: theme.textTheme.labelMedium!.copyWith(
          color: AppColors.errorLight,
        ),
      ),
      icon: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.black,
      ),
      isExpanded: true,
      items: items.map((item) {
        return DropdownMenuItem<T>(
          value: item,
          child: Text(getLabel(item), style: theme.textTheme.bodyLarge),
        );
      }).toList(),
      onChanged: enabled ? onChanged : null,
    );
  }
}
