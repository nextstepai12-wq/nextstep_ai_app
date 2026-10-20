import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/widgets/app_responsive.dart';

import '../../logic/training_center_bloc/training_center_bloc.dart';
import '../../logic/training_programs_bloc/training_programs_bloc.dart';
import '../theme/training_colors.dart';
import '../widgets/training_center_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDataLoaded = false;
  bool _isRefreshing = false;
  bool _isMonthly = true;

  final Map<String, dynamic> _mockStats = {
    'totalStudents': 3240,
    'studentsTrend': '12%',
    'activeCourses': 24,
    'newCourses': '3 جديدة',
    'revenue': '45,800',
    'revenueTrend': '8%',
    'newApplications': 5,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDataLoaded) {
        context.read<TrainingCenterBloc>().add(const LoadTrainingCenters());
        context.read<TrainingProgramsBloc>().add(const LoadTrainingPrograms());
        _isDataLoaded = true;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: TrainingColors.background,
      appBar: _buildAppBar(),
      drawer: const TrainingCenterDrawer(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusBanner(),
            SizedBox(height: 12.h),
            const Align(
              alignment: AlignmentDirectional.centerStart,
              child: SampleDataBadge(),
            ),
            SizedBox(height: 8.h),
            _buildKpiGrid(),
            SizedBox(height: 12.h),
            _buildRevenueChartCard(),
            SizedBox(height: 12.h),
            _buildEnrollmentChartCard(),
            SizedBox(height: 12.h),
            _buildTopCoursesCard(),
            SizedBox(height: 12.h),
            _buildUpcomingActivitiesCard(),
            SizedBox(height: 12.h),
            _buildRecentReviewsCard(),
          ],
        ),
      ),
    );
  }

  

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: Icon(Icons.menu_rounded, color: _primaryContainer, size: 24.sp),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      titleSpacing: 0,
      title: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(6.r),
            child: Image.asset(
              'assets/images/logo.png',
              height: 30.h,
              width: 30.h,
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => Icon(
                Icons.business_rounded,
                color: _primaryContainer,
                size: 22.sp,
              ),
            ),
          ),
          SizedBox(width: 8.w),
          Flexible(
            child: Text(
              'لوحة التحكم',
              style: TextStyle(
                fontSize: 17.sp,
                height: 1.6,
                fontWeight: FontWeight.w600,
                color: _primaryContainer,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        _buildDateFilterChip(),
        SizedBox(width: 8.w),
        BlocBuilder<TrainingCenterBloc, TrainingCenterState>(
          builder: (context, state) {
            String? logoUrl;
            if (state is TrainingCenterLoaded && state.centers.isNotEmpty) {
              logoUrl = state.centers.first.logoUrl;
            }
            return Container(
              width: 34.w,
              height: 34.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _surfaceContainer,
                border: Border.all(color: _outlineVariant),
              ),
              clipBehavior: Clip.antiAlias,
              child: logoUrl != null
                  ? Image.network(logoUrl, fit: BoxFit.cover)
                  : Icon(
                      Icons.person_rounded,
                      color: _primaryContainer,
                      size: 18.sp,
                    ),
            );
          },
        ),
        SizedBox(width: 16.w),
      ],
      centerTitle: false,
      elevation: 0,
      scrolledUnderElevation: 0,
      backgroundColor: TrainingColors.surfaceAlt,
    );
  }

  Widget _buildDateFilterChip() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: _surfaceContainer,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.calendar_today_rounded,
            size: 14.sp,
            color: _primaryContainer,
          ),
          SizedBox(width: 4.w),
          Text(
            'آخر 30 يوم',
            style: TextStyle(
              fontSize: 11.sp,
              height: 1.3,
              fontWeight: FontWeight.w500,
              color: _primaryContainer,
            ),
          ),
          SizedBox(width: 2.w),
          Icon(
            Icons.keyboard_arrow_down_rounded,
            size: 14.sp,
            color: _primaryContainer,
          ),
        ],
      ),
    );
  }

  

  Widget _buildStatusBanner() {
    return BlocBuilder<TrainingCenterBloc, TrainingCenterState>(
      builder: (context, state) {
        String centerName = 'مركز التدريب';
        if (state is TrainingCenterLoaded && state.centers.isNotEmpty) {
          centerName = state.centers.first.name;
        }

        return Container(
          padding: EdgeInsets.all(14.r),
          decoration: BoxDecoration(
            color: _surfaceContainer,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _secondaryContainer,
                      boxShadow: [
                        BoxShadow(
                          color: _secondaryContainer.withValues(alpha: 0.5),
                          blurRadius: 6.r,
                          spreadRadius: 1.r,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'نظرة عامة على أداء $centerName',
                      style: TextStyle(
                        fontSize: 15.sp,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                        color: _primaryContainer,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: _surfaceContainerLowest.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 6.w,
                          height: 6.w,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xFF10B981),
                          ),
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          'بيانات تجريبية',
                          style: TextStyle(
                            fontSize: 10.sp,
                            height: 1.4,
                            fontWeight: FontWeight.w700,
                            color: _onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                    decoration: BoxDecoration(
                      color: _surfaceContainerLowest,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.date_range_rounded,
                          size: 13.sp,
                          color: _primaryContainer,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'آخر 30 يوم',
                          style: TextStyle(
                            fontSize: 11.sp,
                            height: 1.3,
                            fontWeight: FontWeight.w500,
                            color: _primaryContainer,
                          ),
                        ),
                        SizedBox(width: 3.w),
                        Icon(
                          Icons.keyboard_arrow_down_rounded,
                          size: 13.sp,
                          color: _primaryContainer,
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: _isRefreshing ? null : _refresh,
                    child: Container(
                      width: 32.w,
                      height: 32.h,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: _surfaceContainerLowest,
                      ),
                      child: _isRefreshing
                          ? Padding(
                              padding: EdgeInsets.all(8.r),
                              child: CircularProgressIndicator(
                                strokeWidth: 1.6.w,
                                color: _primaryContainer,
                              ),
                            )
                          : Icon(
                              Icons.refresh_rounded,
                              size: 16.sp,
                              color: _primaryContainer,
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _refresh() async {
    setState(() => _isRefreshing = true);
    context.read<TrainingCenterBloc>().add(const LoadTrainingCenters());
    context.read<TrainingProgramsBloc>().add(const LoadTrainingPrograms());
    await Future<void>.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _isRefreshing = false);
  }

  

  Widget _buildKpiGrid() {
    final stats = _mockStats;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            children: [
              _buildKpiCard(
                icon: Icons.group_rounded,
                value: _formatNumber(stats['totalStudents'] as int),
                label: 'إجمالي الطلاب',
                badge: '+${stats['studentsTrend']}',
                badgeColor: _emerald,
              ),
              SizedBox(height: 12.h),
              _buildKpiCard(
                icon: Icons.payments_rounded,
                value: '${stats['revenue']}',
                unit: 'ر.س',
                label: 'الإيرادات المحصلة',
                badge: '+${stats['revenueTrend']}',
                badgeColor: _emerald,
              ),
            ],
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            children: [
              _buildKpiCard(
                icon: Icons.menu_book_rounded,
                value: '${stats['activeCourses']}',
                label: 'الدورات النشطة',
                badge: '+${stats['newCourses']}',
                badgeColor: _emerald,
              ),
              SizedBox(height: 12.h),
              _buildNewApplicationsCard(),
            ],
          ),
        ),
      ],
    );
  }

  String _formatNumber(int number) {
    final string = number.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < string.length; i++) {
      final position = string.length - i;
      buffer.write(string[i]);
      if (position > 1 && position % 3 == 1) buffer.write(',');
    }
    return buffer.toString();
  }

  Widget _buildKpiCard({
    required IconData icon,
    required String value,
    required String label,
    String? unit,
    required String badge,
    required Color badgeColor,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _surfaceContainer,
                ),
                child: Icon(icon, size: 18.sp, color: _primaryContainer),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: badgeColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.arrow_upward_rounded,
                      size: 10.sp,
                      color: badgeColor,
                    ),
                    Flexible(
                      child: Text(
                        badge,
                        style: TextStyle(
                          fontSize: 10.sp,
                          height: 1.4,
                          fontWeight: FontWeight.w700,
                          color: badgeColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Flexible(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 21.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: _primaryContainer,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (unit != null) ...[
                SizedBox(width: 4.w),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 10.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w500,
                    color: _onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              height: 1.4,
              color: _outline,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewApplicationsCard() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36.w,
                height: 36.h,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _secondaryContainer.withValues(alpha: 0.2),
                ),
                child: Icon(
                  Icons.assignment_rounded,
                  size: 18.sp,
                  color: _secondaryContainer,
                ),
              ),
              const Spacer(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  'مطلوبة الآن',
                  style: TextStyle(
                    fontSize: 10.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: _error,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${_mockStats['newApplications']}',
                      style: TextStyle(
                        fontSize: 21.sp,
                        height: 1.2,
                        fontWeight: FontWeight.w800,
                        color: _primaryContainer,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      'طلبات جديدة',
                      style: TextStyle(
                        fontSize: 11.sp,
                        height: 1.4,
                        color: _outline,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 32.w,
                height: 32.h,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: _surfaceContainer,
                ),
                child: Icon(
                  Icons.arrow_back_rounded,
                  size: 15.sp,
                  color: _secondaryContainer,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  

  Widget _buildRevenueChartCard() {
    const monthly = [
      ('يناير', '28k', 60.0),
      ('فبراير', '32k', 72.0),
      ('مارس', '35k', 82.0),
      ('أبريل', '41k', 98.0),
      ('مايو', '39k', 92.0),
      ('يونيو', '45.8k', 114.0),
    ];
    const yearly = [
      ('2021', '180k', 70.0),
      ('2022', '230k', 84.0),
      ('2023', '290k', 96.0),
      ('2024', '350k', 108.0),
      ('2025', '420k', 118.0),
      ('2026', '45.8k', 122.0),
    ];
    final data = _isMonthly ? monthly : yearly;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_rounded,
                  size: 18.sp, color: _primaryContainer),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  'الإيرادات الشهرية',
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: _primaryContainer,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.all(2.r),
                decoration: BoxDecoration(
                  color: _surfaceContainer,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildChartToggle('شهر', _isMonthly,
                        () => setState(() => _isMonthly = true)),
                    _buildChartToggle('سنة', !_isMonthly,
                        () => setState(() => _isMonthly = false)),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          SizedBox(
            height: 150.h,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final (index, item) in data.indexed) ...[
                  if (index > 0) SizedBox(width: 4.w),
                  Expanded(
                      child: _buildBarColumn(
                          item.$1, item.$2, item.$3, index == data.length - 1)),
                ],
              ],
            ),
          ),
          SizedBox(height: 4.h),
          Container(
            height: 1,
            color: _surfaceVariant,
          ),
          SizedBox(height: 4.h),
          Row(
            children: [
              for (final (index, item) in data.indexed) ...[
                if (index > 0) SizedBox(width: 4.w),
                Expanded(
                  child: Text(
                    item.$1,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.sp,
                      height: 1.4,
                      fontWeight: index == data.length - 1
                          ? FontWeight.w700
                          : FontWeight.w400,
                      color: index == data.length - 1
                          ? _secondaryContainer
                          : _outline,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartToggle(String label, bool selected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
        decoration: BoxDecoration(
          color: selected ? _secondaryContainer : Colors.transparent,
          borderRadius: BorderRadius.circular(999.r),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            height: 1.5,
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected ? Colors.white : _onSurfaceVariant,
          ),
        ),
      ),
    );
  }

  Widget _buildBarColumn(
      String label, String value, double height, bool isCurrent) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 10.sp,
            height: 1.4,
            fontWeight: isCurrent ? FontWeight.w700 : FontWeight.w500,
            color: isCurrent ? _secondaryContainer : _outline,
          ),
        ),
        SizedBox(height: 4.h),
        AnimatedContainer(
          duration: const Duration(milliseconds: 400),
          curve: Curves.easeOutCubic,
          width: 22.w,
          height: height.h,
          decoration: BoxDecoration(
            color: isCurrent
                ? _secondaryContainer
                : _primaryContainer.withValues(alpha: 0.85),
            borderRadius: BorderRadius.vertical(top: Radius.circular(8.r)),
          ),
        ),
      ],
    );
  }

  

  Widget _buildEnrollmentChartCard() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'حركة التسجيلات',
                      style: TextStyle(
                        fontSize: 15.sp,
                        height: 1.5,
                        fontWeight: FontWeight.w700,
                        color: _primaryContainer,
                      ),
                    ),
                    Text(
                      'الكورسات الأكاديمية مقابل التدريب الميداني',
                      style: TextStyle(
                        fontSize: 11.sp,
                        height: 1.4,
                        color: _outline,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.show_chart_rounded, size: 18.sp, color: _outline),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              _buildLegendDot(_primaryContainer, 'الدورات الأكاديمية'),
              SizedBox(width: 14.w),
              _buildLegendDot(_secondaryContainer, 'التدريب الميداني'),
            ],
          ),
          SizedBox(height: 12.h),
          SizedBox(
            height: 120.h,
            width: double.infinity,
            child: const CustomPaint(
              size: Size.infinite,
              painter: _SplineChartPainter(
                academicPoints: [
                  Offset(0, 95),
                  Offset(110, 60),
                  Offset(220, 38),
                  Offset(320, 18)
                ],
                fieldPoints: [
                  Offset(0, 105),
                  Offset(120, 80),
                  Offset(230, 55),
                  Offset(320, 40)
                ],
              ),
            ),
          ),
          SizedBox(height: 6.h),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('الأسبوع 1', style: _chartLabelStyle),
              Text('الأسبوع 2', style: _chartLabelStyle),
              Text('الأسبوع 3', style: _chartLabelStyle),
              Text('الأسبوع 4', style: _chartLabelStyle),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLegendDot(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 9.w,
          height: 9.w,
          decoration: BoxDecoration(shape: BoxShape.circle, color: color),
        ),
        SizedBox(width: 5.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 10.sp,
            height: 1.4,
            color: _onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  

  Widget _buildTopCoursesCard() {
    const courses = [
      ('دورة إدارة المشاريع الاحترافية ®PMP', 0.95, '480 طالب مسجل', true),
      ('دورة أمن المعلومات والسيبراني', 0.78, '350 طالب مسجل', false),
      ('تدريب ميداني: صيانة أنظمة HVAC', 0.65, '210 طالب مسجل', false),
    ];

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'أفضل الدورات أداءً',
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: _primaryContainer,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => context.push('/training-center/programs'),
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'عرض الكل',
                      style: TextStyle(
                        fontSize: 11.sp,
                        height: 1.7,
                        fontWeight: FontWeight.w700,
                        color: _secondary,
                      ),
                    ),
                    Icon(Icons.arrow_back_rounded,
                        size: 13.sp, color: _secondary),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ...courses.map((course) {
            final (title, progress, students, isTop) = course;
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(8.r),
              decoration: BoxDecoration(
                color: _surfaceContainerLow,
                borderRadius: BorderRadius.circular(10.r),
              ),
              child: Row(
                children: [
                  Container(
                    width: 46.w,
                    height: 46.h,
                    decoration: BoxDecoration(
                      color: _surfaceContainer,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Icon(
                      Icons.school_rounded,
                      size: 22.sp,
                      color: _primaryContainer.withValues(alpha: 0.6),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                title,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                  color: _primaryContainer,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Text(
                              '${(progress * 100).round()}%',
                              style: TextStyle(
                                fontSize: 10.sp,
                                height: 1.4,
                                fontWeight: FontWeight.w700,
                                color: isTop ? _secondary : _primaryContainer,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999.r),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 5.h,
                            backgroundColor: _surfaceVariant,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isTop ? _secondaryContainer : _primaryContainer,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          students,
                          style: TextStyle(
                            fontSize: 10.sp,
                            height: 1.4,
                            color: _outline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  

  Widget _buildUpcomingActivitiesCard() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'الأنشطة القادمة',
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: _primaryContainer,
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: _error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  '3',
                  style: TextStyle(
                    fontSize: 10.sp,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: _error,
                  ),
                ),
              ),
              SizedBox(width: 6.w),
              Icon(Icons.event_note_rounded, size: 18.sp, color: _outline),
            ],
          ),
          SizedBox(height: 8.h),
          _buildActivityTile(
            day: '15',
            month: 'يونيو',
            title: 'بدء دورة إدارة المشاريع الاحترافية',
            icon: Icons.location_on_rounded,
            subtitle: 'الرياض • القاعة الرئيسية',
            subtitleColor: _outline,
            iconBgColor: _surfaceContainer,
            iconColor: _primaryContainer,
            dayBgColor: _surfaceContainer,
            dayColor: _primaryContainer,
          ),
          _buildActivityTile(
            day: '20',
            month: 'يونيو',
            title: 'تدريب ميداني: ورشة السلامة المهنية',
            icon: Icons.build_rounded,
            subtitle: 'الدمام • موقع التدريب الميداني',
            subtitleColor: _outline,
            iconBgColor: _surfaceContainer,
            iconColor: _primaryContainer,
            dayBgColor: _surfaceContainer,
            dayColor: _primaryContainer,
          ),
          _buildActivityTile(
            day: '25',
            month: 'يونيو',
            title: 'انتهاء التسجيل: دورة Excel المتقدم',
            icon: Icons.timer_rounded,
            subtitle: 'اقتراب إغلاق باب التسجيل (متبقي مقعدين)',
            subtitleColor: _secondary,
            iconBgColor: _secondaryContainer.withValues(alpha: 0.2),
            iconColor: _secondary,
            dayBgColor: _secondaryContainer.withValues(alpha: 0.2),
            dayColor: _secondary,
          ),
        ],
      ),
    );
  }

  Widget _buildActivityTile({
    required String day,
    required String month,
    required String title,
    required IconData icon,
    required String subtitle,
    required Color subtitleColor,
    required Color iconBgColor,
    required Color iconColor,
    required Color dayBgColor,
    required Color dayColor,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 4.h),
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 6.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Container(
            width: 44.w,
            height: 44.h,
            decoration: BoxDecoration(
              color: dayBgColor,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  day,
                  style: TextStyle(
                    fontSize: 13.sp,
                    height: 1.2,
                    fontWeight: FontWeight.w800,
                    color: dayColor,
                  ),
                ),
                Text(
                  month,
                  style: TextStyle(
                    fontSize: 9.sp,
                    height: 1.3,
                    color: dayColor,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 11.sp,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: _primaryContainer,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 2.h),
                Row(
                  children: [
                    Icon(icon, size: 11.sp, color: subtitleColor),
                    SizedBox(width: 3.w),
                    Expanded(
                      child: Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 10.sp,
                          height: 1.4,
                          fontWeight: subtitleColor == _secondary
                              ? FontWeight.w500
                              : FontWeight.w400,
                          color: subtitleColor,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          SizedBox(width: 6.w),
          Icon(Icons.arrow_back_ios_rounded, size: 13.sp, color: _outline),
        ],
      ),
    );
  }

  

  Widget _buildRecentReviewsCard() {
    const reviews = [
      (
        'عبدالله الشمري',
        'محتوى احترافي جداً والمدرب متمكن ومتابع لكل التفاصيل خطوة بخطوة. أنصح بالالتحاق بشدة!',
        Icons.person_rounded
      ),
      (
        'فيصل الخالدي',
        'تنظيم ممتاز وبيئة تدريب عملية تفوق التوقعات، التطبيق الميداني أعطى قيمة حقيقية للشهادة.',
        Icons.person_rounded
      ),
    ];

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: _surfaceContainerLowest,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.star_rounded, size: 18.sp, color: _amber),
              SizedBox(width: 5.w),
              Expanded(
                child: Text(
                  'آخر التقييمات',
                  style: TextStyle(
                    fontSize: 15.sp,
                    height: 1.5,
                    fontWeight: FontWeight.w700,
                    color: _primaryContainer,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'عرض تجريبي',
                    style: TextStyle(
                      fontSize: 11.sp,
                      height: 1.7,
                      fontWeight: FontWeight.w500,
                      color: _outline,
                    ),
                  ),
                ],
              ),
            ],
          ),
          SizedBox(height: 8.h),
          ...reviews.map((review) {
            final (name, text, icon) = review;
            return Container(
              margin: EdgeInsets.only(bottom: 10.h),
              padding: EdgeInsets.all(10.r),
              decoration: BoxDecoration(
                color: _surfaceContainerLow,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 18.r,
                    backgroundColor: _surfaceContainer,
                    foregroundColor: _primaryContainer.withValues(alpha: 0.7),
                    child: Icon(icon, size: 18.sp),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                name,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  height: 1.4,
                                  fontWeight: FontWeight.w600,
                                  color: _primaryContainer,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: List.generate(
                                5,
                                (index) => Icon(
                                  Icons.star_rounded,
                                  size: 13.sp,
                                  color: _amber,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          text,
                          style: TextStyle(
                            fontSize: 11.sp,
                            height: 1.6,
                            color: _onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  

  static const Color _primaryContainer = Color(0xFF1E3A8A);
  static const Color _secondaryContainer = Color(0xFFC2410C);
  static const Color _secondary = Color(0xFF9A3412);
  static const Color _surfaceContainer = Color(0xFFEEF2F8);
  static const Color _surfaceContainerLow = Color(0xFFF5F7FB);
  static const Color _surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color _surfaceVariant = Color(0xFFE4EAF4);
  static const Color _onSurfaceVariant = Color(0xFF475467);
  static const Color _outline = Color(0xFF98A2B3);
  static const Color _outlineVariant = Color(0xFFE4E7EC);
  static const Color _error = Color(0xFFB42318);
  static const Color _emerald = Color(0xFF067647);
  static const Color _amber = Color(0xFFB54708);

  static const TextStyle _chartLabelStyle = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w400,
    color: _outline,
    height: 1.4,
  );
}



class _SplineChartPainter extends CustomPainter {
  const _SplineChartPainter({
    required this.academicPoints,
    required this.fieldPoints,
  });

  final List<Offset> academicPoints;
  final List<Offset> fieldPoints;

  @override
  void paint(Canvas canvas, Size size) {
    const designWidth = 320.0;
    const designHeight = 120.0;
    final scaleX = size.width / designWidth;
    final scaleY = size.height / designHeight;

    Offset map(Offset p) => Offset(p.dx * scaleX, p.dy * scaleY);

    void drawSparkline({
      required List<Offset> rawPoints,
      required Color lineColor,
      required Color fillColorTop,
      required List<int> highlightIndices,
    }) {
      final points = rawPoints.map(map).toList();
      final curved = _createSmoothPath(points);

      
      final fillPath = Path.from(curved)
        ..lineTo(points.last.dx, size.height)
        ..lineTo(points.first.dx, size.height)
        ..close();
      final fillPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [fillColorTop, fillColorTop.withValues(alpha: 0)],
        ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
      canvas.drawPath(fillPath, fillPaint);

      
      canvas.drawPath(
        curved,
        Paint()
          ..color = lineColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.2
          ..strokeCap = StrokeCap.round,
      );

      
      for (final index in highlightIndices) {
        final isLast = index == points.length - 1;
        if (isLast) {
          canvas.drawCircle(points[index], 3.6, Paint()..color = lineColor);
        } else {
          canvas.drawCircle(
            points[index],
            3.2,
            Paint()
              ..color = Colors.white
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.8,
          );
          canvas.drawCircle(
            points[index],
            4.5,
            Paint()
              ..color = lineColor
              ..style = PaintingStyle.stroke
              ..strokeWidth = 1.8,
          );
        }
      }
    }

    
    final gridPaint = Paint()
      ..color = const Color(0xFFE1E8FD)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.8;
    for (final fraction in [20 / 120, 65 / 120, 110 / 120]) {
      final y = size.height * fraction;
      _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), gridPaint);
    }

    drawSparkline(
      rawPoints: fieldPoints,
      lineColor: const Color(0xFFFC8A40),
      fillColorTop: const Color(0xFFFC8A40).withValues(alpha: 0.30),
      highlightIndices: const [1, 2, 3],
    );
    drawSparkline(
      rawPoints: academicPoints,
      lineColor: const Color(0xFF1B3A6B),
      fillColorTop: const Color(0xFF1B3A6B).withValues(alpha: 0.25),
      highlightIndices: const [1, 2, 3],
    );
  }

  Path _createSmoothPath(List<Offset> points) {
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < points.length - 1; i++) {
      final p0 = points[i];
      final p1 = points[i + 1];
      final midX = (p0.dx + p1.dx) / 2;
      path.cubicTo(midX, p0.dy, midX, p1.dy, p1.dx, p1.dy);
    }
    return path;
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashWidth = 5.0;
    const dashSpace = 4.0;
    final distance = (end - start).distance;
    final dx = (end.dx - start.dx) / distance;
    final dy = (end.dy - start.dy) / distance;
    var drawn = 0.0;
    while (drawn < distance) {
      final segment = (drawn + dashWidth).clamp(0, distance) as double;
      canvas.drawLine(
        start + Offset(dx * drawn, dy * drawn),
        start + Offset(dx * segment, dy * segment),
        paint,
      );
      drawn += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(covariant _SplineChartPainter oldDelegate) =>
      oldDelegate.academicPoints != academicPoints ||
      oldDelegate.fieldPoints != fieldPoints;
}
