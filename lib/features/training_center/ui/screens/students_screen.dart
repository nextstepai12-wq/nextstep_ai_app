import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/widgets/app_responsive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/training_colors.dart';
import '../widgets/training_center_drawer.dart';

enum StudentRequestStatus { pending, accepted, rejected }

class StudentRequest {
  const StudentRequest({
    required this.id,
    required this.name,
    required this.initials,
    required this.avatarUrl,
    required this.course,
    required this.courseIcon,
    required this.time,
    required this.bio,
    required this.status,
    this.verified = false,
    this.hasAttachments = false,
    this.attachmentsNote,
    this.rejectionReason,
    this.statusNote,
  });

  final String id;
  final String name;
  final String initials;
  final String avatarUrl;
  final String course;
  final IconData courseIcon;
  final String time;
  final String bio;
  final StudentRequestStatus status;
  final bool verified;
  final bool hasAttachments;
  final String? attachmentsNote;
  final String? rejectionReason;
  final String? statusNote;

  StudentRequest copyWith({required StudentRequestStatus status}) =>
      StudentRequest(
        id: id,
        name: name,
        initials: initials,
        avatarUrl: avatarUrl,
        course: course,
        courseIcon: courseIcon,
        time: time,
        bio: bio,
        status: status,
        verified: verified,
        hasAttachments: hasAttachments,
        attachmentsNote: attachmentsNote,
        rejectionReason: rejectionReason,
        statusNote: statusNote,
      );
}

