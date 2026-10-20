import 'package:flutter/material.dart';

import '../helpers/hive_storage.dart';







class AppTheme {
  AppTheme._();

  static const String fontFamily = 'Cairo';

  
  static const Color primary = Color(0xFF1E3A8A);
  static const Color primaryContainer = Color(0xFF2E4EA8);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color secondary = Color(0xFF0F766E);
  static const Color tertiaryFixedDim = Color(0xFF5EEAD4);
  static const Color surfaceVariant = Color(0xFFEEF2F8);
  static const Color onSurfaceVariant = Color(0xFF475467);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color background = Color(0xFFF5F7FB);
  static const Color borderSubtle = Color(0xFFE4E7EC);
  static const Color outline = Color(0xFF667085);
  static const Color surface = Color(0xFFFFFFFF);

  static final ValueNotifier<ThemeMode> themeModeNotifier =
      ValueNotifier<ThemeMode>(ThemeMode.light);

  static ThemeMode get themeMode => themeModeNotifier.value;

  static bool get isDark => themeModeNotifier.value == ThemeMode.dark;

  static void toggleTheme() {
    themeModeNotifier.value = isDark ? ThemeMode.light : ThemeMode.dark;
  }

  static void setThemeMode(ThemeMode mode) {
    themeModeNotifier.value = mode;
    _persistThemeMode(mode);
  }

  
  static Future<void> loadPersistedThemeMode() async {
    try {
      final settings = await HiveStorage.getSettings();
      final raw = settings['themeMode'];
      if (raw is! String) return;
      themeModeNotifier.value = switch (raw) {
        'dark' => ThemeMode.dark,
        'system' => ThemeMode.system,
        _ => ThemeMode.light,
      };
    } catch (_) {
      
    }
  }

  static Future<void> _persistThemeMode(ThemeMode mode) async {
    try {
      final settings = await HiveStorage.getSettings();
      settings['themeMode'] = mode.name;
      await HiveStorage.saveSettings(settings);
    } catch (_) {
      
    }
  }

  static final ThemeData light = _buildTheme(Brightness.light, AppColors.light);
  static final ThemeData dark = _buildTheme(Brightness.dark, AppColors.dark);

  
  static final ThemeData lightTheme = light;

