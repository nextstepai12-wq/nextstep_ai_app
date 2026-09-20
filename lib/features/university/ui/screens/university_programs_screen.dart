import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/features/university/ui/widgets/university_bottom_nav.dart';

enum ProgramStatus { active, draft, paused }

enum _ProgramAction { edit, pause, delete }

class Program {
  const Program({
    required this.id,
    required this.name,
    required this.faculty,
    required this.facultyKey,
    required this.students,
    required this.views,
    required this.rating,
    required this.status,
    required this.imageUrl,
  });

  final int id;
  final String name;
  final String faculty;
  final String facultyKey;
  final int students;
  final String views;
  final double rating;
  final ProgramStatus status;
  final String imageUrl;

  Program copyWith({ProgramStatus? status}) {
    return Program(
      id: id,
      name: name,
      faculty: faculty,
      facultyKey: facultyKey,
      students: students,
      views: views,
      rating: rating,
      status: status ?? this.status,
      imageUrl: imageUrl,
    );
  }
}

const List<Program> _seedPrograms = <Program>[
  Program(
    id: 1,
    name: 'هندسة البرمجيات',
    faculty: 'كلية الحاسبات وتقنية المعلومات',
    facultyKey: 'computing',
    students: 342,
    views: '2,300',
    rating: 4.8,
    status: ProgramStatus.active,
    imageUrl:
        'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=200&auto=format&fit=crop&q=80',
  ),
  Program(
    id: 2,
    name: 'الذكاء الاصطناعي وعلم البيانات',
    faculty: 'كلية الحاسبات وتقنية المعلومات',
    facultyKey: 'computing',
    students: 289,
    views: '1,850',
    rating: 4.9,
    status: ProgramStatus.active,
    imageUrl:
        'https://images.unsplash.com/photo-1677442136019-21780efad99a?w=200&auto=format&fit=crop&q=80',
  ),
  Program(
    id: 3,
    name: 'الأمن السيبراني والتحري الرقمي',
    faculty: 'كلية الحاسبات وتقنية المعلومات',
    facultyKey: 'computing',
    students: 215,
    views: '1,420',
    rating: 4.7,
    status: ProgramStatus.active,
    imageUrl:
        'https://images.unsplash.com/photo-1550751827-4bd374c3f58b?w=200&auto=format&fit=crop&q=80',
  ),
  Program(
    id: 4,
    name: 'هندسة العمارة والتصميم الرقمي',
    faculty: 'كلية الهندسة والعلوم التطبيقية',
    facultyKey: 'engineering',
    students: 198,
    views: '1,120',
    rating: 4.6,
    status: ProgramStatus.draft,
    imageUrl:
        'https://images.unsplash.com/photo-1486406146926-c627a92ad1ab?w=200&auto=format&fit=crop&q=80',
  ),
  Program(
    id: 5,
    name: 'الطب البشري والجراحة العامة',
    faculty: 'كلية الطب والعلوم الصحية',
    facultyKey: 'medicine',
    students: 420,
    views: '3,100',
    rating: 4.9,
    status: ProgramStatus.active,
    imageUrl:
        'https://images.unsplash.com/photo-1579684385127-1ef15d508118?w=200&auto=format&fit=crop&q=80',
  ),
  Program(
    id: 6,
    name: 'إدارة الأعمال الدولية والريادة',
    faculty: 'كلية العلوم الإدارية والمالية',
    facultyKey: 'business',
    students: 310,
    views: '1,980',
    rating: 4.5,
    status: ProgramStatus.paused,
    imageUrl:
        'https://images.unsplash.com/photo-1454165804606-c3d57bc86b40?w=200&auto=format&fit=crop&q=80',
  ),
  Program(
    id: 7,
    name: 'الهندسة الطبية الحيوية',
    faculty: 'كلية الهندسة والعلوم التطبيقية',
    facultyKey: 'engineering',
    students: 145,
    views: '980',
    rating: 4.4,
    status: ProgramStatus.draft,
    imageUrl:
        'https://images.unsplash.com/photo-1581093458791-9f3c3900df4b?w=200&auto=format&fit=crop&q=80',
  ),
  Program(
    id: 8,
    name: 'الصيدلة السريرية',
    faculty: 'كلية الطب والعلوم الصحية',
    facultyKey: 'medicine',
    students: 180,
    views: '1,050',
    rating: 4.3,
    status: ProgramStatus.paused,
    imageUrl:
        'https://images.unsplash.com/photo-1584308666744-24d5c474f2ae?w=200&auto=format&fit=crop&q=80',
  ),
];