const List<StudentRequest> mockStudentRequests = [
  StudentRequest(
    id: 'REQ-2025-884',
    name: 'عبدالله الشمري',
    initials: 'ع ش',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida-public/AB6AXuDTpV31lKAntO_WyTK1WtD-ISi_qwnIE44Sk_zCb_8CO22nmrS4UFsRB79KHfavrIbYf-0ftMJxkLXdBc_Yw-K2zpzjt4EDjx7a9X4rkwblb5_XZ9E6jQl_smxAeGxsmKi-knLs2VlrGxJMMJX-ydUrqUQqQCuxjxiMEDySuhqcPu2Xjb6sPrCdLMTWtB21KlCzhWU0BhHTge7K16kZRxcEtzVaOs8yfi6plIkg7ElWJwrom9lT1Q21',
    course: 'دورة إدارة المشاريع الاحترافية PMP®',
    courseIcon: Icons.menu_book_rounded,
    time: 'قبل ساعتين',
    bio: '25 سنة • الرياض • طالب خريج',
    status: StudentRequestStatus.pending,
    verified: true,
  ),
  StudentRequest(
    id: 'REQ-2025-881',
    name: 'سارة ناصر الدوسري',
    initials: 'س ن',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida/AEtjO1Ug9zoRkNQbw-RIv-nzyM9NDRDNzRQPKLLWbMxEw9hyvqqELDCVCSrThqfXZU6u3zYm-vVn3be1R4_8JiNvycELiWVlDmzIpuhzqACZLCodQJSBd6yj2yrjpJjp4TeGKYuXvgRs5ZiP73tzu2gtEFemAefhs5iwvT5cMoKxvd72vqkmtu6-lkI2lTxXOj5cc3Y3zT7upj2MAUYxKQ0meWwB_S1oRv8V5kvlwahvjTtBX7JJLpqgCrXgI28',
    course: 'دبلوم الأمن السيبراني واختبار الاختراق',
    courseIcon: Icons.security_rounded,
    time: 'قبل 4 ساعات',
    bio: 'خريجة تقنية معلومات • الرياض',
    status: StudentRequestStatus.pending,
    hasAttachments: true,
    attachmentsNote: 'مرفق شهادة البكالوريوس والسيرة الذاتية (PDF)',
  ),
  StudentRequest(
    id: 'REQ-2025-877',
    name: 'م. فيصل الخالدي',
    initials: 'ف خ',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida/AEtjO1XAsRPv7whWNzShk83CyUqnX0c6za0L3fXpRzaawh65jutsnfAoKaOTmK-EnGKK9Lm9-XxL6XLFFUjpUdLFkQWWVo7xtkIsTT8aALnxo6TFei-q8XVVQKFct-ylmy45gWPahYcXD0DuMqn477WfFPqy2eVCX2muF3FdSjMJ1TzVUulEiMwqHsDk3MlcOwKoLoKs_UkqZUMTn6g3-_hZhwfCYK3zZtqKnIuBgkeokQYlxMxg11ugQJ_OKDM',
    course: 'تدريب ميداني — صيانة خطوط الإنتاج',
    courseIcon: Icons.precision_manufacturing_rounded,
    time: 'أمس، 03:30 م',
    bio: 'مهندس ميكانيكي • الدمام',
    status: StudentRequestStatus.accepted,
    statusNote: 'تم اعتماد القبول وإرسال الفاتورة آلياً',
  ),
  StudentRequest(
    id: 'REQ-2025-869',
    name: 'فهد تركي القحطاني',
    initials: 'ف ت',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida/AEtjO1Vo2kllBbYfTK3-c4XTLMUOcuTrAantg9QHEMD7JVzJd96eYD5Jdr6llG7bi-Tq5iI7LFv73FoVeNXLaHPBeAttQq1zs4tsB-ds15fmKbpsB6reZ-SaTiNWV5_1DF7VcZoILAji-l61-C8Y45qwji4KrXI3_oU7KKh9VzehUkCk4tkS7E1n-nG7tyS3xEiqnOt6FVS-56gf8K_VH-CzM2TnQRWcAUVbXTVB4qNFmfysWv8NhyMwQ6MDGI0',
    course: 'دورة إدارة المشاريع الاحترافية PMP®',
    courseIcon: Icons.menu_book_rounded,
    time: 'منذ يومين',
    bio: 'موظف إداري • جدة',
    status: StudentRequestStatus.rejected,
    rejectionReason: 'عدم استيفاء شروط سنوات الخبرة العملية المطلوبة للدورة.',
  ),
  StudentRequest(
    id: 'REQ-2025-885',
    name: 'عمر عبدالعزيز الحربي',
    initials: 'ع ع',
    avatarUrl:
        'https://lh3.googleusercontent.com/aida/AEtjO1X5PiQCuXDe_R10li0XXnAS17LvCrIp1qBgoemYJDSIPLdfj1h1TLP84nxpXYi4KHpJXaf09VsTcp-5pmQiQYnR8V30WBo2F_QSNnQ7tSLwXt2ey24ub-PC7X7ohcxu0teBYL3XPtptEZdiTHNQDYseOAN6RIct6yusbtd8r5wsJO9Ccmt-2LMSIYnnaTXJFCfbL4sKhNma1zi2eJiJvUTdSbwyZyMxCnnz28sQ2ePQMrb_y2qfPuLo8Dk',
    course: 'تدريب ميداني — إدارة وضبط جودة المشاريع',
    courseIcon: Icons.verified_user_rounded,
    time: 'قبل 5 ساعات',
    bio: 'بكالوريوس إدارة أعمال • مكة المكرمة',
    status: StudentRequestStatus.pending,
  ),
];

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final ScrollController _scrollController = ScrollController();

  final List<StudentRequest> _requests = List.of(mockStudentRequests);
  StudentRequestStatus? _selectedTab;
  String? _courseFilter;
  bool _newestFirst = true;
  bool _tabsVisible = true;
  double _lastScrollOffset = 0;

  static const double _hideTriggerDelta = 6;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_handleScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_handleScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _handleScroll() {
    final offset = _scrollController.offset;
    final delta = offset - _lastScrollOffset;

    bool? nextVisible;
    if (offset <= 0) {
      nextVisible = true;
    } else if (delta > _hideTriggerDelta) {
      nextVisible = false;
    } else if (delta < -_hideTriggerDelta) {
      nextVisible = true;
    }

    if (nextVisible != null && nextVisible != _tabsVisible) {
      setState(() => _tabsVisible = nextVisible!);
    }
    _lastScrollOffset = offset;
  }

  int get _pendingCount => _countOf(StudentRequestStatus.pending);
  int get _acceptedCount => _countOf(StudentRequestStatus.accepted);
  int get _rejectedCount => _countOf(StudentRequestStatus.rejected);
  int get _totalCount => _requests.length;

  int _countOf(StudentRequestStatus status) =>
      _requests.where((r) => r.status == status).length;

  List<StudentRequest> get _visibleRequests {
    final list = _requests.where((request) {
      final matchesTab =
          _selectedTab == null || request.status == _selectedTab;
      final matchesCourse =
          _courseFilter == null || request.course == _courseFilter;
      return matchesTab && matchesCourse;
    }).toList();
    return _newestFirst ? list : list.reversed.toList();
  }

  void _applyDecision(StudentRequest request, bool accept) {
    setState(() {
      final index = _requests.indexWhere((r) => r.id == request.id);
      if (index >= 0) {
        _requests[index] = _requests[index].copyWith(
          status: accept
              ? StudentRequestStatus.accepted
              : StudentRequestStatus.rejected,
        );
      }
    });
    _showDecisionToast(accept, request.name);
  }

  void _showDecisionToast(bool accept, String name) {
    final color = accept ? Colors.green.shade600 : Colors.red.shade600;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
        backgroundColor: color,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(14.r)),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            Icon(
              accept ? Icons.check_circle_rounded : Icons.cancel_rounded,
              color: Colors.white,
            ),
            SizedBox(width: 10.w),
            Expanded(
              child: Text(
                accept
                    ? 'تم قبول طلب $name وتحديث الحالة محلياً'
                    : 'تم رفض طلب $name وتحديث الحالة محلياً',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<bool> _confirmDismiss(
      BuildContext cardContext, StudentRequest request, bool accept) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: cardContext,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RequestConfirmationSheet(
        accept: accept,
        request: request,
      ),
    );
    if (confirmed == true && mounted) {
      _applyDecision(request, accept);
      return true;
    }
    return false;
  }

  Future<void> _openDecisionSheet(StudentRequest request, bool accept) async {
    final confirmed = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => RequestConfirmationSheet(
        accept: accept,
        request: request,
      ),
    );
    if (confirmed == true && mounted) {
      _applyDecision(request, accept);
    }
  }

  Future<void> _openDetails(StudentRequest request) async {
    final status = await context.push<StudentRequestStatus>(
      '/training-center/students/details',
      extra: request,
    );
    if (!mounted || status == null) return;
    _applyDecision(request, status == StudentRequestStatus.accepted);
  }

  @override
  Widget build(BuildContext context) {
    final visible = _visibleRequests;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: TrainingColors.background,
      appBar: _buildAppBar(),
      drawer: const TrainingCenterDrawer(),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 8.h, 16.w, 0),
            child: const Align(
              alignment: AlignmentDirectional.centerStart,
              child: SampleDataBadge(),
            ),
          ),
          _buildStatusTabs(),
          _buildSecondaryFilters(visible.length),
          Expanded(
            child: ListView.separated(
              controller: _scrollController,
              padding: EdgeInsets.fromLTRB(16.w, 4.h, 16.w, 24.h),
              physics: const BouncingScrollPhysics(),
              itemCount: visible.length + 1,
              separatorBuilder: (_, __) => SizedBox(height: 12.h),
              itemBuilder: (context, index) {
                if (index == visible.length) return const _ListFooter();
                final request = visible[index];
                return _Entrance(
                  index: index,
                  child: request.status == StudentRequestStatus.pending
                      ? Dismissible(
                          key: ValueKey(request.id),
                          direction: DismissDirection.horizontal,
                          background: _swipeBackground(accept: false),
                          secondaryBackground: _swipeBackground(accept: true),
                          confirmDismiss: (direction) => _confirmDismiss(
                            context,
                            request,
                            direction == DismissDirection.endToStart,
                          ),
                          child: _RequestCard(
                            request: request,
                            swipeHint: index == 0,
                            onTap: () => _openDetails(request),
                            onDecision: (accept) =>
                                _openDecisionSheet(request, accept),
                          ),
                        )
                      : _RequestCard(
                          request: request,
                          swipeHint: false,
                          onTap: () => _openDetails(request),
                          onDecision: (accept) =>
                              _openDecisionSheet(request, accept),
                        ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _swipeBackground({required bool accept}) {
    final color = accept ? Colors.green.shade600 : TrainingColors.danger;
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 0.w, vertical: 0.h),
      alignment: accept ? Alignment.centerLeft : Alignment.centerRight,
      padding: EdgeInsets.symmetric(horizontal: 24.w),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .92),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            accept ? Icons.check_circle_rounded : Icons.cancel_rounded,
            color: Colors.white,
            size: 28.sp,
          ),
          SizedBox(height: 4.h),
          Text(
            accept ? 'قبول سريع' : 'رفض سريع',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: TrainingColors.surface.withValues(alpha: .92),
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded, color: TrainingColors.primary),
        onPressed: () => _scaffoldKey.currentState?.openDrawer(),
      ),
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 28.h,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 28.w,
              height: 28.w,
              decoration: BoxDecoration(
                color: TrainingColors.primary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: const Icon(Icons.school_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'منصة التدريب التقني',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: TrainingColors.primary,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  'بوابة التدريب الاحترافي',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: TrainingColors.accent,
                    fontWeight: FontWeight.w600,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              icon: const Icon(Icons.notifications_none_rounded,
                  color: TrainingColors.textPrimary),
              onPressed: () => context.push('/training-center/notifications'),
            ),
            Positioned(
              top: 10.h,
              left: 12.w,
              child: Container(
                width: 8.w,
                height: 8.w,
                decoration: const BoxDecoration(
                  color: TrainingColors.accent,
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        ),
        Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: CircleAvatar(
            radius: 16.r,
            backgroundColor: TrainingColors.navySoft,
            child: const Icon(Icons.person_rounded,
                color: TrainingColors.primary, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusTabs() {
    final tabs = <(String, int, StudentRequestStatus?)>[
      ('الكل', _totalCount, null),
      ('جديد', _pendingCount, StudentRequestStatus.pending),
      ('مقبول', _acceptedCount, StudentRequestStatus.accepted),
      ('مرفوض', _rejectedCount, StudentRequestStatus.rejected),
    ];

    return ClipRect(
      child: AnimatedSize(
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _tabsVisible ? 1 : 0,
          child: SizedBox(
            height: _tabsVisible ? 60.h : 0,
            width: double.infinity,
            child: _tabsRow(tabs),
          ),
        ),
      ),
    );
  }

  Widget _tabsRow(List<(String, int, StudentRequestStatus?)> tabs) {
    return SizedBox(
      height: 52.h,
      child: ListView.separated(
        reverse: true,
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
        itemCount: tabs.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final tab = tabs[index];
          final selected = _selectedTab == tab.$3;
          return _StatusTabPill(
            label: tab.$1,
            count: tab.$2,
            selected: selected,
            showDot: tab.$1 == 'جديد' && _pendingCount > 0,
            onTap: () => setState(() => _selectedTab = tab.$3),
          );
        },
      ),
    );
  }

  Widget _buildSecondaryFilters(int shownCount) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 2.h, 16.w, 10.h),
      child: Row(
        children: [
          Expanded(
            child: _FilterButton(
              icon: Icons.filter_list_rounded,
              text: _courseFilter ?? 'كل الدورات',
              active: _courseFilter != null,
              onTap: _showCourseFilter,
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _FilterButton(
              icon: Icons.schedule_rounded,
              text: _newestFirst ? 'الأحدث' : 'الأقدم',
              active: !_newestFirst,
              onTap: _showSortFilter,
            ),
          ),
          SizedBox(width: 10.w),
          Text(
            '$shownCount من أصل $_totalCount',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10.sp,
              color: TrainingColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  void _showCourseFilter() {
    final courses = _requests.map((request) => request.course).toSet().toList();
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: TrainingColors.surface,
      builder: (ctx) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.symmetric(vertical: 12),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(
                'تصفية حسب الدورة',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: TrainingColors.primary,
                ),
              ),
            ),
            ListTile(
              title: const Text('كل الدورات'),
              trailing: _courseFilter == null
                  ? const Icon(Icons.check_rounded,
                      color: TrainingColors.primary)
                  : null,
              onTap: () {
                setState(() => _courseFilter = null);
                Navigator.pop(ctx);
              },
            ),
            for (final course in courses)
              ListTile(
                title: Text(course),
                trailing: _courseFilter == course
                    ? const Icon(Icons.check_rounded,
                        color: TrainingColors.primary)
                    : null,
                onTap: () {
                  setState(() => _courseFilter = course);
                  Navigator.pop(ctx);
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showSortFilter() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: TrainingColors.surface,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Align(
                alignment: AlignmentDirectional.centerStart,
                child: Text(
                  'ترتيب الطلبات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: TrainingColors.primary,
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text('الأحدث أولاً'),
              trailing: _newestFirst
                  ? const Icon(Icons.check_rounded,
                      color: TrainingColors.primary)
                  : null,
              onTap: () {
                setState(() => _newestFirst = true);
                Navigator.pop(ctx);
              },
            ),
            ListTile(
              title: const Text('الأقدم أولاً'),
              trailing: !_newestFirst
                  ? const Icon(Icons.check_rounded,
                      color: TrainingColors.primary)
                  : null,
              onTap: () {
                setState(() => _newestFirst = false);
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Entrance extends StatelessWidget {
  const _Entrance({required this.index, required this.child});

  final int index;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final duration = Duration(milliseconds: 320 + (index * 70).clamp(0, 420));
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: duration,
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 26 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: child,
    );
  }
}

class _RequestCard extends StatelessWidget {
  const _RequestCard({
    required this.request,
    required this.onTap,
    required this.onDecision,
    this.swipeHint = false,
  });

  final StudentRequest request;
  final VoidCallback onTap;
  final ValueChanged<bool> onDecision;
  final bool swipeHint;

  @override
  Widget build(BuildContext context) {
    final pending = request.status == StudentRequestStatus.pending;
    final stripe = switch (request.status) {
      StudentRequestStatus.accepted => TrainingColors.primary,
      StudentRequestStatus.rejected => TrainingColors.danger,
      StudentRequestStatus.pending => null,
    };

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(16.r),
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            boxShadow: TrainingColors.cardShadow,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16.r),
            child: Stack(
              children: [
                Padding(
                  padding: EdgeInsets.all(14.r),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _headerRow(),
                      SizedBox(height: 10.h),
                      _CourseBox(
                          course: request.course, icon: request.courseIcon),
                      if (request.hasAttachments) ...[
                        SizedBox(height: 8.h),
                        _attachmentPill(),
                      ],
                      if (request.status == StudentRequestStatus.accepted) ...[
                        SizedBox(height: 8.h),
                        _acceptedNote(),
                      ],
                      if (request.rejectionReason != null) ...[
                        SizedBox(height: 8.h),
                        _rejectionBox(),
                      ],
                      if (swipeHint && pending) ...[
                        SizedBox(height: 8.h),
                        _swipeHintRow(),
                      ],
                      if (pending) ...[
                        SizedBox(height: 12.h),
                        Row(
                          children: [
                            Expanded(
                              child: _SoftActionButton(
                                label: 'قبول الطلب',
                                icon: Icons.check_circle_outline_rounded,
                                color: Colors.green.shade600,
                                onTap: () => onDecision(true),
                              ),
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: _SoftActionButton(
                                label: 'رفض',
                                icon: Icons.cancel_outlined,
                                color: TrainingColors.danger,
                                onTap: () => onDecision(false),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                if (stripe != null)
                  Positioned(
                    top: 0,
                    bottom: 0,
                    right: 0,
                    width: 4.w,
                    child: ColoredBox(color: stripe),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _headerRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _Avatar(
          request: request,
          size: 48,
          dim: request.status == StudentRequestStatus.rejected,
        ),
        SizedBox(width: 11.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(request.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 14.5.sp,
                            fontWeight: FontWeight.w700,
                            color: TrainingColors.primary)),
                  ),
                  if (request.verified) ...[
                    SizedBox(width: 4.w),
                    Icon(Icons.verified_rounded,
                        size: 16.sp, color: Colors.green.shade600),
                  ],
                ],
              ),
              SizedBox(height: 2.h),
              Row(
                children: [
                  Icon(Icons.history_rounded,
                      size: 13.sp, color: TrainingColors.textMuted),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(request.time,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.5.sp,
                            color: TrainingColors.textSecondary)),
                  ),
                  SizedBox(width: 6.w),
                  Text('•',
                      style: TextStyle(
                          fontSize: 10.sp, color: TrainingColors.textMuted)),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text(request.bio,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.5.sp,
                            color: TrainingColors.textSecondary)),
                  ),
                ],
              ),
            ],
          ),
        ),
        SizedBox(width: 6.w),
        _StatusPill(status: request.status),
      ],
    );
  }

  Widget _attachmentPill() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 7.h),
      decoration: BoxDecoration(
        color: TrainingColors.surfaceMuted,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.attach_file_rounded,
              size: 15.sp, color: TrainingColors.accent),
          SizedBox(width: 6.w),
          Expanded(
            child: Text(request.attachmentsNote ?? '',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w600,
                    color: TrainingColors.primary)),
          ),
        ],
      ),
    );
  }

  Widget _acceptedNote() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: TrainingColors.surfaceAlt,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 16.sp, color: TrainingColors.primary),
          SizedBox(width: 7.w),
          Expanded(
            child: Text(
              request.statusNote ?? '',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.5.sp,
                  color: TrainingColors.textSecondary),
            ),
          ),
          Text('السجل',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.5.sp,
                  fontWeight: FontWeight.w700,
                  color: TrainingColors.accentDark)),
        ],
      ),
    );
  }

  Widget _rejectionBox() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: TrainingColors.dangerSoft,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded,
              size: 16.sp, color: TrainingColors.danger),
          SizedBox(width: 7.w),
          Expanded(
            child: Text.rich(
              TextSpan(children: [
                const TextSpan(
                    text: 'سبب الرفض: ',
                    style: TextStyle(fontWeight: FontWeight.w700)),
                TextSpan(text: request.rejectionReason!),
              ]),
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.5.sp,
                  height: 1.6,
                  color: TrainingColors.danger),
            ),
          ),
        ],
      ),
    );
  }

  Widget _swipeHintRow() {
    return Row(
      children: [
        Icon(Icons.touch_app_rounded,
            size: 14.sp, color: TrainingColors.accent),
        SizedBox(width: 4.w),
        Expanded(
          child: Text('اسحب لليسار للقبول السريع ←',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.sp,
                  color: TrainingColors.accent)),
        ),
        Text('عرض الملف',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.sp,
                fontWeight: FontWeight.w700,
                color: TrainingColors.primary)),
      ],
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.request, this.size = 48, this.dim = false});

  final StudentRequest request;
  final double size;
  final bool dim;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size.w,
      height: size.w,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: TrainingColors.surfaceMuted, width: 2),
      ),
      child: ClipOval(
        child: Opacity(
          opacity: dim ? .85 : 1,
          child: Image.network(
            request.avatarUrl,
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: TrainingColors.navySoft,
              alignment: Alignment.center,
              child: Text(
                request.initials,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontWeight: FontWeight.w700,
                  color: TrainingColors.primary,
                  fontSize: size * .26,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status, this.wide = false});

  final StudentRequestStatus status;
  final bool wide;

  @override
  Widget build(BuildContext context) {
    final data = switch (status) {
      StudentRequestStatus.pending => (
          'جديد',
          'بانتظار القرار',
          TrainingColors.rating,
          Icons.hourglass_top_rounded,
        ),
      StudentRequestStatus.accepted => (
          'مقبول',
          null,
          TrainingColors.success,
          Icons.task_alt_rounded,
        ),
      StudentRequestStatus.rejected => (
          'مرفوض',
          null,
          TrainingColors.danger,
          Icons.block_rounded,
        ),
    };
    final label = wide && data.$2 != null ? '${data.$1} - ${data.$2}' : data.$1;
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: data.$3.withValues(alpha: .12),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(data.$4, size: 13.sp, color: data.$3),
          SizedBox(width: 4.w),
          Flexible(
            child: Text(label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.sp,
                    fontWeight: FontWeight.w700,
                    color: data.$3)),
          ),
        ],
      ),
    );
  }
}

