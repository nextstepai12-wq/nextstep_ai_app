import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shimmer/shimmer.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/widgets/app_responsive.dart';
import 'package:nextstep_ai_app/core/helpers/hive_storage.dart';
import 'package:nextstep_ai_app/core/helpers/token_manager.dart';
import 'package:nextstep_ai_app/core/networking/supabase_service.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_notifications_screen.dart';

/// ─────────────────────────────────────────────────────────────────────────
/// Mock data models — structured so they can be wired to an API later.
/// ─────────────────────────────────────────────────────────────────────────

class AdminStat {
  final String id;
  final String labelEn;
  final String labelAr;
  final String value;
  final String delta;
  final bool positive;
  final IconData icon;
  final Color color;
  final Color softColor;
  final List<double> spark;
  final String periodEn;
  final String periodAr;

  const AdminStat({
    required this.id,
    required this.labelEn,
    required this.labelAr,
    required this.value,
    required this.delta,
    required this.positive,
    required this.icon,
    required this.color,
    required this.softColor,
    required this.spark,
    required this.periodEn,
    required this.periodAr,
  });
}

class AdminQuickAction {
  final IconData icon;
  final Color color;
  final Color softColor;
  final String labelEn;
  final String labelAr;
  final String route;

  const AdminQuickAction({
    required this.icon,
    required this.color,
    required this.softColor,
    required this.labelEn,
    required this.labelAr,
    required this.route,
  });
}

class AdminProduct {
  final String nameEn;
  final String nameAr;
  final int sold;
  final double progress;

  const AdminProduct({
    required this.nameEn,
    required this.nameAr,
    required this.sold,
    required this.progress,
  });
}

enum AdminActivityType { success, info, warning }

class AdminActivity {
  final AdminActivityType type;
  final String boldEn;
  final String boldAr;
  final String restEn;
  final String restAr;
  final String timeEn;
  final String timeAr;

  const AdminActivity({
    required this.type,
    this.boldEn = '',
    this.boldAr = '',
    required this.restEn,
    required this.restAr,
    required this.timeEn,
    required this.timeAr,
  });
}

