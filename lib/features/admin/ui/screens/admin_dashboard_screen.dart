import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/helpers/hive_storage.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_notifications_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_users_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_universities_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_programs_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_reports_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_settings_screen.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_llm_usage_screen.dart';
import 'package:nextstep_ai_app/core/networking/supabase_service.dart';
import 'package:nextstep_ai_app/core/helpers/token_manager.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseService _supabase = SupabaseService();

  String _adminName = 'مدير النظام';
  String _adminEmail = '';
  bool _isLoading = true;
  String? _errorMessage;
  int _unreadNotifications = 0;

  final Map<String, dynamic> _stats = {
    'users': 1250,
    'universities': 24,
    'programs': 45,
    'faculties': 18,
  };

  final List<Map<String, dynamic>> _recentUsers = [
    {
      'name': 'أحمد محمد',
      'email': 'ahmed@university.edu',
      'role': 'student',
      'time': 'منذ 5 دقائق',
      'status': 'نشط',
    },
    {
      'name': 'الجامعة الإسلامية',
      'email': 'info@iugaza.edu',
      'role': 'university',
      'time': 'منذ ساعة',
      'status': 'نشط',
    },
    {
      'name': 'سارة أحمد',
      'email': 'sara@university.edu',
      'role': 'student',
      'time': 'منذ 3 ساعات',
      'status': 'نشط',
    },
    {
      'name': 'جامعة الأزهر',
      'email': 'info@azhar.edu',
      'role': 'university',
      'time': 'منذ يوم',
      'status': 'قيد الانتظار',
    },
  ];

  final List<Map<String, dynamic>> _quickActions = [
    {
      'icon': Icons.person_add_rounded,
      'title': 'إضافة مستخدم',
      'color': const Color(0xFF3B82F6),
      'route': '/admin/users/add',
    },
    {
      'icon': Icons.business_rounded,
      'title': 'إضافة جامعة',
      'color': const Color(0xFF22C55E),
      'route': '/admin/universities/add',
    },
    {
      'icon': Icons.school_rounded,
      'title': 'إضافة تخصص',
      'color': const Color(0xFF8B5CF6),
      'route': '/admin/programs/add',
    },
    {
      'icon': Icons.analytics_rounded,
      'title': 'التقارير',
      'color': const Color(0xFFF97316),
      'route': '/admin/reports',
    },
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _loadAdminData();
    _loadUnreadNotifications();
  }

  Future<void> _loadAdminData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final cachedData = await TokenManager.getUserData();
      if (cachedData['name'] != null && cachedData['name']!.isNotEmpty) {
        setState(() {
          _adminName = cachedData['name'] ?? 'مدير النظام';
          _adminEmail = cachedData['email'] ?? '';
        });
      }

      final user = _supabase.currentUser;
      if (user != null) {
        final userData = await _supabase.getUser(user.id);
        if (userData != null) {
          setState(() {
            _adminName = userData.displayName;
            _adminEmail = user.email ?? '';
          });
        }
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _animationController.forward();
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'تعذّر تحميل البيانات';
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final cached =
          await HiveStorage.getData('notifications_cache', 'notifications');
      if (cached != null && cached.isNotEmpty) {
        final notifications = List<Map<String, dynamic>>.from(cached);
        final unread =
            notifications.where((n) => n['status'] == 'غير مقروء').length;
        setState(() {
          _unreadNotifications = unread;
        });
      }
    } catch (e) {
    }
  }

  void _goToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminNotificationsScreen(),
      ),
    ).then((_) {
      _loadUnreadNotifications();
    });
  }

  void _navigateTo(String route) {
    context.push(route);
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
                        onRefresh: _loadAdminData,
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
                              _buildStatsGrid(),
                              const SizedBox(height: 28),
                              _buildQuickActions(),
                              const SizedBox(height: 28),
                              _buildRecentActivity(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: const Color(0xFFF6F7FB),
      elevation: 0,
      title: const Center(
        child: Text(
          'لوحة التحكم',
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
        Stack(
          children: [
            IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: AppTheme.primaryContainer,
              ),
              onPressed: _goToNotifications,
            ),
            if (_unreadNotifications > 0)
              Positioned(
                right: 4,
                top: 4,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  constraints: const BoxConstraints(
                    minWidth: 18,
                    minHeight: 18,
                  ),
                  child: Text(
                    _unreadNotifications > 9 ? '9+' : '$_unreadNotifications',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
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
                      child: Icon(
                        Icons.admin_panel_settings_rounded,
                        size: 32,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _adminName.isNotEmpty ? _adminName : 'مدير النظام',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _adminEmail.isNotEmpty ? _adminEmail : '',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.7),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'إدارة',
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
                  _buildDrawerItem(
                    icon: Icons.dashboard_rounded,
                    title: 'لوحة التحكم',
                    onTap: () => Navigator.pop(context),
                  ),
                  _buildDrawerItem(
                    icon: Icons.people_rounded,
                    title: 'المستخدمين',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateTo('/admin/users');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.business_rounded,
                    title: 'الجامعات',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateTo('/admin/universities');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.school_rounded,
                    title: 'التخصصات',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateTo('/admin/programs');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.analytics_rounded,
                    title: 'التقارير',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateTo('/admin/reports');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.person_rounded,
                    title: 'الملف الشخصي',
                    onTap: () {
                      Navigator.pop(context);
                      context.push('/admin/profile');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.notifications_rounded,
                    title: 'الإشعارات',
                    onTap: () {
                      Navigator.pop(context);
                      _goToNotifications();
                    },
                    trailing: _unreadNotifications > 0
                        ? Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              borderRadius: BorderRadius.all(
                                Radius.circular(12),
                              ),
                            ),
                            child: Text(
                              '$_unreadNotifications',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        : null,
                  ),
                  _buildDrawerItem(
                    icon: Icons.auto_awesome_rounded,
                    title: 'استخدام الذكاء',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateTo('/admin/llm-usage');
                    },
                  ),
                  const Divider(),
                  _buildDrawerItem(
                    icon: Icons.person_rounded,
                    title: 'الملف الشخصي',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateTo('/admin/profile');
                    },
                  ),
                  _buildDrawerItem(
                    icon: Icons.settings_rounded,
                    title: 'الإعدادات',
                    onTap: () {
                      Navigator.pop(context);
                      _navigateTo('/admin/settings');
                    },
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
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
    Widget? trailing,
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
      trailing: trailing ??
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: Colors.grey.shade400,
          ),
      onTap: onTap,
    );
  }

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
              onPressed: _loadAdminData,
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
                  _adminName.isNotEmpty ? _adminName : 'مدير النظام',
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    'لوحة تحكم الإدارة',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Icon(
                Icons.admin_panel_settings_rounded,
                size: 36,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: 'المستخدمين',
          value: _stats['users'].toString(),
          icon: Icons.people_rounded,
          color: const Color(0xFF3B82F6),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
          ),
        ),
        _buildStatCard(
          title: 'الجامعات',
          value: _stats['universities'].toString(),
          icon: Icons.business_rounded,
          color: const Color(0xFF22C55E),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
          ),
        ),
        _buildStatCard(
          title: 'التخصصات',
          value: _stats['programs'].toString(),
          icon: Icons.school_rounded,
          color: const Color(0xFF8B5CF6),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
          ),
        ),
        _buildStatCard(
          title: 'الكليات',
          value: _stats['faculties'].toString(),
          icon: Icons.account_balance_rounded,
          color: const Color(0xFFF97316),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFF97316), Color(0xFFEA580C)],
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
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.2),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: Colors.white.withValues(alpha: 0.8)),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'إجراءات سريعة',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w800,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
          children: _quickActions.map((action) {
            return _buildQuickActionCard(
              icon: action['icon'],
              title: action['title'],
              color: action['color'],
              onTap: () {
                _navigateTo(action['route']);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildQuickActionCard({
    required IconData icon,
    required String title,
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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentActivity() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'أحدث النشاطات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryContainer,
              ),
            ),
            TextButton(
              onPressed: () => _navigateTo('/admin/users'),
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
        ..._recentUsers.map((user) => _buildActivityItem(user)),
      ],
    );
  }

  Widget _buildActivityItem(Map<String, dynamic> user) {
    Color statusColor;
    switch (user['status']) {
      case 'نشط':
        statusColor = Colors.green;
        break;
      case 'قيد الانتظار':
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.grey;
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
                user['name'][0],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
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
                  user['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryContainer,
                  ),
                ),
                Text(
                  user['email'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  user['status'],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              Text(
                user['time'],
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