class _StatusTabPill extends StatelessWidget {
  const _StatusTabPill({
    required this.label,
    required this.count,
    required this.selected,
    required this.showDot,
    required this.onTap,
  });

  final String label;
  final int count;
  final bool selected;
  final bool showDot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? TrainingColors.primary : Colors.white,
      borderRadius: BorderRadius.circular(20.r),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20.r),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOut,
          padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20.r),
            border: Border.all(
              color: selected ? TrainingColors.primary : TrainingColors.divider,
            ),
            boxShadow: selected ? TrainingColors.softShadow : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showDot) ...[
                const _PulseDot(color: TrainingColors.danger, size: 6),
                SizedBox(width: 6.w),
              ],
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontWeight: FontWeight.w600,
                      fontSize: 12.sp,
                      color: selected ? Colors.white : TrainingColors.primary)),
              SizedBox(width: 6.w),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                decoration: BoxDecoration(
                  color: selected
                      ? Colors.white.withValues(alpha: .22)
                      : TrainingColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Text('$count',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.sp,
                        fontWeight: FontWeight.w700,
                        color:
                            selected ? Colors.white : TrainingColors.primary)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.icon,
    required this.text,
    required this.onTap,
    this.active = false,
  });

  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final bool active;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: active ? TrainingColors.accentSoft : Colors.white,
      borderRadius: BorderRadius.circular(10.r),
      child: InkWell(
        borderRadius: BorderRadius.circular(10.r),
        onTap: onTap,
        child: Container(
          height: 42.h,
          padding: EdgeInsets.symmetric(horizontal: 11.w),
          decoration: BoxDecoration(
            border: Border.all(
              color: active
                  ? TrainingColors.accent
                  : TrainingColors.divider,
            ),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Icon(icon, size: 17.sp, color: TrainingColors.primary),
              SizedBox(width: 7.w),
              Expanded(
                child: Text(text,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: TrainingColors.textPrimary)),
              ),
              Icon(Icons.keyboard_arrow_down_rounded,
                  size: 18.sp, color: TrainingColors.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

class _SoftActionButton extends StatelessWidget {
  const _SoftActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40.h,
      child: Material(
        color: color.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(10.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18.sp, color: color),
              SizedBox(width: 6.w),
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ListFooter extends StatelessWidget {
  const _ListFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 24.h),
      child: Column(
        children: [
          CircleAvatar(
            radius: 20.r,
            backgroundColor: TrainingColors.surfaceMuted,
            child: Icon(Icons.checklist_rtl_rounded,
                color: TrainingColors.accent, size: 22.sp),
          ),
          SizedBox(height: 10.h),
          Text('تمت معاينة جميع الطلبات المتبقية اليوم',
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w700,
                  color: TrainingColors.primary)),
          SizedBox(height: 3.h),
          Text('سيتم تحديث القائمة تلقائياً عند وصول تسجيل جديد',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.5.sp,
                  color: TrainingColors.textSecondary)),
        ],
      ),
    );
  }
}

