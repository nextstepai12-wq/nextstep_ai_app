import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/helpers/token_manager.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isLoading = true;

  // Notification switches
  bool _recommendations = true;
  bool _assessmentDeadlines = true;
  bool _hapticSound = false;

  // Theme: 0 = light, 1 = dark, 2 = auto
  int _themeMode = 0;

  String _userName = '';
  String _userEmail = '';

  String _selectedLanguage = 'العربية';

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (!mounted) return;
    try {
      final data = await TokenManager.getUserData();
      if (mounted) {
        setState(() {
          _userName = data['name'] ?? '';
          _userEmail = data['email'] ?? '';
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _logout() async {
    await TokenManager.clearAll();
    if (mounted) {
      context.go('/login');
    }
  }

  void _showLogoutDialog() {
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 32, offset: const Offset(0, 12))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: c.danger.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(Icons.warning_amber_rounded, color: c.danger, size: 28),
            ),
            const SizedBox(height: 14),
            Text('هل أنت متأكد من تسجيل الخروج؟', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary)),
            const SizedBox(height: 6),
            Text(
              'سيتم حفظ كافة نتائجك وتوصياتك الأكاديمية تلقائياً في السحابة لتبقى آمنة.',
              style: TextStyle(fontSize: 13, color: c.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: c.surfaceAlt,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text('إلغاء الأمر', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      Navigator.pop(ctx);
                      _logout();
                    },
                    child: Container(
                      height: 48,
                      decoration: BoxDecoration(
                        color: c.danger,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Center(
                        child: Text('نعم، تسجيل الخروج', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white)),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker() {
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final languages = [
      {'name': 'العربية', 'flag': '🇸🇦', 'code': 'ar'},
      {'name': 'English', 'flag': '🇺🇸', 'code': 'en'},
      {'name': 'Français', 'flag': '🇫🇷', 'code': 'fr'},
      {'name': 'Türkçe', 'flag': '🇹🇷', 'code': 'tr'},
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        margin: const EdgeInsets.all(20),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 32, offset: const Offset(0, 12))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('اختر اللغة', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: c.textPrimary)),
            const SizedBox(height: 16),
            ...languages.map((lang) {
              final isSelected = lang['name'] == _selectedLanguage;
              return GestureDetector(
                onTap: () {
                  setState(() => _selectedLanguage = lang['name']!);
                  Navigator.pop(ctx);
                },
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                  decoration: BoxDecoration(
                    color: isSelected ? c.primary.withValues(alpha: 0.08) : Colors.transparent,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? c.primary.withValues(alpha: 0.3) : c.divider,
                      width: 1.2,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(lang['flag']!, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: 12),
                      Text(lang['name']!, style: TextStyle(fontSize: 15, fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500, color: c.textPrimary)),
                      const Spacer(),
                      if (isSelected) Icon(Icons.check_circle_rounded, color: c.primary, size: 22),
                    ],
                  ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final initials = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'ط';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        body: _isLoading
            ? Center(child: CircularProgressIndicator(color: c.primary))
            : CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildTopBar(c)),
                  SliverToBoxAdapter(child: _buildProfileCard(c, initials)),
                  SliverToBoxAdapter(child: _buildNotificationsSection(c)),
                  SliverToBoxAdapter(child: _buildAppearanceSection(c)),
                  SliverToBoxAdapter(child: _buildSupportSection(c)),
                  SliverToBoxAdapter(child: _buildPrivacySection(c)),
                  SliverToBoxAdapter(child: _buildLogoutButton(c)),
                  SliverToBoxAdapter(child: _buildFooter(c)),
                  const SliverToBoxAdapter(child: SizedBox(height: 40)),
                ],
              ),
      ),
    );
  }

  // ─── Top Bar ─────────────────────────────────────────────────────────

  Widget _buildTopBar(AppColors c) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 12, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: c.surface,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: c.primary.withValues(alpha: 0.08),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(Icons.arrow_back_ios_new_rounded, color: c.textPrimary, size: 20),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'الإعدادات',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: c.textPrimary),
            ),
          ),
          
        ],
      ),
    );
  }

  // ─── Profile Card ────────────────────────────────────────────────────

  Widget _buildProfileCard(AppColors c, String initials) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 0),
      child: GestureDetector(
        onTap: () => context.push('/student/profile'),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.06), blurRadius: 16, offset: const Offset(0, 4))],
          ),
          child: Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [c.primary, c.primaryContainer],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(initials, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(_userName.isNotEmpty ? _userName : 'طالب', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary)),
                        const SizedBox(width: 4),
                        Icon(Icons.verified_rounded, color: c.primary, size: 18),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(_userEmail, style: TextStyle(fontSize: 12, color: c.textSecondary)),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: c.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.cloud_done_rounded, color: c.primary, size: 14),
                    const SizedBox(width: 4),
                    Text('متزامن', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.primary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Notifications Section ───────────────────────────────────────────

  Widget _buildNotificationsSection(AppColors c) {
    return _section(
      c,
      title: 'التنبيهات والإشعارات',
      icon: Icons.notifications_active_rounded,
      iconColor: c.primary,
      children: [
        _switchTile(c, Icons.auto_awesome_rounded, 'إشعارات التوصيات الأكاديمية', 'تنبيهات فورية بالمسارات والجامعات المتوافقة', _recommendations, (v) => setState(() => _recommendations = v)),
        _switchTile(c, Icons.schedule_rounded, 'تذكير مواعيد التقييم والمحاور', 'إشعارات لإكمال اختبارات الميول وتحليل القدرات', _assessmentDeadlines, (v) => setState(() => _assessmentDeadlines = v)),
        _switchTile(c, Icons.vibration_rounded, 'المؤثرات الصوتية والاهتزاز التفاعلي', 'استجابة لمسية ذكية عند تحقيق الإنجازات', _hapticSound, (v) => setState(() => _hapticSound = v)),
      ],
    );
  }

  // ─── Appearance Section ──────────────────────────────────────────────

  Widget _buildAppearanceSection(AppColors c) {
    return _section(
      c,
      title: 'المظهر والعرض',
      icon: Icons.palette_rounded,
      iconColor: c.primaryContainer,
      children: [
        // Theme segmented control
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('نمط العرض / الوضع', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textPrimary)),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: c.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  children: [
                    _themeSegment(c, 0, Icons.light_mode_rounded, 'فاتح'),
                    _themeSegment(c, 1, Icons.dark_mode_rounded, 'داكن'),
                    _themeSegment(c, 2, Icons.settings_brightness_rounded, 'تلقائي'),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        // Language
        _navTile(c, Icons.translate_rounded, 'لغة AppRoutingModule', 'واجهة التوجيه ونصوص الذكاء الاصطناعي', () => _showLanguagePicker(), trailing: _selectedLanguage),
      ],
    );
  }

  Widget _themeSegment(AppColors c, int index, IconData icon, String label) {
    final isActive = _themeMode == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _themeMode = index),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? c.surface : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isActive ? [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 4)] : [],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: isActive ? c.primary : c.textSecondary, size: 18),
              const SizedBox(width: 6),
              Text(label, style: TextStyle(fontSize: 13, fontWeight: isActive ? FontWeight.w700 : FontWeight.w500, color: isActive ? c.primary : c.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Support Section ─────────────────────────────────────────────────

  Widget _buildSupportSection(AppColors c) {
    return _section(
      c,
      title: 'الدعم والمساعدة',
      icon: Icons.help_center_rounded,
      iconColor: const Color(0xFF00414D),
      children: [
        _navTile(c, Icons.quiz_rounded, 'مركز المساعدة والأسئلة الشائعة', 'إجابات استفسارات القبول والتقييم الذكي', () => context.push('/student/help-center')),
        _navTile(c, Icons.support_agent_rounded, 'تواصل مع فريق التوجيه الأكاديمي', 'استشارات متقدمة مع مستشارين معتمدين', () => context.push('/student/contact-us')),
        _navTile(c, Icons.star_rounded, 'قيّم تجربة NextStep AI', 'رأيك يساعدنا في تحسين دقة محرك التوصيات', () => context.push('/student/rate-app')),
        _navTile(c, Icons.ios_share_rounded, 'مشاركة التطبيق مع زملائك الطلاب', 'ساهم في مساعدة أصدقائك باكتشاف شغفهم', () => context.push('/student/share-app')),
      ],
    );
  }

  // ─── Privacy Section ─────────────────────────────────────────────────

  Widget _buildPrivacySection(AppColors c) {
    return _section(
      c,
      title: 'الخصوصية والأمان',
      icon: Icons.security_rounded,
      iconColor: c.textSecondary,
      children: [
        _navTile(c, Icons.shield_rounded, 'سياسة الخصوصية وحماية بيانات الطالب', 'بيانات تقييماتك مشفرة ولا تتم مشاركتها خارجياً', () => context.push('/student/privacy-policy')),
        _navTile(c, Icons.description_rounded, 'شروط الاستخدام والخدمة', 'المعايير المعتمدة في الإرشاد الطلابي والذكاء الاصطناعي', () => context.push('/student/terms-conditions')),
      ],
    );
  }

  // ─── Logout Button ───────────────────────────────────────────────────

  Widget _buildLogoutButton(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GestureDetector(
        onTap: _showLogoutDialog,
        child: Container(
          height: 52,
          decoration: BoxDecoration(
            color: c.danger.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded, color: c.danger, size: 22),
              const SizedBox(width: 8),
              Text('تسجيل الخروج', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.danger)),
            ],
          ),
        ),
      ),
    );
  }

  // ─── Footer ──────────────────────────────────────────────────────────

  Widget _buildFooter(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 32, 20, 0),
      child: Column(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(color: c.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(10)),
            child: Icon(Icons.explore_rounded, color: c.primary, size: 22),
          ),
          const SizedBox(height: 8),
          Text('NextStep AI • الإصدار 1.0.0', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: c.textSecondary)),
          const SizedBox(height: 2),
          Text('بنية الذكاء الاصطناعي الأكاديمي والمهني الحديثة', style: TextStyle(fontSize: 11, color: c.textSecondary.withValues(alpha: 0.7))),
        ],
      ),
    );
  }

  // ─── Shared Section Builder ──────────────────────────────────────────

  Widget _section(AppColors c, {required String title, required IconData icon, required Color iconColor, required List<Widget> children}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(color: iconColor.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(8)),
                child: Icon(icon, color: iconColor, size: 18),
              ),
              const SizedBox(width: 8),
              Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.04), blurRadius: 16, offset: const Offset(0, 4))],
            ),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  // ─── Shared Switch Tile ──────────────────────────────────────────────

  Widget _switchTile(AppColors c, IconData icon, String title, String subtitle, bool value, ValueChanged<bool> onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: c.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: c.primary, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textPrimary)),
                const SizedBox(height: 2),
                Text(subtitle, style: TextStyle(fontSize: 11, color: c.textSecondary)),
              ],
            ),
          ),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 28,
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                color: value ? c.primary : c.surfaceAlt,
                borderRadius: BorderRadius.circular(14),
              ),
              child: AnimatedAlign(
                duration: const Duration(milliseconds: 200),
                alignment: value ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Shared Nav Tile ─────────────────────────────────────────────────

  Widget _navTile(AppColors c, IconData icon, String title, String subtitle, VoidCallback onTap, {String? trailing}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: c.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: BorderRadius.circular(10)),
              child: Icon(icon, color: c.primary, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: c.textPrimary)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: TextStyle(fontSize: 11, color: c.textSecondary)),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: c.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(8)),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(trailing, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.primary)),
                    const SizedBox(width: 4),
                    Icon(Icons.arrow_forward_ios_rounded, color: c.primary, size: 12),
                  ],
                ),
              ),
            ] else ...[
              const SizedBox(width: 8),
              Icon(Icons.arrow_forward_ios_rounded, color: c.textSecondary, size: 14),
            ],
          ],
        ),
      ),
    );
  }
}
