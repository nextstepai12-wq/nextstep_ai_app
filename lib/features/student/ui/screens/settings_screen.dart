import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/networking/supabase_service.dart';
import 'package:nextstep_ai_app/core/helpers/token_manager.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseService _supabase = SupabaseService();

  // إعدادات التطبيق
  bool _isLoading = true;
  bool _isDarkMode = false;
  bool _notifications = true;
  bool _soundEnabled = true;
  bool _autoSave = true;
  bool _locationServices = false;
  bool _dataSaver = false;

  // اللغة
  String _selectedLanguage = 'ar';
  final Map<String, String> _languages = {
    'ar': 'العربية',
    'en': 'English',
    'fr': 'Français',
    'tr': 'Türkçe',
  };

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
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
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: تحميل الإعدادات من SharedPreferences
      await Future.delayed(const Duration(milliseconds: 500));

      if (mounted) {
        setState(() {
          _isLoading = false;
          _animationController.forward();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _logout() async {
    await TokenManager.clearAll();
    await _supabase.signOut();
    if (mounted) {
      context.pushReplacement('/login');
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('تسجيل الخروج'),
        content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('تسجيل الخروج'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('اختر اللغة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: _languages.entries.map((entry) {
            return RadioListTile<String>(
              title: Text(entry.value),
              value: entry.key,
              groupValue: _selectedLanguage,
              onChanged: (value) {
                setState(() {
                  _selectedLanguage = value!;
                });
                Navigator.pop(context);
                _showSnackBar('تم تغيير اللغة إلى ${entry.value}');
              },
              activeColor: AppTheme.primary,
            );
          }).toList(),
        ),
      ),
    );
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor:
              isSuccess ? const Color(0xFF22C55E) : const Color(0xFFDC2626),
          content: Row(
            children: [
              Icon(
                isSuccess
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
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
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      children: [
                        _buildProfileCard(),
                        const SizedBox(height: 20),
                        _buildPreferencesSection(),
                        const SizedBox(height: 20),
                        _buildAppearanceSection(),
                        const SizedBox(height: 20),
                        _buildPrivacySection(),
                        const SizedBox(height: 20),
                        _buildSupportSection(),
                        const SizedBox(height: 20),
                        _buildAboutSection(),
                        const SizedBox(height: 20),
                        _buildLogoutButton(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // ============================================================
  //  AppBar
  // ============================================================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'الإعدادات',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryContainer,
        ),
      ),
      centerTitle: true,
      leading: const SizedBox.shrink(),
    );
  }

  // ============================================================
  //  Profile Card
  // ============================================================
  Widget _buildProfileCard() {
    return InkWell(
      onTap: () => context.push('/profile'),
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
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primary, AppTheme.primaryContainer],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Center(
                child:
                    Icon(Icons.person_rounded, size: 28, color: Colors.white),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'أحمد الحايك',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryContainer,
                    ),
                  ),
                  const Text(
                    'ahmed@nextstep.ai',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios_rounded,
              size: 18,
              color: Colors.grey.shade400,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  Preferences Section
  // ============================================================
  Widget _buildPreferencesSection() {
    return _buildSection(
      title: 'التفضيلات',
      icon: Icons.tune_rounded,
      color: const Color(0xFF3B82F6),
      children: [
        _buildSwitchTile(
          icon: Icons.notifications_rounded,
          title: 'الإشعارات',
          subtitle: 'تلقي إشعارات التوصيات والتحديثات',
          value: _notifications,
          onChanged: (value) {
            setState(() {
              _notifications = value;
            });
            _showSnackBar(value ? 'تم تفعيل الإشعارات' : 'تم إيقاف الإشعارات');
          },
        ),
        _buildSwitchTile(
          icon: Icons.volume_up_rounded,
          title: 'الأصوات',
          subtitle: 'تشغيل الأصوات في التطبيق',
          value: _soundEnabled,
          onChanged: (value) {
            setState(() {
              _soundEnabled = value;
            });
          },
        ),
        _buildSwitchTile(
          icon: Icons.save_rounded,
          title: 'الحفظ التلقائي',
          subtitle: 'حفظ البيانات تلقائياً عند التعديل',
          value: _autoSave,
          onChanged: (value) {
            setState(() {
              _autoSave = value;
            });
          },
        ),
        _buildSwitchTile(
          icon: Icons.data_usage_rounded,
          title: 'توفير البيانات',
          subtitle: 'تقليل استخدام البيانات أثناء التصفح',
          value: _dataSaver,
          onChanged: (value) {
            setState(() {
              _dataSaver = value;
            });
          },
        ),
      ],
    );
  }

  // ============================================================
  //  Appearance Section
  // ============================================================
  Widget _buildAppearanceSection() {
    return _buildSection(
      title: 'المظهر',
      icon: Icons.palette_rounded,
      color: const Color(0xFF8B5CF6),
      children: [
        _buildSwitchTile(
          icon: Icons.dark_mode_rounded,
          title: 'الوضع الليلي',
          subtitle: 'تفعيل الألوان الداكنة في التطبيق',
          value: _isDarkMode,
          onChanged: (value) {
            setState(() {
              _isDarkMode = value;
            });
            _showSnackBar(
                value ? 'تم تفعيل الوضع الليلي' : 'تم إيقاف الوضع الليلي');
          },
        ),
        _buildLanguageTile(),
        _buildThemeTile(),
      ],
    );
  }

  // ============================================================
  //  Privacy Section
  // ============================================================
  Widget _buildPrivacySection() {
    return _buildSection(
      title: 'الخصوصية والأمان',
      icon: Icons.security_rounded,
      color: const Color(0xFF22C55E),
      children: [
        _buildSwitchTile(
          icon: Icons.location_on_rounded,
          title: 'خدمات الموقع',
          subtitle: 'السماح للتطبيق بالوصول إلى موقعك',
          value: _locationServices,
          onChanged: (value) {
            setState(() {
              _locationServices = value;
            });
          },
        ),
        _buildNavigateTile(
          icon: Icons.privacy_tip_rounded,
          title: 'سياسة الخصوصية',
          subtitle: 'كيف نتعامل مع بياناتك',
          onTap: () => context.push('/privacy-policy'),
        ),
        _buildNavigateTile(
          icon: Icons.description_rounded,
          title: 'الشروط والأحكام',
          subtitle: 'اتفاقية استخدام التطبيق',
          onTap: () => context.push('/terms-conditions'),
        ),
        _buildNavigateTile(
          icon: Icons.cookie_rounded,
          title: 'سياسة ملفات تعريف الارتباط',
          subtitle: 'كيف نستخدم ملفات الكوكيز',
          onTap: () => context.push('/cookies-policy'),
        ),
      ],
    );
  }

  // ============================================================
  //  Support Section
  // ============================================================
  Widget _buildSupportSection() {
    return _buildSection(
      title: 'الدعم والمساعدة',
      icon: Icons.support_agent_rounded,
      color: const Color(0xFFF97316),
      children: [
        _buildNavigateTile(
          icon: Icons.help_center_rounded,
          title: 'مركز المساعدة',
          subtitle: 'الأسئلة الشائعة والإرشادات',
          onTap: () => context.push('/help-center'),
        ),
        _buildNavigateTile(
          icon: Icons.email_rounded,
          title: 'تواصل معنا',
          subtitle: 'nextstepai12@gmail.com',
          onTap: () => context.push('/contact-us'),
        ),
        _buildNavigateTile(
          icon: Icons.star_rounded,
          title: 'تقييم التطبيق',
          subtitle: 'قيم التطبيق في المتجر',
          onTap: () => context.push('/rate-app'),
        ),
        _buildNavigateTile(
          icon: Icons.share_rounded,
          title: 'مشاركة التطبيق',
          subtitle: 'شارك التطبيق مع أصدقائك',
          onTap: () => context.push('/share-app'),
        ),
      ],
    );
  }

  // ============================================================
  //  About Section
  // ============================================================
  Widget _buildAboutSection() {
    return _buildSection(
      title: 'حول التطبيق',
      icon: Icons.info_rounded,
      color: const Color(0xFFA855F7),
      children: [
        _buildAboutItem(
          icon: Icons.rocket_launch_rounded,
          title: 'الإصدار',
          value: '1.0.0',
          subtitle: 'آخر تحديث: أغسطس 2026',
        ),
        _buildAboutItem(
          icon: Icons.code_rounded,
          title: 'المطور',
          value: 'NextStep AI Team',
          subtitle: '© 2026 جميع الحقوق محفوظة',
        ),
        _buildAboutItem(
          icon: Icons.people_rounded,
          title: 'الشركاء',
          value: '5 جامعات',
          subtitle: 'انضم إلى شبكتنا',
        ),
        _buildNavigateTile(
          icon: Icons.stars_rounded,
          title: 'الإصدار التجريبي',
          subtitle: 'نسخة تجريبية - قيد التطوير',
          onTap: () => _showSnackBar('نسخة تجريبية v1.0.0-beta'),
        ),
      ],
    );
  }

  // ============================================================
  //  Logout Button
  // ============================================================
  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: _showLogoutDialog,
        icon: const Icon(Icons.logout_rounded, size: 20),
        label: const Text('تسجيل الخروج'),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red.shade50,
          foregroundColor: Colors.red.shade700,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14),
          side: BorderSide(color: Colors.red.shade200),
        ),
      ),
    );
  }

  // ============================================================
  //  Helper Widgets
  // ============================================================
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        secondary: Icon(icon, color: AppTheme.primary, size: 22),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryContainer,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primary,
        activeTrackColor: AppTheme.primary.withValues(alpha: 0.2),
        inactiveThumbColor: Colors.grey.shade400,
      ),
    );
  }

  Widget _buildNavigateTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: AppTheme.primary, size: 22),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryContainer,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: onTap,
    );
  }

  Widget _buildLanguageTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading:
          const Icon(Icons.language_rounded, color: AppTheme.primary, size: 22),
      title: const Text(
        'اللغة',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryContainer,
        ),
      ),
      subtitle: Text(
        _languages[_selectedLanguage] ?? 'العربية',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: _showLanguageDialog,
    );
  }

  Widget _buildThemeTile() {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading:
          const Icon(Icons.style_rounded, color: AppTheme.primary, size: 22),
      title: const Text(
        'المظهر',
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryContainer,
        ),
      ),
      subtitle: Text(
        _isDarkMode ? 'داكن' : 'فاتح',
        style: TextStyle(
          fontSize: 12,
          color: Colors.grey.shade500,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 16,
        color: Colors.grey.shade400,
      ),
      onTap: () {
        setState(() {
          _isDarkMode = !_isDarkMode;
        });
        _showSnackBar(
            _isDarkMode ? 'تم تفعيل الوضع الليلي' : 'تم تفعيل الوضع النهاري');
      },
    );
  }

  Widget _buildAboutItem({
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: AppTheme.primary, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryContainer,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  URL Launcher
  // ============================================================
  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('لا يمكن فتح الرابط', isSuccess: false);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء فتح الرابط', isSuccess: false);
    }
  }
}
