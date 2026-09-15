import 'package:flutter/material.dart';

import 'package:nextstep_ai_app/core/theming/app_theme.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dummy data — replace with API models later.
// ─────────────────────────────────────────────────────────────────────────────

enum StudentStatus {
  interested('مهتم'),
  applying('قيد التقديم'),
  accepted('مقبول');

  const StudentStatus(this.label);

  final String label;
}

class Student {
  const Student({
    required this.name,
    required this.major,
    required this.status,
    required this.matchScore,
    required this.time,
    required this.location,
  });

  final String name;
  final String major;
  final StudentStatus status;
  final int matchScore;
  final String time;
  final String location;

  /// Two-letter Arabic initials derived from the first and last name.
  String get initials {
    final List<String> parts =
        name.trim().split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '';
    final String first = parts.first.substring(0, 1);
    String last = parts.last;
    if (last.startsWith('ال') && last.length > 2) {
      last = last.substring(2);
    }
    return '$first.${last.substring(0, 1)}';
  }
}

const List<Student> _allStudents = <Student>[
  Student(
    name: 'عمر فيصل القحطاني',
    major: 'هندسة البرمجيات',
    status: StudentStatus.interested,
    matchScore: 94,
    time: 'منذ ساعتين',
    location: 'صنعاء',
  ),
  Student(
    name: 'سارة خالد الدوسري',
    major: 'الصيدلة',
    status: StudentStatus.applying,
    matchScore: 92,
    time: 'منذ ٣ ساعات',
    location: 'عدن',
  ),
  Student(
    name: 'محمد عبدالله العمر',
    major: 'هندسة البرمجيات',
    status: StudentStatus.accepted,
    matchScore: 98,
    time: 'منذ ٥ ساعات',
    location: 'صنعاء',
  ),
  Student(
    name: 'نورة أحمد السالم',
    major: 'إدارة الأعمال',
    status: StudentStatus.interested,
    matchScore: 89,
    time: 'منذ يوم',
    location: 'تعز',
  ),
  Student(
    name: 'عبدالرحمن الشمري',
    major: 'الذكاء الاصطناعي',
    status: StudentStatus.applying,
    matchScore: 95,
    time: 'منذ يومين',
    location: 'صنعاء',
  ),
  Student(
    name: 'ريم منصور العتيبي',
    major: 'الصيدلة',
    status: StudentStatus.accepted,
    matchScore: 91,
    time: 'منذ ٣ أيام',
    location: 'إب',
  ),
  Student(
    name: 'يوسف فهد المهيدب',
    major: 'إدارة الأعمال',
    status: StudentStatus.interested,
    matchScore: 87,
    time: 'منذ ٤ أيام',
    location: 'المكلا',
  ),
];