/// ─────────────────────────────────────────────────────────────────────────
/// Screen
/// ─────────────────────────────────────────────────────────────────────────

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen>
    with TickerProviderStateMixin {
  // Design-system colors (match the approved mockup)
  static const Color _indigo = Color(0xFF6366F1);
  static const Color _indigoDark = Color(0xFF4F46E5);
  static const Color _blue = Color(0xFF3B82F6);
  static const Color _teal = Color(0xFF14B8A6);
  static const Color _tealDark = Color(0xFF0D9488);
  static const Color _amber = Color(0xFFF59E0B);
  static const Color _amberDark = Color(0xFFD97706);
  static const Color _purple = Color(0xFF8B5CF6);
  static const Color _purpleDark = Color(0xFF7C3AED);
  static const Color _roseDark = Color(0xFFE11D48);
  static const Color _green = Color(0xFF10B981);
  static const Color _blueInfo = Color(0xFF3B82F6);

  final SupabaseService _supabase = SupabaseService();

  bool _isLoading = true;
  bool _hasError = false;
  bool _isEnglish = true;
  int _unreadNotifications = 0;

  String _adminName = 'System Admin';
  String _adminEmail = '';

  // ── Mock data (API-ready, labeled as sample in the UI) ──
  final List<AdminStat> _stats = const [
    AdminStat(
      id: 'users',
      labelEn: 'Total Users',
      labelAr: 'إجمالي المستخدمين',
      value: '12,845',
      delta: '+8.2%',
      positive: true,
      icon: Icons.group_rounded,
      color: _indigo,
      softColor: Color(0xFFE0E7FF),
      spark: [3, 5, 4, 6, 7.5, 6.5, 5.5],
      periodEn: '7 days',
      periodAr: '٧ أيام',
    ),
    AdminStat(
      id: 'universities',
      labelEn: 'Universities',
      labelAr: 'الجامعات',
      value: '48',
      delta: '+3',
      positive: true,
      icon: Icons.account_balance_rounded,
      color: _tealDark,
      softColor: Color(0xFFCCFBF1),
      spark: [3, 3, 4, 4, 5, 6, 6.5],
      periodEn: 'This month',
      periodAr: 'هذا الشهر',
    ),
    AdminStat(
      id: 'programs',
      labelEn: 'Academic Programs',
      labelAr: 'التخصصات الأكاديمية',
      value: '312',
      delta: '+14',
      positive: true,
      icon: Icons.menu_book_rounded,
      color: _amberDark,
      softColor: Color(0xFFFEF3C7),
      spark: [5, 5.5, 5, 6, 6.5, 7, 7.5],
      periodEn: 'This month',
      periodAr: 'هذا الشهر',
    ),
    AdminStat(
      id: 'sessions',
      labelEn: 'Active Students',
      labelAr: 'طلاب نشطون',
      value: '3,264',
      delta: '+5.4%',
      positive: true,
      icon: Icons.school_rounded,
      color: _purpleDark,
      softColor: Color(0xFFEDE9FE),
      spark: [3, 2, 4.5, 3, 5, 3.5, 4],
      periodEn: '7 days',
      periodAr: '٧ أيام',
    ),
  ];

  final List<AdminQuickAction> _quickActions = const [
    AdminQuickAction(
      icon: Icons.person_add_alt_rounded,
      color: _indigo,
      softColor: Color(0xFFE0E7FF),
      labelEn: 'Add User',
      labelAr: 'إضافة مستخدم',
      route: '/admin/users/add',
    ),
    AdminQuickAction(
      icon: Icons.account_balance_rounded,
      color: _tealDark,
      softColor: Color(0xFFCCFBF1),
      labelEn: 'Add University',
      labelAr: 'إضافة جامعة',
      route: '/admin/universities/add',
    ),
    AdminQuickAction(
      icon: Icons.post_add_rounded,
      color: _amberDark,
      softColor: Color(0xFFFEF3C7),
      labelEn: 'Add Program',
      labelAr: 'إضافة تخصص',
      route: '/admin/programs/add',
    ),
    AdminQuickAction(
      icon: Icons.campaign_rounded,
      color: _purpleDark,
      softColor: Color(0xFFEDE9FE),
      labelEn: 'Announcement',
      labelAr: 'إعلان',
      route: '/admin/notifications',
    ),
    AdminQuickAction(
      icon: Icons.bar_chart_rounded,
      color: Color(0xFF475569),
      softColor: Color(0xFFE2E8F0),
      labelEn: 'Reports',
      labelAr: 'التقارير',
      route: '/admin/reports',
    ),
    AdminQuickAction(
      icon: Icons.settings_rounded,
      color: Color(0xFF64748B),
      softColor: Color(0xFFF1F5F9),
      labelEn: 'Open Settings',
      labelAr: 'فتح الإعدادات',
      route: '/admin/settings',
    ),
  ];

  final List<double> _weeklyRegistrations = const [45, 60, 52, 75, 95, 68, 40];
  static const List<String> _dayLabelsEn = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const List<String> _dayLabelsAr = [
    'إث',
    'ث',
    'أر',
    'خ',
    'ج',
    'س',
    'ح'
  ];

  final List<AdminProduct> _topPrograms = const [
    AdminProduct(
      nameEn: 'Computer Science',
      nameAr: 'علوم الحاسوب',
      sold: 840,
      progress: 0.84,
    ),
    AdminProduct(
      nameEn: 'Data Science & AI',
      nameAr: 'علوم البيانات والذكاء الاصطناعي',
      sold: 620,
      progress: 0.62,
    ),
    AdminProduct(
      nameEn: 'Business Administration',
      nameAr: 'إدارة الأعمال',
      sold: 480,
      progress: 0.48,
    ),
    AdminProduct(
      nameEn: 'Civil Engineering',
      nameAr: 'الهندسة المدنية',
      sold: 310,
      progress: 0.31,
    ),
  ];

  final List<AdminActivity> _activities = const [
    AdminActivity(
      type: AdminActivityType.success,
      boldEn: 'Ahmed',
      boldAr: 'أحمد',
      restEn: ' registered as a new student',
      restAr: ' سجّل حساب طالب جديد',
      timeEn: '2m ago',
      timeAr: 'منذ دقيقتين',
    ),
    AdminActivity(
      type: AdminActivityType.info,
      boldEn: 'Islamic University',
      boldAr: 'الجامعة الإسلامية',
      restEn: ' published a new program',
      restAr: ' أضافت تخصصاً أكاديمياً جديداً',
      timeEn: '15m ago',
      timeAr: 'منذ ١٥ دقيقة',
    ),
    AdminActivity(
      type: AdminActivityType.warning,
      restEn: 'University verification pending review',
      restAr: 'طلب توثيق جامعة بانتظار المراجعة',
      timeEn: '1h ago',
      timeAr: 'منذ ساعة',
    ),
    AdminActivity(
      type: AdminActivityType.success,
      boldEn: 'Sara',
      boldAr: 'سارة',
      restEn: ' completed the academic assessment',
      restAr: ' أكملت التقييم الأكاديمي',
      timeEn: '2h ago',
      timeAr: 'منذ ساعتين',
    ),
    AdminActivity(
      type: AdminActivityType.info,
      restEn: 'Weekly analytics report generated',
      restAr: 'تم إنشاء التقرير التحليلي الأسبوعي',
      timeEn: '3h ago',
      timeAr: 'منذ ٣ ساعات',
    ),
  ];

  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
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

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadAdminData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _hasError = false;
    });

    try {
      final cachedData = await TokenManager.getUserData();
      if (cachedData['name'] != null &&
          (cachedData['name'] as String).isNotEmpty) {
        _adminName = cachedData['name']!;
        _adminEmail = cachedData['email'] ?? '';
      }

      final user = _supabase.currentUser;
      if (user != null) {
        final userData = await _supabase.getUser(user.id);
        if (userData != null) {
          _adminName = userData.displayName;
          _adminEmail = user.email;
        }
      }

      if (mounted) {
        setState(() => _isLoading = false);
        _animationController.forward(from: 0);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUnreadNotifications() async {
    try {
      final likes = await HiveStorage.getData(
        'notifications_cache',
        'notifications',
      );
      if (likes != null && (likes as List).isNotEmpty) {
        final notifications = likes.cast<Map>();
        final unread =
            notifications.where((n) => n['status'] == 'غير مقروء').length;
        if (mounted) setState(() => _unreadNotifications = unread);
      }
    } catch (_) {}
  }

  void _goToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const AdminNotificationsScreen()),
    ).then((_) => _loadUnreadNotifications());
  }

  Future<void> _logout() async {
    await TokenManager.clearAll();
    await _supabase.signOut();
    if (mounted) context.pushReplacement('/login');
  }

  String _initials(String name) {
    final parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    final first = parts.first.substring(0, 1).toUpperCase();
    final second =
        parts.length > 1 ? parts[1].substring(0, 1).toUpperCase() : '';
    return '$first$second';
  }

  String _formattedDate(bool en) {
    const weekdaysEn = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday',
    ];
    const weekdaysAr = [
      'الإثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];
    const monthsEn = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    const monthsAr = [
      'يناير',
      'فبراير',
      'مارس',
      'أبريل',
      'مايو',
      'يونيو',
      'يوليو',
      'أغسطس',
      'سبتمبر',
      'أكتوبر',
      'نوفمبر',
      'ديسمبر',
    ];
    final now = DateTime.now();
    if (en) {
      return '${weekdaysEn[now.weekday - 1]}, ${monthsEn[now.month - 1]} ${now.day}, ${now.year}';
    }
    return '${weekdaysAr[now.weekday - 1]}، ${now.day} ${monthsAr[now.month - 1]} ${now.year}';
  }

  String t(bool en, String enText, String arText) => en ? enText : arText;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final bool en = _isEnglish;

    return Directionality(
      textDirection: en ? TextDirection.ltr : TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        appBar: _buildTopBar(en, c),
        drawer: _buildDrawer(en, c),
        body: _buildBody(en, c),
      ),
    );
  }

  // ── Top bar ──

  PreferredSizeWidget _buildTopBar(bool en, AppColors c) {
    return AppBar(
      toolbarHeight: 64,
      backgroundColor: c.surface.withValues(alpha: 0.9),
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleSpacing: 8,
      leadingWidth: 48,
      leading: Builder(
        builder: (context) => IconButton(
          tooltip: t(en, 'Open menu', 'فتح القائمة'),
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: Icon(Icons.menu_rounded, size: 22, color: c.textPrimary),
        ),
      ),
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_indigo, _indigoDark],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.admin_panel_settings_rounded,
              size: 18,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'NextStep AI',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
      actions: [
        // Search (compact chip that expands on tap — mobile-friendly)
        _buildSearchChip(en, c),
        _buildLangToggle(en, c),
        IconButton(
          tooltip: t(en, 'Toggle dark mode', 'تبديل الوضع الداكن'),
          onPressed: AppTheme.toggleTheme,
          icon: Icon(
            c.isDark ? Icons.light_mode_rounded : Icons.dark_mode_outlined,
            size: 21,
            color: c.textPrimary,
          ),
        ),
        _buildNotifButton(en, c),
        _buildAccountMenu(en, c),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchChip(bool en, AppColors c) {
    return PopupMenuButton<String>(
      tooltip: t(en, 'Search', 'بحث'),
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: c.divider.withValues(alpha: 0.5)),
      ),
      offset: const Offset(0, 52),
      itemBuilder: (_) => [
        PopupMenuItem(
          enabled: false,
          child: SizedBox(
            height: 40,
            child: TextField(
              autofocus: true,
              decoration: InputDecoration(
                isDense: true,
                filled: true,
                fillColor: c.surfaceAlt,
                prefixIcon: Icon(Icons.search_rounded,
                    size: 18, color: c.textSecondary),
                hintText: t(en, 'Search...', 'بحث...'),
                hintStyle: TextStyle(fontSize: 13, color: c.textSecondary),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(999),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
        ),
      ],
      child: Container(
        width: 38,
        height: 38,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: c.surfaceAlt,
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.search_rounded, size: 19, color: c.textSecondary),
      ),
    );
  }

  Widget _buildLangToggle(bool en, AppColors c) {
    return IconButton(
      tooltip: t(en, 'Switch language', 'تغيير اللغة'),
      onPressed: () => setState(() => _isEnglish = !_isEnglish),
      icon: Container(
        padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
        decoration: BoxDecoration(
          color: c.surfaceAlt,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(
          en ? 'ع' : 'EN',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildNotifButton(bool en, AppColors c) {
    return IconButton(
      tooltip: t(en, 'Notifications', 'الإشعارات'),
      onPressed: _goToNotifications,
      icon: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(Icons.notifications_outlined, size: 22, color: c.textPrimary),
          if (_unreadNotifications > 0)
            Positioned(
              top: -3,
              left: null,
              right: _isEnglish ? -4 : null,
              child: Container(
                padding: const EdgeInsets.all(3),
                constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                decoration: const BoxDecoration(
                  color: Color(0xFFBA1A1A),
                  shape: BoxShape.circle,
                ),
                child: Text(
                  _unreadNotifications > 9 ? '9+' : '$_unreadNotifications',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w800,
                    height: 1,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccountMenu(bool en, AppColors c) {
    return PopupMenuButton<String>(
      tooltip: t(en, 'Account menu', 'قائمة الحساب'),
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: c.divider.withValues(alpha: 0.5)),
      ),
      offset: const Offset(0, 48),
      onSelected: (value) {
        if (value == 'profile') {
          context.push('/admin/profile');
        } else if (value == 'settings') {
          context.push('/admin/settings');
        } else if (value == 'logout') {
          _logout();
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'profile',
          height: 42,
          child: Row(children: [
            Icon(Icons.person_outline_rounded,
                size: 18, color: c.textSecondary),
            const SizedBox(width: 10),
            Text(t(en, 'Profile', 'الملف الشخصي'),
                style: TextStyle(fontSize: 13, color: c.textPrimary)),
          ]),
        ),
        PopupMenuItem(
          value: 'settings',
          height: 42,
          child: Row(children: [
            Icon(Icons.settings_outlined, size: 18, color: c.textSecondary),
            const SizedBox(width: 10),
            Text(t(en, 'Settings', 'الإعدادات'),
                style: TextStyle(fontSize: 13, color: c.textPrimary)),
          ]),
        ),
        const PopupMenuDivider(),
        PopupMenuItem(
          value: 'logout',
          height: 42,
          child: Row(children: [
            Icon(Icons.logout_rounded, size: 18, color: c.danger),
            const SizedBox(width: 10),
            Text(t(en, 'Logout', 'تسجيل الخروج'),
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.danger)),
          ]),
        ),
      ],
      child: Container(
        width: 34,
        height: 34,
        margin: const EdgeInsets.symmetric(horizontal: 4),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_indigo, _purple],
          ),
          shape: BoxShape.circle,
        ),
        alignment: Alignment.center,
        child: Text(
          _initials(_adminName),
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w800,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  // ── Drawer ──

  Widget _buildDrawer(bool en, AppColors c) {
    final Widget? notifBadge = _unreadNotifications > 0
        ? Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
            decoration: BoxDecoration(
              color: c.danger,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Text(
              '$_unreadNotifications',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w800,
              ),
            ),
          )
        : null;

    return Drawer(
      width: 280,
      backgroundColor: c.surface,
      child: SafeArea(
        child: Column(
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [_indigoDark, _indigo],
                ),
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(24),
                  bottomRight: Radius.circular(24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          _initials(_adminName),
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          t(en, 'Admin', 'إدارة'),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _adminName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                  if (_adminEmail.isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      _adminEmail,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.75),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                children: [
                  _drawerItem(Icons.dashboard_rounded,
                      t(en, 'Dashboard', 'لوحة التحكم'), '', en, c,
                      active: true),
                  _drawerItem(Icons.group_rounded, t(en, 'Users', 'المستخدمون'),
                      '/admin/users', en, c),
                  _drawerItem(
                      Icons.account_balance_rounded,
                      t(en, 'Universities', 'الجامعات'),
                      '/admin/universities',
                      en,
                      c),
                  _drawerItem(Icons.menu_book_rounded,
                      t(en, 'Programs', 'التخصصات'), '/admin/programs', en, c),
                  _drawerItem(Icons.analytics_rounded,
                      t(en, 'Reports', 'التقارير'), '/admin/reports', en, c),
                  _drawerItem(
                      Icons.memory_rounded,
                      t(en, 'LLM Usage', 'استخدام الذكاء الاصطناعي'),
                      '/admin/llm-usage',
                      en,
                      c),
                  _drawerItem(Icons.notifications_rounded,
                      t(en, 'Notifications', 'الإشعارات'), 'NOTIF', en, c,
                      trailing: notifBadge),
                  _drawerItem(
                      Icons.person_rounded,
                      t(en, 'Profile', 'الملف الشخصي'),
                      '/admin/profile',
                      en,
                      c),
                  _drawerItem(Icons.settings_rounded,
                      t(en, 'Settings', 'الإعدادات'), '/admin/settings', en, c),
                ],
              ),
            ),
            Divider(height: 1, color: c.divider.withValues(alpha: 0.5)),
            _drawerItem(Icons.logout_rounded, t(en, 'Logout', 'تسجيل الخروج'),
                'LOGOUT', en, c,
                danger: true),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _drawerItem(
    IconData icon,
    String label,
    String route,
    bool en,
    AppColors c, {
    bool active = false,
    bool danger = false,
    Widget? trailing,
  }) {
    final Color fg = danger
        ? c.danger
        : active
            ? _indigo
            : c.textSecondary;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Material(
        color: active ? c.primarySoft : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () {
            Navigator.pop(context);
            if (route == 'LOGOUT') {
              _logout();
            } else if (route == 'NOTIF') {
              _goToNotifications();
            } else if (route.isNotEmpty) {
              context.push(route);
            }
          },
          child: Container(
            height: 46,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                if (active) ...[
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      color: _indigo,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 10),
                ],
                Icon(icon, size: 21, color: fg),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      color: fg,
                    ),
                  ),
                ),
                if (trailing != null) trailing,
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Body ──

  Widget _buildBody(bool en, AppColors c) {
    if (_isLoading) return _buildSkeleton(c);
    if (_hasError) return _buildErrorState(en, c);

    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: RefreshIndicator(
          color: _indigo,
          backgroundColor: c.surface,
          onRefresh: _loadAdminData,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics(),
            ),
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page title + Admin badge
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        t(en, 'Admin Panel', 'لوحة الإدارة'),
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: c.textPrimary,
                          letterSpacing: -0.4,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        color: c.primarySoft,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        t(en, 'Admin', 'إدارة'),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: _indigo,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    SampleDataBadge(
                      label: en ? 'Sample data' : 'بيانات تجريبية',
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // 1. Welcome gradient banner
                _buildWelcomeCard(en, c),
                const SizedBox(height: 20),

                // 2. Stats grid (2x2 on mobile, 4-up on desktop)
                _buildStatsGrid(en, c),
                const SizedBox(height: 20),

                // 3. Quick actions
                _buildQuickActions(en, c),
                const SizedBox(height: 20),

                // 4. Sales Overview (weekly bar chart)
                _buildSalesOverview(en, c),
                const SizedBox(height: 20),

                // 5. Top Products
                _buildTopProducts(en, c),
                const SizedBox(height: 20),

                // 6. Recent Activity
                _buildRecentActivity(en, c),
                const SizedBox(height: 24),

                // Footer
                _buildFooter(en, c),
                const SizedBox(height: 64),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── 1. Welcome card ──

  Widget _buildWelcomeCard(bool en, AppColors c) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_indigoDark, _blue, _tealDark],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: _indigoDark.withValues(alpha: 0.28),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          children: [
            // Decorative blur circles
            Positioned(
              right: en ? -24 : null,
              left: en ? null : -24,
              bottom: -24,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Positioned(
              right: en ? 10 : null,
              left: en ? null : 10,
              top: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: _teal.withValues(alpha: 0.25),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            // Decorative sparkline glyph
            Positioned(
              bottom: 4,
              right: en ? 8 : null,
              left: en ? null : 8,
              child: Icon(Icons.trending_up_rounded,
                  size: 90, color: Colors.white.withValues(alpha: 0.12)),
            ),
            // Content
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date badge
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.calendar_today_rounded,
                          size: 14, color: Colors.white),
                      const SizedBox(width: 6),
                      Text(
                        _formattedDate(en),
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  '${t(en, 'Welcome back', 'مرحباً بعودتك')}, $_adminName 👋',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t(
                    en,
                    "Here's the learning platform overview for today.",
                    'إليك نظرة عامة على المنصة التعليمية اليوم.',
                  ),
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
                const SizedBox(height: 14),
                // CTA
                Material(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () => context.push('/admin/reports'),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 11),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            t(en, 'View Full Report', 'عرض التقرير الكامل'),
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: _indigo,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            en
                                ? Icons.arrow_forward_rounded
                                : Icons.arrow_back_rounded,
                            size: 17,
                            color: _indigo,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Sparkline helper ──

  Widget _sparkline(List<double> points, Color color,
      {double width = 64, double height = 20, double strokeWidth = 2.2}) {
    return SizedBox(
      width: width,
      height: height,
      child:
          CustomPaint(painter: _SparklinePainter(points, color, strokeWidth)),
    );
  }

  // ── 2. Stats grid ──

  Widget _buildStatsGrid(bool en, AppColors c) {
    final List<Widget> cards = _stats.map((s) => _statCard(en, c, s)).toList();

    return LayoutBuilder(builder: (context, cons) {
      final bool fourUp = cons.maxWidth >= 900;
      final bool twoUp = cons.maxWidth >= 480;

      if (fourUp) {
        return Row(
          children: [
            for (int i = 0; i < cards.length; i++) ...[
              if (i > 0) const SizedBox(width: 12),
              Expanded(child: cards[i]),
            ],
          ],
        );
      }
      if (twoUp) {
        return Column(
          children: [
            Row(
              children: [
                Expanded(child: cards[0]),
                const SizedBox(width: 12),
                Expanded(child: cards[1]),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(child: cards[2]),
                const SizedBox(width: 12),
                Expanded(child: cards[3]),
              ],
            ),
          ],
        );
      }
      return Column(
        children: [
          for (int i = 0; i < cards.length; i++) ...[
            if (i > 0) const SizedBox(height: 12),
            cards[i],
          ],
        ],
      );
    });
  }

  Widget _statCard(bool en, AppColors c, AdminStat s) {
    final Color deltaFg = s.positive ? const Color(0xFF047857) : _roseDark;
    final Color deltaBg =
        s.positive ? const Color(0xFFD1FAE5) : const Color(0xFFFFE4E6);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.divider.withValues(alpha: 0.35)),
        boxShadow: [
          if (!c.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: s.softColor,
                  shape: BoxShape.circle,
                ),
                child: Icon(s.icon, size: 19, color: s.color),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: deltaBg,
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  s.delta,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: deltaFg,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            en ? s.labelEn : s.labelAr,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            s.value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: Text(
                  en ? s.periodEn : s.periodAr,
                  style: TextStyle(fontSize: 11, color: c.textSecondary),
                ),
              ),
              _sparkline(s.spark, s.color),
            ],
          ),
        ],
      ),
    );
  }

  // ── 3. Quick actions ──

  Widget _buildQuickActions(bool en, AppColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.bolt_rounded, size: 20, color: _indigo),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                t(en, 'Quick Actions', 'إجراءات سريعة'),
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                t(en, 'Actions', 'إجراءات'),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(builder: (context, cons) {
          final int cols = cons.maxWidth >= 720
              ? 3
              : cons.maxWidth >= 420
                  ? 2
                  : 1;

          return Column(
            children: [
              for (int row = 0; row < _quickActions.length / cols; row++)
                Padding(
                  padding: EdgeInsets.only(top: row > 0 ? 10 : 0),
                  child: Row(
                    children: [
                      for (int col = 0; col < cols; col++)
                        Expanded(
                          child: Padding(
                            padding: EdgeInsets.only(
                                left: en ? (col > 0 ? 10.0 : 0) : 0,
                                right: en ? 0 : (col > 0 ? 10.0 : 0)),
                            child: col < _quickActions.length - row * cols
                                ? _quickActionCard(
                                    en,
                                    c,
                                    _quickActions[row * cols + col],
                                  )
                                : const SizedBox(),
                          ),
                        ),
                    ],
                  ),
                ),
            ],
          );
        }),
      ],
    );
  }

  Widget _quickActionCard(bool en, AppColors c, AdminQuickAction action) {
    return Material(
      color: c.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
        side: BorderSide(color: c.divider.withValues(alpha: 0.4)),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => context.push(action.route),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: action.softColor,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(action.icon, size: 18, color: action.color),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  en ? action.labelEn : action.labelAr,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── 4. Sales overview ──

  Widget _buildSalesOverview(bool en, AppColors c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.divider.withValues(alpha: 0.35)),
        boxShadow: [
          if (!c.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t(en, 'Student Registrations', 'تسجيلات الطلاب'),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      t(en, 'Last 7 days registration activity',
                          'نشاط التسجيل خلال آخر ٧ أيام'),
                      style: TextStyle(
                        fontSize: 12,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: _teal.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  t(en, '+14.8% trend', '+14.8% اتجاه'),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: _tealDark,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bar chart
          SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (int i = 0; i < 7; i++) ...[
                  if (i > 0) const SizedBox(width: 6),
                  Expanded(child: _bar(en, c, i)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(bool en, AppColors c, int i) {
    final bool peak = i == 4; // Friday
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Expanded(
          child: Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              width: double.infinity,
              constraints: const BoxConstraints(maxWidth: 24),
              height: _weeklyRegistrations[i] / 100 * 100,
              decoration: BoxDecoration(
                gradient: peak
                    ? const LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [_indigo, _teal],
                      )
                    : null,
                color: peak ? null : _indigo.withValues(alpha: 0.3),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          en ? _dayLabelsEn[i] : _dayLabelsAr[i],
          style: TextStyle(
            fontSize: 11,
            fontWeight: peak ? FontWeight.w800 : FontWeight.w500,
            color: peak ? _indigo : c.textSecondary,
          ),
        ),
      ],
    );
  }

  // ── 5. Top products ──

  Widget _buildTopProducts(bool en, AppColors c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.divider.withValues(alpha: 0.35)),
        boxShadow: [
          if (!c.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.star_rounded, size: 20, color: _tealDark),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  t(en, 'Top Specializations', 'أعلى التخصصات إقبالاً'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
              ),
              Text(
                t(en, 'Interested students', 'طلاب مهتمون'),
                style: TextStyle(fontSize: 11, color: c.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ...List.generate(_topPrograms.length, (i) {
            final p = _topPrograms[i];
            return Padding(
              padding: EdgeInsets.only(top: i > 0 ? 12 : 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          en ? p.nameEn : p.nameAr,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: c.textPrimary,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${p.sold} ${t(en, 'interested', 'مهتم')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: _indigo,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(999),
                    child: LinearProgressIndicator(
                      value: p.progress,
                      minHeight: 7,
                      backgroundColor: c.surfaceAlt,
                      valueColor: const AlwaysStoppedAnimation<Color>(_indigo),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── 6. Recent activity ──

  Color _activityColor(AdminActivityType t) {
    switch (t) {
      case AdminActivityType.success:
        return _green;
      case AdminActivityType.info:
        return _blueInfo;
      case AdminActivityType.warning:
        return _amber;
    }
  }

  Widget _buildRecentActivity(bool en, AppColors c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.divider.withValues(alpha: 0.35)),
        boxShadow: [
          if (!c.isDark)
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 5),
            ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.history_rounded, size: 20, color: _indigo),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  t(en, 'Recent Activity', 'النشاط الأخير'),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
              ),
              InkWell(
                onTap: () => context.push('/admin/users'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    t(en, 'View All', 'عرض الكل'),
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _indigo,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ...List.generate(_activities.length, (i) {
            final a = _activities[i];
            final color = _activityColor(a.type);

            return Container(
              margin: EdgeInsets.only(top: i > 0 ? 8 : 0),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: c.surfaceAlt.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          if (en ? a.boldEn.isNotEmpty : a.boldAr.isNotEmpty)
                            TextSpan(
                              text: en ? a.boldEn : a.boldAr,
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: c.textPrimary,
                              ),
                            ),
                          TextSpan(
                            text: en ? a.restEn : a.restAr,
                            style: TextStyle(color: c.textPrimary),
                          ),
                        ],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.13),
                      borderRadius: BorderRadius.circular(999),
                    ),
                    child: Text(
                      en ? a.timeEn : a.timeAr,
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  // ── Footer ──

  Widget _buildFooter(bool en, AppColors c) {
    return Column(
      children: [
        Divider(height: 1, color: c.divider.withValues(alpha: 0.35)),
        const SizedBox(height: 14),
        Text(
          t(en, '© 2025 NextStep AI. All rights reserved.',
              '© 2025 NextStep AI. جميع الحقوق محفوظة.'),
          style: TextStyle(fontSize: 12, color: c.textSecondary),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            for (int i = 0; i < 3; i++) ...[
              if (i > 0)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: Text('•', style: TextStyle(color: c.divider)),
                ),
              Text(
                ['Docs', 'Support', 'Privacy'][i],
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _indigo,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }

  // ── Error state ──

  Widget _buildErrorState(bool en, AppColors c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: c.dangerSoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.cloud_off_rounded, size: 32, color: c.danger),
            ),
            const SizedBox(height: 16),
            Text(
              t(en, 'Failed to load data', 'تعذّر تحميل البيانات'),
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              t(
                en,
                'Please check your connection and try again.',
                'يرجى التحقق من الاتصال والمحاولة مرة أخرى.',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13, color: c.textSecondary),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _loadAdminData,
              style: FilledButton.styleFrom(
                backgroundColor: _indigo,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: Text(t(en, 'Retry', 'إعادة المحاولة')),
            ),
          ],
        ),
      ),
    );
  }

  // ── Skeleton loading ──

  Widget _buildSkeleton(AppColors c) {
    final bool isDark = c.isDark;

    Widget box(double? w, double h, {double r = 8}) {
      return Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(r),
        ),
      );
    }

    Widget sh(Widget child) {
      return Shimmer.fromColors(
        baseColor: isDark ? const Color(0xFF334155) : const Color(0xFFE4E8F4),
        highlightColor: isDark ? const Color(0xFF475569) : Colors.white,
        child: child,
      );
    }

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          sh(box(180, 24, r: 10)),
          const SizedBox(height: 16),
          sh(box(null, 190, r: 20)),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(child: sh(box(null, 130, r: 18))),
              const SizedBox(width: 12),
              Expanded(child: sh(box(null, 130, r: 18))),
            ],
          ),
          const SizedBox(height: 16),
          sh(box(null, 60, r: 18)),
          const SizedBox(height: 16),
          sh(box(null, 160, r: 18)),
          const SizedBox(height: 16),
          sh(box(null, 190, r: 18)),
          const SizedBox(height: 16),
          sh(box(null, 220, r: 18)),
        ],
      ),
    );
  }
}

/// Simple polyline sparkline painter used in stat cards.
class _SparklinePainter extends CustomPainter {
  final List<double> points;
  final Color color;
  final double strokeWidth;

  _SparklinePainter(this.points, this.color, this.strokeWidth);

  @override
  void paint(Canvas canvas, Size size) {
    if (points.length < 2) return;

    final double maxV =
        points.reduce((a, b) => a > b ? a : b).clamp(0.001, double.infinity);
    final double minV =
        points.reduce((a, b) => a < b ? a : b).clamp(0, double.infinity);
    final double range = (maxV - minV) == 0 ? 1 : (maxV - minV);

    final Path path = Path();
    for (int i = 0; i < points.length; i++) {
      final double x = i / (points.length - 1) * size.width;
      final double y =
          size.height - ((points[i] - minV) / range) * (size.height - 3) - 1.5;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }

    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _SparklinePainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.points != points;
}
