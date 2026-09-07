import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/networking/supabase_service.dart';
import 'package:nextstep_ai_app/core/helpers/token_manager.dart';

class UniversityHomeScreen extends StatefulWidget {
  const UniversityHomeScreen({super.key});

  @override
  State<UniversityHomeScreen> createState() => _UniversityHomeScreenState();
}

class _UniversityHomeScreenState extends State<UniversityHomeScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseService _supabase = SupabaseService();

  String _userName = 'الجامعة';
  String _userEmail = '';
  String _universityName = '';
  Map<String, dynamic>? _universityData;
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<Map<String, dynamic>> _recentStudents = [
    {'name': 'أحمد محمد', 'major': 'هندسة حاسوب', 'status': 'جديد'},
    {'name': 'سارة أحمد', 'major': 'الذكاء الاصطناعي', 'status': 'مكتمل'},
    {'name': 'محمد خالد', 'major': 'علوم البيانات', 'status': 'قيد الانتظار'},
  ];

  final List<Map<String, dynamic>> _topPrograms = [
    {'name': 'هندسة الحاسوب', 'students': 45, 'growth': '+12%'},
    {'name': 'الذكاء الاصطناعي', 'students': 38, 'growth': '+25%'},
    {'name': 'علوم البيانات', 'students': 32, 'growth': '+18%'},
    {'name': 'الأمن السيبراني', 'students': 28, 'growth': '+8%'},
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _loadUniversityData();
  }

  Future<void> _loadUniversityData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cachedData = await TokenManager.getUserData();
      if (cachedData['name'] != null && cachedData['name']!.isNotEmpty) {
        setState(() {
          _userName = cachedData['name'] ?? 'الجامعة';
          _userEmail = cachedData['email'] ?? '';
        });
      }

      final user = _supabase.currentUser;
      if (user != null) {
        final userData = await _supabase.getUser(user.id);
        if (userData != null) {
          setState(() {
            _userName = userData.displayName;
            _userEmail = user.email ?? '';
          });
        }

        try {
          _universityData = {
            'name': 'الجامعة الإسلامية',
            'location': 'غزة، فلسطين',
            'students_count': 1250,
            'programs_count': 24,
            'rating': 4.8,
            'logo': '',
          };
          setState(() {
            _universityName = _universityData?['name'] ?? 'الجامعة';
          });
        } catch (_) {}
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'تعذّر تحميل البيانات';
        _isLoading = false;
      });
    }
  }

  Future<void> _logout() async {
    await TokenManager.clearAll();
    await _supabase.signOut();
    if (mounted) {
      context.pushReplacement('/login');
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _buildAppBar(),
        drawer: _buildDrawer(),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                ),
              )
            : _errorMessage != null
                ? _buildErrorState()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: RefreshIndicator(
                        onRefresh: _loadUniversityData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildWelcomeSection(),
                              const SizedBox(height: 24),
                              _buildStatsSection(),
                              const SizedBox(height: 28),
                              _buildQuickActionsSection(),
                              const SizedBox(height: 28),
                              _buildProgramsSection(),
                              const SizedBox(height: 28),
                              _buildRecentStudentsSection(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  // ============================================================
  //  Error State
  // ============================================================
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadUniversityData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  AppBar
  // ============================================================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF6F7FB),
      elevation: 0,
      title: const Center(
        child: Text(
          'NextStep AI',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryContainer,
            letterSpacing: -0.3,
          ),
        ),
      ),
      centerTitle: true,
      leading: Builder(
        builder: (context) => IconButton(
          icon: const Icon(
            Icons.menu_rounded,
            color: AppTheme.primaryContainer,
          ),
          onPressed: () => Scaffold.of(context).openDrawer(),
        ),
      ),
      actions: [
        IconButton(
          icon: const Icon(
            Icons.notifications_outlined,
            color: AppTheme.primaryContainer,
          ),
          onPressed: () =>
              context.push('/university/notifications'),
        ),
      ],
    );
  }

  // ============================================================
  //  Drawer
  // ============================================================
 Widget _buildDrawer() {
  return Drawer(
    child: SafeArea(
      child: Column(
        children: [
          // Header مع بيانات الجامعة
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppTheme.primary, AppTheme.primaryContainer],
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.business, size: 32, color: Colors.white),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  _userName.isNotEmpty ? _userName : 'الجامعة',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userEmail.isNotEmpty ? _userEmail : '',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.7),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'جامعة',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                // ✅ 1. الرئيسية
                _buildDrawerItem(
                  icon: Icons.home_rounded,
                  title: 'الرئيسية',
                  onTap: () => Navigator.pop(context),
                ),
                
                // ✅ 2. التخصصات
                _buildDrawerItem(
                  icon: Icons.school_rounded,
                  title: 'التخصصات',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/university/programs');
                  },
                ),
                
                // ✅ 3. الكليات
                _buildDrawerItem(
                  icon: Icons.business_rounded,
                  title: 'الكليات',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/university/faculties');
                  },
                ),
                
                // ✅ 4. التحليلات
                _buildDrawerItem(
                  icon: Icons.analytics_rounded,
                  title: 'التحليلات',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/university/analytics');
                  },
                ),
                
                // ✅ 5. الطلاب
                _buildDrawerItem(
                  icon: Icons.people_rounded,
                  title: 'الطلاب',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/university/students');
                  },
                ),
                
                const Divider(),
                
                // ✅ 6. الملف الشخصي
                _buildDrawerItem(
                  icon: Icons.person_rounded,
                  title: 'الملف الشخصي',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/university/profile');
                  },
                ),
                
                // ✅ 7. الإعدادات
                _buildDrawerItem(
                  icon: Icons.settings_rounded,
                  title: 'الإعدادات',
                  onTap: () {
                    Navigator.pop(context);
                    context.push('/university/settings');
                  },
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ✅ 8. تسجيل الخروج
          _buildDrawerItem(
            icon: Icons.logout_rounded,
            title: 'تسجيل الخروج',
            color: Colors.red,
            onTap: _logout,
          ),
          const SizedBox(height: 12),
        ],
      ),
    ),
  );
}

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primary, size: 24),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: color ?? AppTheme.primaryContainer,
        ),
      ),
      onTap: onTap,
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey.shade400,
      ),
    );
  }

  // ============================================================
  //  Welcome Section
  // ============================================================
  Widget _buildWelcomeSection() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'مرحباً بك 👋',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.85),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _userName.isNotEmpty ? _userName : 'الجامعة',
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    _universityData?['location'] ?? 'غزة، فلسطين',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white.withValues(alpha: 0.9),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF4FC3F7),
                  Color(0xFF0288D1),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF0288D1).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'assets/images/logo.png',
                width: 60,
                height: 60,
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.business_rounded,
                  size: 36,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  Stats Section
  // ============================================================
  Widget _buildStatsSection() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'الطلاب',
            value: '1,250',
            icon: Icons.people_rounded,
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'التخصصات',
            value: '24',
            icon: Icons.school_rounded,
            color: const Color(0xFF22C55E),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildStatCard(
            title: 'التقييم',
            value: '4.8',
            icon: Icons.star_rounded,
            color: const Color(0xFFF97316),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.primaryContainer,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  Quick Actions Section
  // ============================================================
Widget _buildQuickActionsSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const Text(
        'إدارة سريعة',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: AppTheme.primaryContainer,
        ),
      ),
      const SizedBox(height: 14),
      Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.add_rounded,
              title: 'إضافة تخصص',
              subtitle: 'تخصص جديد',
              color: const Color(0xFF3B82F6),
              onTap: () =>
                  context.push('/university/add-program'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.business_rounded, // ✅ تغيير من analytics إلى business
              title: 'الكليات',
              subtitle: 'إدارة الكليات',
              color: const Color(0xFFA855F7),
              onTap: () =>
                  context.push('/university/faculties'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.analytics_rounded,
              title: 'التقارير',
              subtitle: 'عرض التحليلات',
              color: const Color(0xFF22C55E),
              onTap: () =>
                  context.push('/university/analytics'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.people_rounded,
              title: 'الطلاب',
              subtitle: 'إدارة الطلاب',
              color: const Color(0xFFA855F7),
              onTap: () =>
                  context.push('/university/students'),
            ),
          ),
        ],
      ),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.settings_rounded,
              title: 'الإعدادات',
              subtitle: 'تخصيص الجامعة',
              color: const Color(0xFFF97316),
              onTap: () =>
                  context.push('/university/settings'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _buildQuickActionCard(
              icon: Icons.person_rounded,
              title: 'الملف الشخصي',
              subtitle: 'عرض بياناتي',
              color: const Color(0xFF3B82F6),
              onTap: () =>
                  context.push('/university/profile'),
            ),
          ),
        ],
      ),
    ],
  );
}

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: Colors.grey.shade200, width: 1.2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryContainer,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 14,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  Programs Section
  // ============================================================
  Widget _buildProgramsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'أشهر التخصصات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryContainer,
              ),
            ),
            TextButton(
              onPressed: () =>
                  context.push('/university/programs'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.secondary,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._topPrograms.map((program) => _buildProgramCard(
              name: program['name'],
              students: program['students'],
              growth: program['growth'],
            )),
      ],
    );
  }

  Widget _buildProgramCard({
    required String name,
    required int students,
    required String growth,
  }) {
    final isPositive = growth.startsWith('+');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Center(
              child: Icon(
                Icons.school_rounded,
                color: AppTheme.primary,
                size: 22,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryContainer,
                  ),
                ),
                Text(
                  '$students طالب',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: isPositive
                  ? Colors.green.withValues(alpha: 0.1)
                  : Colors.red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              growth,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: isPositive ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  Recent Students Section
  // ============================================================
  Widget _buildRecentStudentsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'أحدث الطلاب',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryContainer,
              ),
            ),
            TextButton(
              onPressed: () =>
                  context.push('/university/students'),
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.secondary,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        ..._recentStudents.map((student) => _buildStudentCard(
              name: student['name'],
              major: student['major'],
              status: student['status'],
            )),
      ],
    );
  }

  Widget _buildStudentCard({
    required String name,
    required String major,
    required String status,
  }) {
    Color statusColor;
    String statusText;

    switch (status) {
      case 'جديد':
        statusColor = Colors.blue;
        statusText = 'جديد';
        break;
      case 'مكتمل':
        statusColor = Colors.green;
        statusText = 'مكتمل';
        break;
      default:
        statusColor = Colors.orange;
        statusText = 'قيد الانتظار';
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                name.isNotEmpty ? name[0] : 'ط',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryContainer,
                  ),
                ),
                Text(
                  major,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              statusText,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: statusColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
