import 'package:flutter/material.dart';

import '../theming/app_theme.dart';

/// Centers content, applies responsive padding and caps line length.
class AppPageBody extends StatelessWidget {
  const AppPageBody({
    super.key,
    required this.child,
    this.maxWidth = AppLayout.maxContentWidth,
    this.padding,
    this.center = true,
  });

  final Widget child;
  final double maxWidth;
  final EdgeInsetsGeometry? padding;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final EdgeInsetsGeometry effectivePadding = padding ?? context.pagePadding;
    final Widget content = Padding(padding: effectivePadding, child: child);
    if (!center) return content;
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: content,
      ),
    );
  }
}

/// Wraps stat cards into a responsive grid without fixed aspect ratios.
class AppAdaptiveGrid extends StatelessWidget {
  const AppAdaptiveGrid({
    super.key,
    required this.children,
    this.spacing = AppSpacing.sm,
    this.minItemWidth = 150,
    this.maxColumns = 4,
  });

  final List<Widget> children;
  final double spacing;
  final double minItemWidth;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    if (children.isEmpty) return const SizedBox.shrink();
    return LayoutBuilder(
      builder: (context, constraints) {
        final double width = constraints.maxWidth;
        int columns =
            ((width + spacing) / (minItemWidth + spacing)).floor().clamp(
                  1,
                  maxColumns,
                );
        if (children.length < columns) columns = children.length;
        final double itemWidth = (width - spacing * (columns - 1)) / columns;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: children
              .map(
                (Widget child) => SizedBox(width: itemWidth, child: child),
              )
              .toList(),
        );
      },
    );
  }
}

/// A row that stacks vertically on phones and lays out horizontally on
/// tablets/desktops. Useful for paired form fields.
class AppAdaptiveRow extends StatelessWidget {
  const AppAdaptiveRow({
    super.key,
    required this.children,
    this.spacing = AppSpacing.md,
    this.breakpoint = AppBreakpoints.tablet,
    this.expandChildren = true,
  });

  final List<Widget> children;
  final double spacing;
  final double breakpoint;
  final bool expandChildren;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final bool horizontal = constraints.maxWidth >= breakpoint;
        if (!horizontal) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              for (int i = 0; i < children.length; i++) ...<Widget>[
                if (i > 0) SizedBox(height: spacing),
                children[i],
              ],
            ],
          );
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            for (int i = 0; i < children.length; i++) ...<Widget>[
              if (i > 0) SizedBox(width: spacing),
              if (expandChildren) Expanded(child: children[i]) else children[i],
            ],
          ],
        );
      },
    );
  }
}

/// Small inline label that marks demo/sample content in this prototype.
class SampleDataBadge extends StatelessWidget {
  const SampleDataBadge({super.key, this.label = 'بيانات تجريبية'});

  final String label;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: c.warningSoft,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: c.warning.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(Icons.science_outlined, size: 12, color: c.warning),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 10.5,
              fontWeight: FontWeight.w700,
              color: c.warning,
            ),
          ),
        ],
      ),
    );
  }
}