class _Option {
  const _Option(this.value, this.label);

  final String value;
  final String label;
}

const List<_Option> _facultyOptions = <_Option>[
  _Option('all', 'الكل'),
  _Option('computing', 'الحاسبات'),
  _Option('engineering', 'الهندسة'),
  _Option('medicine', 'الطب'),
  _Option('business', 'الإدارة'),
];

const List<_Option> _sortOptions = <_Option>[
  _Option('latest', 'الأحدث'),
  _Option('students', 'الأكثر طلاباً'),
  _Option('rating', 'الأعلى تقييماً'),
];

class _FilterResult {
  const _FilterResult(this.faculty, this.sort);

  final String faculty;
  final String sort;
}

class UniversityProgramsScreen extends StatefulWidget {
  const UniversityProgramsScreen({super.key});

  @override
  State<UniversityProgramsScreen> createState() =>
      _UniversityProgramsScreenState();
}

class _UniversityProgramsScreenState extends State<UniversityProgramsScreen> {
  final List<Program> _programs = List<Program>.of(_seedPrograms);
  final TextEditingController _searchController = TextEditingController();

  bool _isSearchOpen = false;
  String _searchQuery = '';
  ProgramStatus? _statusFilter;
  String _facultyFilter = 'all';
  String _sort = 'latest';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Program> get _visiblePrograms {
    final String query = _searchQuery.trim().toLowerCase();

    final List<Program> filtered = _programs.where((Program p) {
      final bool matchesStatus =
          _statusFilter == null || p.status == _statusFilter;
      final bool matchesSearch = query.isEmpty ||
          p.name.toLowerCase().contains(query) ||
          p.faculty.toLowerCase().contains(query);
      final bool matchesFaculty =
          _facultyFilter == 'all' || p.facultyKey == _facultyFilter;
      return matchesStatus && matchesSearch && matchesFaculty;
    }).toList();

    switch (_sort) {
      case 'students':
        filtered
            .sort((Program a, Program b) => b.students.compareTo(a.students));
        break;
      case 'rating':
        filtered.sort((Program a, Program b) => b.rating.compareTo(a.rating));
        break;
      default:
        filtered.sort((Program a, Program b) => a.id.compareTo(b.id));
    }
    return filtered;
  }

  bool get _hasActiveFilters => _facultyFilter != 'all' || _sort != 'latest';

  void _toggleSearch() {
    setState(() => _isSearchOpen = !_isSearchOpen);
  }

  void _closeSearch() {
    setState(() {
      _isSearchOpen = false;
      _searchQuery = '';
      _searchController.clear();
    });
  }

  void _onNavChanged(int index) {
    if (index == 1) return;
    switch (index) {
      case 0:
        context.go('/university');
        break;
      case 2:
        context.go('/university/analytics');
        break;
      case 3:
        context.go('/university/students');
        break;
      case 4:
        context.go('/university/settings');
        break;
    }
  }

  void _openDetails(Program program) {
    context.push('/university/edit-program');
  }

  void _onMenuAction(Program program, _ProgramAction action) {
    switch (action) {
      case _ProgramAction.edit:
        _openDetails(program);
        break;
      case _ProgramAction.pause:
        final ProgramStatus next = program.status == ProgramStatus.paused
            ? ProgramStatus.active
            : ProgramStatus.paused;
        setState(() {
          final int index =
              _programs.indexWhere((Program p) => p.id == program.id);
          if (index != -1) {
            _programs[index] = program.copyWith(status: next);
          }
        });
        _showSnack(
          next == ProgramStatus.paused
              ? 'تم إيقاف "${program.name}" مؤقتاً'
              : 'تم تنشيط "${program.name}"',
        );
        break;
      case _ProgramAction.delete:
        _confirmDelete(program).then((bool ok) {
          if (ok && mounted) _deleteProgram(program);
        });
        break;
    }
  }