  static ThemeData _buildTheme(Brightness brightness, AppColors c) {
    final bool isDark = brightness == Brightness.dark;
    final ColorScheme scheme = ColorScheme(
      brightness: brightness,
      primary: c.primary,
      onPrimary: c.onPrimary,
      primaryContainer: c.primarySoft,
      onPrimaryContainer: isDark ? c.textPrimary : c.primaryDark,
      secondary: c.accent,
      onSecondary: isDark ? const Color(0xFF003731) : Colors.white,
      secondaryContainer: c.accentSoft,
      onSecondaryContainer: isDark ? c.textPrimary : const Color(0xFF0B3B34),
      tertiary: c.purple,
      onTertiary: Colors.white,
      tertiaryContainer: c.purpleSoft,
      onTertiaryContainer: isDark ? c.textPrimary : const Color(0xFF2C2468),
      error: c.danger,
      onError: Colors.white,
      errorContainer: c.dangerSoft,
      onErrorContainer: isDark ? c.textPrimary : c.danger,
      surface: c.surface,
      onSurface: c.textPrimary,
      onSurfaceVariant: c.textSecondary,
      surfaceContainerLowest: c.background,
      surfaceContainerLow: c.surface,
      surfaceContainer: c.surfaceAlt,
      surfaceContainerHigh: c.surfaceAlt,
      surfaceContainerHighest: c.divider,
      outline: c.divider,
      outlineVariant: c.divider,
      shadow: c.shadow,
      scrim: const Color(0x99000000),
      inverseSurface:
          isDark ? const Color(0xFFF1F5F9) : const Color(0xFF1B2437),
      onInverseSurface: isDark ? const Color(0xFF0F172A) : Colors.white,
      inversePrimary: c.primarySoft,
    );

    final TextTheme textTheme = _textTheme(c, brightness);

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: fontFamily,
      colorScheme: scheme,
      scaffoldBackgroundColor: c.background,
      canvasColor: c.background,
      dividerColor: c.divider,
      extensions: <ThemeExtension<dynamic>>[c],
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      materialTapTargetSize: MaterialTapTargetSize.padded,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      appBarTheme: AppBarThemeData(
        backgroundColor: c.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        foregroundColor: c.textPrimary,
        iconTheme: IconThemeData(color: c.textPrimary, size: 22),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: c.textPrimary,
        ),
      ),
      cardTheme: CardThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          side:
              BorderSide(color: c.divider.withValues(alpha: isDark ? 1 : 0.8)),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.inputFill,
        isDense: false,
        hintStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: c.textHint,
          fontWeight: FontWeight.w400,
        ),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          color: c.textSecondary,
          fontWeight: FontWeight.w500,
        ),
        floatingLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13,
          color: c.primary,
          fontWeight: FontWeight.w700,
        ),
        helperStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          color: c.textSecondary,
        ),
        errorStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          color: c.danger,
          fontWeight: FontWeight.w600,
        ),
        prefixIconColor: c.textSecondary,
        suffixIconColor: c.textSecondary,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.divider),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.divider.withValues(alpha: 0.6)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.primary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.danger, width: 1.4),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          borderSide: BorderSide(color: c.danger, width: 1.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.primary.withValues(alpha: 0.45),
          disabledForegroundColor: c.onPrimary.withValues(alpha: 0.9),
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          elevation: 0,
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: c.primary,
          foregroundColor: c.onPrimary,
          disabledBackgroundColor: c.primary.withValues(alpha: 0.45),
          minimumSize: const Size(0, 52),
          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: c.primary,
          disabledForegroundColor: c.textHint,
          minimumSize: const Size(0, 50),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 13),
          side: BorderSide(color: c.divider, width: 1.2),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: c.primary,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          textStyle: const TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: c.textPrimary,
          minimumSize: const Size(44, 44),
          padding: const EdgeInsets.all(10),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: c.primary,
        foregroundColor: c.onPrimary,
        elevation: 0,
        focusElevation: 0,
        hoverElevation: 0,
        highlightElevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: c.surface,
        selectedColor: c.primarySoft,
        disabledColor: c.surfaceAlt,
        checkmarkColor: c.primary,
        side: BorderSide(color: c.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        labelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12.5,
          fontWeight: FontWeight.w600,
          color: c.textSecondary,
        ),
        secondaryLabelStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: c.primary,
        ),
      ),
      badgeTheme: BadgeThemeData(
        backgroundColor: c.danger,
        textColor: Colors.white,
        textStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
      dividerTheme: DividerThemeData(
        color: c.divider,
        thickness: 1,
        space: 1,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.xl),
          side: BorderSide(color: c.divider),
        ),
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: c.textPrimary,
        ),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14,
          height: 1.6,
          color: c.textSecondary,
        ),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        modalBackgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        showDragHandle: true,
        dragHandleColor: c.divider,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadius.xl),
          ),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: isDark ? c.surfaceAlt : const Color(0xFF1B2437),
        contentTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w600,
          color: isDark ? c.textPrimary : Colors.white,
        ),
        actionTextColor: isDark ? c.accent : const Color(0xFF7DD3C7),
        elevation: 0,
        insetPadding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 13.5,
          color: c.textPrimary,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: c.divider),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: c.textSecondary,
        textColor: c.textPrimary,
        titleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 14.5,
          fontWeight: FontWeight.w600,
          color: c.textPrimary,
        ),
        subtitleTextStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12.5,
          height: 1.5,
          color: c.textSecondary,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: c.primary,
        linearTrackColor: c.surfaceAlt,
        circularTrackColor: c.surfaceAlt,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? c.surfaceAlt : const Color(0xFF1B2437),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        textStyle: TextStyle(
          fontFamily: fontFamily,
          fontSize: 12,
          color: isDark ? c.textPrimary : Colors.white,
        ),
        waitDuration: const Duration(milliseconds: 400),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.onPrimary;
          return c.textHint;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.primary;
          return c.surfaceAlt;
        }),
        trackOutlineColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return Colors.transparent;
          return c.divider;
        }),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStatePropertyAll(c.onPrimary),
        side: BorderSide(color: c.textSecondary, width: 1.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return c.primary;
          return c.textSecondary;
        }),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: c.primary,
        inactiveTrackColor: c.surfaceAlt,
        thumbColor: c.primary,
        overlayColor: c.primary.withValues(alpha: 0.12),
        trackHeight: 5,
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: c.primary,
        unselectedLabelColor: c.textSecondary,
        labelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 13.5,
          fontWeight: FontWeight.w500,
        ),
        indicatorColor: c.primary,
        dividerColor: c.divider,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: c.surface,
        selectedItemColor: c.primary,
        unselectedItemColor: c.textSecondary,
        elevation: 0,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        indicatorColor: c.primarySoft,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return TextStyle(
            fontFamily: fontFamily,
            fontSize: 11,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? c.primary : c.textSecondary,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final selected = states.contains(WidgetState.selected);
          return IconThemeData(
            size: 22,
            color: selected ? c.primary : c.textSecondary,
          );
        }),
      ),
      searchBarTheme: SearchBarThemeData(
        backgroundColor: WidgetStatePropertyAll(c.inputFill),
        surfaceTintColor: const WidgetStatePropertyAll(Colors.transparent),
        elevation: const WidgetStatePropertyAll(0),
        textStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: fontFamily,
            fontSize: 14,
            color: c.textPrimary,
          ),
        ),
        hintStyle: WidgetStatePropertyAll(
          TextStyle(
            fontFamily: fontFamily,
            fontSize: 13.5,
            color: c.textHint,
          ),
        ),
        shape: WidgetStatePropertyAll(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            side: BorderSide(color: c.divider),
          ),
        ),
      ),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: c.primary,
        selectionColor: c.primary.withValues(alpha: 0.22),
        selectionHandleColor: c.primary,
      ),
      splashColor: c.primary.withValues(alpha: 0.08),
      highlightColor: c.primary.withValues(alpha: 0.04),
      hoverColor: c.primary.withValues(alpha: 0.04),
      focusColor: c.primary.withValues(alpha: 0.06),
    );
  }

  static TextTheme _textTheme(AppColors c, Brightness brightness) {
    final Color body = c.textPrimary;
    final Color muted = c.textSecondary;
    return TextTheme(
      displayLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 44,
        fontWeight: FontWeight.w800,
        height: 1.18,
        color: body,
      ),
      displayMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 36,
        fontWeight: FontWeight.w800,
        height: 1.2,
        color: body,
      ),
      displaySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 30,
        fontWeight: FontWeight.w800,
        height: 1.22,
        color: body,
      ),
      headlineLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 28,
        fontWeight: FontWeight.w800,
        height: 1.3,
        color: body,
      ),
      headlineMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 24,
        fontWeight: FontWeight.w800,
        height: 1.3,
        color: body,
      ),
      headlineSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 21,
        fontWeight: FontWeight.w700,
        height: 1.35,
        color: body,
      ),
      titleLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 19,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: body,
      ),
      titleMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        height: 1.4,
        color: body,
      ),
      titleSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        height: 1.4,
        color: body,
      ),
      bodyLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 16,
        fontWeight: FontWeight.w400,
        height: 1.65,
        color: body,
      ),
      bodyMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w400,
        height: 1.6,
        color: body,
      ),
      bodySmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12.5,
        fontWeight: FontWeight.w400,
        height: 1.55,
        color: muted,
      ),
      labelLarge: TextStyle(
        fontFamily: fontFamily,
        fontSize: 14,
        fontWeight: FontWeight.w700,
        height: 1.3,
        color: body,
      ),
      labelMedium: TextStyle(
        fontFamily: fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: muted,
      ),
      labelSmall: TextStyle(
        fontFamily: fontFamily,
        fontSize: 11,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: muted,
      ),
    );
  }
}


