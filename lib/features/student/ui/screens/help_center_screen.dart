import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpCenterScreen extends StatefulWidget {
  const HelpCenterScreen({super.key});

  @override
  State<HelpCenterScreen> createState() => _HelpCenterScreenState();
}

class _HelpCenterScreenState extends State<HelpCenterScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedCategory = 'all';
  int _expandedIndex = 0;
  bool _showEmptyState = false;

  late final List<Map<String, dynamic>> _allFaqs;

  final List<Map<String, dynamic>> _categories = const [
    {'key': 'all', 'label': 'الكل', 'icon': Icons.grid_view_rounded},
    {
      'key': 'assessment',
      'label': 'التقييم الأكاديمي',
      'icon': Icons.assessment_rounded
    },
    {
      'key': 'universities',
      'label': 'الجامعات',
      'icon': Icons.account_balance_rounded
    },
    {'key': 'account', 'label': 'الحساب والأمان', 'icon': Icons.shield_rounded},
  ];

  @override
  void initState() {
    super.initState();
    _allFaqs = [
      {
        'question': 'كيف يُحسب تقييمي للتخصصات ومطابقة الميول؟',
        'answer':
            'يستخدم NextStep AI نموذجاً تحليلياً متكاملاً يقيس 6 أبعاد رئيسية لشخصيتك وميولك الأكاديمية عبر مقياس هولاند المطوّر. يُقارن النظام إجاباتك مع ملفات أكاديمية لأكثر من 420 مساراً دراسياً مختلفاً. يعتمد على معايير تشمل: القدرات الفكرية، التفضيلات المهنية، الميول العلمية، الأهداف الوظيفية، بيئة التعلم المفضلة، والمهارات الشخصية. النتيجة: توصيات دقيقة ونسبة توافق لكل تخصص.',
        'category': 'assessment',
        'hasCta': true,
        'ctaText': 'اذهب للتقييم الذكي',
      },
      {
        'question': 'ما الفرق في معايير القبول بين الجامعات الشريكة؟',
        'answer':
            'تختلف معايير القبول بشكل كبير من جامعة لأخرى ومن تخصص لآخر. يعرض لك التطبيق جدولاً تفصيلياً يشمل: المعدل المطلوب، المواد الأساسية المطلوبة، اختبارات القبول الإضافية إن وُجدت، والمواعيد النهائية للتقديم. كما يوفر نسب قبول محدثة من السنوات السابقة لمساعدتك في تقييم فرصك بشكل واقعي.',
        'category': 'universities',
        'hasCta': false,
        'ctaText': '',
      },
      {
        'question': 'هل معدل الثانوية هو المعيار الوحيد للقبول؟',
        'answer':
            'لا، معدل الثانوية عامل مهم لكنه ليس الوحيد. تأخذ بعض الجامعات والبرامج في الاعتبار عوامل أخرى مثل: اختبارات القبول الموحدة، المقابلات الشخصية، النشاطات اللاصفية، الرسائل التعريفية، وخبرات التطوع. يوضح لك التطبيق لكل تخصص ما هي العوامل المهمة التي تؤثر على قبولك.',
        'category': 'universities',
        'hasCta': false,
        'ctaText': '',
      },
      {
        'question': 'كيف أستفيد بالشكل الأمثل من المساعد الأكاديمي؟',
        'answer':
            'المساعد الأكاديمي المدعوم بالذكاء الاصطناعي يمكنه مساعدتك في عدة محاور: طرح أسئلة توضيحية حول تخصصات معينة، شرح محتوى المواد الدراسية لكل مسار، تقديم نصائح للتميز الأكاديمي، المساعدة في فهم نتائج التقييم الذكي، والإجابة على أسئلتك حول الجامعات والتقديم. كلما كانت أسئلتك محددة وواضحة، كانت الإجابات أكثر فائدة.',
        'category': 'assessment',
        'hasCta': false,
        'ctaText': '',
      },
      {
        'question': 'كيف يمكنني تعديل بياناتي الأكاديمية والشخصية؟',
        'answer':
            'يمكنك تعديل بياناتك في أي وقت من خلال: الذهاب إلى الملف الشخصي، ثم الضغط على تعديل البيانات. يمكنك تحديث: المعدل التراكمي، المواد المجتازة، المدينة، رقم الهاتف، والبيانات الشخصية الأخرى. بعد التعديل، قد تتأثر نتائج التقييم والتوصيات بناءً على البيانات الجديدة.',
        'category': 'account',
        'hasCta': false,
        'ctaText': '',
      },
      {
        'question': 'كيف أتحكم في تكرار ونوع إشعارات الفرص والمنح؟',
        'answer':
            'من خلال صفحة الإعدادات ثم تفضيلات الإشعارات، يمكنك التحكم في: نوع الإشعارات (فرص دراسية، منح دراسية، مواعيد نهائية)، تكرار الإشعارات (فوري، يومي، أسبوعي)، وإشعارات حسب تخصصاتك المفضلة. يمكنك أيضاً تفعيل أو تعطيل الإشعارات بالكامل.',
        'category': 'account',
        'hasCta': false,
        'ctaText': '',
      },
    ];
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filteredFaqs {
    List<Map<String, dynamic>> filtered = List.of(_allFaqs);
    if (_selectedCategory != 'all') {
      filtered =
          filtered.where((f) => f['category'] == _selectedCategory).toList();
    }
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      filtered = filtered
          .where((f) =>
              (f['question'] as String).contains(query) ||
              (f['answer'] as String).contains(query))
          .toList();
    }
    return filtered;
  }

  Color _categoryIconColor(String category, AppColors c) {
    switch (category) {
      case 'assessment':
        return c.primary;
      case 'universities':
        return c.success;
      case 'account':
        return c.accent;
      default:
        return c.textSecondary;
    }
  }

  Color _categoryIconBg(String category, AppColors c) {
    switch (category) {
      case 'assessment':
        return c.primarySoft;
      case 'universities':
        return c.successSoft;
      case 'account':
        return c.accentSoft;
      default:
        return c.surfaceAlt;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    final filtered = _filteredFaqs;
    _showEmptyState = filtered.isEmpty;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        body: Column(
          children: [
            _buildHeader(c),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildWelcomeBanner(c),
                    const SizedBox(height: 20),
                    _buildSearchBar(c),
                    const SizedBox(height: 16),
                    _buildCategoryChips(c),
                    const SizedBox(height: 24),
                    if (_showEmptyState)
                      _buildEmptyState(c)
                    else
                      _buildFaqSection(c, filtered),
                    const SizedBox(height: 24),
                    _buildCtaCard(c),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
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
          border: Border(
              bottom: BorderSide(
                  color: c.divider.withValues(alpha: 0.4), width: 0.5)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: c.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(Icons.arrow_forward_ios_rounded,
                    size: 18, color: c.textPrimary),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'مركز المساعدة والدعم',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeBanner(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
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
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              left: -20,
              bottom: -20,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.08),
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.auto_awesome,
                                size: 14, color: Colors.white),
                            SizedBox(width: 6),
                            Text(
                              ' مركز التوجيه والمساعدة',
                              style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'كيف نساعدك اليوم؟',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.3,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'ابحث عن إجابات لأسئلتك أو تواصل مع فريق الدعم',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.white.withValues(alpha: 0.85),
                          height: 1.5,
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
                  child: const Icon(Icons.support_agent_rounded,
                      size: 30, color: Colors.white),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar(AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.06),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            const SizedBox(width: 12),
            Icon(Icons.search_rounded, size: 22, color: c.primaryContainer),
            const SizedBox(width: 8),
            Expanded(
              child: TextField(
                controller: _searchController,
                textDirection: TextDirection.rtl,
                onChanged: (_) => setState(() {}),
                decoration: InputDecoration(
                  hintText: 'ابحث عن سؤال، معيار قبول، أو تخصص...',
                  hintStyle: TextStyle(
                      fontSize: 13,
                      color: c.textSecondary.withValues(alpha: 0.6)),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
                style: TextStyle(fontSize: 14, color: c.textPrimary),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  setState(() {});
                },
                child: Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: c.surfaceAlt,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 16, color: c.textSecondary),
                ),
              ),
            const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips(AppColors c) {
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final cat = _categories[index];
          final isSelected = _selectedCategory == cat['key'];
          return GestureDetector(
            onTap: () {
              setState(() => _selectedCategory = cat['key'] as String);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected ? c.primaryContainer : c.surfaceAlt,
                borderRadius: BorderRadius.circular(12),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                            color: c.primaryContainer.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 2))
                      ]
                    : [],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(cat['icon'] as IconData,
                      size: 16,
                      color: isSelected ? Colors.white : c.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    cat['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFaqSection(AppColors c, List<Map<String, dynamic>> faqs) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.help_center_rounded,
                  size: 20, color: c.primaryContainer),
              const SizedBox(width: 8),
              Text(
                'الأسئلة الأكثر تكراراً',
                style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '${faqs.length} أسئلة',
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: c.primaryContainer),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...List.generate(
              faqs.length, (index) => _buildFaqItem(faqs, index, c)),
        ],
      ),
    );
  }

  Widget _buildFaqItem(
      List<Map<String, dynamic>> faqs, int index, AppColors c) {
    final faq = faqs[index];
    final isExpanded = _expandedIndex == index;

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.04),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            GestureDetector(
              onTap: () {
                setState(() {
                  _expandedIndex = _expandedIndex == index ? -1 : index;
                });
              },
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: _categoryIconBg(faq['category'] as String, c),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 20,
                        color: _categoryIconColor(faq['category'] as String, c),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        faq['question'] as String,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                          height: 1.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 300),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22,
                        color: c.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            if (isExpanded) ...[
              Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                height: 1,
                color: c.divider.withValues(alpha: 0.3),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faq['answer'] as String,
                      style: TextStyle(
                        fontSize: 13,
                        height: 1.7,
                        color: c.textSecondary,
                      ),
                    ),
                    if (faq['hasCta'] == true) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: c.primarySoft,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.timer_outlined,
                                size: 16, color: c.primaryContainer),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'اختبارك يستغرق 7 دقائق فقط',
                                style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: c.primaryContainer),
                              ),
                            ),
                            GestureDetector(
                              onTap: () => context.push('/student/assessment'),
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 6),
                                decoration: BoxDecoration(
                                  color: c.primaryContainer,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  faq['ctaText'] as String,
                                  style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.white),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          const SizedBox(height: 40),
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: c.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.search_off_rounded,
                size: 40, color: c.textSecondary.withValues(alpha: 0.5)),
          ),
          const SizedBox(height: 20),
          Text(
            'لم نعثر على أسئلة مطابقة',
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.textPrimary),
          ),
          const SizedBox(height: 8),
          Text(
            'جرب كلمات بحث أخرى',
            style: TextStyle(fontSize: 13, color: c.textSecondary),
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => _launchURL('mailto:nextstepai12@gmail.com'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              decoration: BoxDecoration(
                color: c.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'تواصل معنا',
                style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white),
              ),
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildCtaCard(AppColors c) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [c.primary, c.primaryDark],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.3),
              blurRadius: 30,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Positioned(
              right: -30,
              top: -30,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.06),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.contact_support_rounded,
                      size: 26, color: Colors.white),
                ),
                const SizedBox(height: 16),
                const Text(
                  'لم تجد إجابتك بعد؟',
                  style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: Colors.white),
                ),
                const SizedBox(height: 8),
                Text(
                  'فريق الدعم جاهز لمساعدتك في أي وقت. تواصل معنا وسنرد عليك في أقرب وقت.',
                  style: TextStyle(
                      fontSize: 13,
                      color: Colors.white.withValues(alpha: 0.85),
                      height: 1.6),
                ),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () => _launchURL('mailto:nextstepai12@gmail.com'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.mail_outline_rounded,
                            size: 18, color: c.primaryContainer),
                        const SizedBox(width: 8),
                        Text(
                          'تواصل معنا عبر البريد والمحادثة',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              color: c.primaryContainer),
                        ),
                      ],
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

  Future<void> _launchURL(String url) async {
    try {
      final Uri uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              behavior: SnackBarBehavior.floating,
              margin: const EdgeInsets.all(16),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              backgroundColor: context.appColors.danger,
              content: const Row(
                children: [
                  Icon(Icons.error_outline, color: Colors.white, size: 20),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'لا يمكن فتح الرابط',
                      style: TextStyle(color: Colors.white, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            behavior: SnackBarBehavior.floating,
            margin: const EdgeInsets.all(16),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            backgroundColor: context.appColors.danger,
            content: const Row(
              children: [
                Icon(Icons.error_outline, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'حدث خطأ أثناء فتح الرابط',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
        );
      }
    }
  }
}
