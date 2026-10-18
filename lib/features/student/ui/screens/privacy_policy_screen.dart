import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0;
  double _fontSize = 15;
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;
    final max = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    setState(() {
      _scrollProgress = max > 0 ? (current / max).clamp(0.0, 1.0) : 0;
      _showBackToTop = current > 300;
    });
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void _increaseFontSize() {
    if (_fontSize < 20) {
      setState(() => _fontSize += 1);
    }
  }

  void _decreaseFontSize() {
    if (_fontSize > 12) {
      setState(() => _fontSize -= 1);
    }
  }

  Future<void> _launchEmail() async {
    final uri = Uri.parse('mailto:nextstepai12@gmail.com');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        body: Stack(
          children: [
            Column(
              children: [
                _buildHeader(c),
                _buildProgressBar(c),
                Expanded(
                  child: NotificationListener<ScrollNotification>(
                    onNotification: (notification) {
                      if (notification is ScrollUpdateNotification) {
                        if (!_scrollController.hasClients) return false;
                        final max = _scrollController.position.maxScrollExtent;
                        final current = _scrollController.offset;
                        setState(() {
                          _scrollProgress =
                              max > 0 ? (current / max).clamp(0.0, 1.0) : 0;
                          _showBackToTop = current > 300;
                        });
                      }
                      return false;
                    },
                    child: SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
                      child: Column(
                        children: [
                          _buildMetaBar(c),
                          const SizedBox(height: 16),
                          _buildIntroductionCard(c),
                          const SizedBox(height: 16),
                          _buildDataCollectionSection(c),
                          const SizedBox(height: 16),
                          _buildAiUsageSection(c),
                          const SizedBox(height: 16),
                          _buildDataProtectionSection(c),
                          const SizedBox(height: 16),
                          _buildRightsSection(c),
                          const SizedBox(height: 16),
                          _buildContactDpoBox(c),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_showBackToTop)
              Positioned(
                left: 20,
                bottom: 80,
                child: _buildBackToTopButton(c),
              ),
            _buildSecurityBadge(c),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors c) {
    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(bottom: BorderSide(color: c.divider, width: 0.5)),
        ),
        child: Row(
          children: [
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: c.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 18,
                  color: c.textPrimary,
                ),
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [c.gradientStart, c.gradientEnd],
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.shield_rounded,
                size: 18,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'سياسة الخصوصية',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(AppColors c) {
    return Container(
      width: double.infinity,
      height: 4,
      color: c.surfaceAlt,
      child: FractionallySizedBox(
        alignment: AlignmentDirectional.centerStart,
        widthFactor: _scrollProgress,
        child: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [c.gradientStart, c.gradientEnd, c.primarySoft],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMetaBar(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: c.successSoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.verified_user_rounded,
              size: 18,
              color: c.success,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'الوثيقة الرسمية',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'آخر تحديث: ١٥ يناير ٢٠٢٥',
                  style: TextStyle(
                    fontSize: 11,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: c.surfaceAlt,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(2),
            child: Row(
              children: [
                _buildFontButton(c, 'A-', _decreaseFontSize),
                Container(
                  width: 1,
                  height: 20,
                  color: c.divider,
                ),
                _buildFontButton(c, 'A+', _increaseFontSize),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFontButton(
    AppColors c,
    String label,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildIntroductionCard(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            c.gradientStart.withValues(alpha: 0.08),
            c.surface,
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.waving_hand_rounded,
              size: 30,
              color: c.primary,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'مرحباً بك في NextStep AI',
            style: TextStyle(
              fontSize: _fontSize + 2,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'نلتزم بحماية خصوصيتك وبياناتك الشخصية. نستخدم أحدث تقنيات الأمان لضمان أن معلوماتك في أمان تام. ت熟悉 هذه السياسة لتتعرف على كيفية جمع واستخدام وحماية بياناتك.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: _fontSize,
              height: 1.7,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataCollectionSection(AppColors c) {
    final items = [
      {
        'icon': Icons.person_rounded,
        'title': 'الهوية الأكاديمية',
        'desc': 'الاسم الكامل والبريد الإلكتروني والجامعة والتخصص',
        'color': c.primary,
        'bg': c.primarySoft,
      },
      {
        'icon': Icons.analytics_rounded,
        'title': 'المعدل والمسار',
        'desc': 'المعدل التراكمي والمسار الأكاديمي والتخصصات الفرعية',
        'color': c.success,
        'bg': c.successSoft,
      },
      {
        'icon': Icons.quiz_rounded,
        'title': 'استبيان الميول',
        'desc': 'إجاباتك على اختبارات الميول والاهتمامات المهنية',
        'color': c.purple,
        'bg': c.purpleSoft,
      },
      {
        'icon': Icons.location_on_rounded,
        'title': 'التفضيلات الجغرافية',
        'desc': 'المدن والمناطق المفضلة للعمل أو الدراسة',
        'color': c.accent,
        'bg': c.accentSoft,
      },
    ];

    return _buildSectionCard(
      c: c,
      icon: Icons.data_usage_rounded,
      iconColor: c.primary,
      iconBg: c.primarySoft,
      title: 'البيانات التي نجمعها',
      child: Column(
        children: [
          Text(
            'نجمع فقط البيانات الضرورية لتقديم لك تجربة مخصصة وفعالة:',
            style: TextStyle(
              fontSize: _fontSize,
              height: 1.6,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 1.1,
            ),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final item = items[index];
              return Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: c.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: c.divider, width: 0.5),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: item['bg'] as Color,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        size: 20,
                        color: item['color'] as Color,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      item['title'] as String,
                      style: TextStyle(
                        fontSize: _fontSize - 1,
                        fontWeight: FontWeight.w700,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item['desc'] as String,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: _fontSize - 3,
                        height: 1.4,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
          const SizedBox(height: 14),
          _buildInfoRow(
            c,
            icon: Icons.phone_android_rounded,
            color: c.textSecondary,
            text: 'كما نجمع معلومات الجهاز ونظام التشغيل لتحسين الأداء',
          ),
        ],
      ),
    );
  }

  Widget _buildAiUsageSection(AppColors c) {
    final allowedItems = [
      'مطابقة اهتماماتك مع التخصصات والأكثر ملاءمة',
      'توليد نصائح أكاديمية ومهنية مخصصة لك',
      'تحليل أنماط التعلم واقتراح مسارات محسّنة',
      'تحسين دقة التوصيات مع كل تفاعل',
    ];

    return _buildSectionCard(
      c: c,
      icon: Icons.smart_toy_rounded,
      iconColor: c.purple,
      iconBg: c.purpleSoft,
      title: 'كيف نستخدم الذكاء الاصطناعي',
      child: Column(
        children: [
          ...allowedItems.map((item) => _buildCheckRow(c, item)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.dangerSoft,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: c.danger.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: c.danger.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.block_rounded,
                    size: 18,
                    color: c.danger,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'لا نبيع بياناتك لأي جهة خارجية مهما كان السبب',
                    style: TextStyle(
                      fontSize: _fontSize - 1,
                      fontWeight: FontWeight.w600,
                      color: c.danger,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDataProtectionSection(AppColors c) {
    return _buildSectionCard(
      c: c,
      icon: Icons.lock_rounded,
      iconColor: c.success,
      iconBg: c.successSoft,
      title: 'حماية وأمان البيانات',
      child: Column(
        children: [
          _buildInfoRow(
            c,
            icon: Icons.storage_rounded,
            color: c.success,
            text: 'استضافة آمنة عبر Supabase مع حماية متعددة الطبقات',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            c,
            icon: Icons.enhanced_encryption_rounded,
            color: c.primary,
            text: 'تشفير AES-256 لجميع البيانات الحساسة أثناء النقل والتخزين',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            c,
            icon: Icons.verified_rounded,
            color: c.purple,
            text: 'متوافق مع معايير SOC2 و ISO27001 للأمان',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            c,
            icon: Icons.update_rounded,
            color: c.accent,
            text: 'نسخ احتياطي تلقائي وتحديثات أمنية دورية',
          ),
          const SizedBox(height: 10),
          _buildInfoRow(
            c,
            icon: Icons.people_alt_rounded,
            color: c.success,
            text: 'وصول محدود للموظفين المصرح لهم فقط',
          ),
        ],
      ),
    );
  }

  Widget _buildRightsSection(AppColors c) {
    final rights = [
      {
        'icon': Icons.download_rounded,
        'title': 'تصدير تقريرك',
        'desc': 'يمكنك تصدير جميع بياناتك في ملف منسق',
      },
      {
        'icon': Icons.edit_document,
        'title': 'تعديل بياناتك',
        'desc': 'تحديث أو تعديل أي معلومات شخصية في أي وقت',
      },
      {
        'icon': Icons.delete_forever_rounded,
        'title': 'حذف حسابك',
        'desc': 'حذف جميع بياناتك نهائياً من أنظمتنا',
      },
    ];

    return _buildSectionCard(
      c: c,
      icon: Icons.gavel_rounded,
      iconColor: c.danger,
      iconBg: c.dangerSoft,
      title: 'حقوقك ومسؤوليتك كطالب',
      child: Column(
        children: [
          ...rights.map((right) => Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: c.surfaceAlt.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: c.surface,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          right['icon'] as IconData,
                          size: 20,
                          color: c.primary,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              right['title'] as String,
                              style: TextStyle(
                                fontSize: _fontSize - 1,
                                fontWeight: FontWeight.w700,
                                color: c.textPrimary,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              right['desc'] as String,
                              style: TextStyle(
                                fontSize: _fontSize - 3,
                                color: c.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: c.surfaceAlt,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  size: 18,
                  color: c.textSecondary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'يحق لك سحب موافقتك على معالجة بياناتك في أي وقت',
                    style: TextStyle(
                      fontSize: _fontSize - 2,
                      color: c.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactDpoBox(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            c.primaryContainer.withValues(alpha: 0.12),
            c.primarySoft.withValues(alpha: 0.6),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.primaryContainer.withValues(alpha: 0.2), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.gradientStart, c.gradientEnd],
              ),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: c.primary.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.mail_rounded,
              size: 24,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            'هل لديك استفسار؟',
            style: TextStyle(
              fontSize: _fontSize + 1,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'تواصل مع مسؤول حماية البيانات',
            style: TextStyle(
              fontSize: _fontSize - 2,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'nextstepai12@gmail.com',
            style: TextStyle(
              fontSize: _fontSize - 2,
              fontWeight: FontWeight.w600,
              color: c.primary,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _launchEmail,
              icon: const Icon(Icons.send_rounded, size: 18),
              label: Text(
                'تواصل معنا',
                style: TextStyle(
                  fontSize: _fontSize,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: c.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                elevation: 2,
                shadowColor: c.primary.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecurityBadge(AppColors c) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.divider, width: 0.5)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: c.successSoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.shield_rounded,
                  size: 16,
                  color: c.success,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'بياناتك مشفرة ومحمية بالكامل',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBackToTopButton(AppColors c) {
    return GestureDetector(
      onTap: _scrollToTop,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [c.gradientStart, c.gradientEnd],
          ),
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Icon(
          Icons.keyboard_arrow_up_rounded,
          size: 24,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildSectionCard({
    required AppColors c,
    required IconData icon,
    required Color iconColor,
    required Color iconBg,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.divider, width: 0.5),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.04),
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
                  color: iconBg,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 20, color: iconColor),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: _fontSize + 1,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }

  Widget _buildCheckRow(AppColors c, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 2),
            padding: const EdgeInsets.all(3),
            decoration: BoxDecoration(
              color: c.successSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_circle_rounded,
              size: 16,
              color: c.success,
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: _fontSize - 1,
                height: 1.6,
                color: c.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(
    AppColors c, {
    required IconData icon,
    required Color color,
    required String text,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 16, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: _fontSize - 1,
              height: 1.6,
              color: c.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}
