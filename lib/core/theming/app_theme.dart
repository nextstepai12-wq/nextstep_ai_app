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
        shadowColor: primary.withValues(alpha: 0.3),
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

  // ─────────────────────────────────────────────────────────────────────────
  // Design System — app-wide theme (Light & Dark)
  // ─────────────────────────────────────────────────────────────────────────

  static const String fontFamily = 'Cairo';

  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static ThemeMode get themeMode => themeModeNotifier.value;

  static bool get isDark => themeModeNotifier.value == ThemeMode.dark;

  static void toggleTheme() {
    themeModeNotifier.value =
        isDark ? ThemeMode.light : ThemeMode.dark;
  }

  static void setThemeMode(ThemeMode mode) {
    themeModeNotifier.value = mode;
  }

  static final ThemeData light = _buildTheme(Brightness.light, AppColors.light);
  static final ThemeData dark = _buildTheme(Brightness.dark, AppColors.dark);

  static ThemeData _buildTheme(Brightness brightness, AppColors c) {
    final bool isDark = brightness == Brightness.dark;

    final ColorScheme scheme = isDark
        ? ColorScheme.dark(
            primary: c.primary,
            onPrimary: Colors.white,
            primaryContainer: c.primaryDark,
            onPrimaryContainer: Colors.white,
            secondary: c.primary,
            onSecondary: Colors.white,
            surface: c.surface,
            onSurface: c.textPrimary,
            onSurfaceVariant: c.textSecondary,
            error: c.danger,
            onError: Colors.white,
            outline: c.divider,
          )
        : ColorScheme.light(
            primary: c.primary,
            onPrimary: Colors.white,
            primaryContainer: c.primarySoft,
            onPrimaryContainer: c.primaryDark,
            secondary: c.primary,
            onSecondary: Colors.white,
            surface: c.surface,
            onSurface: c.textPrimary,
            onSurfaceVariant: c.textSecondary,
            error: c.danger,
            onError: Colors.white,
            outline: c.divider,
          );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      scaffoldBackgroundColor: c.background,
      colorScheme: scheme,
      extensions: <ThemeExtension<dynamic>>[c],
      dividerColor: c.divider,
      splashFactory: InkRipple.splashFactory,
      appBarTheme: AppBarThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: c.textPrimary,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: c.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
          side: isDark ? BorderSide(color: c.divider) : BorderSide.none,
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: TextTheme(
        titleMedium: TextStyle(
          fontFamily: fontFamily,
          fontWeight: FontWeight.w700,
          color: c.textPrimary,
        ),
        bodyMedium: TextStyle(
          fontFamily: fontFamily,
          color: c.textPrimary,
        ),
        bodySmall: TextStyle(
          fontFamily: fontFamily,
          color: c.textSecondary,
        ),
      ),
    );
  }
}

/// Semantic color tokens that adapt to the active [Brightness].
@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryDark,
    required this.primarySoft,
    required this.gradientStart,
    required this.gradientEnd,
    required this.success,
    required this.successSoft,
    required this.accent,
    required this.accentSoft,
    required this.danger,
    required this.dangerSoft,
    required this.purple,
    required this.purpleSoft,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.textPrimary,
    required this.textSecondary,
    required this.divider,
    required this.isDark,
  });

  final Color primary;
  final Color primaryDark;
  final Color primarySoft;
  final Color gradientStart;
  final Color gradientEnd;
  final Color success;
  final Color successSoft;
  final Color accent;
  final Color accentSoft;
  final Color danger;
  final Color dangerSoft;
  final Color purple;
  final Color purpleSoft;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color textPrimary;
  final Color textSecondary;
  final Color divider;
  final bool isDark;

  static const AppColors light = AppColors(
    primary: Color(0xFF2563EB),
    primaryDark: Color(0xFF1E40AF),
    primarySoft: Color(0xFFEFF4FF),
    gradientStart: Color(0xFF2563EB),
    gradientEnd: Color(0xFF3B82F6),
    success: Color(0xFF10B981),
    successSoft: Color(0xFFECFDF5),
    accent: Color(0xFFF59E0B),
    accentSoft: Color(0xFFFFFBEB),
    danger: Color(0xFFEF4444),
    dangerSoft: Color(0xFFFEF2F2),
    purple: Color(0xFF8B5CF6),
    purpleSoft: Color(0xFFF5F3FF),
    background: Color(0xFFF8FAFC),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFF1F5F9),
    textPrimary: Color(0xFF0F172A),
    textSecondary: Color(0xFF64748B),
    divider: Color(0xFFE2E8F0),
    isDark: false,
  );

  static const AppColors dark = AppColors(
    primary: Color(0xFF2563EB),
    primaryDark: Color(0xFF1E40AF),
    primarySoft: Color(0x292563EB),
    gradientStart: Color(0xFF2563EB),
    gradientEnd: Color(0xFF3B82F6),
    success: Color(0xFF10B981),
    successSoft: Color(0x2910B981),
    accent: Color(0xFFF59E0B),
    accentSoft: Color(0x29F59E0B),
    danger: Color(0xFFEF4444),
    dangerSoft: Color(0x29EF4444),
    purple: Color(0xFF8B5CF6),
    purpleSoft: Color(0x298B5CF6),
    background: Color(0xFF0F172A),
    surface: Color(0xFF1E293B),
    surfaceAlt: Color(0xFF334155),
    textPrimary: Color(0xFFF1F5F9),
    textSecondary: Color(0xFF94A3B8),
    divider: Color(0xFF334155),
    isDark: true,
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primarySoft,
    Color? gradientStart,
    Color? gradientEnd,
    Color? success,
    Color? successSoft,
    Color? accent,
    Color? accentSoft,
    Color? danger,
    Color? dangerSoft,
    Color? purple,
    Color? purpleSoft,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? textPrimary,
    Color? textSecondary,
    Color? divider,
    bool? isDark,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primarySoft: primarySoft ?? this.primarySoft,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      purple: purple ?? this.purple,
      purpleSoft: purpleSoft ?? this.purpleSoft,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      divider: divider ?? this.divider,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      purpleSoft: Color.lerp(purpleSoft, other.purpleSoft, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension AppColorsX on BuildContext {
  /// Active semantic colors for the current [Theme].
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;
}
