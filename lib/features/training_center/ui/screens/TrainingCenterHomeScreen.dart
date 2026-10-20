import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nextstep_ai_app/core/widgets/app_responsive.dart';

import '../theme/training_colors.dart';
import '../widgets/training_center_drawer.dart';

class TrainingCenterHomeScreen extends StatefulWidget {
  const TrainingCenterHomeScreen({super.key});

  @override
  State<TrainingCenterHomeScreen> createState() =>
      _TrainingCenterHomeScreenState();
}

class _TrainingCenterHomeScreenState extends State<TrainingCenterHomeScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  late final AnimationController _waveController;
  late final Animation<double> _waveAnimation;

  Timer? _countdownTimer;
  int _remainingSeconds =
      const Duration(days: 2, hours: 14, minutes: 30).inSeconds;

  String _selectedCategory = 'الكل';
  String _searchQuery = '';

  List<_ProgramMock> get _filteredPrograms {
    final query = _searchQuery.trim().toLowerCase();
    return _programs.where((program) {
      final matchesCategory =
          _selectedCategory == 'الكل' || program.category == _selectedCategory;
      final matchesSearch = query.isEmpty ||
          program.title.toLowerCase().contains(query) ||
          program.category.toLowerCase().contains(query);
      return matchesCategory && matchesSearch;
    }).toList();
  }

  List<_InstructorMock> get _filteredInstructors {
    final query = _searchQuery.trim().toLowerCase();
    if (query.isEmpty) return _instructors;
    return _instructors
        .where(
          (instructor) =>
              instructor.name.toLowerCase().contains(query) ||
              instructor.specialty.toLowerCase().contains(query),
        )
        .toList();
  }

  static const String _companyName = 'معهد القادة المعتمد للتدريب';
  static const String _location = 'الرياض، المملكة العربية السعودية';

  final List<String> _categories = const [
    'الكل',
    'برمجة',
    'إدارة أعمال',
    'تسويق',
    'تصميم',
    'لغات',
  ];

  final List<_ProgramMock> _programs = const [
    _ProgramMock(
      id: 'p1',
      title: 'تحليل البيانات المتقدم باستخدام Python',
      category: 'برمجة',
      hours: 30,
      rating: 4.8,
      price: 450,
      oldPrice: 600,
      enrolled: 128,
      status: 'الأكثر طلباً',
      statusColor: TrainingColors.success,
      imageSeed: 'datascience',
    ),
    _ProgramMock(
      id: 'p2',
      title: 'استراتيجيات التسويق الرقمي ونمو الشركات',
      category: 'تسويق',
      hours: 20,
      rating: 4.9,
      price: 380,
      oldPrice: 520,
      enrolled: 96,
      status: 'موصى به',
      statusColor: TrainingColors.accent,
      imageSeed: 'marketing',
    ),
    _ProgramMock(
      id: 'p3',
      title: 'تصميم واجهات وتجربة المستخدم Figma & UI',
      category: 'تصميم',
      hours: 25,
      rating: 4.7,
      price: 420,
      oldPrice: 550,
      enrolled: 74,
      status: 'معتمد',
      statusColor: TrainingColors.primary,
      imageSeed: 'uidesign',
    ),
    _ProgramMock(
      id: 'p4',
      title: 'أساسيات الأمن السيبراني واختبار الاختراق',
      category: 'برمجة',
      hours: 35,
      rating: 4.6,
      price: 550,
      oldPrice: 700,
      enrolled: 152,
      status: 'نشط',
      statusColor: TrainingColors.success,
      imageSeed: 'cybersecurity',
    ),
  ];

  final List<_InstructorMock> _instructors = const [
    _InstructorMock(
      name: 'د. سارة الحربي',
      specialty: 'الذكاء الاصطناعي',
      rating: 4.9,
      avatar: 'https://i.pravatar.cc/160?img=47',
    ),
    _InstructorMock(
      name: 'م. خالد العتيبي',
      specialty: 'إدارة المشاريع',
      rating: 4.8,
      avatar: 'https://i.pravatar.cc/160?img=12',
    ),
    _InstructorMock(
      name: 'د. محمد الزهراني',
      specialty: 'التسويق الرقمي',
      rating: 4.7,
      avatar: 'https://i.pravatar.cc/160?img=33',
    ),
    _InstructorMock(
      name: 'أ. نورة القحطاني',
      specialty: 'تصميم UX',
      rating: 4.9,
      avatar: 'https://i.pravatar.cc/160?img=45',
    ),
    _InstructorMock(
      name: 'د. عبدالله الشمري',
      specialty: 'الأمن السيبراني',
      rating: 4.8,
      avatar: 'https://i.pravatar.cc/160?img=15',
    ),
  ];

  final List<_SessionMock> _sessions = const [
    _SessionMock(
      day: '18',
      month: 'أكتوبر',
      title: 'ورشة مقدمة في الذكاء الاصطناعي التوليدي للأعمال',
      time: '07:00 م - 09:00 م',
      mode: 'عبر زووم (مباشر)',
      online: true,
      accent: TrainingColors.primary,
    ),
    _SessionMock(
      day: '21',
      month: 'أكتوبر',
      title: 'دورة مهارات التفاوض والإقناع للمدراء والقادة',
      time: '06:30 م - 08:30 م',
      mode: 'الرياض (حضوري)',
      online: false,
      accent: TrainingColors.accentDark,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _waveController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);
    _waveAnimation = Tween<double>(begin: -0.18, end: 0.18).animate(
      CurvedAnimation(parent: _waveController, curve: Curves.easeInOut),
    );

    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() {
        if (_remainingSeconds > 0) _remainingSeconds--;
      });
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _searchController.dispose();
    _waveController.dispose();
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
            Padding(
              padding: EdgeInsets.fromLTRB(16.w, 34.h, 16.w, 0),
              child: const Align(
                alignment: AlignmentDirectional.centerStart,
                child: SampleDataBadge(),
              ),
            ),
            SizedBox(height: 8.h),
            _buildCategories(),
            SizedBox(height: 6.h),
            _buildActiveProgramCard(context),
            SizedBox(height: 22.h),
            _buildProgramsSection(context),
            SizedBox(height: 22.h),
            _buildInstructorsSection(context),
            SizedBox(height: 22.h),
            _buildOfferBanner(context),
            SizedBox(height: 24.h),
            _buildSessionsSection(context),
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
          padding: EdgeInsets.fromLTRB(16.w, topInset + 14.h, 16.w, 48.h),
          decoration: BoxDecoration(
            gradient: TrainingColors.headerGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
            boxShadow: TrainingColors.headerShadow,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: _buildGreeting()),
              SizedBox(width: 8.w),
              _headerIconButton(
                icon: Icons.chat_bubble_outline_rounded,
                onTap: () => _comingSoon(context, 'المحادثات'),
              ),
              SizedBox(width: 6.w),
              _headerIconButton(
                icon: Icons.notifications_none_rounded,
                showDot: true,
                onTap: () => context.push('/training-center/notifications'),
              ),
              SizedBox(width: 6.w),
              _headerIconButton(
                icon: Icons.menu_rounded,
                onTap: () => _scaffoldKey.currentState?.openDrawer(),
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

  Widget _buildGreeting() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Flexible(
              child: Text.rich(
                const TextSpan(
                  children: [
                    TextSpan(text: 'صباح الخير، '),
                    TextSpan(
                      text: _companyName,
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                  ],
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 17.sp,
                  height: 1.35,
                  color: TrainingColors.onPrimary,
                ),
              ),
            ),
            SizedBox(width: 4.w),
            RotationTransition(
              turns: _waveAnimation,
              child: Text('👋', style: TextStyle(fontSize: 18.sp)),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Row(
          children: [
            Icon(
              Icons.location_on_rounded,
              size: 15.sp,
              color: TrainingColors.accent,
            ),
            SizedBox(width: 3.w),
            Flexible(
              child: Text(
                _location,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  color: TrainingColors.onPrimary.withValues(alpha: 0.82),
                ),
              ),
            ),
          ],
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
          Icon(
            Icons.search_rounded,
            size: 22.sp,
            color: TrainingColors.textMuted,
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (value) => setState(() => _searchQuery = value),
              textAlign: TextAlign.right,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                color: TrainingColors.textPrimary,
              ),
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: 'ابحث عن برنامج أو مدرب...',
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
                _searchController.clear();
                setState(() => _searchQuery = '');
              },
              child: Container(
                width: 30.w,
                height: 30.w,
                decoration: const BoxDecoration(
                  color: TrainingColors.surfaceAlt,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.close_rounded,
                  size: 17.sp,
                  color: TrainingColors.textSecondary,
                ),
              ),
            )
          else
            GestureDetector(
              onTap: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _selectedCategory = 'الكل';
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
                  Icons.tune_rounded,
                  size: 18.sp,
                  color: TrainingColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  
  
  

  Widget _buildCategories() {
    return SizedBox(
      height: 38.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _categories.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final label = _categories[index];
          final bool active = label == _selectedCategory;
          return GestureDetector(
            onTap: () => setState(() => _selectedCategory = label),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              decoration: BoxDecoration(
                color: active ? TrainingColors.accent : TrainingColors.surface,
                borderRadius: BorderRadius.circular(999.r),
                border:
                    active ? null : Border.all(color: TrainingColors.divider),
                boxShadow: active ? TrainingColors.softShadow : null,
              ),
              child: Row(
                children: [
                  Icon(
                    active ? Icons.stars_rounded : Icons.local_offer_outlined,
                    size: 15.sp,
                    color: active
                        ? TrainingColors.onAccent
                        : TrainingColors.textMuted,
                  ),
                  SizedBox(width: 5.w),
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                      color: active
                          ? TrainingColors.onAccent
                          : TrainingColors.textSecondary,
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

  
  
  

  Widget _buildActiveProgramCard(BuildContext context) {
    return GestureDetector(
      onTap: () => context.push(
        '/training-center/program-details',
        extra: 'p1',
      ),
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 16.w),
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: TrainingColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: TrainingColors.cardShadow,
        ),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              bottom: 0,
              right: 0,
              child: Container(width: 5.w, color: TrainingColors.accent),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(14.w, 14.h, 18.w, 14.h),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: TrainingColors.accentSoft,
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        child: Row(
                          children: [
                            Container(
                              width: 6.w,
                              height: 6.w,
                              decoration: const BoxDecoration(
                                color: TrainingColors.accent,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(width: 5.w),
                            Text(
                              'البرنامج النشط',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: TrainingColors.accent,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Text(
                        'الإشغال 65%',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          color: TrainingColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  Text(
                    'دورة إدارة المشاريع الاحترافية PMP®',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 15.sp,
                      fontWeight: FontWeight.w800,
                      color: TrainingColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 3.h),
                  Row(
                    children: [
                      Icon(
                        Icons.verified_rounded,
                        size: 15.sp,
                        color: TrainingColors.primary,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'المدرب: م. خالد العتيبي',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          color: TrainingColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Row(
                    children: [
                      Text(
                        '65%',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w800,
                          color: TrainingColors.primary,
                        ),
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        'من المقاعد محجوزة',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          color: TrainingColors.textSecondary,
                        ),
                      ),
                      const Spacer(),
                      Icon(
                        Icons.schedule_rounded,
                        size: 14.sp,
                        color: TrainingColors.textMuted,
                      ),
                      SizedBox(width: 3.w),
                      Text(
                        'متبقي 35 مقعداً',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          color: TrainingColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  _buildProgressBar(0.65),
                  SizedBox(height: 14.h),
                  SizedBox(
                    width: double.infinity,
                    height: 46.h,
                    child: ElevatedButton(
                      onPressed: () => context.push(
                        '/training-center/program-details',
                        extra: 'p1',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: TrainingColors.primary,
                        foregroundColor: TrainingColors.onPrimary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'إدارة البرنامج',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Icon(Icons.arrow_back_rounded, size: 18.sp),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar(double value) {
    return SizedBox(
      height: 8.h,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(999.r),
        child: Stack(
          children: [
            const Positioned.fill(
              child: ColoredBox(color: TrainingColors.surfaceMuted),
            ),
            Align(
              alignment: Alignment.centerRight,
              child: FractionallySizedBox(
                widthFactor: value,
                heightFactor: 1,
                child: const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: TrainingColors.accentGradient,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  
  

  Widget _buildProgramsSection(BuildContext context) {
    final programs = _filteredPrograms;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context,
          title: '🔥 برامجك التدريبية',
          actionLabel: 'عرض الكل',
          onTap: () => context.push('/training-center/programs'),
        ),
        SizedBox(height: 12.h),
        if (programs.isEmpty)
          _buildFilteredEmptyState(
            icon: Icons.search_off_rounded,
            message: 'لا توجد برامج مطابقة',
            hint: 'جرّب تصنيفاً آخر أو غيّر كلمة البحث',
          )
        else
          SizedBox(
            height: 262.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: programs.length,
              separatorBuilder: (_, __) => SizedBox(width: 14.w),
              itemBuilder: (context, index) =>
                  _buildProgramCard(context, programs[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildFilteredEmptyState({
    required IconData icon,
    required String message,
    required String hint,
  }) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 24.h),
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: TrainingColors.divider),
      ),
      child: Column(
        children: [
          Icon(icon, size: 34.sp, color: TrainingColors.textMuted),
          SizedBox(height: 10.h),
          Text(
            message,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              fontWeight: FontWeight.w700,
              color: TrainingColors.textPrimary,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            hint,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.sp,
              color: TrainingColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard(BuildContext context, _ProgramMock program) {
    return GestureDetector(
      onTap: () => context.push(
        '/training-center/program-details',
        extra: program.id,
      ),
      child: Container(
        width: 238.w,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: TrainingColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: TrainingColors.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 124.h,
              child: Stack(
                children: [
                  _remoteImage(program.imageSeed, width: 238.w, height: 124.h),
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.0),
                            Colors.black.withValues(alpha: 0.35),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 10.h,
                    right: 10.w,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 3.h,
                      ),
                      decoration: BoxDecoration(
                        color: program.statusColor,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        program.status,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.sp,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: -2.h,
                    left: 12.w,
                    child: Container(
                      width: 38.w,
                      height: 38.w,
                      decoration: BoxDecoration(
                        color: TrainingColors.surface,
                        shape: BoxShape.circle,
                        boxShadow: TrainingColors.softShadow,
                        border: Border.all(
                          color: TrainingColors.surface,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.school_rounded,
                        size: 18.sp,
                        color: TrainingColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 12.h, 12.w, 6.h),
              child: Text(
                program.title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  height: 1.35,
                  color: TrainingColors.textPrimary,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 14.sp,
                    color: TrainingColors.textMuted,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    '${program.hours} ساعة',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5.sp,
                      color: TrainingColors.textSecondary,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.star_rounded,
                    size: 15.sp,
                    color: TrainingColors.rating,
                  ),
                  SizedBox(width: 2.w),
                  Text(
                    program.rating.toStringAsFixed(1),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5.sp,
                      fontWeight: FontWeight.w700,
                      color: TrainingColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 6.h, 12.w, 12.h),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    program.price.toStringAsFixed(0),
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: TrainingColors.primary,
                    ),
                  ),
                  SizedBox(width: 2.w),
                  Padding(
                    padding: EdgeInsets.only(bottom: 2.h),
                    child: Text(
                      'ر.س',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.sp,
                        color: TrainingColors.primary,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    '${program.oldPrice.toStringAsFixed(0)} ر.س',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      decoration: TextDecoration.lineThrough,
                      color: TrainingColors.textMuted,
                    ),
                  ),
                  const Spacer(),
                  Icon(
                    Icons.bookmark_border_rounded,
                    size: 20.sp,
                    color: TrainingColors.primary,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  
  

  Widget _buildInstructorsSection(BuildContext context) {
    final instructors = _filteredInstructors;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader(
          context,
          title: '🏢 مدربون متميزون',
          actionLabel: 'عرض الكل',
          onTap: () => context.push('/training-center/instructors'),
        ),
        SizedBox(height: 12.h),
        if (instructors.isEmpty)
          _buildFilteredEmptyState(
            icon: Icons.person_search_rounded,
            message: 'لا يوجد مدربون مطابقون',
            hint: 'جرّب البحث باسم أو تخصص مختلف',
          )
        else
          SizedBox(
            height: 116.h,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              itemCount: instructors.length,
              separatorBuilder: (_, __) => SizedBox(width: 14.w),
              itemBuilder: (context, index) =>
                  _buildInstructorItem(context, instructors[index]),
            ),
          ),
      ],
    );
  }

  Widget _buildInstructorItem(BuildContext context, _InstructorMock item) {
    return GestureDetector(
      onTap: () => context.push('/training-center/instructors'),
      child: SizedBox(
        width: 78.w,
        child: Column(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  padding: EdgeInsets.all(2.r),
                  decoration: BoxDecoration(
                    color: TrainingColors.surface,
                    shape: BoxShape.circle,
                    border: Border.all(color: TrainingColors.divider),
                  ),
                  child: ClipOval(
                    child: Image.network(
                      item.avatar,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: TrainingColors.navySoft,
                        alignment: Alignment.center,
                        child: Icon(
                          Icons.person_rounded,
                          size: 28.sp,
                          color: TrainingColors.primary,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: -2.w,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 5.w,
                      vertical: 1.h,
                    ),
                    decoration: BoxDecoration(
                      color: TrainingColors.surface,
                      borderRadius: BorderRadius.circular(999.r),
                      boxShadow: TrainingColors.softShadow,
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.star_rounded,
                          size: 11.sp,
                          color: TrainingColors.rating,
                        ),
                        SizedBox(width: 1.w),
                        Text(
                          item.rating.toStringAsFixed(1),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w700,
                            color: TrainingColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Text(
              item.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.sp,
                fontWeight: FontWeight.w700,
                color: TrainingColors.textPrimary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              item.specialty,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.sp,
                color: TrainingColors.textMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  
  

  Widget _buildOfferBanner(BuildContext context) {
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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.bolt_rounded,
                      size: 20.sp,
                      color: Colors.white,
                    ),
                    SizedBox(width: 5.w),
                    Expanded(
                      child: Text(
                        'عرض محدود: وفّر 30% عند الترقية للباقة الاحترافية',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 13.5.sp,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 6.h),
                Text(
                  'برامج غير محدودة، تقارير متقدمة، ودعم أولوية لمركزك التدريبي.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.5.sp,
                    height: 1.6,
                    color: Colors.white.withValues(alpha: 0.95),
                  ),
                ),
                SizedBox(height: 14.h),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _countdownPill(
                        _twoDigits(_remainingSeconds ~/ 86400), 'يوم'),
                    _countdownColon(),
                    _countdownPill(
                      _twoDigits((_remainingSeconds % 86400) ~/ 3600),
                      'ساعة',
                    ),
                    _countdownColon(),
                    _countdownPill(
                      _twoDigits((_remainingSeconds % 3600) ~/ 60),
                      'دقيقة',
                    ),
                    const Spacer(),
                    GestureDetector(
                      onTap: () => context.push('/training-center/settings'),
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
                              'ترقية الباقة',
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _countdownPill(String value, String label) {
    return Column(
      children: [
        Container(
          width: 34.w,
          padding: EdgeInsets.symmetric(vertical: 6.h),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TrainingColors.surface,
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              fontWeight: FontWeight.w800,
              color: TrainingColors.primary,
            ),
          ),
        ),
        SizedBox(height: 3.h),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 9.sp,
            color: Colors.white.withValues(alpha: 0.9),
          ),
        ),
      ],
    );
  }

  Widget _countdownColon() {
    return Padding(
      padding: EdgeInsets.only(bottom: 16.h, left: 3.w, right: 3.w),
      child: Text(
        ':',
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 14.sp,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
      ),
    );
  }

  
  
  

  Widget _buildSessionsSection(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader(
            context,
            title: '📅 ورش وجلسات هذا الأسبوع',
            actionLabel: 'عرض الجدول',
            onTap: () => context.push('/training-center/programs'),
          ),
          SizedBox(height: 12.h),
          ..._sessions.map((s) => Padding(
                padding: EdgeInsets.only(bottom: 12.h),
                child: _buildSessionCard(context, s),
              )),
        ],
      ),
    );
  }

  Widget _buildSessionCard(BuildContext context, _SessionMock session) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.softShadow,
      ),
      child: Row(
        children: [
          Container(
            width: 54.w,
            height: 54.w,
            decoration: BoxDecoration(
              color: session.accent,
              borderRadius: BorderRadius.circular(13.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  session.day,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    height: 1.0,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  session.month,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.sp,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: TrainingColors.textPrimary,
                  ),
                ),
                SizedBox(height: 5.h),
                Row(
                  children: [
                    Icon(
                      session.online
                          ? Icons.videocam_outlined
                          : Icons.location_on_outlined,
                      size: 14.sp,
                      color: session.accent,
                    ),
                    SizedBox(width: 4.w),
                    Expanded(
                      child: Text(
                        '${session.time} • ${session.mode}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          color: TrainingColors.textMuted,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => _comingSoon(context, 'إدارة الجلسة'),
            child: Row(
              children: [
                Text(
                  'إدارة',
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

  
  
  

  Widget _sectionHeader(
    BuildContext context, {
    required String title,
    required String actionLabel,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 17.sp,
              fontWeight: FontWeight.w800,
              color: TrainingColors.textPrimary,
            ),
          ),
          const Spacer(),
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

  Widget _remoteImage(String seed,
      {required double width, required double height}) {
    return Image.network(
      'https://picsum.photos/seed/$seed/${width.toInt()}/${height.toInt()}',
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => Container(
        width: width,
        height: height,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [TrainingColors.primaryContainer, TrainingColors.primary],
          ),
        ),
        alignment: Alignment.center,
        child: Icon(
          Icons.image_outlined,
          size: 30.sp,
          color: Colors.white.withValues(alpha: 0.5),
        ),
      ),
    );
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

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





class _ProgramMock {
  final String id;
  final String title;
  final String category;
  final int hours;
  final double rating;
  final double price;
  final double oldPrice;
  final int enrolled;
  final String status;
  final Color statusColor;
  final String imageSeed;

  const _ProgramMock({
    required this.id,
    required this.title,
    required this.category,
    required this.hours,
    required this.rating,
    required this.price,
    required this.oldPrice,
    required this.enrolled,
    required this.status,
    required this.statusColor,
    required this.imageSeed,
  });
}

class _InstructorMock {
  final String name;
  final String specialty;
  final double rating;
  final String avatar;

  const _InstructorMock({
    required this.name,
    required this.specialty,
    required this.rating,
    required this.avatar,
  });
}

class _SessionMock {
  final String day;
  final String month;
  final String title;
  final String time;
  final String mode;
  final bool online;
  final Color accent;

  const _SessionMock({
    required this.day,
    required this.month,
    required this.title,
    required this.time,
    required this.mode,
    required this.online,
    required this.accent,
  });
}
