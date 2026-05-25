import 'package:flutter/material.dart';

/// Design system color tokens based on DESIGN.md
/// AgriLink Ecosystem — "Digital Agronomy" palette
class AppColors {
  // ── Primary — Fresh Green ──
  static const Color primary = Color(0xFF006B23);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFF1C8634);
  static const Color onPrimaryContainer = Color(0xFFF7FFF1);
  static const Color inversePrimary = Color(0xFF78DC7E);

  // Legacy aliases (for backward compatibility)
  static const Color primaryLight = Color(0xFF52B788);
  static const Color primaryDark = Color(0xFF1B4332);
  static const Color bggreen = Color(0xFFF7FBF2);

  // ── Secondary — Natural Beige ──
  static const Color secondary = Color(0xFF615E57);
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFE7E2D9);
  static const Color onSecondaryContainer = Color(0xFF67645D);

  // ── Tertiary — Earthy Brown ──
  static const Color tertiary = Color(0xFF74554B);
  static const Color onTertiary = Color(0xFFFFFFFF);
  static const Color tertiaryContainer = Color(0xFF8F6D62);
  static const Color onTertiaryContainer = Color(0xFFFFFBFF);

  // ── Surface ──
  static const Color surface = Color(0xFFFAFAF4);
  static const Color surfaceDim = Color(0xFFDADAD5);
  static const Color surfaceBright = Color(0xFFFAFAF4);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerLow = Color(0xFFF4F4EE);
  static const Color surfaceContainer = Color(0xFFEEEEE9);
  static const Color surfaceContainerHigh = Color(0xFFE8E8E3);
  static const Color surfaceContainerHighest = Color(0xFFE3E3DE);
  static const Color onSurface = Color(0xFF1A1C19);
  static const Color onSurfaceVariant = Color(0xFF3F4A3D);
  static const Color inverseSurface = Color(0xFF2F312E);
  static const Color inverseOnSurface = Color(0xFFF1F1EC);
  static const Color surfaceTint = Color(0xFF006E24);

  // Legacy aliases
  static const Color surfaceVariant = Color(0xFFE3E3DE);

  // ── Outline ──
  static const Color outline = Color(0xFF6F7A6C);
  static const Color outlineVariant = Color(0xFFBECABA);

  // ── Accent (legacy) ──
  static const Color accent = Color(0xFFF4A261);
  static const Color accentLight = Color(0xFFFFD9B0);
  static const Color accentDark = Color(0xFFE76F51);

  // ── Background ──
  static const Color background = Color(0xFFFAFAF4);
  static const Color onBackground = Color(0xFF1A1C19);

  // ── Text ──
  static const Color textPrimary = Color(0xFF1A1C19);
  static const Color textSecondary = Color(0xFF3F4A3D);
  static const Color textHint = Color(0xFF6F7A6C);

  // ── Status ──
  static const Color success = Color(0xFF40916C);
  static const Color warning = Color(0xFFF4A261);
  static const Color error = Color(0xFFBA1A1A);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color errorContainer = Color(0xFFFFDAD6);
  static const Color info = Color(0xFF457B9D);

  // ── Fixed colors ──
  static const Color primaryFixed = Color(0xFF93F998);
  static const Color primaryFixedDim = Color(0xFF78DC7E);

  // ── Gradient stops ──
  static const List<Color> heroGradient = [
    Color(0xFF1B4332),
    Color(0xFF2D6A4F),
    Color(0xFF52B788),
  ];
}
