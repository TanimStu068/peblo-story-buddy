// Draws "Pip" the robot buddy using pure Flutter Canvas — no asset dependency.
// Reacts to app state: idle, speaking, happy (correct answer).

import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../providers/story_provider.dart';
import '../utils/app_constants.dart';

class BuddyWidget extends StatefulWidget {
  final AudioState audioState;
  final QuizState quizState;

  const BuddyWidget({
    super.key,
    required this.audioState,
    required this.quizState,
  });

  @override
  State<BuddyWidget> createState() => _BuddyWidgetState();
}

class _BuddyWidgetState extends State<BuddyWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _eyeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _bounceAnimation = Tween<double>(
      begin: 0,
      end: 8,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    _eyeAnimation = Tween<double>(begin: 1.0, end: 0.15).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  bool get _isHappy => widget.quizState == QuizState.correct;
  bool get _isSpeaking => widget.audioState == AudioState.playing;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Transform.translate(
          offset: Offset(0, -_bounceAnimation.value),
          child: CustomPaint(
            size: const Size(120, 120),
            painter: _BuddyPainter(
              isHappy: _isHappy,
              isSpeaking: _isSpeaking,
              eyeScale: _eyeAnimation.value,
              animValue: _controller.value,
            ),
          ),
        );
      },
    );
  }
}

class _BuddyPainter extends CustomPainter {
  final bool isHappy;
  final bool isSpeaking;
  final double eyeScale;
  final double animValue;

  _BuddyPainter({
    required this.isHappy,
    required this.isSpeaking,
    required this.eyeScale,
    required this.animValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    final cy = size.height / 2;

    // ── Body (rounded rectangle) ─────────────────────────────────────
    final bodyPaint = Paint()
      ..color = AppColors.secondary
      ..style = PaintingStyle.fill;

    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.15)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 2), width: 80, height: 80),
        const Radius.circular(24),
      ),
      shadowPaint,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy), width: 80, height: 80),
        const Radius.circular(24),
      ),
      bodyPaint,
    );

    // ── Face plate ────────────────────────────────────────────────────
    final facePaint = Paint()..color = const Color(0xFFECEFF1);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy - 4), width: 60, height: 54),
        const Radius.circular(16),
      ),
      facePaint,
    );

    // ── Antenna ───────────────────────────────────────────────────────
    final antPaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(cx, cy - 40),
      Offset(cx, cy - 55 + math.sin(animValue * math.pi * 2) * 3),
      antPaint,
    );
    canvas.drawCircle(
      Offset(cx, cy - 56 + math.sin(animValue * math.pi * 2) * 3),
      6,
      Paint()..color = AppColors.accent,
    );

    // ── Eyes ──────────────────────────────────────────────────────────
    _drawEye(canvas, Offset(cx - 13, cy - 8), eyeScale, isHappy);
    _drawEye(canvas, Offset(cx + 13, cy - 8), eyeScale, isHappy);

    // ── Mouth ─────────────────────────────────────────────────────────
    if (isHappy) {
      _drawSmile(canvas, Offset(cx, cy + 12));
    } else if (isSpeaking) {
      _drawTalkingMouth(canvas, Offset(cx, cy + 12), animValue);
    } else {
      _drawNeutralMouth(canvas, Offset(cx, cy + 12));
    }

    // ── Ear bolts ─────────────────────────────────────────────────────
    final boltPaint = Paint()..color = AppColors.primaryLight;
    canvas.drawCircle(Offset(cx - 40, cy), 6, boltPaint);
    canvas.drawCircle(Offset(cx + 40, cy), 6, boltPaint);

    // ── Chest panel (gear icon area) ─────────────────────────────────
    final panelPaint = Paint()..color = AppColors.secondaryLight;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(cx, cy + 26), width: 36, height: 16),
        const Radius.circular(6),
      ),
      panelPaint,
    );

    // Gear (lost gear hint!)
    if (isHappy) {
      _drawGear(canvas, Offset(cx, cy + 26), AppColors.accent, animValue);
    } else {
      _drawGearOutline(canvas, Offset(cx, cy + 26));
    }
  }

  void _drawEye(Canvas canvas, Offset center, double scaleY, bool happy) {
    if (happy) {
      // Happy closed arc eyes (^‿^)
      final path = Path();
      path.moveTo(center.dx - 8, center.dy);
      path.quadraticBezierTo(
        center.dx,
        center.dy - 10,
        center.dx + 8,
        center.dy,
      );
      canvas.drawPath(
        path,
        Paint()
          ..color = AppColors.secondary
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3
          ..strokeCap = StrokeCap.round,
      );
    } else {
      // Normal oval eyes with pupil
      canvas.drawOval(
        Rect.fromCenter(
          center: center,
          width: 14,
          height: 14 * scaleY.clamp(0.15, 1.0),
        ),
        Paint()..color = Colors.white,
      );
      canvas.drawCircle(
        center.translate(0, 1),
        4,
        Paint()..color = AppColors.textPrimary,
      );
      canvas.drawCircle(
        center.translate(1, -1),
        1.5,
        Paint()..color = Colors.white,
      );
    }
  }

  void _drawSmile(Canvas canvas, Offset center) {
    final path = Path();
    path.moveTo(center.dx - 14, center.dy - 2);
    path.quadraticBezierTo(
      center.dx,
      center.dy + 10,
      center.dx + 14,
      center.dy - 2,
    );
    canvas.drawPath(
      path,
      Paint()
        ..color = AppColors.success
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawTalkingMouth(Canvas canvas, Offset center, double t) {
    final openness = (math.sin(t * math.pi * 6) * 0.5 + 0.5) * 8 + 2;
    canvas.drawOval(
      Rect.fromCenter(center: center, width: 18, height: openness),
      Paint()..color = AppColors.textPrimary,
    );
  }

  void _drawNeutralMouth(Canvas canvas, Offset center) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: center, width: 20, height: 4),
        const Radius.circular(2),
      ),
      Paint()..color = AppColors.textPrimary,
    );
  }

  void _drawGear(Canvas canvas, Offset center, Color color, double anim) {
    final paint = Paint()..color = color;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(anim * math.pi * 2);
    final path = _gearPath(5, 0);
    canvas.drawPath(path, paint);
    canvas.restore();
  }

  void _drawGearOutline(Canvas canvas, Offset center) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.drawPath(_gearPath(5, 0), paint);
    canvas.restore();
  }

  Path _gearPath(int teeth, double rotation) {
    final path = Path();
    final innerR = 3.0;
    final outerR = 6.0;
    final total = teeth * 2;
    for (int i = 0; i < total; i++) {
      final r = i.isEven ? outerR : innerR;
      final angle = (i / total) * math.pi * 2 + rotation;
      final x = r * math.cos(angle);
      final y = r * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_BuddyPainter old) =>
      old.isHappy != isHappy ||
      old.isSpeaking != isSpeaking ||
      old.eyeScale != eyeScale ||
      old.animValue != animValue;
}
