import 'package:flutter/material.dart';

import '../theming/app_theme.dart';

/// Compact status/label chip with accessible semantic colours.
class AppBadge extends StatelessWidget {
  const AppBadge({
    super.key,
    required this.label,
    this.tone = AppBadgeTone.neutral,
    this.icon,
    this.showDot = false,
    this.dense = false,
  });

  final String label;
  final AppBadgeTone tone;
  final IconData? icon;
  final bool showDot;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final (Color fg, Color bg) = switch (tone) {
      AppBadgeTone.brand => (c.primary, c.primarySoft),
      AppBadgeTone.success => (c.success, c.successSoft),
      AppBadgeTone.info => (c.info, c.infoSoft),
      AppBadgeTone.warning => (c.warning, c.warningSoft),
      AppBadgeTone.danger => (c.danger, c.dangerSoft),
      AppBadgeTone.purple => (c.purple, c.purpleSoft),
      AppBadgeTone.neutral => (c.textSecondary, c.surfaceAlt),
    };

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: dense ? 7 : 9,
        vertical: dense ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: fg.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          if (showDot) ...<Widget>[
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: fg, shape: BoxShape.circle),
            ),
            const SizedBox(width: 5),
          ],
          if (icon != null) ...<Widget>[
            Icon(icon, size: dense ? 12 : 14, color: fg),
            const SizedBox(width: 4),
          ],
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: dense ? 10.5 : 11.5,
                fontWeight: FontWeight.w700,
                height: 1.2,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum AppBadgeTone { neutral, brand, success, info, warning, danger, purple }

/// Count bubble used for notification and navigation indicators.
class AppCountBadge extends StatelessWidget {
  const AppCountBadge({
    super.key,
    required this.count,
    this.max = 99,
    this.color,
  });

  final int count;
  final int max;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (count <= 0) return const SizedBox.shrink();
    final Color background = color ?? context.appColors.danger;
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(
          color: context.appColors.surface,
          width: 1.5,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        count > max ? '$max+' : '$count',
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 9.5,
          fontWeight: FontWeight.w800,
          height: 1.1,
          color: Colors.white,
        ),
      ),
    );
  }
}
