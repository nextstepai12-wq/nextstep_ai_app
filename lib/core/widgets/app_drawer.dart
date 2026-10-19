import 'package:flutter/material.dart';

import '../theming/app_theme.dart';
import 'app_avatar.dart';
import 'app_badge.dart';

/// Gradient drawer header shared by all roles.
class AppDrawerHeader extends StatelessWidget {
  const AppDrawerHeader({
    super.key,
    required this.name,
    this.subtitle,
    this.roleLabel,
    this.imageUrl,
    this.badge,
    this.trailing,
  });

  final String name;
  final String? subtitle;
  final String? roleLabel;
  final String? imageUrl;
  final String? badge;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.lg,
        AppSpacing.xl,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[c.gradientStart, c.gradientEnd],
        ),
        borderRadius: const BorderRadius.vertical(
          bottom: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              AppAvatar(
                name: name,
                imageUrl: imageUrl,
                size: 54,
                backgroundColor: Colors.white.withValues(alpha: 0.18),
                foregroundColor: Colors.white,
              ),
              const Spacer(),
              if (trailing != null) trailing!,
              if (roleLabel != null)
                AppBadge(
                  label: roleLabel!,
                  tone: AppBadgeTone.neutral,
                  dense: true,
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: context.textStyles.titleMedium?.copyWith(
              color: c.onPrimary,
              fontWeight: FontWeight.w800,
            ),
          ),
          if (subtitle != null) ...<Widget>[
            const SizedBox(height: 2),
            Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.bodySmall?.copyWith(
                color: c.onPrimary.withValues(alpha: 0.8),
                height: 1.45,
              ),
            ),
          ],
          if (badge != null) ...<Widget>[
            const SizedBox(height: AppSpacing.md),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppRadius.pill),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.22),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.verified_rounded,
                    color: Colors.white,
                    size: 14,
                  ),
                  const SizedBox(width: 5),
                  Text(
                    badge!,
                    style: const TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Drawer entry with a selected state, badge and 48dp minimum height.
class AppDrawerItem extends StatelessWidget {
  const AppDrawerItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.selected = false,
    this.destructive = false,
    this.trailing,
    this.badgeCount = 0,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool selected;
  final bool destructive;
  final Widget? trailing;
  final int badgeCount;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final Color tone = destructive
        ? c.danger
        : selected
            ? c.primary
            : c.textSecondary;
    final Color background = destructive
        ? c.dangerSoft
        : selected
            ? c.primarySoft
            : Colors.transparent;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.sm,
        vertical: 2,
      ),
      child: Material(
        color: background,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 48),
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.xs,
              ),
              child: Row(
                children: <Widget>[
                  Icon(icon, size: 21, color: tone),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text(
                          label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.titleSmall?.copyWith(
                            color: destructive
                                ? c.danger
                                : selected
                                    ? c.primary
                                    : c.textPrimary,
                            fontWeight:
                                selected ? FontWeight.w800 : FontWeight.w600,
                          ),
                        ),
                        if (subtitle != null)
                          Text(
                            subtitle!,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: context.textStyles.bodySmall,
                          ),
                      ],
                    ),
                  ),
                  if (badgeCount > 0) ...<Widget>[
                    const SizedBox(width: AppSpacing.xs),
                    AppCountBadge(count: badgeCount, max: 9),
                  ],
                  if (trailing != null) ...<Widget>[
                    const SizedBox(width: AppSpacing.xs),
                    trailing!,
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Section label inside a drawer.
class AppDrawerSectionLabel extends StatelessWidget {
  const AppDrawerSectionLabel({super.key, required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.md,
        AppSpacing.lg,
        AppSpacing.xs,
      ),
      child: Row(
        children: <Widget>[
          Container(
            width: 3,
            height: 14,
            decoration: BoxDecoration(
              color: c.primary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppSpacing.xs),
          Text(
            label,
            style: context.textStyles.labelMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

/// Drawer shell with themed background and safe padding.
class AppDrawer extends StatelessWidget {
  const AppDrawer({
    super.key,
    required this.children,
    this.width,
  });

  final List<Widget> children;
  final double? width;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return Drawer(
      width: width,
      backgroundColor: c.background,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: children,
        ),
      ),
    );
  }
}
