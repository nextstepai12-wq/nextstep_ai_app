// lib/features/admin/ui/screens/admin_settings_screen.dart
import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/helpers/hive_storage.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';

class AdminSettingsScreen extends StatefulWidget {
  const AdminSettingsScreen({super.key});

  @override
  State<AdminSettingsScreen> createState() => _AdminSettingsScreenState();
}

class _AdminSettingsScreenState extends State<AdminSettingsScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  //  المتغيرات
  // ============================================================
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;

  // إعدادات LLM
  int _maxLLMCallsPerUser = 50;
  int _maxTokensPerUser = 10000;
  bool _enableRAG = true;
  String _selectedLLMModel = 'claude-3-sonnet-20240229';

  // إعدادات التوصية
  bool _enableAutoRecommendations = true;
  int _minCompatibilityScore = 60;

  // أوزان الأبعاد الستة
  final Map<String, double> _dimensionWeights = {
    'programming': 1.0,
    'math': 1.0,
    'communication': 1.0,
    'research': 1.0,
    'practical': 1.0,
    'management': 1.0,
  };

  // إعدادات الأمان
  bool _requireEmailVerification = true;
  bool _enableTwoFactorAuth = false;
  bool _autoBlockSuspicious = true;

  // إعدادات عامة
  bool _enableMaintenanceMode = false;
  String _selectedLanguage = 'ar';

  final List<String> _llmModels = [
    'claude-3-opus-20240229',
    'claude-3-sonnet-20240229',
    'claude-3-haiku-20240307',
    'gpt-4-turbo-preview',
    'gpt-3.5-turbo',
  ];

  final List<String> _languages = ['ar', 'en'];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ============================================================
  //  دالة مساعدة لترجمة أسماء الأبعاد
  // ============================================================
  String _getDimensionName(String key) {
    switch (key) {
      case 'programming':
        return 'برمجة';
      case 'math':
        return 'رياضيات';
      case 'communication':
        return 'تواصل';
      case 'research':
        return 'بحث علمي';
      case 'practical':
        return 'عملي';
      case 'management':
        return 'إدارة';
      default:
        return key;
    }
  }

  // ============================================================
  //  دورة الحياة
  // ============================================================
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

    _loadSettings();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  //  تحميل الإعدادات من Hive
  // ============================================================
  Future<void> _loadSettings() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final settings = await HiveStorage.getSettings();

      if (settings.isNotEmpty) {
        setState(() {
          _maxLLMCallsPerUser = settings['max_llm_calls_per_user'] ?? 50;
          _maxTokensPerUser = settings['max_tokens_per_user'] ?? 10000;
          _enableRAG = settings['enable_rag'] ?? true;
          _selectedLLMModel = settings['llm_model'] ?? 'claude-3-sonnet-20240229';
          _enableAutoRecommendations = settings['enable_auto_recommendations'] ?? true;
          _minCompatibilityScore = settings['min_compatibility_score'] ?? 60;

          if (settings['dimension_weights'] != null) {
            final weights = Map<String, double>.from(settings['dimension_weights']);
            _dimensionWeights.updateAll((key, value) => weights[key] ?? 1.0);
          }

          _requireEmailVerification = settings['require_email_verification'] ?? true;
          _enableTwoFactorAuth = settings['enable_two_factor_auth'] ?? false;
          _autoBlockSuspicious = settings['auto_block_suspicious'] ?? true;
          _enableMaintenanceMode = settings['enable_maintenance_mode'] ?? false;
          _selectedLanguage = settings['language'] ?? 'ar';
        });
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _animationController.forward();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'فشل تحميل الإعدادات: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  //  حفظ الإعدادات
  // ============================================================
  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      final settings = {
        'max_llm_calls_per_user': _maxLLMCallsPerUser,
        'max_tokens_per_user': _maxTokensPerUser,
        'enable_rag': _enableRAG,
        'llm_model': _selectedLLMModel,
        'enable_auto_recommendations': _enableAutoRecommendations,
        'min_compatibility_score': _minCompatibilityScore,
        'dimension_weights': _dimensionWeights,
        'require_email_verification': _requireEmailVerification,
        'enable_two_factor_auth': _enableTwoFactorAuth,
        'auto_block_suspicious': _autoBlockSuspicious,
        'enable_maintenance_mode': _enableMaintenanceMode,
        'language': _selectedLanguage,
        'updated_at': DateTime.now().toIso8601String(),
      };

      await HiveStorage.saveSettings(settings);

      if (mounted) {
        _showSnackBar('✅ تم حفظ الإعدادات بنجاح', Colors.green);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ خطأ: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  // ============================================================
  //  بناء الواجهة
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _buildAppBar(),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              )
            : _errorMessage != null
                ? _buildErrorState()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: RefreshIndicator(
                        onRefresh: _loadSettings,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 24),
                              _buildLLMSettings(),
                              const SizedBox(height: 20),
                              _buildRecommendationSettings(),
                              const SizedBox(height: 20),
                              _buildSecuritySettings(),
                              const SizedBox(height: 20),
                              _buildGeneralSettings(),
                              const SizedBox(height: 28),
                              _buildSaveButton(),
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
  //  AppBar
  // ============================================================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryContainer),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'إعدادات المنصة',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryContainer,
        ),
      ),
      centerTitle: true,
    );
  }

  // ============================================================
  //  رأس الصفحة
  // ============================================================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(20),
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
                const Text(
                  '⚙️ إعدادات المنصة',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'تحكم بإعدادات الذكاء الاصطناعي، التوصية، والأمان',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Icons.settings_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  إعدادات الذكاء الاصطناعي (LLM)
  // ============================================================
  Widget _buildLLMSettings() {
    return _buildSettingsCard(
      title: '🤖 إعدادات الذكاء الاصطناعي',
      icon: Icons.auto_awesome_rounded,
      color: const Color(0xFF8B5CF6),
      children: [
        _buildSlider(
          label: 'الحد الأقصى للمكالمات لكل مستخدم',
          value: _maxLLMCallsPerUser.toDouble(),
          min: 10,
          max: 200,
          divisions: 19,
          onChanged: (v) => setState(() => _maxLLMCallsPerUser = v.round()),
          suffix: 'مكالمة',
        ),
        const SizedBox(height: 12),
        _buildSlider(
          label: 'الحد الأقصى للرموز (Tokens) لكل مستخدم',
          value: _maxTokensPerUser.toDouble(),
          min: 1000,
          max: 50000,
          divisions: 49,
          onChanged: (v) => setState(() => _maxTokensPerUser = v.round()),
          suffix: 'رمز',
          formatValue: (v) => '${(v / 1000).toStringAsFixed(0)}K',
        ),
        const SizedBox(height: 12),
        _buildDropdown(
          label: 'نموذج اللغة',
          value: _selectedLLMModel,
          items: _llmModels,
          onChanged: (String value) {
            setState(() => _selectedLLMModel = value);
          },
          getLabel: (v) {
            switch (v) {
              case 'claude-3-opus-20240229':
                return 'Claude 3 Opus (الأقوى)';
              case 'claude-3-sonnet-20240229':
                return 'Claude 3 Sonnet (المتوازن)';
              case 'claude-3-haiku-20240307':
                return 'Claude 3 Haiku (الأسرع)';
              case 'gpt-4-turbo-preview':
                return 'GPT-4 Turbo';
              case 'gpt-3.5-turbo':
                return 'GPT-3.5 Turbo';
              default:
                return v;
            }
          },
        ),
        const SizedBox(height: 8),
        _buildSwitch(
          label: 'تفعيل تقنية RAG',
          subtitle: 'استخدام قاعدة المعرفة لتحسين دقة الإجابات',
          value: _enableRAG,
          onChanged: (v) => setState(() => _enableRAG = v),
        ),
      ],
    );
  }

  // ============================================================
  //  إعدادات نظام التوصية
  // ============================================================
  Widget _buildRecommendationSettings() {
    return _buildSettingsCard(
      title: '🎯 إعدادات نظام التوصية',
      icon: Icons.recommend_rounded,
      color: const Color(0xFF22C55E),
      children: [
        _buildSlider(
          label: 'الحد الأدنى لنسبة التوافق',
          value: _minCompatibilityScore.toDouble(),
          min: 30,
          max: 90,
          divisions: 6,
          onChanged: (v) => setState(() => _minCompatibilityScore = v.round()),
          suffix: '%',
        ),
        const SizedBox(height: 8),
        _buildSwitch(
          label: 'تفعيل التوصيات التلقائية',
          subtitle: 'عرض توصيات للطلاب تلقائياً بعد إكمال التقييم',
          value: _enableAutoRecommendations,
          onChanged: (v) => setState(() => _enableAutoRecommendations = v),
        ),
        const SizedBox(height: 12),
        const Text(
          'أوزان أبعاد التوصية',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 8),
        ..._dimensionWeights.keys.map((key) => _buildWeightSlider(key)),
      ],
    );
  }

  Widget _buildWeightSlider(String key) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              _getDimensionName(key),
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Slider(
              value: _dimensionWeights[key]!,
              min: 0,
              max: 2,
              divisions: 20,
              activeColor: const Color(0xFF22C55E),
              inactiveColor: Colors.grey.shade200,
              onChanged: (v) => setState(() => _dimensionWeights[key] = v),
            ),
          ),
          SizedBox(
            width: 40,
            child: Text(
              _dimensionWeights[key]!.toStringAsFixed(1),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: AppTheme.primary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  إعدادات الأمان
  // ============================================================
  Widget _buildSecuritySettings() {
    return _buildSettingsCard(
      title: '🔒 إعدادات الأمان',
      icon: Icons.security_rounded,
      color: const Color(0xFF3B82F6),
      children: [
        _buildSwitch(
          label: 'طلب توثيق البريد الإلكتروني',
          subtitle: 'طلب من المستخدمين توثيق بريدهم الإلكتروني عند التسجيل',
          value: _requireEmailVerification,
          onChanged: (v) => setState(() => _requireEmailVerification = v),
        ),
        _buildSwitch(
          label: 'تفعيل المصادقة الثنائية (2FA)',
          subtitle: 'طبقة أمان إضافية للمستخدمين',
          value: _enableTwoFactorAuth,
          onChanged: (v) => setState(() => _enableTwoFactorAuth = v),
        ),
        _buildSwitch(
          label: 'الحظر التلقائي للحسابات المشبوهة',
          subtitle: 'حظر الحسابات تلقائياً عند اكتشاف نشاط غير طبيعي',
          value: _autoBlockSuspicious,
          onChanged: (v) => setState(() => _autoBlockSuspicious = v),
        ),
      ],
    );
  }

  // ============================================================
  //  إعدادات عامة
  // ============================================================
  Widget _buildGeneralSettings() {
    return _buildSettingsCard(
      title: '🌐 إعدادات عامة',
      icon: Icons.public_rounded,
      color: const Color(0xFFF97316),
      children: [
        _buildDropdown(
          label: 'اللغة الافتراضية',
          value: _selectedLanguage,
          items: _languages,
          onChanged: (String value) {
            setState(() => _selectedLanguage = value);
          },
          getLabel: (v) => v == 'ar' ? 'العربية' : 'English',
        ),
        _buildSwitch(
          label: 'وضع الصيانة',
          subtitle: 'تعطيل المنصة للمستخدمين مع إبقاء الإدارة فقط',
          value: _enableMaintenanceMode,
          onChanged: (v) => setState(() => _enableMaintenanceMode = v),
        ),
      ],
    );
  }

  // ============================================================
  //  بطاقة إعدادات عامة
  // ============================================================
  Widget _buildSettingsCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
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
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  // ============================================================
  //  دالة _buildSlider (المصححة بالكامل) ✅
  // ============================================================
  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
    String suffix = '',
    String? Function(double)? formatValue,
  }) {
    // دالة مساعدة للحصول على النص المعروض بشكل آمن
    String getDisplayValue() {
      if (formatValue != null) {
        final result = formatValue(value);
        return result ?? '${value.round()}$suffix'; // إذا كانت null، استخدم القيمة الافتراضية
      }
      return '${value.round()}$suffix';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppTheme.primaryContainer),
            ),
            Text(
              getDisplayValue(),
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primary,
              ),
            ),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          activeColor: AppTheme.primary,
          inactiveColor: Colors.grey.shade200,
          onChanged: onChanged,
        ),
      ],
    );
  }

  // ============================================================
  //  دالة _buildSwitch
  // ============================================================
  Widget _buildSwitch({
    required String label,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          label,
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: AppTheme.primary,
        dense: true,
      ),
    );
  }

  // ============================================================
  //  دالة _buildDropdown (المصححة)
  // ============================================================
  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String> onChanged,
    required String Function(String) getLabel,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 13, color: AppTheme.primaryContainer),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FB),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_rounded),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    getLabel(item),
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryContainer,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  onChanged(newValue);
                }
              },
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  //  زر الحفظ
  // ============================================================
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'حفظ الإعدادات',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }

  // ============================================================
  //  حالة الخطأ
  // ============================================================
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadSettings,
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
  //  دوال مساعدة
  // ============================================================
  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: color,
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}