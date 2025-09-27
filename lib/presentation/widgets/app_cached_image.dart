// lib/widgets/app_cached_image.dart
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class AppCachedImage extends StatelessWidget {
  final String? url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final bool circular;          // quick circle mode
  final Duration fadeInDuration;
  final Duration fadeOutDuration;
  final Widget? placeholder;    // override default
  final Widget? errorPlaceholder;// override default
  final Color? bgColor;         // placeholder/error bg

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
  });

  @override
  Widget build(BuildContext context) {
    final radius = circular
        ? (width != null ? BorderRadius.circular((width! + (height ?? width!)) / 2) : BorderRadius.circular(9999))
        : (borderRadius ?? BorderRadius.circular(12));

    final defaultBg = bgColor ?? Theme.of(context).colorScheme.surfaceVariant;

    Widget shadedBox(Widget child) => Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: defaultBg,
        borderRadius: radius,
      ),
      alignment: Alignment.center,
      child: child,
    );

    final loading = placeholder ??
        shadedBox(const CupertinoActivityIndicator());

    final error = errorPlaceholder ??
        shadedBox(const Icon(Icons.broken_image_outlined));

    // If url is null or empty, show error right away
    if (url == null || url!.trim().isEmpty) {
      return ClipRRect(borderRadius: radius, child: error);
    }

    final image = CachedNetworkImage(
      imageUrl: url!,
      width: width,
      height: height,
      fit: fit,
      fadeInDuration: fadeInDuration,
      fadeOutDuration: fadeOutDuration,
      placeholder: (_, __) => loading,
      errorWidget: (_, __, ___) => error,
      memCacheHeight: height?.toInt(),
      memCacheWidth: width?.toInt(),
    );

    return ClipRRect(
      borderRadius: radius,
      child: image,
    );
  }
}
