// Paints a playful dotted/star background — lightweight, no images needed.

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/app_constants.dart';

class BackgroundPainter extends CustomPainter {
  final double animValue;

  BackgroundPainter(this.animValue);

  static const _decorations = [
    // (dx_fraction, dy_fraction, radius, type: 0=circle,1=star)
    [0.08, 0.05, 10.0, 1],
    [0.92, 0.10, 8.0, 0],
    [0.15, 0.90, 12.0, 1],
    [0.85, 0.85, 7.0, 0],
    [0.50, 0.03, 9.0, 1],
    [0.03, 0.50, 6.0, 0],
    [0.97, 0.50, 8.0, 1],
    [0.30, 0.12, 5.0, 0],
    [0.70, 0.08, 7.0, 1],
    [0.20, 0.75, 9.0, 0],
    [0.80, 0.78, 6.0, 1],
  ];

  @override
  void paint(Canvas canvas, Size size) {
    for (int i = 0; i < _decorations.length; i++) {
      final d = _decorations[i];
      final phase = i * 0.3;
      final pulse = math.sin((animValue + phase) * math.pi * 2) * 0.15 + 0.85;
      final opacity = (0.06 + (i % 3) * 0.02) * pulse;

      final paint = Paint()
        ..color = (i % 2 == 0 ? AppColors.primary : AppColors.secondary)
            .withOpacity(opacity);

      final center = Offset(
        (d[0] as double) * size.width,
        (d[1] as double) * size.height,
      );
      final r = (d[2] as double) * pulse;

      if (d[3] == 1) {
        _drawStar(canvas, center, r, paint);
      } else {
        canvas.drawCircle(center, r, paint);
      }
    }
  }

  void _drawStar(Canvas canvas, Offset center, double r, Paint paint) {
    final path = Path();
    const sides = 5;
    final angle = (math.pi * 2) / sides;
    for (int i = 0; i <= sides; i++) {
      final outer = Offset(
        center.dx + r * math.cos(i * angle - math.pi / 2),
        center.dy + r * math.sin(i * angle - math.pi / 2),
      );
      final inner = Offset(
        center.dx + r * 0.4 * math.cos(i * angle + angle / 2 - math.pi / 2),
        center.dy + r * 0.4 * math.sin(i * angle + angle / 2 - math.pi / 2),
      );
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(inner.dx, inner.dy);
        path.lineTo(outer.dx, outer.dy);
      }
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BackgroundPainter old) => old.animValue != animValue;
}
