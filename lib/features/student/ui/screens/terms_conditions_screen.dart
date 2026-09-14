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
        body: FadeTransition(
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
                    title: 'القبول والموافقة',
                    icon: Icons.check_circle_outline_rounded,
                    color: const Color(0xFF22C55E),
                    items: [
                      'باستخدامك للتطبيق، فإنك توافق على هذه الشروط',
                      'إذا كنت لا توافق، يرجى عدم استخدام التطبيق',
                      'نحن نحتفظ بالحق في تعديل هذه الشروط في أي وقت',
                      'استمرارك في استخدام التطبيق يعني موافقتك على التغييرات',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'الحساب والتسجيل',
                    icon: Icons.account_circle_rounded,
                    color: const Color(0xFF3B82F6),
                    items: [
                      'يجب أن تقدم معلومات صحيحة وكاملة عند التسجيل',
                      'أنت المسؤول عن الحفاظ على سرية حسابك وكلمة المرور',
                      'يحق لنا تعليق أو إلغاء حسابك في حال المخالفة',
                      'يجب أن يكون عمرك 16 عاماً على الأقل لاستخدام التطبيق',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'استخدام التطبيق',
                    icon: Icons.phone_android_rounded,
                    color: const Color(0xFF8B5CF6),
                    items: [
                      'استخدام التطبيق للأغراض الشخصية والتعليمية فقط',
                      'لا يجوز استخدام التطبيق لأغراض غير قانونية',
                      'لا يجوز نسخ أو توزيع محتوى التطبيق دون إذن',
                      'نحن غير مسؤولين عن أي أضرار ناتجة عن سوء الاستخدام',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'التوصيات الأكاديمية',
                    icon: Icons.school_rounded,
                    color: const Color(0xFFF97316),
                    items: [
                      'التوصيات مبنية على تحليل البيانات وهي لأغراض إرشادية',
                      'لا نضمن دقة التوصيات بنسبة 100%',
                      'القرار النهائي يعود لك وللجهات المختصة',
                      'نحن لسنا مسؤولين عن أي قرارات تتخذها بناءً على التوصيات',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'الملكية الفكرية',
                    icon: Icons.copyright_rounded,
                    color: const Color(0xFFDC2626),
                    items: [
                      'جميع المحتويات محمية بحقوق الملكية الفكرية',
                      'اسم التطبيق والشعار والعلامات التجارية مملوكة لنا',
                      'لا يجوز استخدام المحتوى لأغراض تجارية دون إذن',
                      'المحتوى المقدم من قبل المستخدمين يظل ملكاً لهم',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'الخصوصية والبيانات',
                    icon: Icons.privacy_tip_rounded,
                    color: const Color(0xFFA855F7),
                    items: [
                      'نحن نلتزم بحماية بياناتك وخصوصيتك',
                      'نجمع البيانات اللازمة لتقديم الخدمات',
                      'لا نشارك بياناتك مع أطراف ثالثة دون موافقتك',
                      'يمكنك طلب حذف بياناتك في أي وقت',
                      'للمزيد من التفاصيل، راجع سياسة الخصوصية',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'إخلاء المسؤولية',
                    icon: Icons.warning_amber_rounded,
                    color: const Color(0xFFDC2626),
                    items: [
                      'التطبيق يقدم خدماته "كما هي" دون أي ضمانات',
                      'لا نضمن استمرارية أو عدم انقطاع الخدمة',
                      'لا نضمن دقة المعلومات المقدمة من قبل الجامعات',
                      'نحن غير مسؤولين عن أي خسائر أو أضرار ناتجة عن استخدام التطبيق',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'روابط خارجية',
                    icon: Icons.link_rounded,
                    color: const Color(0xFF3B82F6),
                    items: [
                      'التطبيق قد يحتوي على روابط لمواقع خارجية',
                      'نحن غير مسؤولين عن محتوى هذه المواقع',
                      'استخدامك لهذه المواقع يخضع لشروطها الخاصة',
                      'نوصي بقراءة سياسة الخصوصية لكل موقع',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'التعديلات على الشروط',
                    icon: Icons.update_rounded,
                    color: const Color(0xFF8B5CF6),
                    items: [
                      'نحتفظ بالحق في تعديل هذه الشروط في أي وقت',
                      'سنقوم بإعلامك بالتغييرات الجوهرية',
                      'آخر تحديث لهذه الشروط: 12 أغسطس 2026',
                      'استمرارك في استخدام التطبيق يعني موافقتك على الشروط الجديدة',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'القانون المعمول به',
                    icon: Icons.gavel_rounded,
                    color: const Color(0xFFDC2626),
                    items: [
                      'تخضع هذه الشروط لقوانين فلسطين',
                      'أي نزاع يتم حله في محاكم فلسطين',
                      'إذا كان أي شرط غير قانوني، يبقى باقي الشروط سارية',
                      'هذه الشروط تمثل الاتفاق الكامل بيننا وبينك',
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildContactSection(),
                  const SizedBox(height: 24),
                  _buildAgreementButtons(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

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
        'الشروط والأحكام',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryContainer,
        ),
      ),
      centerTitle: true,
    );
  }

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
                  'الشروط والأحكام 📋',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'اقرأ الشروط بعناية قبل استخدام التطبيق',
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
                Icons.description_rounded,
                size: 30,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLastUpdated() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade200, width: 1.2),
      ),
      child: Row(
        children: [
          Icon(
            Icons.update_rounded,
            size: 20,
            color: Colors.blue.shade700,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'آخر تحديث: 12 أغسطس 2026',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.blue.shade700,
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
                          fontSize: 13.5,
                          height: 1.6,
                          color: AppTheme.onSurfaceVariant,
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
            'إذا كان لديك أي استفسار حول الشروط والأحكام، يرجى التواصل معنا:',
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

  Widget _buildAgreementButtons() {
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
            onPressed: () => Navigator.pop(context),
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
}
