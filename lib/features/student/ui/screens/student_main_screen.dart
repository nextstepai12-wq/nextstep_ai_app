import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/widgets/app_bottom_nav.dart';
import 'package:nextstep_ai_app/core/widgets/app_drawer.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/student_home_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/assessment_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/recommendations_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/profile_screen.dart';
import 'package:nextstep_ai_app/core/helpers/session_helper.dart';
import 'package:nextstep_ai_app/core/helpers/token_manager.dart';

class StudentMainScreen extends StatefulWidget {
  const StudentMainScreen({super.key});

  static final ValueNotifier<int> tabNotifier = ValueNotifier<int>(0);

  @override
  State<StudentMainScreen> createState() => _StudentMainScreenState();
}

class _StudentMainScreenState extends State<StudentMainScreen> {
  int _currentIndex = 0;
  String _userName = '';
  String _userEmail = '';

  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const AssessmentScreen(),
    const RecommendationsScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    StudentMainScreen.tabNotifier.addListener(_onTabChanged);
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final data = await TokenManager.getUserData();
      if (mounted) {
        setState(() {
          _userName = data['name'] ?? '';
          _userEmail = data['email'] ?? '';
        });
      }
    } catch (_) {}
  }

  @override
  void dispose() {
    StudentMainScreen.tabNotifier.removeListener(_onTabChanged);
    super.dispose();
  }

  void _onTabChanged() {
    final newIndex = StudentMainScreen.tabNotifier.value;
    if (newIndex != _currentIndex &&
        newIndex >= 0 &&
        newIndex < _screens.length) {
      setState(() {
        _currentIndex = newIndex;
      });
    }
  }

  void _switchTab(int index) {
    Navigator.of(context).pop();
    setState(() {
      _currentIndex = index;
      StudentMainScreen.tabNotifier.value = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        drawer: _buildDrawer(),
        body: _screens[_currentIndex],
        bottomNavigationBar: _buildFloatingNav(),
      ),
    );
  }

  

  Widget _buildDrawer() {
    return AppDrawer(
      children: <Widget>[
        AppDrawerHeader(
          name: _userName.isNotEmpty ? _userName : 'طالب',
          subtitle: _userEmail.isNotEmpty ? _userEmail : 'طالب NextStep AI',
          badge: 'الحساب موثّق',
        ),
        const AppDrawerSectionLabel(label: 'القائمة الرئيسية'),
        AppDrawerItem(
          icon: Icons.home_rounded,
          label: 'الرئيسية',
          selected: _currentIndex == 0,
          onTap: () => _switchTab(0),
        ),
        AppDrawerItem(
          icon: Icons.psychology_rounded,
          label: 'التقييم الذكي',
          selected: _currentIndex == 1,
          onTap: () => _switchTab(1),
        ),
        AppDrawerItem(
          icon: Icons.explore_rounded,
          label: 'التوصيات',
          selected: _currentIndex == 2,
          onTap: () => _switchTab(2),
        ),
        AppDrawerItem(
          icon: Icons.account_circle_rounded,
          label: 'حسابي',
          selected: _currentIndex == 3,
          onTap: () => _switchTab(3),
        ),
        const AppDrawerSectionLabel(label: 'الدعم والإعدادات'),
        AppDrawerItem(
          icon: Icons.settings_rounded,
          label: 'الإعدادات',
          onTap: () {
            Navigator.pop(context);
            context.push('/settings');
          },
        ),
        AppDrawerItem(
          icon: Icons.help_outline_rounded,
          label: 'مركز المساعدة',
          onTap: () {
            Navigator.pop(context);
            context.push('/student/help-center');
          },
        ),
        AppDrawerItem(
          icon: Icons.share_rounded,
          label: 'مشاركة التطبيق',
          onTap: () {
            Navigator.pop(context);
            context.push('/student/share-app');
          },
        ),
        const Spacer(),
        AppDrawerItem(
          icon: Icons.logout_rounded,
          label: 'تسجيل الخروج',
          destructive: true,
          onTap: () async {
            Navigator.pop(context);
            await logoutToLogin(context);
          },
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  

  Widget _buildFloatingNav() {
    const List<AppNavItem> items = <AppNavItem>[
      AppNavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
      AppNavItem(icon: Icons.psychology_rounded, label: 'التقييم الذكي'),
      AppNavItem(icon: Icons.explore_rounded, label: 'التوصيات'),
      AppNavItem(icon: Icons.account_circle_rounded, label: 'حسابي'),
    ];

    return AppBottomNav(
      items: items,
      currentIndex: _currentIndex,
      onChanged: (int index) {
        setState(() {
          _currentIndex = index;
          StudentMainScreen.tabNotifier.value = index;
        });
      },
    );
  }
}
