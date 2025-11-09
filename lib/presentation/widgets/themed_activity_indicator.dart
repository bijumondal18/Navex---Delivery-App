import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ThemedActivityIndicator extends StatelessWidget {
  final double? radius;
  final Color? color;

  const ThemedActivityIndicator({
    super.key,
    this.radius,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final resolvedColor = color ?? scheme.primary;

    return CupertinoActivityIndicator(
      radius: radius ?? 12,
      color: resolvedColor,
    );
  }
}

