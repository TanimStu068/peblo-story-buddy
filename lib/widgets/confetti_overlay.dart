// Full-screen confetti shown on correct answer.
// Uses the confetti package for a lightweight canvas-based effect.

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:confetti/confetti.dart';
import '../providers/story_provider.dart';
import '../utils/app_constants.dart';

class ConfettiOverlay extends StatefulWidget {
  final QuizState quizState;

  const ConfettiOverlay({super.key, required this.quizState});

  @override
  State<ConfettiOverlay> createState() => _ConfettiOverlayState();
}

class _ConfettiOverlayState extends State<ConfettiOverlay> {
  late ConfettiController _controller;

  @override
  void initState() {
    super.initState();
    _controller = ConfettiController(duration: AppConstants.confettiDuration);
  }

  @override
  void didUpdateWidget(ConfettiOverlay old) {
    super.didUpdateWidget(old);
    if (widget.quizState == QuizState.correct &&
        old.quizState != QuizState.correct) {
      _controller.play();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topCenter,
      child: ConfettiWidget(
        confettiController: _controller,
        blastDirection: pi / 2, // Straight down
        blastDirectionality: BlastDirectionality.explosive,
        emissionFrequency: 0.06,
        numberOfParticles: 18, // Low count for perf on mid-range devices
        maxBlastForce: 40,
        minBlastForce: 10,
        gravity: 0.2,
        shouldLoop: false,
        colors: const [
          AppColors.primary,
          AppColors.secondary,
          AppColors.accent,
          AppColors.success,
          Color(0xFFFF6B9D),
          Color(0xFF00BCD4),
        ],
        createParticlePath: _drawStar,
      ),
    );
  }

  Path _drawStar(Size size) {
    final path = Path();
    const sides = 5;
    final angle = (pi * 2) / sides;
    final halfAngle = angle / 2.0;
    final radius = size.width / 2;
    final innerRadius = radius * 0.4;
    final center = Offset(size.width / 2, size.height / 2);

    for (int i = 0; i <= sides; i++) {
      final outer = Offset(
        center.dx + radius * cos(i * angle - pi / 2),
        center.dy + radius * sin(i * angle - pi / 2),
      );
      final inner = Offset(
        center.dx + innerRadius * cos(i * angle + halfAngle - pi / 2),
        center.dy + innerRadius * sin(i * angle + halfAngle - pi / 2),
      );
      if (i == 0) {
        path.moveTo(outer.dx, outer.dy);
      } else {
        path.lineTo(inner.dx, inner.dy);
        path.lineTo(outer.dx, outer.dy);
      }
    }
    path.close();
    return path;
  }
}
