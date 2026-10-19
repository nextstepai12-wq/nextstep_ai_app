import 'package:flutter/material.dart';

import '../theming/app_theme.dart';

class AppNavItem {
  const AppNavItem({
    required this.icon,
    required this.label,
    this.semanticLabel,
  });

  final IconData icon;
  final String label;
  final String? semanticLabel;
}

/// Floating pill bottom navigation shared by role shells.
class AppBottomNav extends StatelessWidget {
  const AppBottomNav({
    super.key,
    required this.items,
    required this.currentIndex,
    required this.onChanged,
  });

  final List<AppNavItem> items;
  final int currentIndex;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.sm,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(AppRadius.pill),
          border: Border.all(color: c.divider),
          boxShadow: AppShadows.floating(c),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: MediaQuery.withClampedTextScaling(
            maxScaleFactor: 1.3,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 64),
              child: Row(
                children: List<Widget>.generate(items.length, (int index) {
                  final bool selected = index == currentIndex;
                  final AppNavItem item = items[index];
                  return Expanded(
                    child: Semantics(
                      button: true,
                      selected: selected,
                      label: item.semanticLabel ?? item.label,
                      child: InkWell(
                        onTap: () => onChanged(index),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          curve: Curves.easeOut,
                          margin: const EdgeInsets.all(6),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: selected ? c.primarySoft : null,
                            borderRadius: BorderRadius.circular(AppRadius.pill),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: <Widget>[
                              Icon(
                                item.icon,
                                size: 22,
                                color: selected ? c.primary : c.textSecondary,
                              ),
                              const SizedBox(height: 3),
                              Text(
                                item.label,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 10.5,
                                  fontWeight: selected
                                      ? FontWeight.w700
                                      : FontWeight.w500,
                                  color: selected ? c.primary : c.textSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
