// lib/widgets/app_text_field.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:navex/core/themes/app_colors.dart';
import 'package:navex/core/themes/app_sizes.dart';

enum AppTextFieldType { text, email, password, address, mobile, otp }

class AppTextField extends StatefulWidget {
  final AppTextFieldType type;
  final String? label;
  final String? hint;
  final TextEditingController? controller;
  final String? initialValue; // used only if controller is null
  final bool required;
  final int?
  maxLength; // respected for mobile; ignored for address unless provided
  final int?
  maxLines; // respected for address/text; ignored for password/email/mobile
  final Widget? prefix;
  final Widget? suffix;
  final TextInputAction? textInputAction;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final FormFieldValidator<String>? validator; // to override default
  final bool enabled;
  final bool readOnly;
  final VoidCallback? onTap;
  final EdgeInsets contentPadding;

  const AppTextField({
    super.key,
    required this.type,
    this.label,
    this.hint,
    this.controller,
    this.initialValue,
    this.required = false,
    this.maxLength,
    this.maxLines,
    this.prefix,
    this.suffix,
    this.textInputAction,
    this.focusNode,
    this.onChanged,
    this.validator,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.contentPadding = const EdgeInsets.symmetric(
      horizontal: 14,
      vertical: 14,
    ),
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  bool _obscure = true;

  TextInputType get _keyboardType {
    switch (widget.type) {
      case AppTextFieldType.email:
        return TextInputType.emailAddress;
      case AppTextFieldType.password:
        return TextInputType.visiblePassword;
      case AppTextFieldType.address:
        return TextInputType.streetAddress;
      case AppTextFieldType.mobile:
        return TextInputType.phone;
      case AppTextFieldType.otp:
        return TextInputType.number;
      case AppTextFieldType.text:
      default:
        return TextInputType.text;
    }
  }

  List<TextInputFormatter>? get _formatters {
    if (widget.type == AppTextFieldType.mobile) {
      final max = widget.maxLength ?? 15; // handles intl numbers
      return <TextInputFormatter>[
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(max),
      ];
    }
    return null;
  }

  int get _maxLines {
    if (widget.type == AppTextFieldType.address) {
      return widget.maxLines ?? 4;
    }
    if (widget.type == AppTextFieldType.text) {
      return widget.maxLines ?? 1;
    }
    return 1;
  }

  TextCapitalization get _capitalization {
    switch (widget.type) {
      case AppTextFieldType.address:
        return TextCapitalization.sentences;
      case AppTextFieldType.text:
        return TextCapitalization.sentences;
      default:
        return TextCapitalization.none;
    }
  }

  String? _defaultValidator(String? value) {
    final v = value?.trim() ?? '';
    if (widget.required && v.isEmpty) {
      return '${widget.label ?? widget.hint ?? 'This field'} is required';
    }

    switch (widget.type) {
      case AppTextFieldType.email:
        if (v.isEmpty) return null;
        final emailRe = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
        if (!emailRe.hasMatch(v)) return 'Enter a valid email';
        return null;
      case AppTextFieldType.password:
        if (v.isEmpty) return null;
        if (v.length < 6) return 'Password must be at least 6 characters';
        return null;
      case AppTextFieldType.mobile:
        if (v.isEmpty) return null;
        if (v.length < 10) return 'Enter a valid mobile number';
        return null;
      case AppTextFieldType.otp:
        if (v.isEmpty) return null;
        if (v.length < 6) return 'Enter a valid OTP';
        return null;
      case AppTextFieldType.address:
      case AppTextFieldType.text:
        return null;
    }
  }

  InputDecoration _decoration(ThemeData theme) {
    final base = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
      borderSide: BorderSide(color: theme.dividerColor, width: 0.6),
    );
    final focused = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppSizes.cardCornerRadius),
      borderSide: BorderSide(color: theme.primaryColor, width: 0.6),
    );

    return InputDecoration(
      labelText: widget.label,
      hintText: widget.hint,
      hintStyle: Theme.of(
        context,
      ).textTheme.bodyMedium!.copyWith(color: Theme.of(context).hintColor),
      contentPadding: widget.contentPadding,
      prefixIcon: widget.prefix,
      suffixIcon: widget.type == AppTextFieldType.password
          ? IconButton(
              tooltip: _obscure ? 'Show' : 'Hide',
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility),
              onPressed: () => setState(() => _obscure = !_obscure),
            )
          : widget.suffix,
      border: base,
      enabledBorder: base,
      focusedBorder: focused,
      errorBorder: base.copyWith(
        borderSide: BorderSide(color: AppColors.errorLight),
      ),
      focusedErrorBorder: focused.copyWith(
        borderSide: BorderSide(color: AppColors.errorLight),
      ),
      errorStyle: Theme.of(
        context,
      ).textTheme.labelMedium!.copyWith(color: AppColors.errorLight),
      counterText: '', // keeps UI tidy when maxLength used
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: widget.controller,
      initialValue: widget.controller == null ? widget.initialValue : null,
      enabled: widget.enabled,
      readOnly: widget.readOnly,
      onTap: widget.onTap,
      obscureText: widget.type == AppTextFieldType.password ? _obscure : false,
      keyboardType: _keyboardType,
      inputFormatters: _formatters,
      textCapitalization: _capitalization,
      maxLength: widget.type == AppTextFieldType.mobile
          ? (widget.maxLength ?? 15)
          : widget.maxLength,
      maxLines: _maxLines,
      textInputAction:
          widget.textInputAction ??
          (_maxLines > 1 ? TextInputAction.newline : TextInputAction.next),
      decoration: _decoration(theme),
      validator: widget.validator ?? _defaultValidator,
      onChanged: widget.onChanged,
    );
  }
}
