import 'package:flutter/material.dart';

/// Design tokens for the training-center (company account) screens.
///
/// Palette: deep navy primary with a warm orange accent, matching the
/// "Training Platform" visual language (navy header gradient -> orange CTAs).
class TrainingColors {
  TrainingColors._();

  // Primary / navy
  static const Color primary = Color(0xFF1B3A6B);
  static const Color primaryDark = Color(0xFF002452);
  static const Color primaryContainer = Color(0xFF2D5BA8);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Accent / orange
  static const Color accent = Color(0xFFFF8C42);
  static const Color accentDark = Color(0xFFFF6B35);
  static const Color accentSoft = Color(0xFFFFF7ED);
  static const Color onAccent = Color(0xFFFFFFFF);

  // Backgrounds / surfaces
  static const Color background = Color(0xFFF7F8FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFF1F3FF);
  static const Color surfaceMuted = Color(0xFFE9EDFF);
  static const Color navySoft = Color(0xFFE8EEF9);

  // Text
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textMuted = Color(0xFF9CA3AF);

  // State
  static const Color success = Color(0xFF10B981);
  static const Color successSoft = Color(0xFFECFDF5);
  static const Color danger = Color(0xFFEF4444);
  static const Color dangerSoft = Color(0xFFFEF2F2);
  static const Color rating = Color(0xFFF59E0B);
  static const Color divider = Color(0xFFE5E7EB);

  // Gradients
  static const LinearGradient headerGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [primary, primaryContainer],
  );

  static const LinearGradient accentGradient = LinearGradient(
    begin: Alignment.centerRight,
    end: Alignment.centerLeft,
    colors: [accent, accentDark],
  );

  // Shadows
  static const List<BoxShadow> softShadow = [
    BoxShadow(
      color: Color(0x0F000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> cardShadow = [
    BoxShadow(
      color: Color(0x12002452),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> headerShadow = [
    BoxShadow(
      color: Color(0x24002452),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];
}