class _PulseDot extends StatefulWidget {
  const _PulseDot({this.color = TrainingColors.accent, this.size = 7});

  final Color color;
  final double size;

  @override
  State<_PulseDot> createState() => _PulseDotState();
}

class _PulseDotState extends State<_PulseDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1200),
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: .35, end: 1).animate(_controller),
      child: Container(
        width: widget.size.w,
        height: widget.size.w,
        decoration: BoxDecoration(
          color: widget.color,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

class _CourseBox extends StatelessWidget {
  const _CourseBox({required this.course, required this.icon});

  final String course;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 9.h),
      decoration: BoxDecoration(
        color: TrainingColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Icon(icon, color: TrainingColors.primary, size: 19.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('طلب التسجيل في:',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.sp,
                        color: TrainingColors.textSecondary)),
                Text(course,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        color: TrainingColors.primary,
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class StudentRequestDetailsScreen extends StatelessWidget {
  const StudentRequestDetailsScreen({super.key, required this.request});

  final StudentRequest request;

  Future<void> _launch(String uri) async {
    final url = Uri.parse(uri);
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrainingColors.background,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_forward_ios_rounded,
              size: 19, color: TrainingColors.primary),
          onPressed: () => context.pop(),
        ),
        title: const Text('تفاصيل الطلب',
            style: TextStyle(
                fontFamily: 'Cairo',
                color: TrainingColors.primary,
                fontWeight: FontWeight.w700,
                fontSize: 20)),
        actions: [
          IconButton(
            tooltip: 'نسخ ملخص الطلب',
            onPressed: () async {
              await Clipboard.setData(
                ClipboardData(
                  text: '${request.name}\n${request.course}\n'
                      'رقم الطلب: ${request.id}',
                ),
              );
              if (!context.mounted) return;
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('تم نسخ ملخص الطلب'),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            icon: const Icon(Icons.copy_all_rounded,
                color: TrainingColors.primary),
          ),
        ],
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 140.h),
            children: [
              _RequestIdRow(request: request),
              SizedBox(height: 12.h),
              _StudentHeader(request: request),
              SizedBox(height: 16.h),
              const SampleDataBadge(),
              SizedBox(height: 16.h),
              _CourseCard(course: request.course),
              SizedBox(height: 16.h),
              const _InfoCard(),
              SizedBox(height: 16.h),
              const _AttachmentsCard(),
              SizedBox(height: 16.h),
              const _MessageCard(),
              SizedBox(height: 16.h),
              const _PaymentCard(),
            ],
          ),
          _DetailActions(
            request: request,
            onDecision: (accept) async {
              final confirmed = await showModalBottomSheet<bool>(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => RequestConfirmationSheet(
                  accept: accept,
                  request: request,
                ),
              );
              if (confirmed == true && context.mounted) {
                Navigator.pop(
                  context,
                  accept
                      ? StudentRequestStatus.accepted
                      : StudentRequestStatus.rejected,
                );
              }
            },
            onContact: () => _launch('https://wa.me/966551234567'),
          ),
        ],
      ),
    );
  }
}