@immutable
class AppColors extends ThemeExtension<AppColors> {
  const AppColors({
    required this.primary,
    required this.primaryDark,
    required this.primaryContainer,
    required this.primarySoft,
    required this.onPrimary,
    required this.gradientStart,
    required this.gradientEnd,
    required this.success,
    required this.successSoft,
    required this.accent,
    required this.accentSoft,
    required this.danger,
    required this.dangerSoft,
    required this.info,
    required this.infoSoft,
    required this.warning,
    required this.warningSoft,
    required this.purple,
    required this.purpleSoft,
    required this.background,
    required this.surface,
    required this.surfaceAlt,
    required this.inputFill,
    required this.textPrimary,
    required this.textSecondary,
    required this.textHint,
    required this.divider,
    required this.shadow,
    required this.isDark,
  });

  final Color primary;
  final Color primaryDark;
  final Color primaryContainer;
  final Color primarySoft;
  final Color onPrimary;
  final Color gradientStart;
  final Color gradientEnd;
  final Color success;
  final Color successSoft;
  final Color accent;
  final Color accentSoft;
  final Color danger;
  final Color dangerSoft;
  final Color info;
  final Color infoSoft;
  final Color warning;
  final Color warningSoft;
  final Color purple;
  final Color purpleSoft;
  final Color background;
  final Color surface;
  final Color surfaceAlt;
  final Color inputFill;
  final Color textPrimary;
  final Color textSecondary;
  final Color textHint;
  final Color divider;
  final Color shadow;
  final bool isDark;

