// lib/features/student/ui/student_main_screen.dart
import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/student_home_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/assessment_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/recommendations_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/chat_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/profile_screen.dart';

/// ============================================================
///  الشاشة الرئيسية للطالب - تحتوي على BottomNavigationBar
/// ============================================================
class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  // ✅ ✅ ✅ نقل tabNotifier إلى هنا (خارج الـ State)
  static final ValueNotifier<int> tabNotifier = ValueNotifier<int>(0);

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;

  // قائمة الشاشات
  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const AssessmentScreen(),
    const RecommendationsScreen(),
    const ChatScreen(),
    const ProfileScreen(),
  ];

  // قائمة التبويبات
  final List<BottomNavigationBarItem> _bottomNavItems = const [
    BottomNavigationBarItem(
      icon: Icon(Icons.home_rounded),
      label: 'الرئيسية',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.assessment_rounded),
      label: 'الاستبيان',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.recommend_rounded),
      label: 'التوصيات',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.chat_rounded),
      label: 'المساعد',
    ),
    BottomNavigationBarItem(
      icon: Icon(Icons.person_rounded),
      label: 'الملف',
    ),
  ];

  @override
  void initState() {
    super.initState();
    // ✅ الوصول إلى tabNotifier عبر الـ Widget
    StudentMainScreen.tabNotifier.addListener(_onTabChanged);
  }

  @override
  void dispose() {
    StudentMainScreen.tabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    final newIndex = StudentMainScreen.tabNotifier.value;
    if (newIndex != _currentIndex && newIndex >= 0 && newIndex < _screens.length) {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: _screens[_currentIndex],
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
              StudentMainScreen.tabNotifier.value = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: Colors.grey.shade500,
          selectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
          items: _bottomNavItems,
          elevation: 8,
        ),
      ),
    );
  }
}