  Future<bool> _confirmDelete(Program program) async {
    final bool? result = await showDialog<bool>(
      context: context,
      builder: (BuildContext ctx) {
        final AppColors c = ctx.appColors;
        return AlertDialog(
          backgroundColor: c.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            'حذف التخصص',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          content: Text(
            'هل أنت متأكد من حذف "${program.name}"؟',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              color: c.textSecondary,
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(
                'إلغاء',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary,
                ),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(
                'حذف',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: c.danger,
                ),
              ),
            ),
          ],
        );
      },
    );
    return result ?? false;
  }

  void _deleteProgram(Program program) {
    final int index = _programs.indexWhere((Program p) => p.id == program.id);
    if (index == -1) return;
    final String name = program.name;
    setState(() => _programs.removeAt(index));
    _showSnack('تم حذف "$name" بنجاح');
  }

  Future<void> _openFilterSheet() async {
    final _FilterResult? result = await showModalBottomSheet<_FilterResult>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (BuildContext ctx) {
        final AppColors c = ctx.appColors;
        return Container(
          decoration: BoxDecoration(
            color: c.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: c.isDark ? Border(top: BorderSide(color: c.divider)) : null,
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
              child: _FilterBottomSheet(
                initialFaculty: _facultyFilter,
                initialSort: _sort,
              ),
            ),
          ),
        );
      },
    );

    if (!mounted || result == null) return;
    setState(() {
      _facultyFilter = result.faculty;
      _sort = result.sort;
    });
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: context.appColors.success,
          content: Row(
            children: <Widget>[
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    color: Colors.white,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final List<Program> programs = _visiblePrograms;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          bottom: false,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _buildHeader(c),
                _buildSearch(c),
                const SizedBox(height: 12),
                _buildStatusChips(c),
                const SizedBox(height: 16),
                _buildCountRow(c, programs.length),
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: programs.isEmpty
                      ? _EmptyState(
                          onAdd: () => context.push('/university/add-program'))
                      : _buildList(c, programs),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
        ),
        bottomNavigationBar: UniversityBottomNav(
          currentIndex: 1,
          onChanged: _onNavChanged,
        ),
        floatingActionButton: _ExtendedFab(
          onTap: () => context.push('/university/add-program'),
        ),
      ),
    );
  }

  Widget _buildHeader(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  'التخصصات',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: c.textPrimary,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '24 تخصص نشط',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: c.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          _RoundIconButton(
            icon: Icons.search_rounded,
            onTap: _toggleSearch,
          ),
          const SizedBox(width: 8),
          _RoundIconButton(
            icon: Icons.filter_list_rounded,
            onTap: _openFilterSheet,
            showDot: _hasActiveFilters,
          ),
        ],
      ),
    );
  }

  Widget _buildSearch(AppColors c) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      alignment: Alignment.topCenter,
      child: !_isSearchOpen
          ? const SizedBox(width: double.infinity)
          : Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                onChanged: (String value) =>
                    setState(() => _searchQuery = value),
                textInputAction: TextInputAction.search,
                textAlign: TextAlign.right,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: c.textPrimary,
                ),
                decoration: InputDecoration(
                  hintText: 'ابحث عن تخصص...',
                  hintStyle: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    color: c.textSecondary,
                  ),
                  filled: true,
                  fillColor: c.surface,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                  prefixIcon: IconButton(
                    onPressed: _closeSearch,
                    iconSize: 20,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(
                      minWidth: 44,
                      minHeight: 44,
                    ),
                    icon: Icon(
                      Icons.arrow_forward_rounded,
                      color: c.textSecondary,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  suffixIcon: Icon(
                    Icons.search_rounded,
                    size: 20,
                    color: c.textSecondary,
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: c.primary.withValues(alpha: 0.4),
                      width: 1.5,
                    ),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildStatusChips(AppColors c) {
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        children: <Widget>[
          _FilterChip(
            label: 'الكل',
            selected: _statusFilter == null,
            onTap: () => setState(() => _statusFilter = null),
            unselectedColor: c.surface,
            unselectedBorder: c.divider,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'نشط',
            dotColor: c.success,
            selected: _statusFilter == ProgramStatus.active,
            onTap: () => setState(() => _statusFilter = ProgramStatus.active),
            unselectedColor: c.surface,
            unselectedBorder: c.divider,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'مسودة',
            dotColor: c.accent,
            selected: _statusFilter == ProgramStatus.draft,
            onTap: () => setState(() => _statusFilter = ProgramStatus.draft),
            unselectedColor: c.surface,
            unselectedBorder: c.divider,
          ),
          const SizedBox(width: 8),
          _FilterChip(
            label: 'موقوف',
            dotColor: c.danger,
            selected: _statusFilter == ProgramStatus.paused,
            onTap: () => setState(() => _statusFilter = ProgramStatus.paused),
            unselectedColor: c.surface,
            unselectedBorder: c.divider,
          ),
        ],
      ),
    );
  }

  Widget _buildCountRow(AppColors c, int count) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: <Widget>[
          Text(
            'عرض النتائج',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              color: c.textSecondary,
            ),
          ),
          const Spacer(),
          Text(
            '$count تخصص',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildList(AppColors c, List<Program> programs) {
    return Column(
      children: <Widget>[
        for (int i = 0; i < programs.length; i++) ...<Widget>[
          if (i > 0) const SizedBox(height: 12),
          _ProgramCard(
            program: programs[i],
            onTap: () => _openDetails(programs[i]),
            onAction: (_ProgramAction action) =>
                _onMenuAction(programs[i], action),
            confirmDismiss: () => _confirmDelete(programs[i]),
            onDismissed: () => _deleteProgram(programs[i]),
          ),
        ],
      ],
    );
  }
}