  static const AppColors light = AppColors(
    primary: Color(0xFF1E3A8A),
    primaryDark: Color(0xFF172554),
    primaryContainer: Color(0xFF2E4EA8),
    primarySoft: Color(0xFFE8EEFB),
    onPrimary: Color(0xFFFFFFFF),
    gradientStart: Color(0xFF1E3A8A),
    gradientEnd: Color(0xFF2E5AAC),
    success: Color(0xFF067647),
    successSoft: Color(0xFFE7F6EF),
    accent: Color(0xFF0F766E),
    accentSoft: Color(0xFFE6F4F1),
    danger: Color(0xFFB42318),
    dangerSoft: Color(0xFFFEF3F2),
    info: Color(0xFF175CD3),
    infoSoft: Color(0xFFEAF2FF),
    warning: Color(0xFFB54708),
    warningSoft: Color(0xFFFFF6E5),
    purple: Color(0xFF5B4BB7),
    purpleSoft: Color(0xFFF1EEFF),
    background: Color(0xFFF5F7FB),
    surface: Color(0xFFFFFFFF),
    surfaceAlt: Color(0xFFEEF2F8),
    inputFill: Color(0xFFF8FAFC),
    textPrimary: Color(0xFF101828),
    textSecondary: Color(0xFF475467),
    textHint: Color(0xFF98A2B3),
    divider: Color(0xFFE4E7EC),
    shadow: Color(0x140F172A),
    isDark: false,
  );

  static const AppColors dark = AppColors(
    primary: Color(0xFF3B6FE0),
    primaryDark: Color(0xFF1E3A8A),
    primaryContainer: Color(0xFF2E4EA8),
    primarySoft: Color(0xFF1B2A4A),
    onPrimary: Color(0xFFFFFFFF),
    gradientStart: Color(0xFF2B4BA8),
    gradientEnd: Color(0xFF3B6FE0),
    success: Color(0xFF4ADE80),
    successSoft: Color(0x2614B87A),
    accent: Color(0xFF5EEAD4),
    accentSoft: Color(0x2614B8A6),
    danger: Color(0xFFF97066),
    dangerSoft: Color(0x26F97066),
    info: Color(0xFF84ADFF),
    infoSoft: Color(0x26175CD3),
    warning: Color(0xFFFDB022),
    warningSoft: Color(0x26F79009),
    purple: Color(0xFFB4A5FF),
    purpleSoft: Color(0x268B5CF6),
    background: Color(0xFF0B1220),
    surface: Color(0xFF121B2E),
    surfaceAlt: Color(0xFF1B2740),
    inputFill: Color(0xFF162137),
    textPrimary: Color(0xFFF0F4FA),
    textSecondary: Color(0xFFA3AFC4),
    textHint: Color(0xFF748198),
    divider: Color(0xFF2A3854),
    shadow: Color(0x40000000),
    isDark: true,
  );