class _RequestIdRow extends StatelessWidget {
  const _RequestIdRow({required this.request});

  final StudentRequest request;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const _PulseDot(),
        SizedBox(width: 8.w),
        Expanded(
          child: Text('طلب رقم #${request.id}',
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  color: TrainingColors.textSecondary)),
        ),
      ],
    );
  }
}

class _StudentHeader extends StatelessWidget {
  const _StudentHeader({required this.request});

  final StudentRequest request;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _Avatar(request: request, size: 72),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(request.name,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 18.sp,
                            fontWeight: FontWeight.w700,
                            color: TrainingColors.primary)),
                    SizedBox(height: 3.h),
                    Text(request.bio,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            color: TrainingColors.textSecondary)),
                    SizedBox(height: 7.h),
                    Row(
                      children: [
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: const BoxDecoration(
                              color: TrainingColors.success,
                              shape: BoxShape.circle),
                        ),
                        SizedBox(width: 6.w),
                        Expanded(
                          child: Text('تم تدقيق الهوية الوطنية',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10.sp,
                                  color: TrainingColors.textSecondary)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: TrainingColors.surfaceMuted,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(Icons.hourglass_top_rounded,
                    size: 18.sp, color: TrainingColors.rating),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text('حالة الطلب:',
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          color: TrainingColors.textPrimary)),
                ),
                SizedBox(width: 8.w),
                _StatusPill(status: request.status, wide: true),
              ],
            ),
          ),
          SizedBox(height: 14.h),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: TrainingColors.surfaceAlt,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(Icons.phone_iphone_rounded,
                    size: 18.sp, color: TrainingColors.primary),
                SizedBox(width: 8.w),
                const Expanded(
                  child: Text('+966 55 123 4567',
                      textDirection: TextDirection.ltr,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: TrainingColors.textPrimary)),
                ),
                SizedBox(width: 8.w),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 9.w, vertical: 5.h),
                  decoration: BoxDecoration(
                    color: TrainingColors.successSoft,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.chat_bubble_outline_rounded,
                          size: 14.sp, color: TrainingColors.success),
                      SizedBox(width: 4.w),
                      Flexible(
                        child: Text('واتساب مباشر',
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 10.sp,
                                fontWeight: FontWeight.w700,
                                color: TrainingColors.success)),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 18, color: TrainingColors.divider),
          Row(
            children: [
              Icon(Icons.mail_outline_rounded,
                  size: 18.sp, color: TrainingColors.textSecondary),
              SizedBox(width: 8.w),
              Expanded(
                child: Text('abdullah.alshammari@example.com',
                    textDirection: TextDirection.ltr,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.sp,
                        color: TrainingColors.textPrimary)),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  const _CourseCard({required this.course});

  final String course;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_stories_outlined,
                  color: TrainingColors.primary, size: 20.sp),
              SizedBox(width: 7.w),
              Expanded(
                child: Text('الدورة المطلوبة',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15.sp,
                        fontWeight: FontWeight.w700,
                        color: TrainingColors.primary)),
              ),
              const _MiniBadge('كورس معتمد', TrainingColors.primary),
            ],
          ),
          SizedBox(height: 12.h),
          Container(
            padding: EdgeInsets.all(10.r),
            decoration: BoxDecoration(
              color: TrainingColors.surfaceAlt,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Row(
              children: [
                Container(
                  width: 64.w,
                  height: 64.w,
                  decoration: BoxDecoration(
                    color: TrainingColors.primary,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(Icons.groups_rounded,
                      color: Colors.white, size: 32.sp),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(course,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: TrainingColors.primary)),
                      const SizedBox(height: 5),
                      const Text(
                        'التفاصيل الإضافية للدورة غير متوفرة في هذه النسخة.',
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10,
                            color: TrainingColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.cardShadow,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('البيانات الأكاديمية والمهنية', Icons.badge_outlined),
          SizedBox(height: 14),
          _InfoRow(
            icon: Icons.school_outlined,
            title: 'المؤهل العلمي',
            value: 'بكالوريوس إدارة أعمال',
            sub: 'جامعة الملك سعود — معدل 4.65 من 5.00',
          ),
          _InfoRow(
            icon: Icons.domain_rounded,
            title: 'جهة العمل الحالية',
            value: 'شركة التقنية المتقدمة للحلول الرقمية',
            sub: 'دوام كامل • قسم إدارة البرامج التقنية',
          ),
          _InfoRow(
            icon: Icons.work_history_outlined,
            title: 'سنوات الخبرة العملية',
            value: '3 سنوات كمنسق مشاريع تقنية',
            sub: 'إشراف وتنسيق مشاريع تطوير الأنظمة المؤسسية',
            last: true,
          ),
        ],
      ),
    );
  }
}

class _AttachmentsCard extends StatelessWidget {
  const _AttachmentsCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.cardShadow,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.attach_file_rounded,
                  color: TrainingColors.primary, size: 20),
              SizedBox(width: 7),
              Expanded(
                child: Text('المرفقات والمستندات',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: TrainingColors.primary)),
              ),
              Text('مستندان مرفقان',
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10,
                      color: TrainingColors.textMuted)),
            ],
          ),
          SizedBox(height: 12),
          _FileRow(
            title: 'سيرة_عبدالله_الشمري.pdf',
            sub: '240 كيلوبايت • السيرة الذاتية',
            icon: Icons.picture_as_pdf_outlined,
            color: TrainingColors.danger,
          ),
          SizedBox(height: 8),
          _FileRow(
            title: 'وثيقة_البكالوريوس.jpg',
            sub: '1.2 ميجابايت • شهادة التخرج',
            icon: Icons.image_outlined,
            color: TrainingColors.primary,
            status: 'معتمدة',
          ),
        ],
      ),
    );
  }
}

