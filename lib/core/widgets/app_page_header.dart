import 'package:flutter/material.dart';

import '../theming/app_theme.dart';
import 'app_buttons.dart';

/// Gradient page header used at the top of primary screens.
///
/// For scroll views that need a collapsing header use [AppSliverPageHeader].
class AppPageHeader extends StatelessWidget {
  const AppPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    this.showBack = true,
    this.onBack,
    this.gradient = true,
    this.bottom,
    this.child,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showBack;
  final VoidCallback? onBack;
  final bool gradient;
  final Widget? bottom;

  /// Optional content rendered below the title row inside the header.
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final Color fg = gradient ? c.onPrimary : c.textPrimary;
    final Color muted =
        gradient ? c.onPrimary.withValues(alpha: 0.8) : c.textSecondary;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: gradient
            ? LinearGradient(
                begin: AlignmentDirectional.topStart,
                end: AlignmentDirectional.bottomEnd,
                colors: <Color>[c.gradientStart, c.gradientEnd],
              )
            : null,
        color: gradient ? null : c.background,
        border: gradient ? null : Border(bottom: BorderSide(color: c.divider)),
        borderRadius: gradient
            ? const BorderRadius.vertical(
                bottom: Radius.circular(AppRadius.xl),
              )
            : null,
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.xs,
            AppSpacing.md,
            AppSpacing.md,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Row(
                children: <Widget>[
                  if (showBack)
                    AppIconAction(
                      icon: Directionality.of(context) == TextDirection.rtl
                          ? Icons.arrow_forward_rounded
                          : Icons.arrow_back_rounded,
                      tooltip: 'رجوع',
                      onPressed: onBack ?? () => Navigator.maybePop(context),
                      background: gradient
                          ? Colors.white.withValues(alpha: 0.16)
                          : c.surface,
                      foreground: fg,
                    ),
                  if (showBack) const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: context.textStyles.headlineSmall?.copyWith(
                            color: fg,
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
                              color: muted,
                              height: 1.45,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  ...actions,
                ],
              ),
              if (child != null) ...<Widget>[
                const SizedBox(height: AppSpacing.md),
                child!,
              ],
              if (bottom != null) ...<Widget>[
                const SizedBox(height: AppSpacing.sm),
                bottom!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Collapsing gradient header for sliver-based screens.
class AppSliverPageHeader extends StatelessWidget {
  const AppSliverPageHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const <Widget>[],
    this.showBack = true,
    this.onBack,
    this.expandedHeight = 136,
    this.bottom,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final bool showBack;
  final VoidCallback? onBack;
  final double expandedHeight;
  final PreferredSizeWidget? bottom;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: c.primary,
      surfaceTintColor: Colors.transparent,
      foregroundColor: c.onPrimary,
      expandedHeight: expandedHeight,
      leading: showBack
          ? IconButton(
              tooltip: 'رجوع',
              icon: Icon(
                Directionality.of(context) == TextDirection.rtl
                    ? Icons.arrow_forward_rounded
                    : Icons.arrow_back_rounded,
                color: c.onPrimary,
              ),
              onPressed: onBack ?? () => Navigator.maybePop(context),
            )
          : null,
      actions: actions,
      bottom: bottom,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: EdgeInsetsDirectional.only(
          start: showBack ? 56 : 20,
          end: actions.isEmpty ? 20 : 56,
          bottom: 14,
        ),
        centerTitle: false,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: context.textStyles.titleLarge?.copyWith(
                color: c.onPrimary,
                fontWeight: FontWeight.w800,
              ),
            ),
            if (subtitle != null)
              Text(
                subtitle!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: context.textStyles.bodySmall?.copyWith(
                  color: c.onPrimary.withValues(alpha: 0.8),
                ),
              ),
          ],
        ),
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: <Color>[c.gradientStart, c.gradientEnd],
            ),
          ),
        ),
      ),
    );
  }
}
