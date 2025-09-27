// lib/widgets/vertical_dotted_divider.dart
import 'package:flutter/material.dart';

class VerticalDottedDivider extends StatelessWidget {
  final double height;        // total height
  final double dotSize;       // diameter of each dot
  final double gap;           // space between dots
  final Color color;          // dot color
  final EdgeInsetsGeometry padding;

  const VerticalDottedDivider({
    super.key,
    this.height = 48,
    this.dotSize = 3,
    this.gap = 4,
    this.color = const Color(0xFFBDBDBD),
    this.padding = const EdgeInsets.symmetric(horizontal: 8),
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: padding,
      child: SizedBox(
        width: dotSize,            // thin column of dots
        height: height,
        child: CustomPaint(
          painter: _DottedPainter(
            dotSize: dotSize,
            gap: gap,
            color: color,
          ),
        ),
      ),
    );
  }
}

class _DottedPainter extends CustomPainter {
  final double dotSize;
  final double gap;
  final Color color;

  _DottedPainter({required this.dotSize, required this.gap, required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final radius = dotSize / 2;
    final step = dotSize + gap;

    double y = 0;
    final cx = size.width / 2;
    while (y <= size.height - dotSize) {
      canvas.drawCircle(Offset(cx, y + radius), radius, paint);
      y += step;
    }
  }

  @override
  bool shouldRepaint(covariant _DottedPainter old) =>
      old.dotSize != dotSize || old.gap != gap || old.color != color;
}
