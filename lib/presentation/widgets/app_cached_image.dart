// lib/widgets/app_cached_image.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:navex/core/themes/app_sizes.dart';

class AppCachedImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool circular;                // circle avatar mode
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Widget? placeholder;          // override default
  final Widget? errorPlaceholder;     // override default
  final Color? bgColor;               // placeholder/error bg

  // NEW: border controls
  final Color borderColor;
  final double borderWidth;

  const AppCachedImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.circular = false,
    this.fadeInDuration = const Duration(milliseconds: 250),
    this.fadeOutDuration = const Duration(milliseconds: 150),
    this.placeholder,
    this.errorPlaceholder,
    this.bgColor,
    this.borderColor = Colors.white,          // <- white border
    this.borderWidth = 1.0,                   // <- default width
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSizes.cardCornerRadius);
    final defaultBg = bgColor ?? Theme.of(context).colorScheme.surface.withAlpha(100);

    // Outer decorated container draws the border
    Widget withBorder(Widget child) {
      final decoration = circular
          ? BoxDecoration(
        shape: BoxShape.circle,
        color: defaultBg,
        border: Border.all(color: borderColor, width: borderWidth),
      )
          : BoxDecoration(
        color: defaultBg,
        borderRadius: radius,
        border: Border.all(color: borderColor, width: borderWidth),
      );

      final clip = circular
          ? ClipOval(child: child)
          : ClipRRect(borderRadius: radius, child: child);

      return Container(
        width: width,
        height: height,
        decoration: decoration,
        clipBehavior: Clip.antiAlias,
        child: clip,
      );
    }

    Widget shadedBox(Widget inner) => Container(
      color: defaultBg,
      alignment: Alignment.center,
      child: inner,
    );

    final loading = placeholder ?? shadedBox(const CupertinoActivityIndicator());
    final error    = errorPlaceholder ?? shadedBox(const Icon(Icons.broken_image_outlined));

    // If url is empty, show error in bordered container
    if (url == null || url!.trim().isEmpty) {
      return withBorder(error);
    }

    // Compute cache dimensions in physical pixels to keep images crisp without distortion.
    final mediaQuery = MediaQuery.maybeOf(context);
    final devicePixelRatio = mediaQuery?.devicePixelRatio ?? 1.0;

    int? cacheWidth;
    int? cacheHeight;

    if (width != null) {
      cacheWidth = (width! * devicePixelRatio).round();
    }
    if (height != null) {
      cacheHeight = (height! * devicePixelRatio).round();
    }

    final image = CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
      placeholder: (_, __) => loading,
      errorWidget:  (_, __, ___) => error,
      memCacheWidth: cacheWidth,
      memCacheHeight: cacheHeight,
    );

    return withBorder(image);
  }
}
