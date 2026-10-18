import 'dart:math';
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
  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  bool _showBackToTop = false;
  bool _showConsent = true;
  double _fontSizeScale = 1.0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _scrollController.addListener(_onScroll);
    _animController.forward();
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final max = _scrollController.position.maxScrollExtent;
      if (max > 0) {
        setState(() {
          _scrollProgress = (_scrollController.offset / max).clamp(0.0, 1.0);
          _showBackToTop = _scrollController.offset > 300;
        });
      }
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: isSuccess ? const Color(0xFF22C55E) : const Color(0xFFDC2626),
          content: Row(
            children: [
              Icon(
                isSuccess ? Icons.check_circle_outline_rounded : Icons.error_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
        ),
      );
  }

  void _scrollToTop() {
    _scrollController.animateTo(0, duration: const Duration(milliseconds: 500), curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        body: Stack(
          children: [
            Column(
              children: [
                _buildTopBar(c),
                _buildProgressBar(c),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnim,
                    child: SlideTransition(
                      position: _slideAnim,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 120),
                        child: Column(
                          children: [
                            _buildHeader(c),
                            const SizedBox(height: 16),
                            _buildFontControls(c),
                            const SizedBox(height: 20),
                            _buildLastUpdated(c),
                            const SizedBox(height: 20),
                            _buildIntroCard(c),
                            const SizedBox(height: 16),
                            _buildSection(
                              c: c,
                              title: 'أنواع الملفات',
                              icon: Icons.category_rounded,
                              color: c.success,
                              items: [
                                '🔹 **الأساسية (Essential)** — ضرورية لتشغيل التطبيق والخدمات الأساسية',
                                '🔹 **الأداء (Performance)** — لتحسين سرعة وأداء التطبيق وقياس الأخطاء',
                                '🔹 **التفضيلات (Preferences)** — لتذكر إعداداتك وتخصيص تجربتك',
                                '🔹 **التحليل (Analytics)** — لفهم كيفية تفاعلك مع التطبيق وتحسين المحتوى',
                                '🔹 **التسويق (Marketing)** — لتقديم إعلانات ومحتوى مخصص وقياس فعاليتها',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              c: c,
                              title: 'كيف نستخدمها',
                              icon: Icons.settings_rounded,
                              color: c.purple,
                              items: [
                                'تحليل أداء التطبيق وتحسين السرعة والاستقرار',
                                'تذكر تفضيلاتك وإعداداتك الشخصية',
                                'تقديم توصيات مخصصة بناءً على اهتماماتك',
                                'جمع بيانات إحصائية لتحسين المحتوى والخدمات',
                                'تحسين تجربة المستخدم بشكل عام',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              c: c,
                              title: 'الملفات التابعة لجهات خارجية',
                              icon: Icons.share_rounded,
                              color: c.accent,
                              items: [
                                'قد نستخدم خدمات جهات خارجية مثل Google Analytics',
                                'هذه الخدمات قد تضع ملفات تعريف الارتباط الخاصة بها على جهازك',
                                'لا نتحكم في ملفات تعريف الارتباط التابعة لجهات خارجية',
                                'ننصح بقراءة سياسة الخصوصية الخاصة بكل خدمة خارجية',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              c: c,
                              title: 'مدة الصلاحية',
                              icon: Icons.timer_rounded,
                              color: c.danger,
                              items: [
                                '🔹 **الجلسة (Session)** — تنتهي تلقائياً عند إغلاق التطبيق أو المتصفح',
                                '🔹 **الدائمة (Persistent)** — تبقى مخزنة على جهازك حتى تاريخ انتهاء صلاحيتها',
                                'نستخدم كلا النوعين معاً لتحسين تجربتك واستقرار التطبيق',
                                'يمكنك حذف ملفات تعريف الارتباط في أي وقت من إعدادات جهازك',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              c: c,
                              title: 'إدارة الملفات',
                              icon: Icons.manage_accounts_rounded,
                              color: c.primary,
                              items: [
                                'يمكنك قبول جميع ملفات تعريف الارتباط عبر زر "قبول الكل"',
                                'يمكنك رفض جميع الملفات غير الأساسية عبر زر "رفض الكل"',
                                'يمكنك حذف الملفات المخزنة من إعدادات المتصفح أو الجهاز',
                                'تعطيل بعض الملفات قد يؤثر على بعض ميزات التطبيق',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              c: c,
                              title: 'تحديثات السياسة',
                              icon: Icons.update_rounded,
                              color: c.purple,
                              items: [
                                'قد نقوم بتحديث سياسة الملفات من وقت لآخر',
                                'سنخطرك بأي تغييرات جوهرية عبر التطبيق أو البريد الإلكتروني',
                                'آخر تحديث لهذه السياسة: **12 أغسطس 2026**',
                                'استمرارك في استخدام التطبيق يعني موافقتك على السياسة المحدثة',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildContactSection(c),
                            const SizedBox(height: 24),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_showConsent) _buildConsentBanner(c),
            if (_showBackToTop) Positioned(
              bottom: _showConsent ? 190 : 24,
              left: 20,
              child: _buildBackToTopButton(c),
            ),
            Positioned(
              bottom: _showConsent ? 190 : 24,
              right: 20,
              child: _buildSecurityBadge(c),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(AppColors c) {
    return Container(
      padding: EdgeInsets.fromLTRB(12, MediaQuery.of(context).padding.top + 8, 12, 8),
      decoration: BoxDecoration(
        color: c.surface,
        border: Border(bottom: BorderSide(color: c.divider, width: 0.5)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: c.surfaceAlt, shape: BoxShape.circle),
            child: IconButton(
              icon: Icon(Icons.arrow_back_rounded, color: c.primary, size: 22),
              onPressed: () => Navigator.pop(context),
              splashRadius: 22,
            ),
          ),
          const Spacer(),
          Text(
            'سياسة الكوكيز',
            style: TextStyle(
              fontSize: 18 * _fontSizeScale,
              fontWeight: FontWeight.w800,
              color: c.textPrimary,
            ),
          ),
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }

  Widget _buildProgressBar(AppColors c) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      height: 3,
      decoration: BoxDecoration(color: c.divider),
      child: Align(
        alignment: Alignment.centerRight,
        child: FractionallySizedBox(
          widthFactor: _scrollProgress,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: [c.gradientStart, c.gradientEnd]),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFontControls(AppColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: BorderRadius.circular(14)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'حجم الخط',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: c.textSecondary),
          ),
          const SizedBox(width: 10),
          _buildFontBtn(c, Icons.remove_rounded, () {
            setState(() => _fontSizeScale = max(0.8, _fontSizeScale - 0.1));
          }),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              '${(_fontSizeScale * 100).round()}%',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: c.primary),
            ),
          ),
          _buildFontBtn(c, Icons.add_rounded, () {
            setState(() => _fontSizeScale = min(1.6, _fontSizeScale + 0.1));
          }),
        ],
      ),
    );
  }

  Widget _buildFontBtn(AppColors c, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 32,
        height: 32,
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.divider),
        ),
        child: Icon(icon, size: 18, color: c.primary),
      ),
    );
  }

  Widget _buildHeader(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.gradientStart, c.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(color: c.primary.withValues(alpha: 0.25), blurRadius: 30, offset: const Offset(0, 10)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🍪 سياسة الكوكيز',
                  style: TextStyle(fontSize: 21 * _fontSizeScale, fontWeight: FontWeight.w800, color: Colors.white),
                ),
                const SizedBox(height: 6),
                Text(
                  'نستخدم ملفات تعريف الارتباط لتحسين تجربتك وخدماتنا',
                  style: TextStyle(fontSize: 13 * _fontSizeScale, color: Colors.white.withValues(alpha: 0.8)),
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
            child: const Center(child: Icon(Icons.cookie_rounded, size: 30, color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.primarySoft,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: c.primary.withValues(alpha: 0.15), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(Icons.update_rounded, size: 20, color: c.primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'آخر تحديث: 12 أغسطس 2026',
              style: TextStyle(fontSize: 13 * _fontSizeScale, fontWeight: FontWeight.w600, color: c.primary),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntroCard(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.divider, width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: c.primarySoft, borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.info_outline_rounded, color: c.primary, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'ما هي ملفات تعريف الارتباط؟',
                  style: TextStyle(fontSize: 15 * _fontSizeScale, fontWeight: FontWeight.w700, color: c.primaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'ملفات تعريف الارتباط (Cookies) هي ملفات نصية صغيرة يتم تخزينها على جهازك عند زيارة تطبيقنا. '
            'تساعدنا في تذكّر تفضيلاتك وتحسين تجربتك، ولا تحتوي على معلومات شخصية مباشرة تعرّف هويتك.',
            style: TextStyle(fontSize: 13.5 * _fontSizeScale, height: 1.7, color: c.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required AppColors c,
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.divider, width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: color.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 15 * _fontSizeScale, fontWeight: FontWeight.w700, color: c.primaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: TextStyle(fontSize: 13.5 * _fontSizeScale, height: 1.6, color: c.textSecondary),
                        children: _parseItemText(item),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<TextSpan> _parseItemText(String text) {
    final List<TextSpan> spans = [];
    if (text.contains('**')) {
      final parts = text.split('**');
      for (var i = 0; i < parts.length; i++) {
        if (parts[i].isEmpty) continue;
        if (i % 2 == 1) {
          spans.add(TextSpan(
            text: parts[i],
            style: const TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary),
          ));
        } else {
          spans.add(TextSpan(text: parts[i]));
        }
      }
    } else {
      spans.add(TextSpan(text: text));
    }
    return spans;
  }

  Widget _buildContactSection(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.divider, width: 1.2),
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(color: c.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(10)),
                child: Icon(Icons.contact_support_rounded, color: c.accent, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                'تواصل معنا',
                style: TextStyle(fontSize: 15 * _fontSizeScale, fontWeight: FontWeight.w700, color: c.primaryContainer),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'إذا كان لديك أي استفسار حول سياسة ملفات تعريف الارتباط، يرجى التواصل معنا:',
            style: TextStyle(fontSize: 13 * _fontSizeScale, color: c.textSecondary),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _launchURL('mailto:nextstepai12@gmail.com'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: [
                  Icon(Icons.email_rounded, color: c.primary, size: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'nextstepai12@gmail.com',
                      style: TextStyle(fontSize: 14 * _fontSizeScale, fontWeight: FontWeight.w600, color: c.primary, decoration: TextDecoration.underline),
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded, size: 16, color: c.divider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConsentBanner(AppColors c) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: c.surface.withValues(alpha: 0.92),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.divider, width: 0.5),
          boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, -4))],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(color: c.accent.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(12)),
                  child: const Center(child: Icon(Icons.cookie_rounded, color: Color(0xFFF59E0B), size: 26)),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'نستخدم ملفات تعريف الارتباط',
                        style: TextStyle(fontSize: 14 * _fontSizeScale, fontWeight: FontWeight.w700, color: c.textPrimary),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'لتحسين تجربتك وتقديم محتوى مخصص',
                        style: TextStyle(fontSize: 12 * _fontSizeScale, color: c.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => setState(() => _showConsent = false),
                    style: TextButton.styleFrom(
                      foregroundColor: c.textSecondary,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('رفض الكل', style: TextStyle(fontSize: 14 * _fontSizeScale, fontWeight: FontWeight.w600)),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _showConsent = false);
                      _showSnackBar('تم قبول ملفات تعريف الارتباط');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: c.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text('قبول الكل', style: TextStyle(fontSize: 14 * _fontSizeScale, fontWeight: FontWeight.w600)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackToTopButton(AppColors c) {
    return GestureDetector(
      onTap: _scrollToTop,
      child: AnimatedScale(
        scale: _showBackToTop ? 1.0 : 0.0,
        duration: const Duration(milliseconds: 250),
        child: Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: c.surface,
            shape: BoxShape.circle,
            border: Border.all(color: c.divider),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.06), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: Icon(Icons.keyboard_arrow_up_rounded, color: c.primary, size: 26),
        ),
      ),
    );
  }

  Widget _buildSecurityBadge(AppColors c) {
    return AnimatedScale(
      scale: _showBackToTop ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 250),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: c.successSoft,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: c.success.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.shield_rounded, color: c.success, size: 16),
            const SizedBox(width: 4),
            Text('آمن', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.success)),
          ],
        ),
      ),
    );
  }
}