class _FileRow extends StatelessWidget {
  const _FileRow({
    required this.title,
    required this.sub,
    required this.icon,
    required this.color,
    this.status,
  });

  final String title;
  final String sub;
  final IconData icon;
  final Color color;
  final String? status;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: TrainingColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Row(
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(icon, color: color, size: 21.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontWeight: FontWeight.w600,
                              fontSize: 12.sp,
                              color: TrainingColors.textPrimary)),
                    ),
                    if (status != null) ...[
                      SizedBox(width: 6.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                            horizontal: 6.w, vertical: 2.h),
                        decoration: BoxDecoration(
                          color: TrainingColors.successSoft,
                          borderRadius: BorderRadius.circular(5.r),
                        ),
                        child: Text(status!,
                            style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 9.sp,
                                fontWeight: FontWeight.w700,
                                color: TrainingColors.success)),
                      ),
                    ],
                  ],
                ),
                SizedBox(height: 2.h),
                Text(sub,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.sp,
                        color: TrainingColors.textSecondary)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {},
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.visibility_outlined,
                size: 19, color: TrainingColors.primary),
          ),
          IconButton(
            onPressed: () {},
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.download_rounded,
                size: 19, color: TrainingColors.primary),
          ),
        ],
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  const _MessageCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.cardShadow,
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _SectionTitle('رسالة ورغبة المتدرب', Icons.format_quote_rounded),
          SizedBox(height: 10),
          _QuoteBox(),
        ],
      ),
    );
  }
}

class _QuoteBox extends StatelessWidget {
  const _QuoteBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: TrainingColors.surfaceAlt,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Stack(
        children: [
          Positioned(
            bottom: -8.h,
            left: -8.w,
            child: Icon(
              Icons.format_quote_rounded,
              size: 64.sp,
              color: TrainingColors.surfaceMuted.withValues(alpha: .7),
            ),
          ),
          const Text(
            'أرغب بتطوير مهاراتي العملية في تخطيط وجدولة المشاريع وفق أحدث معايير PMI للحصول على شهادة PMP والتأهل لقيادة مشاريع التحول الرقمي بالمنشأة.',
            style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12,
                height: 1.9,
                color: TrainingColors.textPrimary),
          ),
        ],
      ),
    );
  }
}

