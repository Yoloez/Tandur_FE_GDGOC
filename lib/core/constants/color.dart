import 'package:flutter/material.dart';

class AppColors {
  // Primary - lush green tones
  static const Color primary = Color(0xFF2D6A4F);
  static const Color primaryLight = Color(0xFF52B788);
  static const Color primaryDark = Color(0xFF1B4332);

  // Accent - warm earth tones
  static const Color accent = Color(0xFFF4A261);
  static const Color accentLight = Color(0xFFFFD9B0);
  static const Color accentDark = Color(0xFFE76F51);

  // Neutral
  static const Color background = Color(0xFFF8F4EF);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFEEF4EE);

  // Text
  static const Color textPrimary = Color(0xFF1B2F1E);
  static const Color textSecondary = Color(0xFF5A7A5E);
  static const Color textHint = Color(0xFF9EBD9E);

  // Status
  static const Color success = Color(0xFF40916C);
  static const Color warning = Color(0xFFF4A261);
  static const Color error = Color(0xFFE63946);
  static const Color info = Color(0xFF457B9D);

  // Gradient stops
  static const List<Color> heroGradient = [
    Color(0xFF1B4332),
    Color(0xFF2D6A4F),
    Color(0xFF52B788),
  ];
}
