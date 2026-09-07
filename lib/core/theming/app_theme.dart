import 'package:flutter/material.dart';

class AppTheme {
  static const Color primary = Color(0xFF002045);
  static const Color primaryContainer = Color(0xFF1A365D);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color tertiaryFixedDim = Color(0xFF3EDFAA);
  static const Color surfaceVariant = Color(0xFFD9E3F6);
  static const Color onSurfaceVariant = Color(0xFF43474E);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFFFFFFF);
  
  static const Color secondary = Color(0xFF004FDA);
  static const Color secondaryContainer = Color(0xFF2B69FD);
  static const Color borderSubtle = Color(0xFFE5E7EB);
  static const Color outline = Color(0xFF74777F);
  static const Color surface = Color(0xFFF8F9FF);

  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    primaryColor: primary,
    scaffoldBackgroundColor: Colors.white,
    fontFamily: 'BeVietnamPro',
    colorScheme: const ColorScheme.light(
      primary: primary,
      onPrimary: onPrimary,
      primaryContainer: primaryContainer,
      secondary: secondary,
      tertiary: Color(0xFF002619),
      tertiaryContainer: Color(0xFF003E2C),
      error: Color(0xFFBA1A1A),
      surface: Color(0xFFFFFFFF),
      onSurface: Color(0xFF121C2A),
      onSurfaceVariant: onSurfaceVariant,
      outline: outline,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        fontFamily: 'BeVietnamPro',
        fontSize: 48,
        fontWeight: FontWeight.w700,
        height: 1.17,
        letterSpacing: -0.02,
        color: primary,
      ),
      headlineLarge: TextStyle(
        fontFamily: 'BeVietnamPro',
        fontSize: 32,
        fontWeight: FontWeight.w600,
        height: 1.25,
        letterSpacing: -0.01,
        color: primary,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'BeVietnamPro',
        fontSize: 28,
        fontWeight: FontWeight.w600,
        height: 1.29,
        color: primary,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'BeVietnamPro',
        fontSize: 18,
        fontWeight: FontWeight.w400,
        height: 1.56,
        color: onSurfaceVariant,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'BeVietnamPro',
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.5,
        color: onSurfaceVariant,
      ),
      labelLarge: TextStyle(
        fontFamily: 'BeVietnamPro',
        fontSize: 14,
        fontWeight: FontWeight.w600,
        height: 1.14,
        color: onPrimary,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: onPrimary,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        elevation: 4,
        shadowColor: primary.withOpacity(0.3),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: secondary,
        textStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          height: 1.14,
        ),
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderSubtle),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderSubtle),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: secondary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.red, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    ),
  );
}