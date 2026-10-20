import 'package:flutter/material.dart';

import '../theming/app_theme.dart';
import 'app_badge.dart';


class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.loading = false,
    this.fullWidth = true,
    this.compact = false,
    this.danger = false,
    this.semanticLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool loading;
  final bool fullWidth;
  final bool compact;
  final bool danger;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final Widget content = loading
        ? SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.4,
              valueColor: AlwaysStoppedAnimation<Color>(c.onPrimary),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (icon != null) ...<Widget>[
                Icon(icon, size: 19),
                const SizedBox(width: AppSpacing.xs),
              ],
              Flexible(
                child: Text(
                  label,
                  maxLines: 2,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          );

    return Semantics(
      button: true,
      label: semanticLabel ?? label,
      child: SizedBox(
        width: fullWidth ? double.infinity : null,
        child: FilledButton(
          onPressed: loading ? null : onPressed,
          style: FilledButton.styleFrom(
            backgroundColor: danger ? c.danger : c.primary,
            foregroundColor: c.onPrimary,
            minimumSize: Size(0, compact ? 44 : 52),
            padding: EdgeInsets.symmetric(
              horizontal: compact ? 16 : 22,
              vertical: compact ? 10 : 14,
            ),
          ),
          child: content,
        ),
      ),
    );
  }
}


class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.fullWidth = true,
    this.compact = false,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool fullWidth;
  final bool compact;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return SizedBox(
      width: fullWidth ? double.infinity : null,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: danger ? c.danger : c.primary,
          side: BorderSide(
            color: danger ? c.danger.withValues(alpha: 0.5) : c.divider,
          ),
          minimumSize: Size(0, compact ? 44 : 50),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if (icon != null) ...<Widget>[
              Icon(icon, size: 18),
              const SizedBox(width: AppSpacing.xs),
            ],
            Flexible(
              child: Text(
                label,
                maxLines: 2,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class AppIconAction extends StatelessWidget {
  const AppIconAction({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.background,
    this.foreground,
    this.badgeCount = 0,
    this.size = 42,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;
  final Color? background;
  final Color? foreground;
  final int badgeCount;
  final double size;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return IconButton(
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: background ?? c.surface,
        foregroundColor: foreground ?? c.textPrimary,
        minimumSize: Size(size, size),
        side: BorderSide(color: c.divider),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
      ),
      icon: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Icon(icon, size: 21),
          if (badgeCount > 0)
            PositionedDirectional(
              top: -7,
              end: -8,
              child: AppCountBadge(count: badgeCount, max: 9),
            ),
        ],
      ),
    );
  }
}
