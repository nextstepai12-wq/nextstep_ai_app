import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nextstep_ai_app/core/widgets/app_responsive.dart';

import '../theme/training_colors.dart';
import '../widgets/training_center_drawer.dart';

class TrainingProgramsScreen extends StatefulWidget {
  const TrainingProgramsScreen({super.key});

  @override
  State<TrainingProgramsScreen> createState() => _TrainingProgramsScreenState();
}

class _TrainingProgramsScreenState extends State<TrainingProgramsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  _ProgramType _selectedType = _ProgramType.all;
  _ProgramSort _sort = _ProgramSort.latest;
  String _searchQuery = '';

  final List<_ProgramMock> _allPrograms = const [
    _ProgramMock(
      id: 'p1',
      type: _ProgramType.course,
      title: 'دورة إدارة المشاريع الاحترافية PMP®',
      trainer: 'د. خالد العتيبي',
      students: 320,
      duration: '30 ساعة',
      startDate: '15 يونيو',
      location: 'الرياض (هجين)',
      locationIcon: Icons.location_on_rounded,
      rating: 4.8,
      price: 450,
      available: true,
      imageSeed: 'pmpcourse',
    ),
    _ProgramMock(
      id: 'p2',
      type: _ProgramType.field,
      title: 'تدريب ميداني — صيانة وتشغيل خطوط الإنتاج',
      trainer: 'م. فيصل الدوسري',
      students: 145,
      duration: '40 س عملي',
      startDate: '20 يونيو',
      location: 'الصناعية الثانية',
      locationIcon: Icons.location_on_rounded,
      rating: 4.9,
      price: 850,
      available: true,
      imageSeed: 'maintenance',
    ),
    _ProgramMock(
      id: 'p3',
      type: _ProgramType.course,
      title: 'دبلوم الأمن السيبراني المتقدم واختبار الاختراق',
      trainer: 'م. عبد العزيز الشمري',
      students: 410,
      duration: '45 ساعة',
      startDate: '1 يوليو',
      location: 'معامل سحابية',
      locationIcon: Icons.cloud_outlined,
      rating: 4.9,
      price: 1450,
      available: true,
      imageSeed: 'cyberdiploma',
    ),
    _ProgramMock(
      id: 'p4',
      type: _ProgramType.field,
      title: 'تدريب ميداني — إدارة وضبط جودة المشاريع الإنشائية',
      trainer: 'د. سلطان القحطاني',
      students: 95,
      duration: '35 س موقعي',
      startDate: '10 يوليو',
      location: 'المشاريع الكبرى',
      locationIcon: Icons.location_on_rounded,
      rating: 4.7,
      price: 920,
      available: false,
      imageSeed: 'civilworks',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<_ProgramMock> get _filteredPrograms {
    final programs = _allPrograms.where((p) {
      final matchesType =
          _selectedType == _ProgramType.all || p.type == _selectedType;
      final query = _searchQuery.trim().toLowerCase();
      final matchesSearch = query.isEmpty ||
          p.title.toLowerCase().contains(query) ||
          p.trainer.toLowerCase().contains(query);
      return matchesType && matchesSearch;
    }).toList();

    switch (_sort) {
      case _ProgramSort.popular:
        programs.sort((a, b) => b.students.compareTo(a.students));
        break;
      case _ProgramSort.rating:
        programs.sort((a, b) => b.rating.compareTo(a.rating));
        break;
      case _ProgramSort.priceLow:
        programs.sort((a, b) => a.price.compareTo(b.price));
        break;
      case _ProgramSort.latest:
        break;
    }
    return programs;
  }

  int _countFor(_ProgramType type) {
    if (type == _ProgramType.all) return _allPrograms.length;
    return _allPrograms.where((p) => p.type == type).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: TrainingColors.background,
      appBar: _buildAppBar(),
      drawer: const TrainingCenterDrawer(),
      body: _buildBody(context),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: TrainingColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      toolbarHeight: 68.h,
      titleSpacing: 0,
      leading: IconButton(
        icon: Icon(
          Icons.menu_rounded,
          size: 24.sp,
          color: TrainingColors.primary,
        ),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'الدورات والتدريب',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 19.sp,
              fontWeight: FontWeight.w800,
              color: TrainingColors.primary,
            ),
          ),
          SizedBox(height: 2.h),
          Row(
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
                '${_allPrograms.where((p) => p.available).length} برامج متاحة من أصل ${_allPrograms.length}',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.5.sp,
                  color: TrainingColors.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
      actions: [
        _filterButton(),
        SizedBox(width: 16.w),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: TrainingColors.divider),
      ),
    );
  }

  Widget _filterButton() {
    return GestureDetector(
      onTap: _showFilterSheet,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 44.w,
            height: 44.w,
            decoration: BoxDecoration(
              color: TrainingColors.surface,
              borderRadius: BorderRadius.circular(13.r),
              border: Border.all(color: TrainingColors.divider),
              boxShadow: TrainingColors.softShadow,
            ),
            child: Icon(
              Icons.tune_rounded,
              size: 21.sp,
              color: TrainingColors.primary,
            ),
          ),
          if (_sort != _ProgramSort.latest)
            Positioned(
              top: -1,
              left: -1,
              child: Container(
                width: 11.w,
                height: 11.w,
                decoration: BoxDecoration(
                  color: TrainingColors.accent,
                  shape: BoxShape.circle,
                  border: Border.all(color: TrainingColors.surface, width: 2),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildBody(BuildContext context) {
    final programs = _filteredPrograms;

    return ListView(
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 28.h),
      physics: const BouncingScrollPhysics(),
      children: [
        _buildSearchBar(),
        SizedBox(height: 10.h),
        const Align(
          alignment: AlignmentDirectional.centerStart,
          child: SampleDataBadge(),
        ),
        SizedBox(height: 10.h),
        _buildTypeTabs(),
        SizedBox(height: 16.h),
        if (programs.isEmpty)
          _buildEmptyState()
        else ...[
          ...programs.map(
            (p) => Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: _buildProgramCard(context, p),
            ),
          ),
          SizedBox(height: 4.h),
          _buildListFooter(programs.length),
        ],
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Search + type tabs
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildSearchBar() {
    return Container(
      height: 50.h,
      padding: EdgeInsets.symmetric(horizontal: 14.w),
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(999.r),
        border: Border.all(color: TrainingColors.divider),
        boxShadow: TrainingColors.softShadow,
      ),
      child: Row(
        children: [
          Icon(
            Icons.search_rounded,
            size: 22.sp,
            color: TrainingColors.primary,
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
                hintText: 'ابحث عن دورة أو تدريب ميداني...',
                hintStyle: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  color: TrainingColors.textMuted,
                ),
              ),
            ),
          ),
          SizedBox(width: 6.w),
          Icon(
            Icons.mic_none_rounded,
            size: 20.sp,
            color: TrainingColors.textSecondary,
          ),
        ],
      ),
    );
  }

  Widget _buildTypeTabs() {
    return SizedBox(
      height: 38.h,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        children: [
          _typeTab(
            label: 'الكل',
            count: _countFor(_ProgramType.all),
            type: _ProgramType.all,
            icon: null,
          ),
          SizedBox(width: 8.w),
          _typeTab(
            label: 'كورسات',
            count: _countFor(_ProgramType.course),
            type: _ProgramType.course,
            icon: Icons.menu_book_rounded,
          ),
          SizedBox(width: 8.w),
          _typeTab(
            label: 'تدريب ميداني',
            count: _countFor(_ProgramType.field),
            type: _ProgramType.field,
            icon: Icons.engineering_rounded,
          ),
        ],
      ),
    );
  }

  Widget _typeTab({
    required String label,
    required int count,
    required _ProgramType type,
    required IconData? icon,
  }) {
    final bool active = _selectedType == type;
    final Color badgeBg = active
        ? Colors.white.withValues(alpha: 0.2)
        : TrainingColors.surfaceMuted;
    final Color badgeText =
        active ? TrainingColors.onPrimary : TrainingColors.textSecondary;

    return GestureDetector(
      onTap: () => setState(() => _selectedType = type),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: active ? TrainingColors.primary : TrainingColors.surface,
          borderRadius: BorderRadius.circular(999.r),
          border: active ? null : Border.all(color: TrainingColors.divider),
          boxShadow: active ? TrainingColors.softShadow : null,
        ),
        child: Row(
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                size: 16.sp,
                color: active
                    ? TrainingColors.onPrimary
                    : (type == _ProgramType.field
                        ? TrainingColors.accent
                        : TrainingColors.primary),
              ),
              SizedBox(width: 5.w),
            ],
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.5.sp,
                fontWeight: active ? FontWeight.w700 : FontWeight.w500,
                color: active
                    ? TrainingColors.onPrimary
                    : TrainingColors.textSecondary,
              ),
            ),
            SizedBox(width: 6.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
              decoration: BoxDecoration(
                color: badgeBg,
                borderRadius: BorderRadius.circular(999.r),
              ),
              child: Text(
                count.toString(),
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w600,
                  color: badgeText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Program card
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildProgramCard(BuildContext context, _ProgramMock program) {
    final bool isField = program.type == _ProgramType.field;

    return GestureDetector(
      onTap: () => context.push(
        '/training-center/program-details',
        extra: program.id,
      ),
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: TrainingColors.surface,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: TrainingColors.cardShadow,
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _buildThumbnail(program, isField),
              SizedBox(width: 12.w),
              Expanded(child: _buildCardContent(context, program)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThumbnail(_ProgramMock program, bool isField) {
    final Color badgeColor =
        isField ? TrainingColors.accent : TrainingColors.primary;
    final Color statusColor =
        program.available ? TrainingColors.success : TrainingColors.rating;

    return SizedBox(
      width: 112.w,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _remoteImage(program.imageSeed),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.05),
                    Colors.black.withValues(alpha: 0.45),
                  ],
                ),
              ),
            ),
            Positioned(
              top: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: badgeColor,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  isField ? 'تدريب ميداني' : 'كورس',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            Positioned(
              bottom: 8.h,
              right: 8.w,
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: TrainingColors.surface.withValues(alpha: 0.92),
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.w,
                      decoration: BoxDecoration(
                        color: statusColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      program.available ? 'متاح' : 'قريباً',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                        color: TrainingColors.textPrimary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardContent(BuildContext context, _ProgramMock program) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          program.title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 14.sp,
            fontWeight: FontWeight.w700,
            height: 1.4,
            color: TrainingColors.textPrimary,
          ),
        ),
        SizedBox(height: 7.h),
        Row(
          children: [
            Container(
              width: 20.w,
              height: 20.w,
              decoration: const BoxDecoration(
                color: TrainingColors.surfaceAlt,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.person_rounded,
                size: 13.sp,
                color: TrainingColors.primary,
              ),
            ),
            SizedBox(width: 5.w),
            Flexible(
              child: Text.rich(
                TextSpan(
                  children: [
                    const TextSpan(
                      text: 'المدرب: ',
                      style: TextStyle(color: TrainingColors.textSecondary),
                    ),
                    TextSpan(
                      text: program.trainer,
                      style: const TextStyle(
                        color: TrainingColors.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 5.h),
        Row(
          children: [
            Icon(
              Icons.groups_rounded,
              size: 15.sp,
              color: TrainingColors.textSecondary,
            ),
            SizedBox(width: 5.w),
            Text(
              '${program.students} مسجل',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.5.sp,
                color: TrainingColors.textSecondary,
              ),
            ),
            SizedBox(width: 4.w),
            Icon(
              Icons.verified_rounded,
              size: 13.sp,
              color: TrainingColors.primaryContainer,
            ),
          ],
        ),
        SizedBox(height: 7.h),
        _buildMetaRow(program),
        SizedBox(height: 10.h),
        _buildCardFooter(context, program),
      ],
    );
  }

  Widget _buildMetaRow(_ProgramMock program) {
    return Wrap(
      spacing: 6.w,
      runSpacing: 4.h,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        _metaItem(Icons.schedule_rounded, program.duration),
        _metaBullet(),
        _metaItem(Icons.calendar_today_rounded, program.startDate),
        _metaBullet(),
        _metaItem(program.locationIcon, program.location),
      ],
    );
  }

  Widget _metaItem(IconData icon, String text) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 13.sp, color: TrainingColors.textMuted),
        SizedBox(width: 3.w),
        Text(
          text,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10.5.sp,
            color: TrainingColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _metaBullet() {
    return Text(
      '•',
      style: TextStyle(
        fontFamily: 'Cairo',
        fontSize: 10.sp,
        color: TrainingColors.textMuted,
      ),
    );
  }

  Widget _buildCardFooter(BuildContext context, _ProgramMock program) {
    return Row(
      children: [
        Text(
          _formatPrice(program.price),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 16.sp,
            fontWeight: FontWeight.w800,
            color: TrainingColors.primary,
          ),
        ),
        SizedBox(width: 3.w),
        Text(
          'ر.س',
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10.sp,
            color: TrainingColors.textSecondary,
          ),
        ),
        SizedBox(width: 8.w),
        Icon(Icons.star_rounded, size: 14.sp, color: TrainingColors.rating),
        SizedBox(width: 2.w),
        Text(
          program.rating.toStringAsFixed(1),
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 12.sp,
            fontWeight: FontWeight.w700,
            color: TrainingColors.rating,
          ),
        ),
        const Spacer(),
        GestureDetector(
          onTap: () => context.push(
            '/training-center/program-details',
            extra: program.id,
          ),
          child: Container(
            height: 36.h,
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            decoration: BoxDecoration(
              color: TrainingColors.accent,
              borderRadius: BorderRadius.circular(12.r),
              boxShadow: TrainingColors.softShadow,
            ),
            child: Row(
              children: [
                Text(
                  'عرض التفاصيل',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: TrainingColors.onAccent,
                  ),
                ),
                SizedBox(width: 3.w),
                Icon(
                  Icons.arrow_back_rounded,
                  size: 15.sp,
                  color: TrainingColors.onAccent,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Empty state + load more
  // ───────────────────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 48.h),
      child: Column(
        children: [
          Icon(
            Icons.search_off_rounded,
            size: 48.sp,
            color: TrainingColors.textMuted,
          ),
          SizedBox(height: 12.h),
          Text(
            'لا توجد برامج مطابقة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 14.sp,
              fontWeight: FontWeight.w700,
              color: TrainingColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'جرّب تغيير نوع التدريب أو كلمة البحث',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              color: TrainingColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListFooter(int visibleCount) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.done_all_rounded,
            size: 16.sp,
            color: TrainingColors.textMuted,
          ),
          SizedBox(width: 6.w),
          Text(
            'تم عرض $visibleCount من أصل ${_allPrograms.length} برنامج',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              color: TrainingColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Sort sheet
  // ───────────────────────────────────────────────────────────────────────────

  Future<void> _showFilterSheet() async {
    _ProgramSort selected = _sort;

    final result = await showModalBottomSheet<_ProgramSort>(
      context: context,
      backgroundColor: TrainingColors.surface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
      ),
      builder: (sheetContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (context, setSheetState) {
              return Padding(
                padding: EdgeInsets.fromLTRB(20.w, 12.h, 20.w, 24.h),
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
                          borderRadius: BorderRadius.circular(999.r),
                        ),
                      ),
                    ),
                    SizedBox(height: 18.h),
                    Text(
                      'ترتيب البرامج',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: TrainingColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 14.h),
                    _filterOption(
                      icon: Icons.access_time_rounded,
                      label: 'الأحدث تحديثاً',
                      selected: selected == _ProgramSort.latest,
                      onTap: () => setSheetState(
                        () => selected = _ProgramSort.latest,
                      ),
                    ),
                    _filterOption(
                      icon: Icons.groups_rounded,
                      label: 'الأكثر تسجيلاً',
                      selected: selected == _ProgramSort.popular,
                      onTap: () => setSheetState(
                        () => selected = _ProgramSort.popular,
                      ),
                    ),
                    _filterOption(
                      icon: Icons.star_rounded,
                      label: 'الأعلى تقييماً',
                      selected: selected == _ProgramSort.rating,
                      onTap: () => setSheetState(
                        () => selected = _ProgramSort.rating,
                      ),
                    ),
                    _filterOption(
                      icon: Icons.attach_money_rounded,
                      label: 'السعر: من الأقل',
                      selected: selected == _ProgramSort.priceLow,
                      onTap: () => setSheetState(
                        () => selected = _ProgramSort.priceLow,
                      ),
                    ),
                    SizedBox(height: 12.h),
                    SizedBox(
                      width: double.infinity,
                      height: 48.h,
                      child: ElevatedButton(
                        onPressed: () => Navigator.pop(sheetContext, selected),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: TrainingColors.primary,
                          foregroundColor: TrainingColors.onPrimary,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                        ),
                        child: Text(
                          'تطبيق',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.sp,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    if (result != null && mounted) {
      setState(() => _sort = result);
    }
  }

  Widget _filterOption({
    required IconData icon,
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 38.w,
        height: 38.w,
        decoration: BoxDecoration(
          color:
              selected ? TrainingColors.accentSoft : TrainingColors.surfaceAlt,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon,
          size: 19.sp,
          color: selected ? TrainingColors.accentDark : TrainingColors.primary,
        ),
      ),
      title: Text(
        label,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13.5.sp,
          fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
          color: TrainingColors.textPrimary,
        ),
      ),
      trailing: selected
          ? Icon(
              Icons.check_circle_rounded,
              size: 20.sp,
              color: TrainingColors.accent,
            )
          : null,
      onTap: onTap,
    );
  }

  // ───────────────────────────────────────────────────────────────────────────
  // Helpers
  // ───────────────────────────────────────────────────────────────────────────

  Widget _remoteImage(String seed) {
    return Image.network(
      'https://picsum.photos/seed/$seed/400/600',
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => const DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [TrainingColors.primaryContainer, TrainingColors.primary],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.image_outlined,
            color: Color(0x80FFFFFF),
            size: 28,
          ),
        ),
      ),
    );
  }

  String _formatPrice(int price) {
    final String digits = price.toString();
    final StringBuffer buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write(',');
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

// ───────────────────────────────────────────────────────────────────────────
// Mock model
// ───────────────────────────────────────────────────────────────────────────

enum _ProgramType { all, course, field }

enum _ProgramSort { latest, popular, rating, priceLow }

class _ProgramMock {
  final String id;
  final _ProgramType type;
  final String title;
  final String trainer;
  final int students;
  final String duration;
  final String startDate;
  final String location;
  final IconData locationIcon;
  final double rating;
  final int price;
  final bool available;
  final String imageSeed;

  const _ProgramMock({
    required this.id,
    required this.type,
    required this.title,
    required this.trainer,
    required this.students,
    required this.duration,
    required this.startDate,
    required this.location,
    required this.locationIcon,
    required this.rating,
    required this.price,
    required this.available,
    required this.imageSeed,
  });
}
