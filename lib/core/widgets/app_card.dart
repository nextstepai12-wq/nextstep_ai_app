import 'package:flutter/material.dart';

import '../theming/app_theme.dart';



class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.md),
    this.margin,
    this.onTap,
    this.color,
    this.gradient,
    this.borderRadius,
    this.borderColor,
    this.showBorder = true,
    this.semanticLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;
  final Color? color;
  final Gradient? gradient;
  final double? borderRadius;
  final Color? borderColor;
  final bool showBorder;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final double radius = borderRadius ?? AppRadius.lg;

    final BoxDecoration decoration = BoxDecoration(
      color: gradient == null ? (color ?? c.surface) : null,
      gradient: gradient,
      borderRadius: BorderRadius.circular(radius),
      border: showBorder ? Border.all(color: borderColor ?? c.divider) : null,
    );

    final Widget content = Padding(padding: padding, child: child);

    if (onTap == null) {
      return Container(
        margin: margin,
        decoration: decoration,
        child: content,
      );
    }

    return Container(
      margin: margin,
      decoration: decoration,
      clipBehavior: Clip.antiAlias,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius),
          child: Semantics(
            button: true,
            label: semanticLabel,
            child: content,
          ),
        ),
      ),
    );
  }
}


class AppNoticeCard extends StatelessWidget {
  const AppNoticeCard({
    super.key,
    required this.message,
    this.title,
    this.icon = Icons.info_outline_rounded,
    this.tone = AppNoticeTone.info,
    this.action,
  });

  final String message;
  final String? title;
  final IconData icon;
  final AppNoticeTone tone;
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final (Color fg, Color soft) = switch (tone) {
      AppNoticeTone.info => (c.info, c.infoSoft),
      AppNoticeTone.success => (c.success, c.successSoft),
      AppNoticeTone.warning => (c.warning, c.warningSoft),
      AppNoticeTone.danger => (c.danger, c.dangerSoft),
      AppNoticeTone.neutral => (c.textSecondary, c.surfaceAlt),
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: fg.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(icon, size: 20, color: fg),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                if (title != null) ...<Widget>[
                  Text(
                    title!,
                    style: context.textStyles.titleSmall?.copyWith(
                      color: fg,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                ],
                Text(
                  message,
                  style: context.textStyles.bodySmall?.copyWith(
                    color: fg,
                    height: 1.55,
                  ),
                ),
                if (action != null) ...<Widget>[
                  const SizedBox(height: AppSpacing.xs),
                  action!,
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

enum AppNoticeTone { info, success, warning, danger, neutral }
