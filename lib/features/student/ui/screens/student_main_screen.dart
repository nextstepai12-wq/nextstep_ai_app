import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/student_home_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/assessment_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/recommendations_screen.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/profile_screen.dart';
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
    if (newIndex != _currentIndex && newIndex >= 0 && newIndex < _screens.length) {
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
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        extendBody: true,
        drawer: _buildDrawer(c),
        body: _screens[_currentIndex],
        bottomNavigationBar: _buildFloatingNav(),
      ),
    );
  }

  // ─── Drawer ───────────────────────────────────────────────────────────────

  Widget _buildDrawer(AppColors c) {
    final initial = _userName.isNotEmpty ? _userName.trim()[0] : 'ط';

    return Drawer(
      backgroundColor: c.background,
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [c.primary, c.primaryContainer, c.purple],
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.35),
                            width: 1.5,
                          ),
                        ),
                        child: Center(
                          child: Text(
                            initial,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _userName.isNotEmpty ? _userName : 'طالب',
                              style: const TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _userEmail.isNotEmpty ? _userEmail : 'طالب NextStep AI',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.75),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.verified_rounded, color: Colors.white, size: 13),
                        SizedBox(width: 5),
                        Text(
                          'الحساب موثّق',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _drawerSectionLabel(c, 'القائمة الرئيسية'),
            _drawerItem(
              c: c,
              icon: Icons.home_rounded,
              title: 'الرئيسية',
              isActive: _currentIndex == 0,
              onTap: () => _switchTab(0),
            ),
            _drawerItem(
              c: c,
              icon: Icons.psychology_rounded,
              title: 'التقييم الذكي',
              isActive: _currentIndex == 1,
              onTap: () => _switchTab(1),
            ),
            _drawerItem(
              c: c,
              icon: Icons.explore_rounded,
              title: 'التوصيات',
              isActive: _currentIndex == 2,
              onTap: () => _switchTab(2),
            ),
            _drawerItem(
              c: c,
              icon: Icons.account_circle_rounded,
              title: 'حسابي',
              isActive: _currentIndex == 3,
              onTap: () => _switchTab(3),
            ),
            const SizedBox(height: 16),
            _drawerSectionLabel(c, 'الدعم والإعدادات'),
            _drawerItem(
              c: c,
              icon: Icons.settings_rounded,
              title: 'الإعدادات',
              onTap: () {
                Navigator.pop(context);
                context.push('/settings');
              },
            ),
            _drawerItem(
              c: c,
              icon: Icons.help_outline_rounded,
              title: 'مركز المساعدة',
              onTap: () {
                Navigator.pop(context);
                context.push('/student/help-center');
              },
            ),
            _drawerItem(
              c: c,
              icon: Icons.share_rounded,
              title: 'مشاركة التطبيق',
              onTap: () {
                Navigator.pop(context);
                context.push('/student/share-app');
              },
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _drawerItem(
                c: c,
                icon: Icons.logout_rounded,
                title: 'تسجيل الخروج',
                color: c.danger,
                isLogout: true,
                onTap: () async {
                  await TokenManager.clearAll();
                  if (mounted) {
                    context.pushReplacement('/login');
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _drawerSectionLabel(AppColors c, String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 14,
            decoration: BoxDecoration(
              color: c.primary,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: c.textSecondary,
              letterSpacing: 0.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem({
    required AppColors c,
    required IconData icon,
    required String title,
    bool isActive = false,
    bool isLogout = false,
    Color? color,
    required VoidCallback onTap,
  }) {
    final activeColor = isLogout ? c.danger : c.primary;
    final iconBg = isLogout
        ? c.dangerSoft
        : isActive
            ? c.primarySoft
            : c.surfaceAlt;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? c.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isActive ? c.primary.withValues(alpha: 0.3) : Colors.transparent,
              width: 1.2,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: isActive || isLogout ? activeColor : c.textSecondary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isActive || isLogout ? FontWeight.w700 : FontWeight.w500,
                    color: isActive || isLogout
                        ? activeColor
                        : (color ?? c.textPrimary),
                  ),
                ),
              ),
              if (isActive && !isLogout)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: c.primary,
                    shape: BoxShape.circle,
                  ),
                )
              else if (!isLogout)
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 13,
                  color: c.textSecondary.withValues(alpha: 0.6),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Floating Bottom Nav ──────────────────────────────────────────────────

  Widget _buildFloatingNav() {
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    final items = [
      _NavItem(icon: Icons.home_rounded, label: 'الرئيسية'),
      _NavItem(icon: Icons.psychology_rounded, label: 'التقييم الذكي'),
      _NavItem(icon: Icons.explore_rounded, label: 'التوصيات'),
      _NavItem(icon: Icons.account_circle_rounded, label: 'حسابي'),
    ];

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Container(
        height: 64,
        decoration: BoxDecoration(
          color: c.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.12),
              blurRadius: 32,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: List.generate(items.length, (i) {
            final isActive = _currentIndex == i;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _currentIndex = i;
                  StudentMainScreen.tabNotifier.value = i;
                });
              },
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 64,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      items[i].icon,
                      size: 24,
                      color: isActive ? c.primary : c.textSecondary,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      items[i].label,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                        color: isActive ? c.primary : c.textSecondary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            );
          }),
        ),
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  _NavItem({required this.icon, required this.label});
}
