import 'package:flutter/material.dart';

import '../theming/app_theme.dart';

enum AppSnackTone { success, error, info, warning }

/// Consistent floating snackbars with an icon and accessible contrast.
abstract final class AppSnack {
  static void show(
    BuildContext context,
    String message, {
    AppSnackTone tone = AppSnackTone.info,
    SnackBarAction? action,
    Duration duration = const Duration(seconds: 3),
  }) {
    final AppColors c = context.appColors;
    final (IconData icon, Color color) = switch (tone) {
      AppSnackTone.success => (Icons.check_circle_rounded, c.success),
      AppSnackTone.error => (Icons.error_rounded, c.danger),
      AppSnackTone.info => (Icons.info_rounded, c.info),
      AppSnackTone.warning => (Icons.warning_rounded, c.warning),
    };

    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          duration: duration,
          action: action,
          content: Row(
            children: <Widget>[
              Icon(icon, size: 20, color: color),
              const SizedBox(width: AppSpacing.xs),
              Expanded(child: Text(message)),
            ],
          ),
        ),
      );
  }

  static void success(BuildContext context, String message) =>
      show(context, message, tone: AppSnackTone.success);

  static void error(BuildContext context, String message) =>
      show(context, message, tone: AppSnackTone.error);

  static void info(BuildContext context, String message) =>
      show(context, message, tone: AppSnackTone.info);

  static void warning(BuildContext context, String message) =>
      show(context, message, tone: AppSnackTone.warning);
}
