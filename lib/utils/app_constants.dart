import 'package:flutter/material.dart';

/// Peblo brand colours and design tokens.
class AppColors {
  // Primary palette (warm, child-friendly)
  static const Color primary = Color(0xFFFF6B35); // Peblo orange
  static const Color primaryLight = Color(0xFFFF9A6C);
  static const Color secondary = Color(0xFF6C63FF); // Purple accent
  static const Color secondaryLight = Color(0xFF9D97FF);
  static const Color accent = Color(0xFFFFD93D); // Sunny yellow

  // Background
  static const Color background = Color(0xFFFFF8F0); // Warm cream
  static const Color cardBackground = Color(0xFFFFFFFF);
  static const Color surface = Color(0xFFFFF0E0);

  // State colours
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0xFFE8F5E9);
  static const Color error = Color(0xFFE53935);
  static const Color errorLight = Color(0xFFFFEBEE);

  // Text
  static const Color textPrimary = Color(0xFF2D2D2D);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Option button tints (cycling colours for variety)
  static const List<Color> optionColors = [
    Color(0xFFE3F2FD), // light blue
    Color(0xFFF3E5F5), // light purple
    Color(0xFFFFF9C4), // light yellow
    Color(0xFFE8F5E9), // light green
    Color(0xFFFFEBEE), // light pink
  ];

  static const List<Color> optionBorderColors = [
    Color(0xFF1E88E5),
    Color(0xFF8E24AA),
    Color(0xFFFBC02D),
    Color(0xFF43A047),
    Color(0xFFE53935),
  ];
}

/// The story text narrated via TTS.
class AppConstants {
  static const String storyText =
      'Once upon a time, a clever little robot named Pip '
      'lost his shiny blue gear in the Whispering Woods...';

  static const String storyTitle = "Pip's Lost Gear";

  /// Simulated backend JSON payload — never hardcode the quiz UI itself.
  /// Swap this out (or fetch from a real endpoint) and the UI adapts automatically.
  static const Map<String, dynamic> quizJson = {
    'question': "What colour was Pip the Robot's lost gear?",
    'options': ['Red', 'Green', 'Blue', 'Yellow'],
    'answer': 'Blue',
  };

  // TTS settings
  static const double ttsRate = 0.45; // Slightly slower for children
  static const double ttsPitch = 1.1; // Slightly higher, friendly tone
  static const double ttsVolume = 1.0;

  // Animation durations
  static const Duration shakeAnimDuration = Duration(milliseconds: 500);
  static const Duration quizRevealDuration = Duration(milliseconds: 600);
  static const Duration confettiDuration = Duration(seconds: 3);
}