class _ExtendedFab extends StatelessWidget {
  const _ExtendedFab({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        decoration: BoxDecoration(
          color: c.primary,
          borderRadius: BorderRadius.circular(18),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: c.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 18, vertical: 14),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Icon(
                  Icons.post_add_rounded,
                  size: 20,
                  color: Colors.white,
                ),
                SizedBox(width: 8),
                Text(
                  'إضافة تخصص',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ProgramCard extends StatelessWidget {
  const _ProgramCard({
    required this.program,
    required this.onTap,
    required this.onAction,
    required this.confirmDismiss,
    required this.onDismissed,
  });

  final Program program;
  final VoidCallback onTap;
  final ValueChanged<_ProgramAction> onAction;
  final Future<bool> Function() confirmDismiss;
  final VoidCallback onDismissed;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Dismissible(
      key: ValueKey<int>(program.id),
      direction: DismissDirection.horizontal,
      confirmDismiss: (_) => confirmDismiss(),
      onDismissed: (_) => onDismissed(),
      background: _deleteBackground(c, AlignmentDirectional.centerStart),
      secondaryBackground: _deleteBackground(c, AlignmentDirectional.centerEnd),
      child: Container(
        decoration: _cardDecoration(c, radius: 20),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  _ProgramThumb(url: program.imageUrl),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Expanded(
                              child: Text(
                                program.name,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: c.textPrimary,
                                  height: 1.2,
                                ),
                              ),
                            ),
                            const SizedBox(width: 6),
                            _StatusPill(status: program.status),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: <Widget>[
                            Icon(
                              Icons.business_rounded,
                              size: 13,
                              color: c.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Text(
                                program.faculty,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontFamily: AppTheme.fontFamily,
                                  fontSize: 11,
                                  color: c.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        _StatsRow(program: program),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 72,
                    child: Padding(
                      padding: const EdgeInsets.only(left: 2),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: <Widget>[
                          _MenuButton(onAction: onAction),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _deleteBackground(AppColors c, AlignmentDirectional alignment) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      decoration: BoxDecoration(
        color: c.danger,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Icon(
        Icons.delete_outline_rounded,
        color: Colors.white,
        size: 22,
      ),
    );
  }
}

class _ProgramThumb extends StatelessWidget {
  const _ProgramThumb({required this.url});

  final String url;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 72,
        height: 72,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => _fallback(c),
          loadingBuilder:
              (BuildContext context, Widget child, ImageChunkEvent? progress) {
            if (progress == null) return child;
            return _fallback(c);
          },
        ),
      ),
    );
  }

  Widget _fallback(AppColors c) {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            c.primary.withValues(alpha: 0.75),
            c.primaryDark,
          ],
        ),
      ),
      child: const Center(
        child: Icon(Icons.school_rounded, color: Colors.white, size: 26),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  const _StatusPill({required this.status});

  final ProgramStatus status;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    Color background = c.textSecondary.withValues(alpha: 0.12);
    Color foreground = c.textSecondary;
    String label = '';

    switch (status) {
      case ProgramStatus.active:
        background = c.successSoft;
        foreground = c.success;
        label = 'نشط';
        break;
      case ProgramStatus.draft:
        background = c.accentSoft;
        foreground = c.accent;
        label = 'مسودة';
        break;
      case ProgramStatus.paused:
        background = c.dangerSoft;
        foreground = c.danger;
        label = 'موقوف';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  const _StatsRow({required this.program});

  final Program program;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Wrap(
      spacing: 10,
      runSpacing: 4,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: <Widget>[
        _Stat(
          icon: Icons.people_rounded,
          color: c.textSecondary,
          label: '${program.students} طالب',
        ),
        _Stat(
          icon: Icons.visibility_rounded,
          color: c.textSecondary,
          label: '${program.views} مشاهدة',
        ),
        _Stat(
          icon: Icons.star_rounded,
          color: const Color(0xFFFBBF24),
          label: program.rating.toStringAsFixed(1),
          valueColor: c.textPrimary,
          valueWeight: FontWeight.w600,
        ),
      ],
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat({
    required this.icon,
    required this.color,
    required this.label,
    this.valueColor,
    this.valueWeight = FontWeight.w400,
  });

  final IconData icon;
  final Color color;
  final String label;
  final Color? valueColor;
  final FontWeight valueWeight;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Icon(icon, size: 13, color: color),
        const SizedBox(width: 3),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 10,
            fontWeight: valueWeight,
            color: valueColor ?? c.textSecondary,
          ),
        ),
      ],
    );
  }
}

class _MenuButton extends StatelessWidget {
  const _MenuButton({required this.onAction});