class _PaymentCard extends StatelessWidget {
  const _PaymentCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: TrainingColors.primary,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.cardShadow,
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('رسوم التسجيل المعتمدة',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: Colors.white70)),
                SizedBox(height: 2.h),
                Text('1,500 ريال سعودي',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 22.sp,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.credit_score_outlined,
                    size: 15.sp, color: TrainingColors.accent),
                SizedBox(width: 5.w),
                Text('بانتظار موافقة المنشأة',
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.sp,
                        color: TrainingColors.accent)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailActions extends StatelessWidget {
  const _DetailActions({
    required this.request,
    required this.onDecision,
    required this.onContact,
  });

  final StudentRequest request;
  final ValueChanged<bool> onDecision;
  final VoidCallback onContact;

  @override
  Widget build(BuildContext context) {
    final pending = request.status == StudentRequestStatus.pending;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Container(
        padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 8.h),
        decoration: const BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
                color: Color(0x16000000), blurRadius: 12, offset: Offset(0, -3))
          ],
        ),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (pending)
                Row(
                  children: [
                    Expanded(
                      child: _DecisionButton(
                        label: 'قبول الطالب',
                        icon: Icons.check_circle_rounded,
                        color: TrainingColors.success,
                        solid: true,
                        onTap: () => onDecision(true),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: _DecisionButton(
                        label: 'رفض الطلب',
                        icon: Icons.close_rounded,
                        color: TrainingColors.danger,
                        outlined: true,
                        onTap: () => onDecision(false),
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: _StatusSummaryBanner(status: request.status),
                ),
              SizedBox(height: 8.h),
              GestureDetector(
                onTap: onContact,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.chat_bubble_outline_rounded,
                        size: 15.sp, color: TrainingColors.success),
                    SizedBox(width: 5.w),
                    Flexible(
                      child: Text('تواصل مع الطالب مباشرة عبر واتساب',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.sp,
                              color: TrainingColors.textSecondary)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusSummaryBanner extends StatelessWidget {
  const _StatusSummaryBanner({required this.status});

  final StudentRequestStatus status;

  @override
  Widget build(BuildContext context) {
    final data = switch (status) {
      StudentRequestStatus.accepted => (
          'تم اعتماد قبول الطالب وإرسال الفاتورة آلياً',
          TrainingColors.success,
          Icons.task_alt_rounded,
        ),
      StudentRequestStatus.rejected => (
          'تم رفض الطلب وإشعار المتقدم بالسبب',
          TrainingColors.danger,
          Icons.block_rounded,
        ),
      StudentRequestStatus.pending => (
          'بانتظار قرار المنشأة',
          TrainingColors.rating,
          Icons.hourglass_top_rounded,
        ),
    };
    return Container(
      height: 46.h,
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      decoration: BoxDecoration(
        color: data.$2.withValues(alpha: .10),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: data.$2.withValues(alpha: .35)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(data.$3, size: 18.sp, color: data.$2),
          SizedBox(width: 7.w),
          Flexible(
            child: Text(data.$1,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w700,
                    color: data.$2)),
          ),
        ],
      ),
    );
  }
}

class _DecisionButton extends StatelessWidget {
  const _DecisionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
    this.solid = false,
    this.outlined = false,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final bool solid;
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48.h,
      child: Material(
        color: outlined ? Colors.white : color,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12.r),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12.r),
              border: outlined ? Border.all(color: color) : null,
              boxShadow: solid
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: .30),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 18.sp, color: solid ? Colors.white : color),
                SizedBox(width: 6.w),
                Text(label,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.5.sp,
                        fontWeight: FontWeight.w700,
                        color: solid ? Colors.white : color)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title, this.icon);

  final String title;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: TrainingColors.primary, size: 20.sp),
        SizedBox(width: 7.w),
        Expanded(
          child: Text(title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 15.sp,
                  fontWeight: FontWeight.w700,
                  color: TrainingColors.primary)),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.title,
    required this.value,
    required this.sub,
    this.last = false,
  });

  final IconData icon;
  final String title;
  final String value;
  final String sub;
  final bool last;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 14.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18.r,
            backgroundColor: TrainingColors.surfaceAlt,
            child: Icon(icon, color: TrainingColors.primary, size: 19.sp),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.sp,
                        color: TrainingColors.textSecondary)),
                SizedBox(height: 1.h),
                Text(value,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w700,
                        color: TrainingColors.textPrimary)),
                Text(sub,
                    style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 10.sp,
                        color: TrainingColors.textSecondary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MiniBadge extends StatelessWidget {
  const _MiniBadge(this.text, this.color);

  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
      decoration: BoxDecoration(
        color: color.withValues(alpha: .13),
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Text(text,
          style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 9.5.sp,
              fontWeight: FontWeight.w700,
              color: color)),
    );
  }
}

class RequestConfirmationSheet extends StatefulWidget {
  const RequestConfirmationSheet({
    super.key,
    required this.accept,
    required this.request,
  });

  final bool accept;
  final StudentRequest request;

  @override
  State<RequestConfirmationSheet> createState() =>
      _RequestConfirmationSheetState();
}

enum _SheetPhase { idle, loading, success }

