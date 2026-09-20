import 'package:flutter/material.dart';

import 'package:nextstep_ai_app/core/theming/app_theme.dart';

class _NavSpec {
  const _NavSpec({
    required this.icon,
    required this.outlinedIcon,
    required this.label,
  });

  final IconData icon;
  final IconData outlinedIcon;
  final String label;
}

/// Custom floating bottom navigation for the University experience.
///
/// The active tab renders a soft pill highlight behind its icon.
class UniversityBottomNav extends StatelessWidget {
  const UniversityBottomNav({
    super.key,
    this.currentIndex = 0,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const List<_NavSpec> _items = [
    _NavSpec(
      icon: Icons.home_rounded,
      outlinedIcon: Icons.home_outlined,
      label: 'الرئيسية',
    ),
    _NavSpec(
      icon: Icons.menu_book,
      outlinedIcon: Icons.menu_book_outlined,
      label: 'التخصصات',
    ),
    _NavSpec(
      icon: Icons.insights,
      outlinedIcon: Icons.insights_outlined,
      label: 'التحليلات',
    ),
    _NavSpec(
      icon: Icons.people,
      outlinedIcon: Icons.people_outline,
      label: 'الطلاب',
    ),
    _NavSpec(
      icon: Icons.settings,
      outlinedIcon: Icons.settings_outlined,
      label: 'الإعدادات',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: c.isDark ? Border(top: BorderSide(color: c.divider)) : null,
        boxShadow: c.isDark
            ? null
            : <BoxShadow>[
                BoxShadow(
                  color: const Color(0xFF0F172A).withValues(alpha: 0.05),
                  blurRadius: 20,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: List<Widget>.generate(_items.length, (int index) {
              return Expanded(
                child: _NavItem(
                  spec: _items[index],
                  isActive: index == currentIndex,
                  onTap: () => onChanged(index),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.spec,
    required this.isActive,
    required this.onTap,
  });

  final _NavSpec spec;
  final bool isActive;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOut,
            padding: EdgeInsets.symmetric(
              horizontal: isActive ? 14 : 10,
              vertical: isActive ? 6 : 4,
            ),
            decoration: BoxDecoration(
              color: isActive ? c.primarySoft : Colors.transparent,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              isActive ? spec.icon : spec.outlinedIcon,
              size: 22,
              color: isActive ? c.primary : c.textSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            spec.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 10,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
              color: isActive ? c.primary : c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
