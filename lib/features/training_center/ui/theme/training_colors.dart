import 'package:flutter/material.dart';

/// Design tokens for the training-center (company account) screens.
///
/// Palette: deep navy primary with a warm orange accent, matching the
/// "Training Platform" visual language (navy header gradient -> orange CTAs).
class TrainingColors {
  TrainingColors._();

  // Primary / navy
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryDark = Color(0xFF172554);
  static const Color primaryContainer = Color(0xFF2E4EA8);
  static const Color onPrimary = Color(0xFFFFFFFF);

  // Accent / warm orange for training CTAs
  static const Color accent = Color(0xFFC2410C);
  static const Color accentDark = Color(0xFF9A3412);
  static const Color accentSoft = Color(0xFFFFF4ED);
  static const Color onAccent = Color(0xFFFFFFFF);

  // Backgrounds / surfaces
  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceAlt = Color(0xFFEEF2F8);
  static const Color surfaceMuted = Color(0xFFE4EAF4);
  static const Color navySoft = Color(0xFFE8EEFB);

  // Text
  static const Color textPrimary = Color(0xFF101828);
  static const Color textSecondary = Color(0xFF475467);
  static const Color textMuted = Color(0xFF98A2B3);

  // State
  static const Color success = Color(0xFF067647);
  static const Color successSoft = Color(0xFFE7F6EF);
  static const Color danger = Color(0xFFB42318);
  static const Color dangerSoft = Color(0xFFFEF3F2);
  static const Color rating = Color(0xFFB54708);
  static const Color divider = Color(0xFFE4E7EC);

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
