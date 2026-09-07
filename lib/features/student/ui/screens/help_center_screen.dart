import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // قائمة الأسئلة الشائعة
  final List<Map<String, String>> _faqs = [
    {
      'question': 'ما هو NextStep AI؟',
      'answer':
          'NextStep AI هي منصة ذكية للإرشاد الأكاديمي والمهني تستخدم الذكاء الاصطناعي لمساعدة الطلاب في اختيار التخصصات والجامعات المناسبة بناءً على ميولهم وقدراتهم.',
    },
    {
      'question': 'كيف يمكنني إنشاء حساب؟',
      'answer':
          'يمكنك إنشاء حساب جديد من خلال النقر على زر "إنشاء حساب جديد" في شاشة تسجيل الدخول، ثم ملء البيانات المطلوبة مثل الاسم والبريد الإلكتروني وكلمة المرور.',
    },
    {
      'question': 'ما هو الاستبيان الذكي؟',
      'answer':
          'الاستبيان الذكي هو مجموعة من الأسئلة المصممة لتحليل شخصيتك وميولك الأكاديمية والمهنية، ويستخدم لتقديم توصيات دقيقة ومخصصة لك.',
    },
    {
      'question': 'كيف أحصل على التوصيات؟',
      'answer':
          'بعد إكمال الاستبيان الذكي، ستظهر لك التوصيات تلقائياً في صفحة "التوصيات" حيث يمكنك رؤية التخصصات والجامعات المناسبة لك مع نسبة التوافق.',
    },
    {
      'question': 'هل بياناتي آمنة؟',
      'answer':
          'نعم، بياناتك مشفرة ومخزنة بشكل آمن. نحن نلتزم بسياسات الخصوصية الصارمة ولا نشارك بياناتك مع أي طرف ثالث دون موافقتك.',
    },
    {
      'question': 'كيف يمكنني تحديث بياناتي الشخصية؟',
      'answer':
          'يمكنك تحديث بياناتك الشخصية من خلال صفحة "الملف الشخصي" حيث يمكنك تعديل الاسم، رقم الهاتف، المدينة وغيرها من المعلومات.',
    },
    {
      'question': 'ماذا لو نسيت كلمة المرور؟',
      'answer':
          'في حالة نسيان كلمة المرور، يمكنك النقر على "نسيت كلمة المرور" في شاشة تسجيل الدخول، وسنرسل لك رابطاً لإعادة تعيينها عبر البريد الإلكتروني.',
    },
    {
      'question': 'كيف يمكنني التواصل مع الدعم الفني؟',
      'answer':
          'يمكنك التواصل مع فريق الدعم الفني عبر البريد الإلكتروني: nextstepai12@gmail.com، وسنرد عليك في أقرب وقت ممكن.',
    },
  ];

  // قائمة المواضيع
  final List<Map<String, dynamic>> _topics = [
    {
      'title': 'حسابي',
      'icon': Icons.account_circle_rounded,
      'color': const Color(0xFF3B82F6),
      'items': ['تسجيل الدخول', 'إنشاء حساب', 'استعادة كلمة المرور', 'تحديث البيانات'],
    },
    {
      'title': 'الاستبيان والتوصيات',
      'icon': Icons.assessment_rounded,
      'color': const Color(0xFF22C55E),
      'items': ['الاستبيان الذكي', 'نتائج التوصيات', 'نسبة التوافق'],
    },
    {
      'title': 'التطبيق',
      'icon': Icons.app_settings_alt_rounded,
      'color': const Color(0xFF8B5CF6),
      'items': ['الإعدادات', 'الملف الشخصي', 'الإشعارات', 'اللغة'],
    },
  ];

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
    _animationController.forward();
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
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildTopicsSection(),
                  const SizedBox(height: 24),
                  _buildFAQsSection(),
                  const SizedBox(height: 24),
                  _buildContactSection(),
                  const SizedBox(height: 20),
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
        'مركز المساعدة',
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
                  'كيف يمكننا مساعدتك؟ 👋',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  'ابحث عن إجابات لأسئلتك أو تواصل مع فريق الدعم',
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
                Icons.support_agent_rounded,
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
  //  Topics Section
  // ============================================================
  Widget _buildTopicsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'المواضيع الشائعة',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.9,
          ),
          itemCount: _topics.length,
          itemBuilder: (context, index) {
            final topic = _topics[index];
            return _buildTopicCard(
              title: topic['title'],
              icon: topic['icon'],
              color: topic['color'],
              onTap: () {
                _showTopicDialog(topic);
              },
            );
          },
        ),
      ],
    );
  }

  Widget _buildTopicCard({
    required String title,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
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
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  void _showTopicDialog(Map<String, dynamic> topic) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: topic['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    topic['icon'],
                    color: topic['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  topic['title'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ...(topic['items'] as List<String>).map((item) {
              return ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(
                  Icons.circle_rounded,
                  size: 8,
                  color: AppTheme.primary,
                ),
                title: Text(
                  item,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.onSurfaceVariant,
                  ),
                ),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('جاري البحث عن: $item');
                },
              );
            }),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إغلاق'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  FAQs Section
  // ============================================================
  Widget _buildFAQsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'الأسئلة الشائعة',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryContainer,
              ),
            ),
            TextButton(
              onPressed: () {
                // TODO: البحث في الأسئلة
              },
              style: TextButton.styleFrom(
                foregroundColor: AppTheme.secondary,
                textStyle: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('عرض الكل'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ..._faqs.take(4).map((faq) => _buildFAQItem(faq)),
        if (_faqs.length > 4)
          Center(
            child: TextButton(
              onPressed: () {
                // TODO: عرض جميع الأسئلة
              },
              child: const Text('عرض المزيد من الأسئلة'),
            ),
          ),
      ],
    );
  }

  Widget _buildFAQItem(Map<String, String> faq) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          leading: const Icon(
            Icons.help_outline_rounded,
            color: AppTheme.primary,
            size: 22,
          ),
          title: Text(
            faq['question']!,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryContainer,
            ),
          ),
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              child: Text(
                faq['answer']!,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.7,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  //  Contact Section
  // ============================================================
  Widget _buildContactSection() {
    return Container(
      padding: const EdgeInsets.all(20),
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
          _buildContactMethod(
            icon: Icons.email_rounded,
            title: 'البريد الإلكتروني',
            subtitle: 'nextstepai12@gmail.com',
            color: const Color(0xFF3B82F6),
            onTap: () => _launchURL('mailto:nextstepai12@gmail.com'),
          ),
          const SizedBox(height: 8),
          _buildContactMethod(
            icon: Icons.chat_rounded,
            title: 'المساعد الأكاديمي',
            subtitle: 'اسأل الذكاء الاصطناعي',
            color: const Color(0xFF8B5CF6),
            onTap: () {
              Navigator.pop(context);
              context.push('/chat');
            },
          ),
          const SizedBox(height: 8),
          _buildContactMethod(
            icon: Icons.star_rounded,
            title: 'تقييم التطبيق',
            subtitle: 'ساعدنا في التطوير',
            color: const Color(0xFFF97316),
            onTap: () => _launchURL(
                'https://play.google.com/store/apps/details?id=com.example.nextstep_ai_app'),
          ),
        ],
      ),
    );
  }

  Widget _buildContactMethod({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryContainer,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
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
    );
  }

  // ============================================================
  //  Helpers
  // ============================================================
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: const Color(0xFF22C55E),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
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

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        _showSnackBar('لا يمكن فتح الرابط');
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء فتح الرابط');
    }
  }
}