class _RequestConfirmationSheetState extends State<RequestConfirmationSheet>
    with SingleTickerProviderStateMixin {
  bool _welcomeMessage = true;
  bool _telegramLink = true;
  _SheetPhase _phase = _SheetPhase.idle;

  late final AnimationController _pulseController = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  )..repeat();

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _confirm() async {
    if (_phase != _SheetPhase.idle) return;
    setState(() => _phase = _SheetPhase.loading);

    await Future<void>.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _phase = _SheetPhase.success);

    await Future<void>.delayed(const Duration(milliseconds: 1400));
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final accept = widget.accept;
    final color = accept ? TrainingColors.success : TrainingColors.danger;
    final canInteract = _phase == _SheetPhase.idle;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28.r)),
          boxShadow: const [
            BoxShadow(
              color: Color(0x2E000000),
              blurRadius: 30,
              offset: Offset(0, -8),
            ),
          ],
        ),
        padding: EdgeInsets.fromLTRB(
            24.w, 10.h, 24.w, 18.h + MediaQuery.of(context).viewPadding.bottom),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 42.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: TrainingColors.divider,
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
            SizedBox(height: 18.h),
            _Emblem(color: color, accept: accept, controller: _pulseController),
            SizedBox(height: 12.h),
            Text(
              accept ? 'تأكيد قبول الطالب في الدورة' : 'تأكيد رفض الطلب',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 17.sp,
                fontWeight: FontWeight.w700,
                color: TrainingColors.primary,
              ),
            ),
            SizedBox(height: 10.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: TrainingColors.surfaceMuted,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.school_rounded,
                      size: 15.sp, color: TrainingColors.accent),
                  SizedBox(width: 6.w),
                  Flexible(
                    child: Text.rich(
                      TextSpan(children: [
                        const TextSpan(text: 'الطالب: '),
                        TextSpan(
                          text: widget.request.name,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        TextSpan(text: ' • ${widget.request.course}'),
                      ]),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.sp,
                        color: TrainingColors.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10.h),
            Text(
              accept
                  ? 'سيتم إشعار الطالب فوراً برسالة نصية وتطبيق الواتساب بقبول طلبه، وإصدار رابط سداد الفاتورة تلقائياً، وإضافته لكشف الحضور الرسمي الخاص بالدورة.'
                  : 'هل أنت متأكد من رفض طلب ${widget.request.name}؟ سيتم إشعاره وتحديث حالة الطلب.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 12.sp,
                height: 1.8,
                color: TrainingColors.textSecondary,
              ),
            ),
            if (accept) ...[
              SizedBox(height: 16.h),
              _SheetOption(
                checked: _welcomeMessage && canInteract,
                disabled: !canInteract,
                onChanged: (value) => setState(() => _welcomeMessage = value),
                title: 'إرسال رسالة ترحيبية وتفاصيل القاعة التدريبية',
                subtitle: 'عبر البريد الإلكتروني والواتساب',
              ),
              SizedBox(height: 10.h),
              _SheetOption(
                checked: _telegramLink && canInteract,
                disabled: !canInteract,
                onChanged: (value) => setState(() => _telegramLink = value),
                title: 'تضمين رابط الانضمام لمجموعة تليجرام الخاصة بالدورة',
                subtitle: 'للتواصل المباشر مع المدرب وزملائه المتدربين',
              ),
              SizedBox(height: 12.h),
              const _CapacityStrip(),
            ],
            if (_phase == _SheetPhase.success) ...[
              SizedBox(height: 14.h),
              const _SuccessNotice(),
            ],
            SizedBox(height: 18.h),
            _ConfirmButton(
              accept: accept,
              phase: _phase,
              onConfirm: _confirm,
            ),
            SizedBox(height: 6.h),
            TextButton(
              onPressed:
                  canInteract ? () => Navigator.pop(context, false) : null,
              child: Text(
                accept ? 'رجوع وإلغاء' : 'رجوع',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: canInteract
                      ? TrainingColors.textSecondary
                      : TrainingColors.textSecondary.withValues(alpha: .5),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Emblem extends StatelessWidget {
  const _Emblem({
    required this.color,
    required this.accept,
    required this.controller,
  });

  final Color color;
  final bool accept;
  final AnimationController controller;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 80.w,
      height: 80.w,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AnimatedBuilder(
            animation: controller,
            builder: (context, _) {
              final scale = 1.0 + (controller.value * .25);
              return Transform.scale(
                scale: scale,
                child: Opacity(
                  opacity: (1 - controller.value) * .35,
                  child: Container(
                    width: 80.w,
                    height: 80.w,
                    decoration:
                        BoxDecoration(color: color, shape: BoxShape.circle),
                  ),
                ),
              );
            },
          ),
          Container(
            width: 62.w,
            height: 62.w,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            child: Icon(
              accept ? Icons.check_rounded : Icons.close_rounded,
              size: 32.sp,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _SheetOption extends StatelessWidget {
  const _SheetOption({
    required this.checked,
    required this.onChanged,
    required this.title,
    required this.subtitle,
    this.disabled = false,
  });

  final bool checked;
  final bool disabled;
  final ValueChanged<bool> onChanged;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: disabled
          ? TrainingColors.surfaceAlt.withValues(alpha: .6)
          : TrainingColors.surfaceAlt,
      borderRadius: BorderRadius.circular(12.r),
      child: InkWell(
        onTap: disabled ? null : () => onChanged(!checked),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(12.r),
          child: Row(
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                curve: Curves.easeOut,
                width: 22.w,
                height: 22.w,
                decoration: BoxDecoration(
                  color: checked ? TrainingColors.accent : Colors.transparent,
                  border: Border.all(
                    color: checked
                        ? TrainingColors.accent
                        : TrainingColors.divider,
                    width: 1.6,
                  ),
                  borderRadius: BorderRadius.circular(6.r),
                ),
                child: AnimatedScale(
                  scale: checked ? 1 : 0,
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutBack,
                  child: const Icon(Icons.check_rounded,
                      size: 15, color: Colors.white),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontWeight: FontWeight.w600,
                            fontSize: 11.5.sp,
                            height: 1.5,
                            color: TrainingColors.textPrimary)),
                    Text(subtitle,
                        style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 10.sp,
                            height: 1.5,
                            color: TrainingColors.textSecondary)),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CapacityStrip extends StatelessWidget {
  const _CapacityStrip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: TrainingColors.surfaceMuted,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Row(
        children: [
          Icon(Icons.event_seat_rounded,
              color: TrainingColors.accent, size: 20.sp),
          SizedBox(width: 8.w),
          Expanded(
            child: Text.rich(
              const TextSpan(children: [
                TextSpan(text: 'سيتم حجز مقعد رسمي فوراً '),
                TextSpan(
                  text: '(المتبقي: 4 مقاعد من 20)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: TrainingColors.accentDark,
                  ),
                ),
              ]),
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.5.sp,
                color: TrainingColors.textPrimary,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text('20% شاغر',
                style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w700,
                    color: TrainingColors.accent)),
          ),
        ],
      ),
    );
  }
}

class _SuccessNotice extends StatelessWidget {
  const _SuccessNotice();

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 12 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.all(12.r),
        decoration: BoxDecoration(
          color: TrainingColors.primary,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle_rounded, size: 20.sp, color: Colors.white),
            SizedBox(width: 8.w),
            Flexible(
              child: Text(
                'تم اعتماد القبول وإرسال الإشعارات بنجاح! جاري التحديث...',
                maxLines: 2,
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontFamily: 'Cairo', fontSize: 12.sp, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ConfirmButton extends StatelessWidget {
  const _ConfirmButton({
    required this.accept,
    required this.phase,
    required this.onConfirm,
  });

  final bool accept;
  final _SheetPhase phase;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    final color = accept ? TrainingColors.success : TrainingColors.danger;
    final label = switch (phase) {
      _SheetPhase.idle =>
        accept ? 'تأكيد القبول وإرسال الإشعار' : 'تأكيد الرفض',
      _SheetPhase.loading => 'جاري تأكيد التسجيل...',
      _SheetPhase.success => 'تم تأكيد القبول',
    };

    return SizedBox(
      width: double.infinity,
      height: 52.h,
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
        child: InkWell(
          onTap: phase == _SheetPhase.idle ? onConfirm : null,
          borderRadius: BorderRadius.circular(12.r),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: switch (phase) {
                  _SheetPhase.idle => Icon(
                      accept ? Icons.check_rounded : Icons.close_rounded,
                      key: const ValueKey('idle'),
                      size: 22.sp,
                      color: Colors.white),
                  _SheetPhase.loading => SizedBox(
                      key: const ValueKey('loading'),
                      width: 20.w,
                      height: 20.w,
                      child: const CircularProgressIndicator(
                        strokeWidth: 2.2,
                        color: Colors.white,
                      ),
                    ),
                  _SheetPhase.success => Icon(Icons.done_all_rounded,
                      key: const ValueKey('success'),
                      size: 22.sp,
                      color: Colors.white),
                },
              ),
              SizedBox(width: 8.w),
              Text(label,
                  style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w700,
                      color: Colors.white)),
            ],
          ),
        ),
      ),
    );
  }
}
