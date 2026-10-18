
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/features/student/ui/screens/student_main_screen.dart';
import 'package:nextstep_ai_app/core/helpers/token_manager.dart';

class StudentHomeScreen extends StatefulWidget {
  const StudentHomeScreen({super.key});

  @override
  State<StudentHomeScreen> createState() => _StudentHomeScreenState();
}

class _StudentHomeScreenState extends State<StudentHomeScreen>
    with TickerProviderStateMixin {
  String _userName = 'طالب';
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;
  String? _errorMessage;

  late AnimationController _staggerController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  static const int _itemCount = 7;

  @override
  void initState() {
    super.initState();
    _initStaggeredAnimations();
    _loadUserData();
  }

  void _initStaggeredAnimations() {
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _fadeAnimations = [];
    _slideAnimations = [];
    for (int i = 0; i < _itemCount; i++) {
      final start = (i * 0.08).clamp(0.0, 1.0);
      final end = (start + 0.4).clamp(0.0, 1.0);
      _fadeAnimations.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
      );
      _slideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0, 0.15),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );
    }
    _staggerController.forward();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _changeTab(int index) {
    StudentMainScreen.tabNotifier.value = index;
  }

  Future<void> _loadUserData() async {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final cachedData = await TokenManager.getUserData();
      if (mounted) {
        setState(() {
          _userName = cachedData['name'] ?? 'طالب';
          _profileData = {
            'student_type': 'tawjihi',
            'high_school_score': 96.4,
          };
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = 'تعذّر تحميل البيانات');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        extendBodyBehindAppBar: true,
        body: _isLoading
            ? _buildSkeleton(c)
            : _errorMessage != null
                ? _buildErrorState(c)
                : _buildContent(c),
      ),
    );
  }

  // ─── Skeleton Loading ─────────────────────────────────────────────────────

  Widget _buildSkeleton(AppColors c) {
    return Stack(
      children: [
        _buildGradientBg(c),
        SafeArea(
          child: Column(
            children: [
              _buildShimmerHeader(c),
              Expanded(
                child: SingleChildScrollView(
                  physics: const NeverScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  child: Column(
                    children: List.generate(
                      5,
                      (_) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: _shimmerBox(c, height: 80, radius: 20),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _shimmerBox(AppColors c, {double height = 80, double radius = 20}) {
    return Container(
      height: height,
      decoration: BoxDecoration(
        color: c.surfaceAlt.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  Widget _buildShimmerHeader(AppColors c) {
    return Container(
      height: 140,
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            c.primary.withValues(alpha: 0.15),
            c.primaryContainer.withValues(alpha: 0.08),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
    );
  }

  // ─── Gradient Background ──────────────────────────────────────────────────

  Widget _buildGradientBg(AppColors c) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 220,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              c.primarySoft.withValues(alpha: 0.45),
              c.surfaceAlt.withValues(alpha: 0.2),
              c.background,
            ],
          ),
        ),
      ),
    );
  }

  // ─── Error State ──────────────────────────────────────────────────────────

  Widget _buildErrorState(AppColors c) {
    return Stack(
      children: [
        _buildGradientBg(c),
        Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.error_outline_rounded, size: 56, color: c.textSecondary),
                const SizedBox(height: 16),
                Text(
                  _errorMessage!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: c.textSecondary, fontSize: 14),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: _loadUserData,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('إعادة المحاولة'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: c.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ─── Main Content ─────────────────────────────────────────────────────────

  Widget _buildContent(AppColors c) {
    return Stack(
      children: [
        _buildGradientBg(c),
        SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _animatedItem(0, _buildAppBar(c)),
                      const SizedBox(height: 8),
                      _animatedItem(1, _buildWelcomeSection(c)),
                      const SizedBox(height: 16),
                      _animatedItem(2, _buildSearchBar(c)),
                      const SizedBox(height: 16),
                      _animatedItem(3, _buildProgressCard(c)),
                      const SizedBox(height: 16),
                      _animatedItem(4, _buildStatsSection(c)),
                      const SizedBox(height: 24),
                      _animatedItem(5, _buildQuickServices(c)),
                      const SizedBox(height: 24),
                      _animatedItem(6, _buildRecommendations(c)),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 88,
          left: 16,
          child: _buildFAB(c),
        ),
      ],
    );
  }

  Widget _animatedItem(int index, Widget child) {
    if (index >= _fadeAnimations.length) return child;
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  // ─── AppBar ───────────────────────────────────────────────────────────────

  Widget _buildAppBar(AppColors c) {
    return Row(
      children: [
        _iconButton(
          c: c,
          icon: Icons.menu_rounded,
          onTap: () => Scaffold.of(context).openDrawer(),
        ),
        const SizedBox(width: 8),
        _iconButton(
          c: c,
          icon: Icons.notifications_outlined,
          badge: '3',
          onTap: () => context.push('/student/notifications'),
        ),
        const Spacer(),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: c.primary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.school_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 6),
              Text(
                'NextStep AI',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _iconButton({
    required AppColors c,
    required IconData icon,
    String? badge,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: c.surface.withValues(alpha: 0.8),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, color: c.primary, size: 22),
            if (badge != null)
              Positioned(
                top: 6,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Color(0xFFBA1A1A),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    badge,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      height: 1,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ─── Welcome Section ──────────────────────────────────────────────────────

  Widget _buildWelcomeSection(AppColors c) {
    final studentType = _profileData?['student_type'] == 'university'
        ? 'طالب جامعي'
        : 'طالب توجيهي';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        'مرحباً بك',
                        style: TextStyle(
                          fontSize: 14,
                          color: c.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Text('👋', style: TextStyle(fontSize: 18)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          _userName,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: c.primary,
                            letterSpacing: -0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          color: c.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.verified, color: c.primary, size: 12),
                            const SizedBox(width: 3),
                            Text(
                              studentType,
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: c.primary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'اكتشف التخصص الأنسب لشغفك ومستقبلك الأكاديمي 🚀',
                    style: TextStyle(
                      fontSize: 13,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [c.primary, c.primaryContainer],
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: c.primary.withValues(alpha: 0.2),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Icon(
                    Icons.stairs_rounded,
                    color: Colors.white,
                    size: 24,
                  ),
                  Positioned(
                    top: 4,
                    right: 4,
                    child: Icon(
                      Icons.star,
                      color: c.accent,
                      size: 10,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Search Bar ───────────────────────────────────────────────────────────

  Widget _buildSearchBar(AppColors c) {
    return GestureDetector(
      onTap: () => _changeTab(3),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: c.surface.withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.auto_awesome, color: c.primary, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                'اسأل NextStep AI عن أي تخصص أو مهارة...',
                style: TextStyle(fontSize: 13, color: c.textSecondary),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(
                      color: c.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'مستعد',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: c.primary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Progress Reminder Card ───────────────────────────────────────────────

  Widget _buildProgressCard(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
          colors: [c.primary, c.primaryContainer, c.purple],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            left: -20,
            bottom: -20,
            width: 100,
            height: 100,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            right: 0,
            top: 0,
            width: 80,
            height: 80,
            child: Container(
              decoration: BoxDecoration(
                color: c.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.flag_rounded, color: Colors.white, size: 12),
                        SizedBox(width: 4),
                        Text(
                          'محور المهارات التحليلية',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    'باقي خطوة واحدة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              const Text(
                'استكمل تقييم الميول الأكاديمي 🎯',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                'أنهِ المحور الأخير لتحصل على دقة مطابقة 100% مع التخصصات الجامعية الواعدة وسوق العمل.',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.8),
                  fontSize: 13,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => _changeTab(1),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: c.surface.withValues(alpha: 0.95),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'متابعة التقييم الآن',
                            style: TextStyle(
                              color: c.primary,
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            color: c.primary,
                            size: 14,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Spacer(),
                  const Text(
                    '3 من 4 مكتملة',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ─── Stats Section ────────────────────────────────────────────────────────

  Widget _buildStatsSection(AppColors c) {
    return Row(
      children: [
        Expanded(
          child: _statCard(
            c: c,
            icon: Icons.school_rounded,
            iconBg: c.primarySoft,
            iconColor: c.primary,
            value: '${_profileData?['high_school_score'] ?? '--'}%',
            label: 'المعدل التراكمي',
            badge: 'مرتفع',
            badgeColor: c.success,
            badgeBg: c.successSoft,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            c: c,
            icon: Icons.insights_rounded,
            iconBg: c.surfaceAlt,
            iconColor: c.purple,
            value: '78%',
            label: 'اكتمال التقييم',
            progress: 0.78,
            progressColor: c.purple,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _statCard(
            c: c,
            icon: Icons.auto_graph_rounded,
            iconBg: c.primarySoft,
            iconColor: c.primary,
            value: '12',
            label: 'تخصص ملائم',
            dot: c.purple,
          ),
        ),
      ],
    );
  }

  Widget _statCard({
    required AppColors c,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String value,
    required String label,
    String? badge,
    Color? badgeColor,
    Color? badgeBg,
    double? progress,
    Color? progressColor,
    Color? dot,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const Spacer(),
              if (badge != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: badgeBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      fontSize: 9,
                      fontWeight: FontWeight.w700,
                      color: badgeColor,
                    ),
                  ),
                )
              else if (progress != null)
                _miniProgress(progress, progressColor ?? c.purple, c)
              else if (dot != null)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: dot,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
              letterSpacing: -0.3,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _miniProgress(double value, Color color, AppColors c) {
    return SizedBox(
      width: 22,
      height: 22,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: 1.0,
            strokeWidth: 3,
            color: c.surfaceAlt,
            strokeCap: StrokeCap.round,
          ),
          CircularProgressIndicator(
            value: value,
            strokeWidth: 3,
            color: color,
            strokeCap: StrokeCap.round,
          ),
        ],
      ),
    );
  }

  // ─── Quick Services ───────────────────────────────────────────────────────

  Widget _buildQuickServices(AppColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'الخدمات السريعة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'أدوات التوجيه الذكية المدعومة بالذكاء الاصطناعي',
                    style: TextStyle(
                      fontSize: 11,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '4 خدمات',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: c.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        Row(
          children: [
            Expanded(
              child: _serviceCard(
                c: c,
                icon: Icons.psychology_rounded,
                gradient: [c.primarySoft, c.surfaceAlt],
                iconColor: c.primary,
                title: 'التقييم الذكي',
                subtitle: 'تحليل الميول والقدرات عبر 40 سؤالاً ذكياً',
                badge: 'نشط الآن',
                badgeColor: c.primary,
                badgeBg: c.primarySoft,
                onTap: () => _changeTab(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _serviceCard(
                c: c,
                icon: Icons.dashboard_customize_rounded,
                gradient: [c.successSoft, c.surfaceAlt],
                iconColor: c.success,
                title: 'التوصيات الأكاديمية',
                subtitle: 'استكشف الجامعات والمسارات المطابقة لمعدلك',
                dotColor: c.success,
                onTap: () => _changeTab(2),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _serviceCard(
                c: c,
                icon: Icons.smart_toy_rounded,
                gradient: [c.surfaceAlt, c.surface],
                iconColor: c.purple,
                title: 'المستشار الفوري',
                subtitle: 'محادثة تفاعلية فورية لإجابة استفساراتك',
                badge: 'مستشار 24/7',
                badgeColor: c.purple,
                badgeBg: c.surfaceAlt,
                onTap: () => _changeTab(3),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _serviceCard(
                c: c,
                icon: Icons.badge_rounded,
                gradient: [c.purpleSoft, c.surfaceAlt],
                iconColor: c.primary,
                title: 'الملف الأكاديمي',
                subtitle: 'سجل المهارات والشهادات والنتائج',
                trailingIcon: Icons.verified_user_rounded,
                trailingColor: c.textSecondary,
                onTap: () => _changeTab(3),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _serviceCard({
    required AppColors c,
    required IconData icon,
    required List<Color> gradient,
    required Color iconColor,
    required String title,
    required String subtitle,
    String? badge,
    Color? badgeColor,
    Color? badgeBg,
    Color? dotColor,
    IconData? trailingIcon,
    Color? trailingColor,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.04),
              blurRadius: 20,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: gradient,
                    ),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const Spacer(),
                if (badge != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontSize: 9,
                        fontWeight: FontWeight.w700,
                        color: badgeColor,
                      ),
                    ),
                  )
                else if (dotColor != null)
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: dotColor,
                      shape: BoxShape.circle,
                    ),
                  )
                else if (trailingIcon != null)
                  Icon(trailingIcon, color: trailingColor, size: 18),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 11,
                color: c.textSecondary,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Recommendations ──────────────────────────────────────────────────────

  Widget _buildRecommendations(AppColors c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'توصيات مقترحة لك',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.arrow_back_ios_new_rounded, color: c.primary, size: 18),
            const Spacer(),
            GestureDetector(
              onTap: () => _changeTab(2),
              child: Text(
                'عرض الكل',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.primary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        _recommendationItem(
          c: c,
          icon: Icons.memory_rounded,
          iconBg: c.surfaceAlt,
          iconColor: c.primary,
          title: 'هندسة الذكاء الاصطناعي',
          subtitle: 'كلية علوم الحاسب والمعلومات',
          matchPercent: 98,
          badgeText: '🔥 عالي الطلب في سوق العمل',
          badgeColor: c.primary,
          badgeBg: c.primarySoft,
          tags: ['4 سنوات', 'جامعة الملك سعود'],
          tagIcons: [Icons.schedule_rounded, Icons.location_on_rounded],
        ),
        const SizedBox(height: 12),
        _recommendationItem(
          c: c,
          icon: Icons.shield_rounded,
          iconBg: c.surfaceAlt,
          iconColor: c.purple,
          title: 'الأمن السيبراني والشبكات',
          subtitle: 'كلية تقنية المعلومات',
          matchPercent: 94,
          badgeText: '🛡️ مسار مستقبلي واعد',
          badgeColor: c.purple,
          badgeBg: c.surfaceAlt,
          tags: ['4 سنوات', 'جامعة الملك عبدالعزيز'],
          tagIcons: [Icons.schedule_rounded, Icons.location_on_rounded],
        ),
        const SizedBox(height: 12),
        _recommendationItem(
          c: c,
          icon: Icons.query_stats_rounded,
          iconBg: c.surfaceAlt,
          iconColor: c.success,
          title: 'علم البيانات وتحليل النظم',
          subtitle: 'كلية العلوم وهندسة الحاسب',
          matchPercent: 89,
          badgeText: '📈 متزايد في قطاع الأعمال',
          badgeColor: c.success,
          badgeBg: c.successSoft,
          tags: ['4 سنوات'],
          tagIcons: [Icons.schedule_rounded],
        ),
      ],
    );
  }

  Widget _recommendationItem({
    required AppColors c,
    required IconData icon,
    required Color iconBg,
    required Color iconColor,
    required String title,
    required String subtitle,
    required int matchPercent,
    required String badgeText,
    required Color badgeColor,
    required Color badgeBg,
    required List<String> tags,
    required List<IconData> tagIcons,
  }) {
    return GestureDetector(
      onTap: () => context.push('/student/recommendations'),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.06),
              blurRadius: 24,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: iconColor, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                _matchBadge(c: c, percent: matchPercent, color: iconColor),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _tag(c: c, text: badgeText, color: badgeColor, bg: badgeBg),
                for (int i = 0; i < tags.length; i++)
                  _tag(
                    c: c,
                    text: tags[i],
                    color: c.textSecondary,
                    bg: c.surfaceAlt,
                    icon: tagIcons[i],
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _matchBadge({
    required AppColors c,
    required int percent,
    required Color color,
  }) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$percent%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          Text(
            'توافق',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _tag({
    required AppColors c,
    required String text,
    required Color color,
    required Color bg,
    IconData? icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 12, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            text,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // ─── FAB ──────────────────────────────────────────────────────────────────

  Widget _buildFAB(AppColors c) {
    return GestureDetector(
      onTap: () => _changeTab(1),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c.primary, c.primaryContainer, c.purple],
          ),
          borderRadius: BorderRadius.circular(28),
          boxShadow: [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.4),
              blurRadius: 28,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.psychology_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              'ابدأ التقييم الذكي',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