const List<String> _majorFilters = <String>[
  'هندسة البرمجيات',
  'الصيدلة',
  'إدارة الأعمال',
  'الذكاء الاصطناعي',
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class UniversityStudentsScreen extends StatefulWidget {
  const UniversityStudentsScreen({super.key});

  @override
  State<UniversityStudentsScreen> createState() =>
      _UniversityStudentsScreenState();
}

class _UniversityStudentsScreenState extends State<UniversityStudentsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  String _query = '';
  StudentStatus? _statusFilter;
  String? _majorFilter;

  bool get _hasActiveFilters =>
      _query.trim().isNotEmpty || _statusFilter != null || _majorFilter != null;

  List<Student> get _filteredStudents {
    final String query = _query.trim().toLowerCase();
    return _allStudents.where((Student student) {
      final bool matchesStatus =
          _statusFilter == null || student.status == _statusFilter;
      final bool matchesMajor =
          _majorFilter == null || student.major == _majorFilter;
      final bool matchesQuery = query.isEmpty ||
          student.name.toLowerCase().contains(query) ||
          student.major.toLowerCase().contains(query) ||
          student.location.toLowerCase().contains(query);
      return matchesStatus && matchesMajor && matchesQuery;
    }).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _resetFilters() {
    _searchController.clear();
    setState(() {
      _query = '';
      _statusFilter = null;
      _majorFilter = null;
    });
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: context.appColors.textPrimary,
          content: Text(
            message,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: context.appColors.background,
            ),
          ),
        ),
      );
  }

  Future<void> _openFilterSheet() async {
    final _FilterSelection? result =
        await showModalBottomSheet<_FilterSelection>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext context) => _FilterSheet(
        initialStatus: _statusFilter,
        initialMajor: _majorFilter,
      ),
    );
    if (result != null && mounted) {
      setState(() {
        _statusFilter = result.status;
        _majorFilter = result.major;
      });
    }
  }

  Future<void> _openStudentOptions(Student student) {
    return showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) => _StudentOptionsSheet(
        student: student,
        onAction: (String action) {
          Navigator.of(context).pop();
          _showMessage('$action: ${student.name}');
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final List<Student> students = _filteredStudents;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        body: Stack(
          children: <Widget>[
            CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(
                parent: AlwaysScrollableScrollPhysics(),
              ),
              slivers: <Widget>[
                SliverToBoxAdapter(
                  child: _StudentsHeader(
                    studentCount: students.length,
                    onFilter: _openFilterSheet,
                    onExport: () => _showMessage('جاري تصدير قائمة الطلاب...'),
                  ),
                ),
                SliverToBoxAdapter(
                  child: _SearchBar(
                    controller: _searchController,
                    onChanged: (String value) => setState(() => _query = value),
                    onClear: () {
                      _searchController.clear();
                      setState(() => _query = '');
                    },
                  ),
                ),
                SliverToBoxAdapter(
                  child: _FilterChips(
                    statusFilter: _statusFilter,
                    majorFilter: _majorFilter,
                    onStatusSelected: (StudentStatus? status) =>
                        setState(() => _statusFilter = status),
                    onMajorSelected: (String? major) =>
                        setState(() => _majorFilter = major),
                  ),
                ),
                if (students.isEmpty)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: _EmptyState(onReset: _resetFilters),
                  )
                else
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    sliver: SliverList.builder(
                      itemCount: students.length,
                      itemBuilder: (BuildContext context, int index) {
                        final Student student = students[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _StudentCard(
                            student: student,
                            onContact: () =>
                                _showMessage('تواصل مع ${student.name}'),
                            onOptions: () => _openStudentOptions(student),
                          ),
                        );
                      },
                    ),
                  ),
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 92,
              child: Center(
                child: AnimatedBuilder(
                  animation: _scrollController,
                  builder: (BuildContext context, Widget? child) {
                    final bool scrolled = _scrollController.hasClients &&
                        _scrollController.offset > 40;
                    return _FloatingCountPill(
                      count: students.length,
                      visible: students.isNotEmpty &&
                          (scrolled || _hasActiveFilters),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (1) Header
// ─────────────────────────────────────────────────────────────────────────────

class _StudentsHeader extends StatelessWidget {
  const _StudentsHeader({
    required this.studentCount,
    required this.onFilter,
    required this.onExport,
  });

  final int studentCount;
  final VoidCallback onFilter;
  final VoidCallback onExport;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Row(
          children: <Widget>[
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'الطلاب',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_arabicNumber(studentCount)} طالب مهتم بجامعتك',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
            const Spacer(),
            _HeaderIconButton(
              icon: Icons.filter_list,
              size: 22,
              onTap: onFilter,
            ),
            const SizedBox(width: 10),
            _HeaderIconButton(
              icon: Icons.ios_share,
              size: 20,
              onTap: onExport,
            ),
          ],
        ),
      ),
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  const _HeaderIconButton({
    required this.icon,
    required this.size,
    required this.onTap,
  });

  final IconData icon;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return DecoratedBox(
      decoration: _surfaceDecoration(c, radius: 16),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: SizedBox(
            width: 44,
            height: 44,
            child: Icon(icon, size: size, color: c.textPrimary),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (2) Search bar
// ─────────────────────────────────────────────────────────────────────────────

class _SearchBar extends StatelessWidget {
  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        height: 48,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: c.isDark ? c.surfaceAlt : c.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: c.divider),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.search, size: 20, color: c.textSecondary),
            const SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                textInputAction: TextInputAction.search,
                cursorColor: c.primary,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  color: c.textPrimary,
                ),
                decoration: InputDecoration(
                  isCollapsed: true,
                  border: InputBorder.none,
                  hintText: 'ابحث عن طالب بالاسم أو التخصص...',
                  hintStyle: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ),
            ValueListenableBuilder<TextEditingValue>(
              valueListenable: controller,
              builder: (BuildContext context, TextEditingValue value, _) {
                if (value.text.isEmpty) return const SizedBox.shrink();
                return GestureDetector(
                  onTap: onClear,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Icon(
                      Icons.cancel,
                      size: 18,
                      color: c.textSecondary,
                    ),
                  ),
                );
              },
            ),
            Icon(Icons.mic_none, size: 20, color: c.textSecondary),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (3) Filter chips
// ─────────────────────────────────────────────────────────────────────────────

class _FilterChips extends StatelessWidget {
  const _FilterChips({
    required this.statusFilter,
    required this.majorFilter,
    required this.onStatusSelected,
    required this.onMajorSelected,
  });

  final StudentStatus? statusFilter;
  final String? majorFilter;
  final ValueChanged<StudentStatus?> onStatusSelected;
  final ValueChanged<String?> onMajorSelected;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: SizedBox(
        height: 40,
        child: ListView(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20),
          children: <Widget>[
            _FilterChip(
              label: 'الكل',
              selected: statusFilter == null,
              onTap: () => onStatusSelected(null),
            ),
            for (final StudentStatus status in StudentStatus.values)
              _FilterChip(
                label: status.label,
                selected: statusFilter == status,
                onTap: () => onStatusSelected(status),
              ),
            Container(
              width: 1,
              height: 20,
              margin: const EdgeInsets.symmetric(horizontal: 8),
              color: c.divider,
            ),
            _FilterChip(
              label: 'جميع التخصصات',
              selected: majorFilter == null,
              onTap: () => onMajorSelected(null),
            ),
            for (final String major in _majorFilters)
              _FilterChip(
                label: major,
                selected: majorFilter == major,
                onTap: () => onMajorSelected(major),
              ),
          ],
        ),
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(50),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            curve: Curves.easeOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: selected ? c.primary : c.surface,
              borderRadius: BorderRadius.circular(50),
              border: Border.all(
                color: selected ? c.primary : c.divider,
              ),
            ),
            child: Text(
              label,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                color: selected ? Colors.white : c.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (4) Student card
// ─────────────────────────────────────────────────────────────────────────────

class _StudentCard extends StatelessWidget {
  const _StudentCard({
    required this.student,
    required this.onContact,
    required this.onOptions,
  });

  final Student student;
  final VoidCallback onContact;
  final VoidCallback onOptions;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: _surfaceDecoration(c, radius: 20),
      child: Row(
        children: <Widget>[
          _StudentAvatar(student: student),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Row(
                  children: <Widget>[
                    Flexible(
                      child: Text(
                        student.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _MatchBadge(score: student.matchScore),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'مهتم ب${student.major}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: c.textSecondary,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    Icon(Icons.schedule, size: 12, color: c.textSecondary),
                    const SizedBox(width: 4),
                    Text(
                      student.time,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 10,
                        color: c.textSecondary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.location_on, size: 12, color: c.textSecondary),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        student.location,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 10,
                          color: c.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            children: <Widget>[
              _ActionButton(
                icon: Icons.chat_bubble_outline,
                color: c.success,
                background: c.successSoft,
                onTap: onContact,
              ),
              const SizedBox(height: 8),
              _ActionButton(
                icon: Icons.more_horiz,
                color: c.primary,
                background: c.primarySoft,
                onTap: onOptions,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StudentAvatar extends StatelessWidget {
  const _StudentAvatar({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return SizedBox(
      width: 50,
      height: 50,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: 50,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: <Color>[c.primary, c.purple],
              ),
            ),
            child: Text(
              student.initials,
              style: const TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: _StatusDot(status: student.status),
          ),
        ],
      ),
    );
  }
}

class _StatusDot extends StatelessWidget {
  const _StatusDot({required this.status});

  final StudentStatus status;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    final Color color;
    switch (status) {
      case StudentStatus.interested:
        color = c.accent;
        break;
      case StudentStatus.applying:
        color = c.primary;
        break;
      case StudentStatus.accepted:
        color = c.success;
        break;
    }

    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: Border.all(color: c.surface, width: 2),
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  const _MatchBadge({required this.score});

  final int score;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: c.primarySoft,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        'نسبة توافق $score%',
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 9,
          fontWeight: FontWeight.w700,
          color: c.primary,
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.icon,
    required this.color,
    required this.background,
    required this.onTap,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: SizedBox(
          width: 36,
          height: 36,
          child: Center(
            child: Icon(icon, size: 17, color: color),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (5) Student options bottom sheet
// ─────────────────────────────────────────────────────────────────────────────

class _StudentOptionsSheet extends StatelessWidget {
  const _StudentOptionsSheet({
    required this.student,
    required this.onAction,
  });

  final Student student;
  final ValueChanged<String> onAction;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: c.divider,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: <Widget>[
                _StudentAvatar(student: student),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        student.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'مهتم ب${student.major}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 11,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Divider(height: 1, thickness: 1, color: c.divider),
            _SheetOptionTile(
              icon: Icons.person_outline,
              color: c.primary,
              softColor: c.primarySoft,
              label: 'عرض الملف الكامل',
              onTap: () => onAction('عرض الملف الكامل'),
            ),
            _SheetOptionTile(
              icon: Icons.assignment_outlined,
              color: c.purple,
              softColor: c.purpleSoft,
              label: 'نتيجة الاستبيان',
              onTap: () => onAction('نتيجة الاستبيان'),
            ),
            _SheetOptionTile(
              icon: Icons.check_circle_outline,
              color: c.success,
              softColor: c.successSoft,
              label: 'تغيير الحالة',
              onTap: () => onAction('تغيير الحالة'),
            ),
            _SheetOptionTile(
              icon: Icons.folder_shared_outlined,
              color: c.accent,
              softColor: c.accentSoft,
              label: 'إضافة ملاحظة',
              onTap: () => onAction('إضافة ملاحظة'),
            ),
            _SheetOptionTile(
              icon: Icons.block,
              color: c.danger,
              softColor: c.dangerSoft,
              label: 'إزالة من القائمة',
              isDestructive: true,
              onTap: () => onAction('إزالة من القائمة'),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SheetOptionTile extends StatelessWidget {
  const _SheetOptionTile({
    required this.icon,
    required this.color,
    required this.softColor,
    required this.label,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final Color color;
  final Color softColor;
  final String label;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final Color textColor = isDestructive ? c.danger : c.textPrimary;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        height: 52,
        child: Row(
          children: <Widget>[
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: softColor,
                shape: BoxShape.circle,
              ),
              child: Icon(icon, size: 20, color: color),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: textColor,
                ),
              ),
            ),
            Icon(
              Icons.chevron_left,
              size: 20,
              color: isDestructive ? c.danger : c.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Filter bottom sheet (opened from the header)
// ─────────────────────────────────────────────────────────────────────────────

class _FilterSelection {
  const _FilterSelection({required this.status, required this.major});

  final StudentStatus? status;
  final String? major;
}

class _FilterSheet extends StatefulWidget {
  const _FilterSheet({required this.initialStatus, required this.initialMajor});

  final StudentStatus? initialStatus;
  final String? initialMajor;

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  StudentStatus? _status;
  String? _major;

  @override
  void initState() {
    super.initState();
    _status = widget.initialStatus;
    _major = widget.initialMajor;
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: c.divider,
                  borderRadius: BorderRadius.circular(50),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'تصفية الطلاب',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'الحالة',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _FilterChip(
                  label: 'الكل',
                  selected: _status == null,
                  onTap: () => setState(() => _status = null),
                ),
                for (final StudentStatus status in StudentStatus.values)
                  _FilterChip(
                    label: status.label,
                    selected: _status == status,
                    onTap: () => setState(() => _status = status),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              'التخصص',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: <Widget>[
                _FilterChip(
                  label: 'جميع التخصصات',
                  selected: _major == null,
                  onTap: () => setState(() => _major = null),
                ),
                for (final String major in _majorFilters)
                  _FilterChip(
                    label: major,
                    selected: _major == major,
                    onTap: () => setState(() => _major = major),
                  ),
              ],
            ),
            const SizedBox(height: 24),
            Row(
              children: <Widget>[
                Expanded(
                  child: FilledButton(
                    onPressed: () => Navigator.of(context).pop(
                      _FilterSelection(status: _status, major: _major),
                    ),
                    style: FilledButton.styleFrom(
                      backgroundColor: c.primary,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('تطبيق التصفية'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: () => setState(() {
                      _status = null;
                      _major = null;
                    }),
                    style: FilledButton.styleFrom(
                      backgroundColor: c.surfaceAlt,
                      foregroundColor: c.textSecondary,
                      elevation: 0,
                      minimumSize: const Size.fromHeight(48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      textStyle: const TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text('إعادة تعيين'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (6) Empty state
// ─────────────────────────────────────────────────────────────────────────────

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onReset});

  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                color: c.primarySoft,
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.person_search, size: 40, color: c.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'لا يوجد طلاب مطابقون',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: c.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'جرّب تعديل البحث أو الفلاتر',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                color: c.textSecondary,
              ),
            ),
            const SizedBox(height: 20),
            TextButton(
              onPressed: onReset,
              style: TextButton.styleFrom(
                backgroundColor: c.primarySoft,
                foregroundColor: c.primary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(50),
                ),
                textStyle: const TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              child: const Text('مسح الفلاتر'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (7) Floating count pill
// ─────────────────────────────────────────────────────────────────────────────

class _FloatingCountPill extends StatelessWidget {
  const _FloatingCountPill({required this.count, required this.visible});

  final int count;
  final bool visible;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return IgnorePointer(
      child: AnimatedOpacity(
        opacity: visible ? 1 : 0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: c.textPrimary,
            borderRadius: BorderRadius.circular(50),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: c.textPrimary.withValues(alpha: 0.25),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            '${_arabicNumber(count)} طالب',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: c.background,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared pieces
// ─────────────────────────────────────────────────────────────────────────────

BoxDecoration _surfaceDecoration(AppColors c, {required double radius}) {
  return BoxDecoration(
    color: c.surface,
    borderRadius: BorderRadius.circular(radius),
    border: c.isDark ? Border.all(color: c.divider) : null,
    boxShadow: c.isDark
        ? null
        : <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
  );
}

/// Converts Western digits to Arabic-Indic digits for display.
String _arabicNumber(int value) {
  const String western = '0123456789';
  const String eastern = '٠١٢٣٤٥٦٧٨٩';
  final StringBuffer buffer = StringBuffer();
  for (final String digit in value.toString().split('')) {
    final int index = western.indexOf(digit);
    buffer.write(index == -1 ? digit : eastern[index]);
  }
  return buffer.toString();
}
