import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/training_colors.dart';

class TrainingProgramDetailsScreen extends StatefulWidget {
  final String programId;

  const TrainingProgramDetailsScreen({super.key, required this.programId});

  @override
  State<TrainingProgramDetailsScreen> createState() =>
      _TrainingProgramDetailsScreenState();
}

class _TrainingProgramDetailsScreenState
    extends State<TrainingProgramDetailsScreen> {
  bool _isFavorite = false;

  _ProgramDetailsMock? get _details => _detailsFor(widget.programId);

  @override
  Widget build(BuildContext context) {
    final details = _details;
    if (details == null) {
      return _buildProgramUnavailable(context);
    }

    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: TrainingColors.background,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) => [
            SliverToBoxAdapter(
              child: _buildHeroAndTitle(context, details),
            ),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarHeaderDelegate(
                TabBar(
                  labelColor: TrainingColors.primary,
                  unselectedLabelColor: TrainingColors.textSecondary,
                  indicatorColor: TrainingColors.accent,
                  indicatorWeight: 3,
                  indicatorSize: TabBarIndicatorSize.label,
                  dividerColor: Colors.transparent,
                  labelStyle: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w800,
                  ),
                  unselectedLabelStyle: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w600,
                  ),
                  tabs: const [
                    Tab(text: 'نظرة عامة'),
                    Tab(text: 'المحتوى والمقرر'),
                    Tab(text: 'المدرب'),
                    Tab(text: 'التقييمات'),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            children: [
              Builder(builder: (ctx) => _buildOverviewTab(ctx, details)),
              _buildCurriculumTab(details),
              _buildInstructorTab(details),
              _buildReviewsTab(details),
            ],
          ),
        ),
        bottomNavigationBar: _buildBottomBar(context, details),
      ),
    );
  }

  
  
  

  Widget _buildHeroAndTitle(BuildContext context, _ProgramDetailsMock details) {
    final double topInset = MediaQuery.of(context).padding.top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 240.h,
          child: _buildHero(context, details, topInset),
        ),
        Padding(
          padding: EdgeInsets.only(top: 216.h),
          child: _buildTitleCard(details),
        ),
      ],
    );
  }

  Widget _buildHero(
    BuildContext context,
    _ProgramDetailsMock details,
    double topInset,
  ) {
    return Stack(
      fit: StackFit.expand,
      children: [
        Image.network(
          'https://picsum.photos/seed/${details.imageSeed}/800/600',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [Color(0xFF293040), TrainingColors.primaryDark],
              ),
            ),
          ),
        ),
        DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withValues(alpha: 0.35),
                Colors.black.withValues(alpha: 0.15),
                Colors.black.withValues(alpha: 0.7),
              ],
            ),
          ),
        ),
        Positioned(
          top: topInset + 8.h,
          right: 16.w,
          child: _circleButton(
            icon: Icons.arrow_forward_ios_rounded,
            onTap: () {
              if (context.canPop()) {
                context.pop();
              } else {
                context.go('/training-center/programs');
              }
            },
          ),
        ),
        Positioned(
          top: topInset + 8.h,
          left: 16.w,
          child: Row(
            children: [
              _circleButton(
                icon: Icons.ios_share_rounded,
                onTap: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: '${details.title}\n${details.centerName}\n'
                          '${details.price} ر.س',
                    ),
                  );
                  if (!context.mounted) return;
                  _snack(context, 'تم نسخ ملخص الدورة');
                },
              ),
              SizedBox(width: 8.w),
              _circleButton(
                icon: _isFavorite
                    ? Icons.favorite_rounded
                    : Icons.favorite_border_rounded,
                color: _isFavorite
                    ? TrainingColors.danger
                    : TrainingColors.primary,
                onTap: () => setState(() => _isFavorite = !_isFavorite),
              ),
            ],
          ),
        ),
        Positioned(
          bottom: 32.h,
          right: 16.w,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
            decoration: BoxDecoration(
              color: TrainingColors.success.withValues(alpha: 0.92),
              borderRadius: BorderRadius.circular(999.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 7.w,
                  height: 7.w,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                ),
                SizedBox(width: 5.w),
                Text(
                  details.statusLabel,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
    Color color = TrainingColors.primary,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.92),
          shape: BoxShape.circle,
          boxShadow: TrainingColors.softShadow,
        ),
        child: Icon(icon, size: 19.sp, color: color),
      ),
    );
  }

  Widget _buildTitleCard(_ProgramDetailsMock details) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 16.h),
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: TrainingColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: TrainingColors.divider,
                borderRadius: BorderRadius.circular(999.r),
              ),
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            details.title,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 19.sp,
              fontWeight: FontWeight.w800,
              height: 1.35,
              color: TrainingColors.textPrimary,
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            children: [
              Container(
                width: 28.w,
                height: 28.w,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: TrainingColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: TrainingColors.accent.withValues(alpha: 0.25),
                    width: 2,
                  ),
                ),
                child: Text(
                  details.centerMonogram,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w800,
                    color: TrainingColors.accent,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  details.centerName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: TrainingColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(width: 4.w),
              Icon(
                Icons.verified_rounded,
                size: 16.sp,
                color: const Color(0xFF3B82F6),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          SizedBox(
            height: 32.h,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              children: [
                _metaChip(
                  icon: Icons.star_rounded,
                  iconColor: TrainingColors.rating,
                  text: '${details.rating}',
                  trailing: '(${details.reviews} تقييم)',
                  background: const Color(0xFFFFFBEB),
                  borderColor: const Color(0xFFFDE68A),
                ),
                SizedBox(width: 8.w),
                _metaChip(
                  icon: Icons.schedule_rounded,
                  text: '${details.hours} ساعة تدريبية',
                ),
                SizedBox(width: 8.w),
                _metaChip(
                  icon: Icons.groups_rounded,
                  text: '${details.students} متدرب',
                ),
                SizedBox(width: 8.w),
                _metaChip(
                  icon: Icons.workspace_premium_rounded,
                  iconColor: TrainingColors.success,
                  text: 'شهادة معتمدة',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metaChip({
    required IconData icon,
    required String text,
    Color? iconColor,
    String? trailing,
    Color background = const Color(0xFFF3F4F6),
    Color? borderColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(9.r),
        border: borderColor != null ? Border.all(color: borderColor) : null,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 14.sp,
            color: iconColor ?? TrainingColors.textSecondary,
          ),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 11.5.sp,
              fontWeight: FontWeight.w700,
              color: TrainingColors.textPrimary,
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: 4.w),
            Text(
              trailing,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.5.sp,
                color: TrainingColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }

  
  
  

  Widget _buildOverviewTab(
    BuildContext context,
    _ProgramDetailsMock details,
  ) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      physics: const BouncingScrollPhysics(),
      children: [
        _sectionCard(
          icon: Icons.info_outline_rounded,
          iconColor: TrainingColors.accent,
          title: 'وصف الدورة',
          child: Text(
            details.description,
            textAlign: TextAlign.justify,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              height: 1.7,
              color: TrainingColors.textSecondary,
            ),
          ),
        ),
        SizedBox(height: 16.h),
        _sectionCard(
          icon: Icons.check_circle_outline_rounded,
          iconColor: TrainingColors.success,
          title: 'ماذا ستتعلم في هذه الدورة؟',
          child: Column(
            children:
                details.learnPoints.map((point) => _learnRow(point)).toList(),
          ),
        ),
        SizedBox(height: 16.h),
        _sectionCard(
          icon: Icons.calendar_month_rounded,
          iconColor: TrainingColors.primary,
          title: 'تفاصيل وجدولة الدورة',
          child: Column(
            children: [
              _scheduleRow(
                emoji: '📅',
                background: const Color(0xFFDBEAFE),
                label: 'تاريخ البداية',
                value: details.startDate,
              ),
              SizedBox(height: 8.h),
              _scheduleRow(
                emoji: '⏰',
                background: const Color(0xFFFEF3C7),
                label: 'المواعيد الأسبوعية',
                value: details.weeklySchedule,
              ),
              SizedBox(height: 8.h),
              _scheduleRow(
                emoji: '📍',
                background: const Color(0xFFD1FAE5),
                label: 'نمط الحضور',
                value: details.attendanceMode,
              ),
              SizedBox(height: 8.h),
              _scheduleRow(
                emoji: '🌐',
                background: const Color(0xFFEDE9FE),
                label: 'لغة الشرح والمواد',
                value: details.language,
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        _instructorSummaryCard(context, details),
      ],
    );
  }

  Widget _sectionCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required Widget child,
  }) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18.sp, color: iconColor),
              SizedBox(width: 6.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: TrainingColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          child,
        ],
      ),
    );
  }

  Widget _learnRow(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: 10.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 22.w,
            height: 22.w,
            decoration: const BoxDecoration(
              color: TrainingColors.successSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check_rounded,
              size: 14.sp,
              color: TrainingColors.success,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.5.sp,
                height: 1.6,
                color: TrainingColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _scheduleRow({
    required String emoji,
    required Color background,
    required String label,
    required String value,
  }) {
    return Container(
      padding: EdgeInsets.all(10.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Text(emoji, style: TextStyle(fontSize: 14.sp)),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.5.sp,
                    color: TrainingColors.textMuted,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.5.sp,
                    fontWeight: FontWeight.w700,
                    color: TrainingColors.primary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _instructorSummaryCard(
    BuildContext context,
    _ProgramDetailsMock details,
  ) {
    final instructor = details.instructor;
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.cardShadow,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.person_outline_rounded,
                size: 18.sp,
                color: TrainingColors.accent,
              ),
              SizedBox(width: 6.w),
              Text(
                'مدرب الدورة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w800,
                  color: TrainingColors.primary,
                ),
              ),
              const Spacer(),
              GestureDetector(
                onTap: () => DefaultTabController.of(context).animateTo(2),
                child: Row(
                  children: [
                    Text(
                      'الملف التعريفي',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: TrainingColors.accent,
                      ),
                    ),
                    Icon(
                      Icons.chevron_left_rounded,
                      size: 17.sp,
                      color: TrainingColors.accent,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _avatarWithStatus(instructor.avatar, 56.w),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            instructor.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w800,
                              color: TrainingColors.primary,
                            ),
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 6.w,
                            vertical: 2.h,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFFFBEB),
                            borderRadius: BorderRadius.circular(6.r),
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
                                '${instructor.rating}',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w700,
                                  color: const Color(0xFF92400E),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 3.h),
                    Text(
                      instructor.specialty,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5.sp,
                        color: TrainingColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    Row(
                      children: [
                        Text(
                          'خبرة +${instructor.yearsExperience} سنة',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.5.sp,
                            color: TrainingColors.textMuted,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Text(
                          '•',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.sp,
                            color: TrainingColors.textMuted,
                          ),
                        ),
                        SizedBox(width: 6.w),
                        Flexible(
                          child: Text(
                            'درّب أكثر من ${instructor.trainees} متدرب',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.5.sp,
                              color: TrainingColors.textMuted,
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
        ],
      ),
    );
  }

  Widget _avatarWithStatus(String avatar, double size) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          padding: EdgeInsets.all(2.r),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: TrainingColors.accent.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: ClipOval(
            child: Image.network(
              avatar,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: TrainingColors.navySoft,
                alignment: Alignment.center,
                child: Icon(
                  Icons.person_rounded,
                  size: size * 0.45,
                  color: TrainingColors.primary,
                ),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 0,
          left: 0,
          child: Container(
            width: 14.w,
            height: 14.w,
            decoration: BoxDecoration(
              color: TrainingColors.success,
              shape: BoxShape.circle,
              border: Border.all(color: TrainingColors.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }

  
  
  

  Widget _buildCurriculumTab(_ProgramDetailsMock details) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      physics: const BouncingScrollPhysics(),
      children: [
        _sectionCard(
          icon: Icons.menu_book_rounded,
          iconColor: TrainingColors.primary,
          title: 'محتوى المقرر التدريبي',
          child: Column(
            children: [
              for (int i = 0; i < details.modules.length; i++)
                Padding(
                  padding: EdgeInsets.only(
                    bottom: i == details.modules.length - 1 ? 0 : 10.h,
                  ),
                  child: _moduleRow(index: i + 1, module: details.modules[i]),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _moduleRow({required int index, required _ModuleMock module}) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: const Color(0xFFF3F4F6)),
      ),
      child: Row(
        children: [
          Container(
            width: 32.w,
            height: 32.w,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: TrainingColors.navySoft,
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Text(
              '$index',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: TrainingColors.primary,
              ),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  module.title,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w700,
                    color: TrainingColors.textPrimary,
                  ),
                ),
                SizedBox(height: 3.h),
                Text(
                  '${module.lessons} دروس • ${module.duration}',
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
            Icons.play_circle_outline_rounded,
            size: 20.sp,
            color: TrainingColors.accent,
          ),
        ],
      ),
    );
  }

  
  
  

  Widget _buildInstructorTab(_ProgramDetailsMock details) {
    final instructor = details.instructor;
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: TrainingColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: TrainingColors.cardShadow,
          ),
          child: Column(
            children: [
              _avatarWithStatus(instructor.avatar, 76.w),
              SizedBox(height: 12.h),
              Text(
                instructor.name,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w800,
                  color: TrainingColors.primary,
                ),
              ),
              SizedBox(height: 3.h),
              Text(
                instructor.specialty,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  color: TrainingColors.textSecondary,
                ),
              ),
              SizedBox(height: 14.h),
              Row(
                children: [
                  _instructorStat('${instructor.rating}', 'التقييم'),
                  _statDivider(),
                  _instructorStat(
                      '+${instructor.yearsExperience}', 'سنوات خبرة'),
                  _statDivider(),
                  _instructorStat(instructor.trainees, 'متدرب'),
                ],
              ),
              SizedBox(height: 16.h),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  instructor.bio,
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.5.sp,
                    height: 1.7,
                    color: TrainingColors.textSecondary,
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'مجالات الخبرة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: TrainingColors.primary,
                  ),
                ),
              ),
              SizedBox(height: 10.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: instructor.expertise
                    .map(
                      (tag) => Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 5.h,
                        ),
                        decoration: BoxDecoration(
                          color: TrainingColors.accentSoft,
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                        child: Text(
                          tag,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: TrainingColors.accent,
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _instructorStat(String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: TrainingColors.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10.5.sp,
              color: TrainingColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 28.h,
      color: TrainingColors.divider,
    );
  }

  
  
  

  Widget _buildReviewsTab(_ProgramDetailsMock details) {
    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 24.h),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: TrainingColors.surface,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: TrainingColors.cardShadow,
          ),
          child: Row(
            children: [
              Column(
                children: [
                  Text(
                    '${details.rating}',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 30.sp,
                      fontWeight: FontWeight.w800,
                      height: 1.0,
                      color: TrainingColors.primary,
                    ),
                  ),
                  SizedBox(height: 4.h),
                  _starRow(details.rating, 13.sp),
                  SizedBox(height: 4.h),
                  Text(
                    '${details.reviews} تقييم',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10.5.sp,
                      color: TrainingColors.textMuted,
                    ),
                  ),
                ],
              ),
              SizedBox(width: 20.w),
              Expanded(
                child: Column(
                  children: [
                    _ratingBar(5, 0.78),
                    _ratingBar(4, 0.16),
                    _ratingBar(3, 0.04),
                    _ratingBar(2, 0.01),
                    _ratingBar(1, 0.01),
                  ],
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 16.h),
        ...details.reviewItems.map((review) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _reviewCard(review),
            )),
      ],
    );
  }

  Widget _ratingBar(int stars, double value) {
    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Row(
        children: [
          Text(
            '$stars',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10.sp,
              color: TrainingColors.textMuted,
            ),
          ),
          SizedBox(width: 4.w),
          Icon(Icons.star_rounded, size: 11.sp, color: TrainingColors.rating),
          SizedBox(width: 6.w),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(999.r),
              child: SizedBox(
                height: 6.h,
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
                        child: const ColoredBox(color: TrainingColors.rating),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _starRow(double rating, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final filled = index < rating.round();
        return Icon(
          filled ? Icons.star_rounded : Icons.star_border_rounded,
          size: size,
          color: TrainingColors.rating,
        );
      }),
    );
  }

  Widget _reviewCard(_ReviewMock review) {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18.r,
                backgroundColor: TrainingColors.navySoft,
                child: Text(
                  review.initial,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: TrainingColors.primary,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      review.name,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: TrainingColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 3.h),
                    _starRow(review.rating, 12.sp),
                  ],
                ),
              ),
              Text(
                review.date,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.5.sp,
                  color: TrainingColors.textMuted,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Text(
            review.text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              height: 1.6,
              color: TrainingColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  
  
  

  Widget _buildBottomBar(BuildContext context, _ProgramDetailsMock details) {
    return Container(
      decoration: BoxDecoration(
        color: TrainingColors.surface.withValues(alpha: 0.97),
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 25,
            offset: Offset(0, -6),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 14.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department_rounded,
                    size: 15.sp,
                    color: TrainingColors.danger,
                  ),
                  SizedBox(width: 3.w),
                  Expanded(
                    child: Text(
                      'متبقي ${details.seatsLeft} مقاعد فقط من أصل '
                      '${details.seatsTotal} مقعداً',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        fontWeight: FontWeight.w700,
                        color: TrainingColors.danger,
                      ),
                    ),
                  ),
                  Text(
                    'مكتمل بنسبة ${details.fillPercent}%',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10.5.sp,
                      fontWeight: FontWeight.w600,
                      color: TrainingColors.textMuted,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              ClipRRect(
                borderRadius: BorderRadius.circular(999.r),
                child: SizedBox(
                  height: 6.h,
                  child: Stack(
                    children: [
                      const Positioned.fill(
                        child: ColoredBox(color: TrainingColors.surfaceMuted),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: FractionallySizedBox(
                          widthFactor: details.fillPercent / 100,
                          heightFactor: 1,
                          child: const DecoratedBox(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  TrainingColors.accent,
                                  TrainingColors.danger,
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 12.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            details.price,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 21.sp,
                              fontWeight: FontWeight.w800,
                              height: 1.0,
                              color: TrainingColors.primary,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Padding(
                            padding: EdgeInsets.only(bottom: 2.h),
                            child: Text(
                              'ر.س',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 11.sp,
                                fontWeight: FontWeight.w700,
                                color: TrainingColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Text(
                            '${details.oldPrice} ر.س',
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.sp,
                              decoration: TextDecoration.lineThrough,
                              color: TrainingColors.textMuted,
                            ),
                          ),
                          SizedBox(width: 6.w),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 5.w,
                              vertical: 1.h,
                            ),
                            decoration: BoxDecoration(
                              color: TrainingColors.dangerSoft,
                              borderRadius: BorderRadius.circular(5.r),
                            ),
                            child: Text(
                              'وفر ${details.discountPercent}%',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 9.5.sp,
                                fontWeight: FontWeight.w800,
                                color: TrainingColors.danger,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => context.push(
                        '/training-center/apply',
                        extra: details.id,
                      ),
                      child: Container(
                        height: 50.h,
                        decoration: BoxDecoration(
                          color: TrainingColors.accent,
                          borderRadius: BorderRadius.circular(12.r),
                          boxShadow: [
                            BoxShadow(
                              color: TrainingColors.accent.withValues(
                                alpha: 0.35,
                              ),
                              blurRadius: 20,
                              offset: const Offset(0, 8),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'سجل الآن',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 15.sp,
                                fontWeight: FontWeight.w800,
                                color: TrainingColors.onAccent,
                              ),
                            ),
                            SizedBox(width: 6.w),
                            Icon(
                              Icons.chevron_left_rounded,
                              size: 20.sp,
                              color: TrainingColors.onAccent,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _snack(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(label),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  Widget _buildProgramUnavailable(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: TrainingColors.background,
        appBar: AppBar(
          backgroundColor: TrainingColors.surface,
          title: const Text(
            'تفاصيل البرنامج',
            style: TextStyle(
              fontFamily: 'Cairo',
              color: TrainingColors.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.menu_book_outlined,
                    size: 48, color: TrainingColors.textMuted),
                const SizedBox(height: 12),
                const Text(
                  'البرنامج غير متاح',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: TrainingColors.primary,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'لم نعثر على برنامج بهذا المعرّف في البيانات التجريبية.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12,
                    color: TrainingColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    if (context.canPop()) {
                      context.pop();
                    } else {
                      context.go('/training-center/programs');
                    }
                  },
                  child: const Text('عرض البرامج'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}





class _TabBarHeaderDelegate extends SliverPersistentHeaderDelegate {
  final TabBar tabBar;

  const _TabBarHeaderDelegate(this.tabBar);

  @override
  double get minExtent => tabBar.preferredSize.height;

  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        border: const Border(
          top: BorderSide(color: TrainingColors.divider),
          bottom: BorderSide(color: TrainingColors.divider),
        ),
        boxShadow: overlapsContent ? TrainingColors.softShadow : null,
      ),
      child: tabBar,
    );
  }

  @override
  bool shouldRebuild(covariant _TabBarHeaderDelegate oldDelegate) =>
      oldDelegate.tabBar != tabBar;
}





class _InstructorDetailsMock {
  final String name;
  final String specialty;
  final String avatar;
  final double rating;
  final int yearsExperience;
  final String trainees;
  final String bio;
  final List<String> expertise;

  const _InstructorDetailsMock({
    required this.name,
    required this.specialty,
    required this.avatar,
    required this.rating,
    required this.yearsExperience,
    required this.trainees,
    required this.bio,
    required this.expertise,
  });
}

class _ModuleMock {
  final String title;
  final int lessons;
  final String duration;

  const _ModuleMock({
    required this.title,
    required this.lessons,
    required this.duration,
  });
}

class _ReviewMock {
  final String name;
  final String initial;
  final double rating;
  final String date;
  final String text;

  const _ReviewMock({
    required this.name,
    required this.initial,
    required this.rating,
    required this.date,
    required this.text,
  });
}

class _ProgramDetailsMock {
  final String id;
  final String title;
  final String imageSeed;
  final String centerName;
  final String centerMonogram;
  final String statusLabel;
  final double rating;
  final int reviews;
  final int hours;
  final String students;
  final String price;
  final String oldPrice;
  final int discountPercent;
  final int seatsTotal;
  final int seatsLeft;
  final int fillPercent;
  final String description;
  final List<String> learnPoints;
  final String startDate;
  final String weeklySchedule;
  final String attendanceMode;
  final String language;
  final _InstructorDetailsMock instructor;
  final List<_ModuleMock> modules;
  final List<_ReviewMock> reviewItems;

  const _ProgramDetailsMock({
    required this.id,
    required this.title,
    required this.imageSeed,
    required this.centerName,
    required this.centerMonogram,
    required this.statusLabel,
    required this.rating,
    required this.reviews,
    required this.hours,
    required this.students,
    required this.price,
    required this.oldPrice,
    required this.discountPercent,
    required this.seatsTotal,
    required this.seatsLeft,
    required this.fillPercent,
    required this.description,
    required this.learnPoints,
    required this.startDate,
    required this.weeklySchedule,
    required this.attendanceMode,
    required this.language,
    required this.instructor,
    required this.modules,
    required this.reviewItems,
  });
}

const List<String> _baseLearnPoints = [
  'تخطيط المشاريع وضبط نطاق العمل بدقة واحترافية.',
  'إدارة المخاطر التشغيلية وتحليل الأثر الاستراتيجي.',
  'قيادة الفرق المتنوعة وإدارة خطط التواصل الفعّال.',
  'إعداد الجداول الزمنية المتقدمة ومخططات Gantt الاحترافية.',
  'ضبط ومراقبة الميزانيات وإجراءات تسليم وإغلاق المشاريع.',
];

const List<_ModuleMock> _baseModules = [
  _ModuleMock(
      title: 'مقدمة في إدارة المشاريع', lessons: 4, duration: '3 ساعات'),
  _ModuleMock(
      title: 'إدارة النطاق والجدول الزمني', lessons: 6, duration: '5 ساعات'),
  _ModuleMock(
      title: 'إدارة التكاليف والميزانية', lessons: 5, duration: '4 ساعات'),
  _ModuleMock(
      title: 'إدارة المخاطر وأصحاب المصلحة', lessons: 5, duration: '4 ساعات'),
  _ModuleMock(
      title: 'المنهجيات الرشيقة والاختبار النهائي',
      lessons: 6,
      duration: '6 ساعات'),
];

const List<_ReviewMock> _baseReviews = [
  _ReviewMock(
    name: 'أحمد الغامدي',
    initial: 'أ',
    rating: 5,
    date: 'قبل 3 أيام',
    text:
        'دورة ممتازة ومحتوى عملي جداً، ساعدتني في اجتياز اختبار PMP من المحاولة الأولى.',
  ),
  _ReviewMock(
    name: 'منى العتيبي',
    initial: 'م',
    rating: 5,
    date: 'قبل أسبوع',
    text: 'المدرب متمكن والشرح واضح، والملفات المرفقة منظمة ومفيدة جداً.',
  ),
  _ReviewMock(
    name: 'سلطان الحربي',
    initial: 'س',
    rating: 4,
    date: 'قبل أسبوعين',
    text:
        'تجربة رائعة بشكل عام، أتمنى إضافة المزيد من الجلسات العملية التطبيقية.',
  ),
];

_ProgramDetailsMock? _detailsFor(String programId) {
  switch (programId) {
    case 'p2':
      return const _ProgramDetailsMock(
        id: 'p2',
        title: 'استراتيجيات التسويق الرقمي ونمو الشركات',
        imageSeed: 'marketingdetails',
        centerName: 'معهد القادة المعتمد للتدريب',
        centerMonogram: 'ق',
        statusLabel: 'التسجيل متاح',
        rating: 4.9,
        reviews: 96,
        hours: 20,
        students: '310',
        price: '380',
        oldPrice: '520',
        discountPercent: 27,
        seatsTotal: 30,
        seatsLeft: 9,
        fillPercent: 70,
        description:
            'برنامج تدريبي عملي يزوّدك بأحدث استراتيجيات التسويق الرقمي '
            'وإدارة الحملات الإعلانية وبناء مسار نمو مستدام للشركات، '
            'مع دراسات حالة حقيقية وأدوات تحليلية متقدمة.',
        learnPoints: _baseLearnPoints,
        startDate: '20 يونيو 2025',
        weeklySchedule: 'الاثنين والأربعاء — 7:00 م (توقيت مكة)',
        attendanceMode: 'الرياض / متاح حضورياً وعن بُعد (هجين)',
        language: 'اللغة العربية (المصطلحات بالإنجليزية)',
        instructor: _InstructorDetailsMock(
          name: 'د. محمد الزهراني',
          specialty: 'خبير التسويق الرقمي — Google, Meta',
          avatar: 'https://i.pravatar.cc/200?img=33',
          rating: 4.8,
          yearsExperience: 12,
          trainees: '1,400',
          bio: 'مستشار تسويق رقمي عمل مع أكثر من 60 شركة، متخصص في '
              'بناء استراتيجيات النمو وإدارة الحملات المدفوعة.',
          expertise: ['SEO', 'إعلانات مدفوعة', 'تحليل البيانات', 'نمو الشركات'],
        ),
        modules: _baseModules,
        reviewItems: _baseReviews,
      );
    case 'p3':
      return const _ProgramDetailsMock(
        id: 'p3',
        title: 'تصميم واجهات وتجربة المستخدم Figma & UI',
        imageSeed: 'uidesigndetails',
        centerName: 'معهد القادة المعتمد للتدريب',
        centerMonogram: 'ق',
        statusLabel: 'التسجيل متاح',
        rating: 4.7,
        reviews: 74,
        hours: 25,
        students: '265',
        price: '420',
        oldPrice: '550',
        discountPercent: 24,
        seatsTotal: 25,
        seatsLeft: 6,
        fillPercent: 76,
        description:
            'تعلّم تصميم واجهات المستخدم وتجربة تجربة الاستخدام (UI/UX) '
            'باستخدام Figma من الصفر حتى الاحتراف، مع مشاريع عملية '
            'وبناء ملف أعمال (Portfolio) جاهز لسوق العمل.',
        learnPoints: _baseLearnPoints,
        startDate: '25 يونيو 2025',
        weeklySchedule: 'الأحد والخميس — 6:30 م (توقيت مكة)',
        attendanceMode: 'عن بُعد (بث مباشر)',
        language: 'اللغة العربية (المصطلحات بالإنجليزية)',
        instructor: _InstructorDetailsMock(
          name: 'أ. نورة القحطاني',
          specialty: 'مصممة تجربة مستخدم — UX Lead',
          avatar: 'https://i.pravatar.cc/200?img=45',
          rating: 4.9,
          yearsExperience: 9,
          trainees: '980',
          bio: 'قائدة تصميم تجربة المستخدم في منتجات رقمية كبرى، '
              'متخصصة في أبحاث المستخدم وبناء أنظمة التصميم.',
          expertise: [
            'Figma',
            'أنظمة التصميم',
            'أبحاث المستخدم',
            'Prototyping'
          ],
        ),
        modules: _baseModules,
        reviewItems: _baseReviews,
      );
    case 'p4':
      return const _ProgramDetailsMock(
        id: 'p4',
        title: 'أساسيات الأمن السيبراني واختبار الاختراق',
        imageSeed: 'cyberdetails',
        centerName: 'معهد القادة المعتمد للتدريب',
        centerMonogram: 'ق',
        statusLabel: 'التسجيل متاح',
        rating: 4.6,
        reviews: 152,
        hours: 35,
        students: '410',
        price: '550',
        oldPrice: '700',
        discountPercent: 21,
        seatsTotal: 40,
        seatsLeft: 12,
        fillPercent: 70,
        description:
            'برنامج متخصص في أساسيات الأمن السيبراني واختبار الاختراق، '
            'يغطي حماية الشبكات والأنظمة، مع مختبرات سحابية تفاعلية '
            'وتطبيق عملي على أدوات الحماية والكشف.',
        learnPoints: _baseLearnPoints,
        startDate: '1 يوليو 2025',
        weeklySchedule: 'الثلاثاء والخميس — 8:00 م (توقيت مكة)',
        attendanceMode: 'عن بُعد (مختبرات سحابية)',
        language: 'اللغة العربية (المصطلحات بالإنجليزية)',
        instructor: _InstructorDetailsMock(
          name: 'م. عبد العزيز الشمري',
          specialty: 'خبير أمن سيبراني — CEH, OSCP',
          avatar: 'https://i.pravatar.cc/200?img=15',
          rating: 4.8,
          yearsExperience: 11,
          trainees: '1,200',
          bio: 'مستشار أمن سيبراني متخصص في اختبار الاختراق وحماية '
              'البنى التحتية، مدرّب معتمد في الشهادات الدولية.',
          expertise: [
            'اختبار الاختراق',
            'أمن الشبكات',
            'الاستجابة للحوادث',
            'OSCP'
          ],
        ),
        modules: _baseModules,
        reviewItems: _baseReviews,
      );
    case 'p1':
      return const _ProgramDetailsMock(
        id: 'p1',
        title: 'دورة إدارة المشاريع الاحترافية PMP®',
        imageSeed: 'pmpdetails',
        centerName: 'مركز التدريب التقني المعتمد',
        centerMonogram: 'تقن',
        statusLabel: 'التسجيل متاح',
        rating: 4.8,
        reviews: 120,
        hours: 30,
        students: '245',
        price: '450',
        oldPrice: '600',
        discountPercent: 25,
        seatsTotal: 20,
        seatsLeft: 5,
        fillPercent: 75,
        description:
            'برنامج تدريبي متقدم وشامل يؤهلك لاجتياز اختبار محترف إدارة '
            'المشاريع (PMP®) وفق أحدث معايير معهد إدارة المشاريع العالمي '
            '(PMI). يغطي البرنامج المنهجيات التقليدية والذكية (Agile) '
            'مع تطبيقات عملية ومحاكاة واقعية للاختبار الدولي.',
        learnPoints: _baseLearnPoints,
        startDate: '15 يونيو 2025',
        weeklySchedule: 'الأحد والثلاثاء — 6:00 م (توقيت مكة)',
        attendanceMode: 'الرياض / متاح حضورياً وعن بُعد (هجين)',
        language: 'اللغة العربية (المصطلحات بالإنجليزية)',
        instructor: _InstructorDetailsMock(
          name: 'د. خالد العتيبي',
          specialty: 'خبير ومستشار إدارة المشاريع — PMP, PMI-ACP',
          avatar: 'https://i.pravatar.cc/200?img=12',
          rating: 4.9,
          yearsExperience: 15,
          trainees: '1,800',
          bio: 'خبير ومستشار إدارة مشاريع معتمد، قاد مشاريع كبرى في '
              'قطاعات متعددة، ومدرّب معتمد لدى معهد إدارة المشاريع (PMI).',
          expertise: ['PMP', 'Agile', 'إدارة المخاطر', 'قيادة الفرق'],
        ),
        modules: _baseModules,
        reviewItems: _baseReviews,
      );
    default:
      return null;
  }
}