  @override
  AppColors copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryContainer,
    Color? primarySoft,
    Color? onPrimary,
    Color? gradientStart,
    Color? gradientEnd,
    Color? success,
    Color? successSoft,
    Color? accent,
    Color? accentSoft,
    Color? danger,
    Color? dangerSoft,
    Color? info,
    Color? infoSoft,
    Color? warning,
    Color? warningSoft,
    Color? purple,
    Color? purpleSoft,
    Color? background,
    Color? surface,
    Color? surfaceAlt,
    Color? inputFill,
    Color? textPrimary,
    Color? textSecondary,
    Color? textHint,
    Color? divider,
    Color? shadow,
    bool? isDark,
  }) {
    return AppColors(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryContainer: primaryContainer ?? this.primaryContainer,
      primarySoft: primarySoft ?? this.primarySoft,
      onPrimary: onPrimary ?? this.onPrimary,
      gradientStart: gradientStart ?? this.gradientStart,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      success: success ?? this.success,
      successSoft: successSoft ?? this.successSoft,
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      danger: danger ?? this.danger,
      dangerSoft: dangerSoft ?? this.dangerSoft,
      info: info ?? this.info,
      infoSoft: infoSoft ?? this.infoSoft,
      warning: warning ?? this.warning,
      warningSoft: warningSoft ?? this.warningSoft,
      purple: purple ?? this.purple,
      purpleSoft: purpleSoft ?? this.purpleSoft,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      surfaceAlt: surfaceAlt ?? this.surfaceAlt,
      inputFill: inputFill ?? this.inputFill,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textHint: textHint ?? this.textHint,
      divider: divider ?? this.divider,
      shadow: shadow ?? this.shadow,
      isDark: isDark ?? this.isDark,
    );
  }

  @override
  AppColors lerp(ThemeExtension<AppColors>? other, double t) {
    if (other is! AppColors) return this;
    return AppColors(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryContainer:
          Color.lerp(primaryContainer, other.primaryContainer, t)!,
      primarySoft: Color.lerp(primarySoft, other.primarySoft, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      gradientStart: Color.lerp(gradientStart, other.gradientStart, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      success: Color.lerp(success, other.success, t)!,
      successSoft: Color.lerp(successSoft, other.successSoft, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      accentSoft: Color.lerp(accentSoft, other.accentSoft, t)!,
      danger: Color.lerp(danger, other.danger, t)!,
      dangerSoft: Color.lerp(dangerSoft, other.dangerSoft, t)!,
      info: Color.lerp(info, other.info, t)!,
      infoSoft: Color.lerp(infoSoft, other.infoSoft, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      warningSoft: Color.lerp(warningSoft, other.warningSoft, t)!,
      purple: Color.lerp(purple, other.purple, t)!,
      purpleSoft: Color.lerp(purpleSoft, other.purpleSoft, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      surfaceAlt: Color.lerp(surfaceAlt, other.surfaceAlt, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textHint: Color.lerp(textHint, other.textHint, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shadow: Color.lerp(shadow, other.shadow, t)!,
      isDark: t < 0.5 ? isDark : other.isDark,
    );
  }
}

extension AppColorsX on BuildContext {
  
  AppColors get appColors =>
      Theme.of(this).extension<AppColors>() ?? AppColors.light;

  ThemeData get theme => Theme.of(this);

  TextTheme get textStyles => Theme.of(this).textTheme;

  bool get isDarkMode => Theme.of(this).brightness == Brightness.dark;

  bool get isCompact => MediaQuery.sizeOf(this).width < AppBreakpoints.tablet;

  bool get isTabletWidth =>
      MediaQuery.sizeOf(this).width >= AppBreakpoints.tablet;

  bool get isDesktopWidth =>
      MediaQuery.sizeOf(this).width >= AppBreakpoints.desktop;

  
  EdgeInsets get pagePadding {
    final double width = MediaQuery.sizeOf(this).width;
    if (width >= AppBreakpoints.desktop) {
      return const EdgeInsets.symmetric(horizontal: 48, vertical: 24);
    }
    if (width >= AppBreakpoints.tablet) {
      return const EdgeInsets.symmetric(horizontal: 32, vertical: 20);
    }
    return const EdgeInsets.symmetric(horizontal: 16, vertical: 12);
  }
}


abstract final class AppSpacing {
  static const double xxs = 4;
  static const double xs = 8;
  static const double sm = 12;
  static const double md = 16;
  static const double lg = 20;
  static const double xl = 24;
  static const double xxl = 32;
  static const double xxxl = 40;
  static const double huge = 56;
}


abstract final class AppRadius {
  static const double xs = 8;
  static const double sm = 10;
  static const double md = 14;
  static const double lg = 18;
  static const double xl = 24;
  static const double xxl = 32;
  static const double pill = 999;
}


abstract final class AppBreakpoints {
  static const double mobile = 0;
  static const double tablet = 720;
  static const double desktop = 1024;
  static const double wide = 1280;
}


abstract final class AppShadows {
  static List<BoxShadow> soft(AppColors c) => <BoxShadow>[
        BoxShadow(
          color: c.shadow,
          blurRadius: 18,
          offset: const Offset(0, 6),
        ),
      ];

  static List<BoxShadow> floating(AppColors c) => <BoxShadow>[
        BoxShadow(
          color: c.shadow,
          blurRadius: 28,
          offset: const Offset(0, 12),
        ),
      ];
}


abstract final class AppLayout {
  static const double maxContentWidth = 1080;
  static const double maxFormWidth = 640;
  static const double maxReadingWidth = 760;
}
