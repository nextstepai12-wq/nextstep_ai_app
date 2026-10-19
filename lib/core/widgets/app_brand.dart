import 'package:flutter/material.dart';

import '../theming/app_theme.dart';

/// The NextStep AI logo lockup used on auth, splash and empty surfaces.
class AppBrandMark extends StatelessWidget {
  const AppBrandMark({
    super.key,
    this.size = 56,
    this.showWordmark = false,
    this.subtitle,
    this.onDark = false,
  });

  final double size;
  final bool showWordmark;
  final String? subtitle;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final Color fg = onDark ? c.onPrimary : c.primary;
    final Color muted =
        onDark ? c.onPrimary.withValues(alpha: 0.78) : c.textSecondary;

    final Widget mark = Container(
      width: size,
      height: size,
      padding: EdgeInsets.all(size * 0.14),
      decoration: BoxDecoration(
        color: onDark ? Colors.white.withValues(alpha: 0.14) : c.primarySoft,
        borderRadius: BorderRadius.circular(size * 0.3),
        border: Border.all(
          color: onDark
              ? Colors.white.withValues(alpha: 0.22)
              : c.primary.withValues(alpha: 0.12),
        ),
      ),
      child: Image.asset(
        'assets/images/logo.png',
        fit: BoxFit.contain,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.school_rounded,
          size: size * 0.56,
          color: fg,
        ),
      ),
    );

    if (!showWordmark) return mark;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        mark,
        const SizedBox(width: AppSpacing.sm),
        Flexible(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'NextStep AI',
                textDirection: TextDirection.ltr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: size * 0.33,
                  fontWeight: FontWeight.w800,
                  color: fg,
                  height: 1.2,
                ),
              ),
              if (subtitle != null) ...<Widget>[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: size * 0.19,
                    fontWeight: FontWeight.w500,
                    color: muted,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
