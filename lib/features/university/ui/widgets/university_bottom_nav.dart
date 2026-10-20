import 'package:flutter/material.dart';

import 'package:nextstep_ai_app/core/widgets/app_bottom_nav.dart';





class UniversityBottomNav extends StatelessWidget {
  const UniversityBottomNav({
    super.key,
    this.currentIndex = 0,
    required this.onChanged,
  });

  final int currentIndex;
  final ValueChanged<int> onChanged;

  static const List<AppNavItem> _items = <AppNavItem>[
    AppNavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
    AppNavItem(icon: Icons.menu_book, label: 'التخصصات'),
    AppNavItem(icon: Icons.insights, label: 'التحليلات'),
    AppNavItem(icon: Icons.people, label: 'الطلاب'),
    AppNavItem(icon: Icons.settings, label: 'الإعدادات'),
  ];

  @override
  Widget build(BuildContext context) {
    return AppBottomNav(
      items: _items,
      currentIndex: currentIndex,
      onChanged: onChanged,
    );
  }
}
