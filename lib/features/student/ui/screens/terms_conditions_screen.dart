import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class TermsConditionsScreen extends StatefulWidget {
  const TermsConditionsScreen({super.key});

  @override
  State<TermsConditionsScreen> createState() => _TermsConditionsScreenState();
}

class _TermsConditionsScreenState extends State<TermsConditionsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  bool _showBackToTop = false;
  double _fontSizeScale = 1.0;

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

    _scrollController.addListener(_onScroll);
  }

  void _onScroll() {
    if (_scrollController.hasClients) {
      final maxScroll = _scrollController.position.maxScrollExtent;
      final currentScroll = _scrollController.offset;
      setState(() {
        _scrollProgress = maxScroll > 0 ? (currentScroll / maxScroll).clamp(0.0, 1.0) : 0.0;
        _showBackToTop = currentScroll > 400;
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToTop() {
    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutCubic,
    );
  }

  void _increaseFontSize() {
    if (_fontSizeScale < 1.5) {
      setState(() => _fontSizeScale += 0.1);
    }
  }

  void _decreaseFontSize() {
    if (_fontSizeScale > 0.7) {
      setState(() => _fontSizeScale -= 0.1);
    }
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
          backgroundColor: isSuccess
              ? Theme.of(context).extension<AppColors>()?.success ?? const Color(0xFF10B981)
              : Theme.of(context).extension<AppColors>()?.danger ?? const Color(0xFFBA1A1A),
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
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        appBar: _buildAppBar(c),
        body: Stack(
          children: [
            Column(
              children: [
                _buildReadingProgressBar(c),
                _buildFontScalingControls(c),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        controller: _scrollController,
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                        child: Column(
                          children: [
                            _buildHeader(c),
                            const SizedBox(height: 24),
                            _buildLastUpdated(c),
                            const SizedBox(height: 20),
                            _buildSection(
                              title: 'مقدمة',
                              icon: Icons.waving_hand_rounded,
                              color: c.primaryContainer,
                              items: [
                                'مرحباً بك في شروط الاستخدام الخاصة بتطبيق NextStep AI',
                                'يتم استخدام التطبيق وتوظيفه من قِبلك يُشكّل موافقة كاملة على هذه الشروط',
                                'يرجى قراءة جميع البنود بعناية قبل البدء في استخدام التطبيق',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              title: 'القبول والموافقة',
                              icon: Icons.how_to_reg_rounded,
                              color: c.success,
                              items: [
                                'باستخدامك للتطبيق فأنت تقر وتوافق على جميع هذه الشروط والأحكام',
                                'إذا كنت لا توافق على أي من هذه الشروط، يرجى التوقف عن استخدام التطبيق فوراً',
                                'نحتفظ بحق تعديل هذه الشروط في أي وقت دون إشعار مسبق',
                                'استمرارك في استخدام التطبيق بعد التعديلات يُعتبر موافقة صريحة على الشروط المعدلة',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              title: 'الحساب والتسجيل',
                              icon: Icons.person_add_rounded,
                              color: c.accent,
                              items: [
                                'يجب عليك تقديم معلومات دقيقة وكاملة عند التسجيل',
                                'أنت مسؤول عن الحفاظ على سرية كلمة المرور وحسابك',
                                'يجب أن يكون عمرك 16 سنة أو أكثر لاستخدام التطبيق',
                                'يُحظر إنشاء أكثر من حساب واحد لكل مستخدم',
                                'نحتفظ بحق تعليق أو حذف الحسابات المخالفة',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              title: 'استخدام التطبيق',
                              icon: Icons.phone_android_rounded,
                              color: c.primaryContainer,
                              items: [
                                'التطبيق مخصص للاستخدام الشخصي والتعليمي فقط',
                                'يُمنع استخدام التطبيق لأغراض تجارية دون إذن مسبق مكتوب',
                                'يُمنع التلاعب بالبيانات أو محاولة الوصول غير المصرح به',
                                'يُمنع نسخ أو توزيع محتوى التطبيق دون إذن',
                                'نحتفظ بحق تقييد الوصول للمستخدمين المخالفين',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              title: 'التوصيات الأكاديمية',
                              icon: Icons.lightbulb_rounded,
                              color: c.accent,
                              items: [
                                'التوصيات المقدمة من التطبيق هي استشارات أكاديمية عامة فقط',
                                'لا تضمن التوصيات دقيقة بنسبة 100% لأنها مبنية على البيانات المدخلة',
                                'التوصيات ليست بديلاً عن استشارة أخصائي أكاديمي متخصص',
                                'يتحمل المستخدم المسؤولية الكاملة عن القرارات الأكاديمية التي يتخذها',
                                'النتائج الفعلية قد تختلف حسب ظروف كل طالب الخاصة',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              title: 'الملكية الفكرية',
                              icon: Icons.shield_rounded,
                              color: c.purple,
                              items: [
                                'جميع محتويات التطبيق محمية بموجب قوانين الملكية الفكرية',
                                'اسم التطبيق والشعارات والتصميمات هي ملك حصري لـ NextStep AI',
                                'يُمنع أي استخدام غير مصرح به لمحتويات التطبيق',
                                'البيانات المُولّدة من الذكاء الاصطناعي مرخصة لاستخدامك الشخصي فقط',
                                'جميع الحقوق محفوظة لـ NextStep AI 2026',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              title: 'الخصوصية والبيانات',
                              icon: Icons.lock_rounded,
                              color: c.success,
                              items: [
                                'تتم معالجة بياناتك وفقاً لسياسة الخصوصية الخاصة بنا',
                                'باستخدامك للتطبيق فأنت توافق على جمع واستخدام بياناتك كما هو موضح في سياسة الخصوصية',
                                'نلتزم بحماية بياناتك الشخصية و Kensingtonكل سرية',
                                'يمكنك الاطلاع على سياسة الخصوصية الكاملة من داخل التطبيق',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              title: 'إخلاء المسؤولية',
                              icon: Icons.info_outline_rounded,
                              color: c.danger,
                              items: [
                                'يُقدم التطبيق كما هو ("as is") دون أي ضمانات صريحة أو ضمنية',
                                'لا نضمن دقة أو اكتمال التوصيات المقدمة',
                                'لا نتحمل المسؤولية عن أي أضرار ناتجة عن استخدام التطبيق',
                                'لا نضمن توفر التطبيق بشكل مستمر وبدون انقطاع',
                                'يتحمل المستخدم المسؤولية الكاملة عن استخدامه للتطبيق',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              title: 'روابط خارجية',
                              icon: Icons.link_rounded,
                              color: c.purple,
                              items: [
                                'قد يحتوي التطبيق على روابط لمواقع إلكترونية خارجية',
                                'لا نتحمل المسؤولية عن محتوى هذه المواقع أو سياساتها',
                                'روابط خارجية تُقدّم لأغراض توضيحية فقط',
                                'يجب عليك مراجعة شروط واستخدام هذه المواقع بعناية',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              title: 'التعديلات على الشروط',
                              icon: Icons.edit_note_rounded,
                              color: c.primaryContainer,
                              items: [
                                'نحتفظ بحق تعديل هذه الشروط والأحكام في أي وقت',
                                'ستُنشر التعديلات على التطبيق مباشرة عند توفرها',
                                'يُنصح بمراجعة هذه الشروط بشكل دوري',
                                'آخر تحديث لهذه الشروط: 12 أغسطس 2026',
                                'استمرارك في استخدام التطبيق بعد التعديلات يُشكل موافقة على الشروط الجديدة',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildSection(
                              title: 'القانون المعمول به',
                              icon: Icons.balance_rounded,
                              color: c.accent,
                              items: [
                                'تخضع هذه الشروط والأحكام لقوانين دولة فلسطين',
                                'أي نزاعات تنشأ عن هذه الشروط ستخضع للاختصاص القضائي لمحاكم فلسطين',
                                'في حالة عدم صلاحية أي بند، تبقى باقي البنود سارية المفعول',
                              ],
                            ),
                            const SizedBox(height: 16),
                            _buildContactSection(c),
                            const SizedBox(height: 24),
                            _buildAgreementButtons(c),
                            const SizedBox(height: 20),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (_showBackToTop)
              Positioned(
                bottom: 24,
                left: 20,
                child: _buildBackToTopButton(c),
              ),
            Positioned(
              bottom: _showBackToTop ? 80 : 24,
              left: 20,
              child: _buildSecurityBadge(c),
            ),
          ],
        ),
      ),
    );
  }

  AppBar _buildAppBar(AppColors c) {
    return AppBar(
      backgroundColor: c.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: c.surfaceAlt,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            color: c.primaryContainer,
          ),
          onPressed: () => Navigator.pop(context),
          splashRadius: 24,
        ),
      ),
      title: Text(
        'الشروط والأحكام',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: c.primaryContainer,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildReadingProgressBar(AppColors c) {
    return Container(
      height: 3,
      color: c.surfaceAlt,
      child: Align(
        alignment: Alignment.centerLeft,
        child: FractionallySizedBox(
          widthFactor: _scrollProgress,
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [c.gradientStart, c.gradientEnd],
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(2),
                bottomLeft: Radius.circular(2),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFontScalingControls(AppColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Icon(Icons.text_fields_rounded, size: 18, color: c.textSecondary),
          const SizedBox(width: 8),
          Text(
            'حجم الخط',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: c.textSecondary,
            ),
          ),
          const Spacer(),
          _buildFontButton(
            c: c,
            label: 'A-',
            onTap: _decreaseFontSize,
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: c.primarySoft,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '${(_fontSizeScale * 100).round()}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: c.primary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          _buildFontButton(
            c: c,
            label: 'A+',
            onTap: _increaseFontSize,
          ),
        ],
      ),
    );
  }

  Widget _buildFontButton({
    required AppColors c,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: c.divider, width: 1),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w700,
            color: c.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [c.gradientStart, c.gradientEnd],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.25),
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
                Text(
                  '\u{1F4DC} الشروط والأحكام',
                  style: TextStyle(
                    fontSize: (20 * _fontSizeScale).clamp(14.0, 30.0),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'اقرأها بعناية، استخدامك للتطبيق يعني موافقتك عليها',
                  style: TextStyle(
                    fontSize: (13 * _fontSizeScale).clamp(10.0, 19.5),
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
                Icons.gavel_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
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
        border: Border.all(color: c.primaryContainer.withValues(alpha: 0.2), width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update_rounded,
            size: 20,
            color: c.primaryContainer,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'آخر تحديث: 12 أغسطس 2026',
              style: TextStyle(
                fontSize: (13 * _fontSizeScale).clamp(10.0, 19.5),
                fontWeight: FontWeight.w600,
                color: c.primaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Color color,
    required List<String> items,
  }) {
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.divider.withValues(alpha: 0.4), width: 1.2),
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
                    fontSize: (15 * _fontSizeScale).clamp(11.0, 22.5),
                    fontWeight: FontWeight.w700,
                    color: c.primaryContainer,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...items.map((item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: color,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        item,
                        style: TextStyle(
                          fontSize: (13.5 * _fontSizeScale).clamp(10.0, 20.25),
                          height: 1.6,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildContactSection(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: c.divider.withValues(alpha: 0.4), width: 1.2),
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
                  color: c.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.contact_support_rounded,
                  color: c.accent,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                'تواصل معنا',
                style: TextStyle(
                  fontSize: (15 * _fontSizeScale).clamp(11.0, 22.5),
                  fontWeight: FontWeight.w700,
                  color: c.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'إذا كان لديك أي استفسار حول الشروط والأحكام، يرجى التواصل معنا:',
            style: TextStyle(
              fontSize: (13 * _fontSizeScale).clamp(10.0, 19.5),
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          InkWell(
            onTap: () => _launchURL('mailto:nextstepai12@gmail.com'),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.email_rounded,
                    color: c.primary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'nextstepai12@gmail.com',
                      style: TextStyle(
                        fontSize: (14 * _fontSizeScale).clamp(10.0, 21.0),
                        fontWeight: FontWeight.w600,
                        color: c.primary,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 16,
                    color: c.textSecondary,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgreementButtons(AppColors c) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: c.primaryContainer,
              side: BorderSide(color: c.divider),
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
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
              elevation: 4,
              shadowColor: c.primary.withValues(alpha: 0.3),
            ),
            child: const Text('أوافق'),
          ),
        ),
      ],
    );
  }

  Widget _buildBackToTopButton(AppColors c) {
    return GestureDetector(
      onTap: _scrollToTop,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: c.primary,
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
          Icons.keyboard_arrow_up_rounded,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }

  Widget _buildSecurityBadge(AppColors c) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: c.successSoft,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: c.success.withValues(alpha: 0.2), width: 1),
        boxShadow: [
          BoxShadow(
            color: c.success.withValues(alpha: 0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.verified_user_rounded,
            size: 16,
            color: c.success,
          ),
          const SizedBox(width: 6),
          Text(
            'آمن ومحمي',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c.success,
            ),
          ),
        ],
      ),
    );
  }
}