  final ValueChanged<_ProgramAction> onAction;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return PopupMenuButton<_ProgramAction>(
      onSelected: onAction,
      color: c.surface,
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: c.divider),
      ),
      icon: Icon(
        Icons.more_vert_rounded,
        size: 18,
        color: c.textSecondary,
      ),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<_ProgramAction>>[
        _menuItem(
            c, _ProgramAction.edit, Icons.edit_rounded, 'تعديل', c.primary),
        _menuItem(
          c,
          _ProgramAction.pause,
          Icons.pause_circle_outline_rounded,
          'إيقاف مؤقت',
          c.accent,
        ),
        const PopupMenuDivider(),
        _menuItem(
          c,
          _ProgramAction.delete,
          Icons.delete_outline_rounded,
          'حذف',
          c.danger,
        ),
      ],
    );
  }

  PopupMenuItem<_ProgramAction> _menuItem(
    AppColors c,
    _ProgramAction action,
    IconData icon,
    String label,
    Color color,
  ) {
    return PopupMenuItem<_ProgramAction>(
      value: action,
      child: Row(
        children: <Widget>[
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: action == _ProgramAction.delete
                  ? FontWeight.w600
                  : FontWeight.w500,
              color: action == _ProgramAction.delete ? c.danger : c.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: c.surface,
        shape: BoxShape.circle,
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
      ),
      child: Material(
        color: Colors.transparent,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Icon(icon, size: 20, color: c.textPrimary),
              if (showDot)
                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      color: c.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.surface, width: 1.5),
                    ),
                  ),
                ),
            ],
          ),
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
    this.dotColor,
    this.unselectedColor,
    this.unselectedBorder,
    this.height = 40,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Color? dotColor;
  final Color? unselectedColor;
  final Color? unselectedBorder;
  final double height;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final Color background =
        selected ? c.primary : (unselectedColor ?? c.surface);
    final Color foreground = selected ? Colors.white : c.textSecondary;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(50),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: Container(
          height: height,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(50),
            border: selected || unselectedBorder == null
                ? null
                : Border.all(color: unselectedBorder!),
            boxShadow: selected && !c.isDark
                ? <BoxShadow>[
                    BoxShadow(
                      color: c.primary.withValues(alpha: 0.25),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (dotColor != null) ...<Widget>[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: dotColor,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: foreground,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FilterBottomSheet extends StatefulWidget {
  const _FilterBottomSheet({
    required this.initialFaculty,
    required this.initialSort,
  });

  final String initialFaculty;
  final String initialSort;

  @override
  State<_FilterBottomSheet> createState() => _FilterBottomSheetState();
}

class _FilterBottomSheetState extends State<_FilterBottomSheet> {
  late String _faculty;
  late String _sort;

  @override
  void initState() {
    super.initState();
    _faculty = widget.initialFaculty;
    _sort = widget.initialSort;
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Column(
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
        Row(
          children: <Widget>[
            Expanded(
              child: Text(
                'تصفية النتائج',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
            ),
            SizedBox(
              width: 32,
              height: 32,
              child: Material(
                color: Colors.transparent,
                shape: const CircleBorder(),
                child: InkWell(
                  onTap: () => Navigator.pop(context),
                  customBorder: const CircleBorder(),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionLabel(c, 'الكلية'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final _Option option in _facultyOptions)
              _FilterChip(
                label: option.label,
                selected: _faculty == option.value,
                height: 36,
                onTap: () => setState(() => _faculty = option.value),
                unselectedColor: c.surfaceAlt,
              ),
          ],
        ),
        const SizedBox(height: 16),
        _sectionLabel(c, 'الترتيب حسب'),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: <Widget>[
            for (final _Option option in _sortOptions)
              _FilterChip(
                label: option.label,
                selected: _sort == option.value,
                height: 36,
                onTap: () => setState(() => _sort = option.value),
                unselectedColor: c.surfaceAlt,
              ),
          ],
        ),
        const SizedBox(height: 20),
        Row(
          children: <Widget>[
            Expanded(
              child: TextButton(
                onPressed: () => Navigator.pop(
                  context,
                  const _FilterResult('all', 'latest'),
                ),
                style: TextButton.styleFrom(
                  backgroundColor: c.surfaceAlt,
                  foregroundColor: c.textSecondary,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: Text(
                  'إعادة تعيين',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: c.textSecondary,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () => Navigator.pop(
                  context,
                  _FilterResult(_faculty, _sort),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Text(
                  'تطبيق',
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _sectionLabel(AppColors c, String label) {
    return Text(
      label,
      style: TextStyle(
        fontFamily: AppTheme.fontFamily,
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: c.textSecondary,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onAdd});

  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Padding(
      padding: const EdgeInsets.only(top: 48, bottom: 24),
      child: Column(
        children: <Widget>[
          Container(
            width: 140,
            height: 140,
            decoration: BoxDecoration(
              color: c.primarySoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.menu_book_rounded,
              size: 56,
              color: c.primary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'لا توجد تخصصات',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'جرب تغيير البحث أو الفلتر، أو أضف تخصصاً جديداً للجامعة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 12,
              color: c.textSecondary,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded, size: 18),
            label: const Text(
              'إضافة تخصص',
              style: TextStyle(
                fontFamily: AppTheme.fontFamily,
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

BoxDecoration _cardDecoration(AppColors c, {required double radius}) {
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
