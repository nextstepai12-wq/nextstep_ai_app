import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nextstep_ai_app/core/widgets/app_responsive.dart';

import '../theme/training_colors.dart';
import '../widgets/training_center_drawer.dart';

class HelpScreen extends StatefulWidget {
  const HelpScreen({super.key});

  @override
  State<HelpScreen> createState() => _HelpScreenState();
}

class _HelpScreenState extends State<HelpScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  int _selectedCategoryFilter = -1;
  int _expandedFaqIndex = -1;

  final List<Map<String, dynamic>> _helpCategories = [
    {
      'title': 'إدارة الحساب',
      'description': 'إعدادات الملف الشخصي، كلمات المرور، الصلاحيات.',
      'icon': Icons.person_rounded,
      'color': TrainingColors.primary,
      'bg': TrainingColors.navySoft,
      'articles': 12,
    },
    {
      'title': 'الدعم التقني',
      'description': 'مشاكل النظام، الأخطاء، توافق الأجهزة.',
      'icon': Icons.computer_rounded,
      'color': TrainingColors.primaryContainer,
      'bg': TrainingColors.surfaceAlt,
      'articles': 8,
    },
    {
      'title': 'الفواتير والدفع',
      'description': 'الاشتراكات، طرق الدفع، الفواتير الضريبية.',
      'icon': Icons.payments_rounded,
      'color': TrainingColors.accent,
      'bg': TrainingColors.accentSoft,
      'articles': 6,
    },
    {
      'title': 'إدارة الدورات',
      'description': 'إضافة المحتوى، شهادات الطلاب، التقييمات.',
      'icon': Icons.school_rounded,
      'color': TrainingColors.success,
      'bg': TrainingColors.successSoft,
      'articles': 10,
    },
  ];

  final List<Map<String, dynamic>> _faqs = [
    {
      'question': 'كيف يمكنني إضافة مدرب جديد إلى النظام؟',
      'answer':
          'يمكنك إضافة مدرب جديد من خلال الذهاب إلى قسم "المدربون" ثم الضغط على زر "إضافة مدرب" وملء البيانات المطلوبة.',
      'category': 'إدارة الحساب',
    },
    {
      'question': 'ما هي طريقة تصدير تقارير الطلاب؟',
      'answer':
          'يمكنك تصدير تقارير الطلاب بصيغة PDF أو Excel من خلال الذهاب إلى قسم "التقارير" واختيار التقرير المطلوب.',
      'category': 'التقارير والإحصائيات',
    },
    {
      'question': 'كيف يمكنني تغيير باقة الاشتراك؟',
      'answer':
          'يمكنك تغيير باقة الاشتراك من خلال الذهاب إلى "الإعدادات" ثم "الاشتراكات" واختيار الباقة المناسبة.',
      'category': 'الفواتير والدفع',
    },
    {
      'question': 'هل يمكنني إلغاء اشتراك في برنامج تدريبي؟',
      'answer':
          'نعم، يمكنك إلغاء الاشتراك من خلال قسم "البرامج التدريبية" واختيار البرنامج ثم الضغط على "إلغاء الاشتراك" قبل بدئه بـ 48 ساعة.',
      'category': 'إدارة الدورات',
    },
  ];

  final List<Map<String, dynamic>> _activeTickets = [
    {
      'id': '#1234',
      'title': 'مشكلة في تصدير التقارير',
      'status': 'قيد المعالجة',
      'statusColor': TrainingColors.primaryContainer,
      'time': 'منذ ساعتين',
    },
    {
      'id': '#1230',
      'title': 'تحديث بيانات المدرب',
      'status': 'بانتظار الرد',
      'statusColor': TrainingColors.rating,
      'time': 'منذ يوم واحد',
    },
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: TrainingColors.background,
      drawer: const TrainingCenterDrawer(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 34.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: const Align(
                alignment: AlignmentDirectional.centerStart,
                child: SampleDataBadge(),
              ),
            ),
            SizedBox(height: 12.h),
            _buildQuickContact(context),
            SizedBox(height: 22.h),
            _buildSupportStats(),
            SizedBox(height: 22.h),
            _buildHelpCategories(context),
            SizedBox(height: 22.h),
            _buildFAQs(),
            SizedBox(height: 22.h),
            _buildActiveTicketsSection(context),
            SizedBox(height: 22.h),
            _buildContactBanner(context),
            SizedBox(height: 28.h),
          ],
        ),
      ),
    );
  }

  
  
  

  Widget _buildHeader(BuildContext context) {
    final double topInset = MediaQuery.of(context).padding.top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, topInset + 12.h, 16.w, 46.h),
          decoration: const BoxDecoration(
            gradient: TrainingColors.headerGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: TrainingColors.headerShadow,
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30.h,
                left: -30.w,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: -46.h,
                left: -46.w,
                child: Container(
                  width: 150.w,
                  height: 150.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _headerIconButton(
                        icon: Icons.menu_rounded,
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      const Spacer(),
                      _headerIconButton(
                        icon: Icons.notifications_none_rounded,
                        showDot: true,
                        onTap: () =>
                            context.push('/training-center/notifications'),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: [
                      Container(
                        width: 44.w,
                        height: 44.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                        ),
                        child: Icon(
                          Icons.support_agent_rounded,
                          size: 23.sp,
                          color: TrainingColors.accent,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'المساعدة والدعم',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 18,
                                fontWeight: FontWeight.w800,
                                color: TrainingColors.onPrimary,
                              ),
                            ),
                            SizedBox(height: 2.h),
                            Text(
                              'مركز المساعدة لمراكز التدريب',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 12.sp,
                                color: TrainingColors.onPrimary
                                    .withValues(alpha: 0.8),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: -26.h,
          child: _buildSearchBar(),
        ),
      ],
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 21.sp, color: TrainingColors.onPrimary),
            if (showDot)
              Positioned(
                top: 9.h,
                right: 9.w,
                child: Container(
                  width: 9.w,
                  height: 9.w,
                  decoration: BoxDecoration(
                    color: TrainingColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: TrainingColors.primaryContainer,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 52.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(999.r),
        boxShadow: TrainingColors.cardShadow,
      ),
      child: Row(
        children: [
          const Icon(
            Icons.search_rounded,
            size: 22,
            color: TrainingColors.textMuted,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              textAlign: TextAlign.right,
              onChanged: (value) => setState(() => _searchQuery = value),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                color: TrainingColors.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'ابحث في الأسئلة الشائعة والمقالات...',
                hintStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  color: TrainingColors.textMuted,
                ),
              ),
            ),
          ),
          if (_searchQuery.isNotEmpty)
            GestureDetector(
              onTap: () {
                setState(() {
                  _searchController.clear();
                  _searchQuery = '';
                });
              },
              child: Container(
                width: 34.w,
                height: 34.w,
                decoration: const BoxDecoration(
                  color: TrainingColors.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 18.sp,
                  color: TrainingColors.textSecondary,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () => _comingSoon(context, 'تصفية البحث'),
              child: Container(
                width: 34.w,
                height: 34.w,
                decoration: const BoxDecoration(
                  color: TrainingColors.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.tune_rounded,
                  size: 18,
                  color: TrainingColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  
  
  

  Widget _buildQuickContact(BuildContext context) {
    final items = [
      {
        'label': 'دردشة مباشرة',
        'icon': Icons.chat_bubble_rounded,
        'color': TrainingColors.primary,
        'bg': TrainingColors.navySoft,
        'onTap': () => _comingSoon(context, 'الدردشة المباشرة'),
      },
      {
        'label': 'جديد تذكرة',
        'icon': Icons.confirmation_number_rounded,
        'color': TrainingColors.accent,
        'bg': TrainingColors.accentSoft,
        'onTap': () => _comingSoon(context, 'تذكرة جديدة'),
      },
      {
        'label': 'الأسئلة الشائعة',
        'icon': Icons.quiz_outlined,
        'color': TrainingColors.success,
        'bg': TrainingColors.successSoft,
        'onTap': () => _comingSoon(context, 'الأسئلة الشائعة'),
      },
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;
          return Expanded(
            child: GestureDetector(
              onTap: item['onTap'] as VoidCallback,
              child: Container(
                margin: EdgeInsets.only(
                  right: index == 0 ? 0 : 6.w,
                  left: index == items.length - 1 ? 0 : 6.w,
                ),
                padding: EdgeInsets.symmetric(vertical: 14.h),
                decoration: BoxDecoration(
                  color: TrainingColors.surface,
                  borderRadius: BorderRadius.circular(14.r),
                  boxShadow: TrainingColors.softShadow,
                ),
                child: Column(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: BoxDecoration(
                        color: item['bg'] as Color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        item['icon'] as IconData,
                        size: 20.sp,
                        color: item['color'] as Color,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      item['label'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: TrainingColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  
  
  

  Widget _buildSupportStats() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(vertical: 14.h),
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.softShadow,
      ),
      child: Row(
        children: [
          _buildStatItem(
              '48', 'مقالات', Icons.article_rounded, TrainingColors.primary),
          _buildStatDivider(),
          _buildStatItem('156', 'تذاكر محلولة', Icons.check_circle_rounded,
              TrainingColors.success),
          _buildStatDivider(),
          _buildStatItem('2.5س', 'متوسط الرد', Icons.schedule_rounded,
              TrainingColors.accent),
          _buildStatDivider(),
          _buildStatItem(
              '94%', 'الرضا', Icons.star_rounded, TrainingColors.rating),
        ],
      ),
    );
  }

  Widget _buildStatItem(
      String value, String label, IconData icon, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16.sp),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              fontWeight: FontWeight.w800,
              color: TrainingColors.textPrimary,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 9.5.sp,
              color: TrainingColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 44.h,
      color: TrainingColors.divider,
    );
  }

  
  
  

  Widget _buildHelpCategories(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title: '📚 مواضيع المساعدة'),
        SizedBox(height: 12.h),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12.w,
            mainAxisSpacing: 12.h,
            childAspectRatio: 1.25,
          ),
          itemCount: _helpCategories.length,
          itemBuilder: (context, index) {
            final category = _helpCategories[index];
            final bool selected = _selectedCategoryFilter == index;
            return _buildCategoryCard(context, category, selected, () {
              setState(() {
                _selectedCategoryFilter = selected ? -1 : index;
              });
            });
          },
        ),
      ],
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    Map<String, dynamic> category,
    bool selected,
    VoidCallback onTap,
  ) {
    final color = category['color'] as Color;
    final bg = category['bg'] as Color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: TrainingColors.surface,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(
            color: selected ? color : Colors.transparent,
            width: 1.4,
          ),
          boxShadow:
              selected ? TrainingColors.cardShadow : TrainingColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 36.w,
                  height: 36.w,
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Icon(
                    category['icon'] as IconData,
                    color: color,
                    size: 18.sp,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: bg,
                    borderRadius: BorderRadius.circular(999.r),
                  ),
                  child: Text(
                    '${category['articles']} مقالة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 9.sp,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ),
              ],
            ),
            const Spacer(),
            Text(
              category['title'] as String,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: TrainingColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              category['description'] as String,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 9.5.sp,
                height: 1.4,
                color: TrainingColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  
  

  Widget _buildFAQs() {
    final filteredFaqs = _searchQuery.isEmpty
        ? _faqs
        : _faqs
            .where((faq) =>
                faq['question'].toString().contains(_searchQuery) ||
                faq['answer'].toString().contains(_searchQuery))
            .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(title: '❓ الأسئلة الشائعة'),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: filteredFaqs.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: TrainingColors.surface,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: TrainingColors.softShadow,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.search_off_rounded,
                        size: 34.sp,
                        color: TrainingColors.textMuted,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'لا توجد نتائج مطابقة لبحثك',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: TrainingColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: filteredFaqs.asMap().entries.map((entry) {
                    return _buildFAQItem(entry.value, entry.key);
                  }).toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildFAQItem(Map<String, dynamic> faq, int itemIndex) {
    final isExpanded = _expandedFaqIndex == itemIndex;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(
          color: isExpanded
              ? TrainingColors.accent.withValues(alpha: 0.4)
              : Colors.transparent,
          width: 1.2,
        ),
        boxShadow: TrainingColors.softShadow,
      ),
      child: Column(
        children: [
          Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14.r),
            child: InkWell(
              borderRadius: BorderRadius.circular(14.r),
              onTap: () {
                setState(() {
                  _expandedFaqIndex = isExpanded ? -1 : itemIndex;
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 14.h),
                child: Row(
                  children: [
                    Container(
                      width: 32.w,
                      height: 32.w,
                      decoration: BoxDecoration(
                        color: isExpanded
                            ? TrainingColors.accentSoft
                            : TrainingColors.navySoft,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.help_outline_rounded,
                        size: 17.sp,
                        color: isExpanded
                            ? TrainingColors.accent
                            : TrainingColors.primary,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        faq['question'] as String,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          fontWeight:
                              isExpanded ? FontWeight.w800 : FontWeight.w600,
                          color: TrainingColors.textPrimary,
                          height: 1.4,
                        ),
                      ),
                    ),
                    SizedBox(width: 8.w),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        size: 22.sp,
                        color: isExpanded
                            ? TrainingColors.accent
                            : TrainingColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            height: isExpanded ? null : 0,
            child: isExpanded
                ? Container(
                    width: double.infinity,
                    padding: EdgeInsets.fromLTRB(14.w, 4.h, 14.w, 14.h),
                    child: Text(
                      faq['answer'] as String,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.5.sp,
                        height: 1.7,
                        color: TrainingColors.textSecondary,
                      ),
                    ),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  
  
  

  Widget _buildActiveTicketsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(
          title: '🎫 تذاكر الدعم النشطة',
          actionLabel: 'عرض الكل',
          onTap: () => _comingSoon(context, 'جميع التذاكر'),
        ),
        SizedBox(height: 12.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w),
          child: _activeTickets.isEmpty
              ? Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(24.r),
                  decoration: BoxDecoration(
                    color: TrainingColors.surface,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: TrainingColors.softShadow,
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.support_agent_rounded,
                        size: 34.sp,
                        color: TrainingColors.accent,
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        'لا توجد تذاكر نشطة حالياً',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w600,
                          color: TrainingColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: _activeTickets
                      .map((ticket) => _buildTicketItem(ticket))
                      .toList(),
                ),
        ),
      ],
    );
  }

  Widget _buildTicketItem(Map<String, dynamic> ticket) {
    final color = ticket['statusColor'] as Color;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: TrainingColors.softShadow,
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: SizedBox(
              width: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(color: TrainingColors.primary),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 18.w, 14.h),
            child: Row(
              children: [
                Container(
                  width: 42.w,
                  height: 42.w,
                  decoration: BoxDecoration(
                    color: TrainingColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(11.r),
                  ),
                  child: Icon(
                    Icons.receipt_long_rounded,
                    size: 20.sp,
                    color: TrainingColors.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket['title'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.sp,
                          fontWeight: FontWeight.w700,
                          color: TrainingColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: BoxDecoration(
                                    color: color,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  ticket['status'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: color,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            '${ticket['id']} • ${ticket['time']}',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.sp,
                              color: TrainingColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_back_ios_new_rounded,
                  size: 14.sp,
                  color: TrainingColors.textMuted,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  
  
  

  Widget _buildContactBanner(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: TrainingColors.accentGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: TrainingColors.accent.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            top: -46.h,
            left: -46.w,
            child: Container(
              width: 150.w,
              height: 150.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50.h,
            right: -30.w,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: const Icon(
                    Icons.headset_mic_rounded,
                    size: 26,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 14.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'فريق الدعم جاهز للمساعدة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.5,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'متاح على مدار الساعة • 24/7',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.5.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 10.w),
                GestureDetector(
                  onTap: _showContactOptions,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 9.h,
                    ),
                    decoration: BoxDecoration(
                      color: TrainingColors.primary,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'تواصل الآن',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w700,
                            color: TrainingColors.onPrimary,
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Icon(
                          Icons.arrow_back_rounded,
                          size: 15.sp,
                          color: TrainingColors.onPrimary,
                        ),
                      ],
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

  void _showContactOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Container(
            padding: EdgeInsets.all(20.r),
            decoration: BoxDecoration(
              color: TrainingColors.surface,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40.w,
                    height: 4.h,
                    decoration: BoxDecoration(
                      color: TrainingColors.divider,
                      borderRadius: BorderRadius.circular(2.r),
                    ),
                  ),
                ),
                SizedBox(height: 18.h),
                Row(
                  children: [
                    Container(
                      width: 40.w,
                      height: 40.w,
                      decoration: const BoxDecoration(
                        color: TrainingColors.accentSoft,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.support_agent_rounded,
                        size: 21,
                        color: TrainingColors.accent,
                      ),
                    ),
                    SizedBox(width: 10.w),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'اختر طريقة التواصل',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w800,
                            color: TrainingColors.textPrimary,
                          ),
                        ),
                        Text(
                          'فريقنا سيرد عليك في أسرع وقت',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: TrainingColors.textMuted,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 18.h),
                _buildContactOption(
                  icon: Icons.chat_rounded,
                  title: 'الدردشة المباشرة',
                  subtitle: 'متوسط الرد 5 دقائق',
                  color: TrainingColors.primary,
                  bg: TrainingColors.navySoft,
                  onTap: () => _comingSoon(context, 'الدردشة المباشرة'),
                ),
                SizedBox(height: 10.h),
                _buildContactOption(
                  icon: Icons.email_rounded,
                  title: 'البريد الإلكتروني',
                  subtitle: 'support@nextstep.ai',
                  color: TrainingColors.success,
                  bg: TrainingColors.successSoft,
                  onTap: () => _comingSoon(context, 'البريد الإلكتروني'),
                ),
                SizedBox(height: 10.h),
                _buildContactOption(
                  icon: Icons.phone_rounded,
                  title: 'اتصال هاتفي',
                  subtitle: '8001-234-567',
                  color: TrainingColors.accent,
                  bg: TrainingColors.accentSoft,
                  onTap: () => _comingSoon(context, 'الاتصال الهاتفي'),
                ),
                SizedBox(height: 16.h),
                SizedBox(
                  width: double.infinity,
                  height: 46.h,
                  child: GestureDetector(
                    onTap: () => Navigator.pop(sheetContext),
                    child: Container(
                      decoration: BoxDecoration(
                        color: TrainingColors.surfaceAlt,
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'إلغاء',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w700,
                          color: TrainingColors.textSecondary,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 8.h),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildContactOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color bg,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        onTap();
      },
      child: Container(
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: TrainingColors.background,
          borderRadius: BorderRadius.circular(14.r),
          border: Border.all(color: TrainingColors.divider),
        ),
        child: Row(
          children: [
            Container(
              width: 42.w,
              height: 42.w,
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(icon, color: color, size: 21.sp),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.5.sp,
                      fontWeight: FontWeight.w700,
                      color: TrainingColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      color: TrainingColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 14.sp,
              color: TrainingColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  
  
  

  Widget _buildSectionHeader({
    required String title,
    String? actionLabel,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: TrainingColors.textPrimary,
            ),
          ),
          const Spacer(),
          if (actionLabel != null && onTap != null)
            GestureDetector(
              onTap: onTap,
              behavior: HitTestBehavior.opaque,
              child: Row(
                children: [
                  Text(
                    actionLabel,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.5.sp,
                      fontWeight: FontWeight.w700,
                      color: TrainingColors.accent,
                    ),
                  ),
                  Icon(
                    Icons.arrow_back_rounded,
                    size: 15.sp,
                    color: TrainingColors.accent,
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label: قريباً'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
