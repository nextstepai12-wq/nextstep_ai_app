import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class CookiesPolicyScreen extends StatefulWidget {
  const CookiesPolicyScreen({super.key});

  @override
  State<CookiesPolicyScreen> createState() => _CookiesPolicyScreenState();
}

class _CookiesPolicyScreenState extends State<CookiesPolicyScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _showConsent = true;

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
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      _showSnackBar('لا يمكن فتح الرابط', isSuccess: false);
    }
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
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _buildAppBar(),
        body: Stack(
          children: [
            FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                  child: Column(
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildLastUpdated(),
                      const SizedBox(height: 20),
                      _buildSection(
                        title: 'ما هي ملفات تعريف الارتباط؟',
                        icon: Icons.info_outline_rounded,
                        color: const Color(0xFF3B82F6),
                        items: [
                          'ملفات تعريف الارتباط هي ملفات نصية صغيرة يتم تخزينها على جهازك',
                          'تساعدنا في تحسين تجربتك عند استخدام التطبيق',
                          'نستخدمها لفهم كيفية تفاعلك مع التطبيق',
                          'لا تحتوي ملفات تعريف الارتباط على معلومات شخصية مباشرة',
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        title: 'أنواع ملفات تعريف الارتباط التي نستخدمها',
                        icon: Icons.category_rounded,
                        color: const Color(0xFF22C55E),
                        items: [
                          '🔹 **الأساسية (Essential)** - ضرورية لتشغيل التطبيق',
                          '🔹 **الأداء (Performance)** - لتحسين سرعة وأداء التطبيق',
                          '🔹 **التفضيلات (Preferences)** - لتذكر إعداداتك وتفضيلاتك',
                          '🔹 **التحليل (Analytics)** - لفهم كيفية استخدام التطبيق',
                          '🔹 **التسويق (Marketing)** - لتقديم محتوى مخصص',
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        title: 'كيف نستخدم ملفات تعريف الارتباط',
                        icon: Icons.settings_rounded,
                        color: const Color(0xFF8B5CF6),
                        items: [
                          'تحليل أداء التطبيق وسرعته',
                          'تذكر تفضيلاتك وإعداداتك',
                          'تقديم توصيات مخصصة لك',
                          'تحسين تجربة المستخدم بشكل عام',
                          'جمع بيانات إحصائية عن استخدام التطبيق',
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        title: 'ملفات تعريف الارتباط التابعة لجهات خارجية',
                        icon: Icons.share_rounded,
                        color: const Color(0xFFF97316),
                        items: [
                          'قد نستخدم خدمات جهات خارجية مثل Google Analytics',
                          'هذه الخدمات قد تضع ملفات تعريف الارتباط الخاصة بها',
                          'لا نتحكم في ملفات تعريف الارتباط التابعة لجهات خارجية',
                          'ننصح بقراءة سياسة الخصوصية لكل خدمة',
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        title: 'مدة صلاحية ملفات تعريف الارتباط',
                        icon: Icons.timer_rounded,
                        color: const Color(0xFFDC2626),
                        items: [
                          '🔹 **الجلسة (Session)** - تنتهي عند إغلاق التطبيق',
                          '🔹 **الدائمة (Persistent)** - تبقى حتى تاريخ انتهاء صلاحيتها',
                          'نستخدم كلا النوعين لتحسين تجربتك',
                          'يمكنك حذف ملفات تعريف الارتباط في أي وقت',
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        title: 'إدارة ملفات تعريف الارتباط',
                        icon: Icons.control_point_rounded,
                        color: const Color(0xFFA855F7),
                        items: [
                          'يمكنك قبول أو رفض ملفات تعريف الارتباط',
                          'يمكنك حذف ملفات تعريف الارتباط المخزنة',
                          'يمكنك تعطيل ملفات تعريف الارتباط من إعدادات الجهاز',
                          'تعطيل بعض الملفات قد يؤثر على تجربتك في التطبيق',
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildSection(
                        title: 'تغييرات سياسة ملفات تعريف الارتباط',
                        icon: Icons.update_rounded,
                        color: const Color(0xFF3B82F6),
                        items: [
                          'قد نقوم بتحديث هذه السياسة من وقت لآخر',
                          'سنخطرك بأي تغييرات جوهرية',
                          'آخر تحديث لهذه السياسة: 12 أغسطس 2026',
                          'استمرارك في استخدام التطبيق يعني موافقتك على السياسة',
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildContactSection(),
                      const SizedBox(height: 24),
                      _buildConsentButtons(),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
            // Floating Consent Banner
            if (_showConsent)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: _buildConsentBanner(),
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
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppTheme.primaryContainer,
          ),
          onPressed: () => Navigator.pop(context),
          splashRadius: 24,
        ),
      ),
      title: const Text(
        'سياسة ملفات تعريف الارتباط',
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
  //  Header
  // ============================================================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 30,
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
                  'سياسة ملفات تعريف الارتباط 🍪',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'نستخدم ملفات تعريف الارتباط لتحسين تجربتك',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Center(
              child: Icon(
                Icons.cookie_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  Last Updated
  // ============================================================
  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.orange.shade200, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update_rounded,
            size: 20,
            color: Colors.orange.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'آخر تحديث: 12 أغسطس 2026',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.orange.shade700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  Section Builder
  // ============================================================
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
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
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 13.5,
                      height: 1.6,
                      color: AppTheme.onSurfaceVariant,
                    ),
                    children: _parseItemText(item),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  List<TextSpan> _parseItemText(String text) {
    final List<TextSpan> spans = [];
    if (text.startsWith('🔹')) {
      final parts = text.split('**');
      if (parts.length == 3) {
        spans.add(TextSpan(
          text: parts[0],
          style: const TextStyle(fontWeight: FontWeight.w400),
        ));
        spans.add(TextSpan(
          text: parts[1],
          style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary),
        ));
        spans.add(TextSpan(
          text: parts[2],
          style: const TextStyle(fontWeight: FontWeight.w400),
        ));
      } else {
        spans.add(TextSpan(text: text));
      }
    } else {
      spans.add(TextSpan(text: text));
    }
    return spans;
  }

  // ============================================================
  //  Contact Section
  // ============================================================
  Widget _buildContactSection() {
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
                  color: const Color(0xFFF97316).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.contact_support_rounded,
                  color: Color(0xFFF97316),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'تواصل معنا',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'إذا كان لديك أي استفسار حول سياسة ملفات تعريف الارتباط، يرجى التواصل معنا:',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _launchURL('mailto:nextstepai12@gmail.com'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.email_rounded,
                    color: AppTheme.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'nextstepai12@gmail.com',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.secondary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: Colors.grey,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  Consent Buttons
  // ============================================================
  Widget _buildConsentButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryContainer,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('رجوع'),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton(
            onPressed: () {
              setState(() {
                _showConsent = false;
              });
              _showSnackBar('تم قبول ملفات تعريف الارتباط');
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
            child: const Text('أوافق'),
          ),
        ),
      ],
    );
  }

  // ============================================================
  //  Consent Banner (Floating)
  // ============================================================
  Widget _buildConsentBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              const Icon(
                Icons.cookie_rounded,
                color: Colors.orange,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'نستخدم ملفات تعريف الارتباط',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryContainer,
                      ),
                    ),
                    Text(
                      'نستخدم ملفات تعريف الارتباط لتحسين تجربتك',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: () {
                    setState(() {
                      _showConsent = false;
                    });
                  },
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.grey.shade600,
                  ),
                  child: const Text('رفض الكل'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showConsent = false;
                    });
                    _showSnackBar('تم قبول ملفات تعريف الارتباط');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('قبول الكل'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}