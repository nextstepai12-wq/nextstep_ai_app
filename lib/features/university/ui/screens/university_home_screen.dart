import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/features/university/ui/widgets/university_bottom_nav.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dummy data — replace with API models later.
// ─────────────────────────────────────────────────────────────────────────────

class _StatData {
  const _StatData({
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
    required this.softColor,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;
  final Color softColor;
}

class _QuickActionData {
  const _QuickActionData({
    required this.icon,
    required this.label,
    required this.color,
    required this.softColor,
    required this.route,
  });

  final IconData icon;
  final String label;
  final Color color;
  final Color softColor;
  final String route;
}

class _ProgramData {
  const _ProgramData({
    required this.name,
    required this.views,
    required this.rating,
    required this.growth,
  });

  final String name;
  final String views;
  final double rating;
  final String growth;
}

class _StudentData {
  const _StudentData({
    required this.name,
    required this.interest,
    required this.initials,
    required this.time,
    required this.avatarGradient,
    this.isNew = false,
  });

  final String name;
  final String interest;
  final String initials;
  final String time;
  final List<Color> avatarGradient;
  final bool isNew;
}

const List<_ProgramData> _programs = <_ProgramData>[
  _ProgramData(
    name: 'هندسة البرمجيات',
    views: '2,300',
    rating: 4.8,
    growth: '12%',
  ),
  _ProgramData(
    name: 'الذكاء الاصطناعي',
    views: '1,850',
    rating: 4.9,
    growth: '18%',
  ),
  _ProgramData(
    name: 'الأمن السيبراني',
    views: '1,420',
    rating: 4.7,
    growth: '9%',
  ),
  _ProgramData(
    name: 'إدارة الأعمال',
    views: '1,190',
    rating: 4.5,
    growth: '14%',
  ),
];

const List<_StudentData> _students = <_StudentData>[
  _StudentData(
    name: 'محمد عبدالله العمر',
    interest: 'مهتم بهندسة البرمجيات',
    initials: 'م.ع',
    time: 'الآن',
    avatarGradient: <Color>[Color(0xFF2563EB), Color(0xFF60A5FA)],
    isNew: true,
  ),
  _StudentData(
    name: 'سارة خالد الدوسري',
    interest: 'مهتمة بالذكاء الاصطناعي',
    initials: 'س.د',
    time: 'منذ ساعة',
    avatarGradient: <Color>[Color(0xFF8B5CF6), Color(0xFFC084FC)],
  ),
  _StudentData(
    name: 'عمر فيصل القحطاني',
    interest: 'مهتم بالأمن السيبراني',
    initials: 'ع.ق',
    time: 'منذ ٤ س',
    avatarGradient: <Color>[Color(0xFF0D9488), Color(0xFF2DD4BF)],
  ),
];

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class UniversityHomeScreen extends StatefulWidget {
  const UniversityHomeScreen({super.key});

  @override
  State<UniversityHomeScreen> createState() => _UniversityHomeScreenState();
}

class _UniversityHomeScreenState extends State<UniversityHomeScreen>
    with SingleTickerProviderStateMixin {
  int _navIndex = 0;

  late final AnimationController _entrance;
  late final Animation<double> _headerOpacity;
  late final Animation<Offset> _headerSlide;
  late final Animation<double> _statsOpacity;
  late final Animation<Offset> _statsSlide;
  late final Animation<double> _quickOpacity;
  late final Animation<Offset> _quickSlide;
  late final Animation<double> _programsOpacity;
  late final Animation<Offset> _programsSlide;
  late final Animation<double> _studentsOpacity;
  late final Animation<Offset> _studentsSlide;

  @override
  void initState() {
    super.initState();
    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..forward();

    _headerOpacity = _fade(0.00, 0.30);
    _headerSlide = _slide(0.00, 0.30);
    _statsOpacity = _fade(0.10, 0.42);
    _statsSlide = _slide(0.10, 0.42);
    _quickOpacity = _fade(0.20, 0.54);
    _quickSlide = _slide(0.20, 0.54);
    _programsOpacity = _fade(0.30, 0.66);
    _programsSlide = _slide(0.30, 0.66);
    _studentsOpacity = _fade(0.40, 0.78);
    _studentsSlide = _slide(0.40, 0.78);
  }

  Animation<double> _fade(double begin, double end) {
    return CurvedAnimation(
      parent: _entrance,
      curve: Interval(begin, end, curve: Curves.easeOutCubic),
    );
  }

  Animation<Offset> _slide(double begin, double end) {
    return Tween<Offset>(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(
      CurvedAnimation(
        parent: _entrance,
        curve: Interval(begin, end, curve: Curves.easeOutCubic),
      ),
    );
  }

  @override
  void dispose() {
    _entrance.dispose();
    super.dispose();
  }

  void _onNavChanged(int index) {
    setState(() => _navIndex = index);
    switch (index) {
      case 1:
        context.push('/university/programs');
        break;
      case 2:
        context.push('/university/analytics');
        break;
      case 3:
        context.push('/university/students');
        break;
      case 4:
        context.push('/university/settings');
        break;
      default:
        _navIndex = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        body: Stack(
          children: <Widget>[
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                child: Container(
                  height: 300,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: <Color>[
                        c.primarySoft,
                        c.primarySoft.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            SafeArea(
              bottom: false,
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(
                  parent: AlwaysScrollableScrollPhysics(),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    _SectionEntrance(
                      opacity: _headerOpacity,
                      slide: _headerSlide,
                      child: _HeaderCard(
                        greeting: 'صباح الخير',
                        universityName: 'جامعة العلوم والتكنولوجيا',
                        announcement: 'عدد الزوار هذا الأسبوع ارتفع 18%',
                        onNotifications: () =>
                            context.push('/university/notifications'),
                      ),
                    ),
                    _SectionEntrance(
                      opacity: _statsOpacity,
                      slide: _statsSlide,
                      child: Transform.translate(
                        offset: const Offset(0, -24),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: _StatsStrip(
                            items: <_StatData>[
                              _StatData(
                                icon: Icons.groups,
                                value: '1,250',
                                label: 'طالب مهتم',
                                color: c.primary,
                                softColor: c.primarySoft,
                              ),
                              _StatData(
                                icon: Icons.menu_book,
                                value: '24',
                                label: 'تخصص نشط',
                                color: c.success,
                                softColor: c.successSoft,
                              ),
                              _StatData(
                                icon: Icons.visibility,
                                value: '8.4K',
                                label: 'مشاهدة',
                                color: c.accent,
                                softColor: c.accentSoft,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _SectionEntrance(
                      opacity: _quickOpacity,
                      slide: _quickSlide,
                      child: _QuickActionsSection(
                        actions: <_QuickActionData>[
                          _QuickActionData(
                            icon: Icons.post_add,
                            label: 'إضافة تخصص',
                            color: c.primary,
                            softColor: c.primarySoft,
                            route: '/university/add-program',
                          ),
                          _QuickActionData(
                            icon: Icons.query_stats,
                            label: 'التحليلات',
                            color: c.purple,
                            softColor: c.purpleSoft,
                            route: '/university/analytics',
                          ),
                          _QuickActionData(
                            icon: Icons.people_alt,
                            label: 'الطلاب',
                            color: c.success,
                            softColor: c.successSoft,
                            route: '/university/students',
                          ),
                          _QuickActionData(
                            icon: Icons.business,
                            label: 'الكليات',
                            color: c.accent,
                            softColor: c.accentSoft,
                            route: '/university/faculties',
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 28),
                    _SectionEntrance(
                      opacity: _programsOpacity,
                      slide: _programsSlide,
                      child: _TopProgramsSection(
                        programs: _programs,
                        onViewAll: () => context.push('/university/programs'),
                      ),
                    ),
                    const SizedBox(height: 28),
                    _SectionEntrance(
                      opacity: _studentsOpacity,
                      slide: _studentsSlide,
                      child: _InterestedStudentsSection(
                        students: _students,
                        onViewAll: () => context.push('/university/students'),
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
        bottomNavigationBar: UniversityBottomNav(
          currentIndex: _navIndex,
          onChanged: _onNavChanged,
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (1) Hero header
// ─────────────────────────────────────────────────────────────────────────────

class _HeaderCard extends StatelessWidget {
  const _HeaderCard({
    required this.greeting,
    required this.universityName,
    required this.announcement,
    required this.onNotifications,
  });

  final String greeting;
  final String universityName;
  final String announcement;
  final VoidCallback onNotifications;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 30),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: <Color>[c.gradientStart, c.gradientEnd],
          ),
          borderRadius: BorderRadius.circular(24),
          boxShadow: c.isDark
              ? null
              : <BoxShadow>[
                  BoxShadow(
                    color: c.primary.withValues(alpha: 0.22),
                    blurRadius: 24,
                    offset: const Offset(0, 10),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '$greeting ☀️',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        universityName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                _NotificationButton(onTap: onNotifications),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: <Widget>[
                  const Icon(
                    Icons.trending_up,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      announcement,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 12,
                        color: Colors.white.withValues(alpha: 0.95),
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
}

class _NotificationButton extends StatelessWidget {
  const _NotificationButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Material(
            color: Colors.white.withValues(alpha: 0.20),
            shape: const CircleBorder(),
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: const SizedBox(
                width: 44,
                height: 44,
                child: Icon(
                  Icons.notifications_none_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),
          ),
          Positioned(
            top: 2,
            left: 2,
            child: Container(
              width: 11,
              height: 11,
              decoration: BoxDecoration(
                color: context.appColors.accent,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (2) Floating stats strip
// ─────────────────────────────────────────────────────────────────────────────

class _StatsStrip extends StatelessWidget {
  const _StatsStrip({required this.items});

  final List<_StatData> items;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: _cardDecoration(c, radius: 20),
      child: Row(
        children: <Widget>[
          for (int i = 0; i < items.length; i++) ...<Widget>[
            if (i > 0) Container(width: 1, height: 32, color: c.divider),
            Expanded(child: _StatItem(data: items[i])),
          ],
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.data});

  final _StatData data;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Column(
      children: <Widget>[
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: data.softColor,
            shape: BoxShape.circle,
          ),
          child: Icon(data.icon, size: 18, color: data.color),
        ),
        const SizedBox(height: 6),
        Text(
          data.value,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          data.label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 10,
            color: c.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (3) Quick actions
// ─────────────────────────────────────────────────────────────────────────────

class _QuickActionsSection extends StatelessWidget {
  const _QuickActionsSection({required this.actions});

  final List<_QuickActionData> actions;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: _SectionHeader(title: 'إجراءات سريعة'),
        ),
        const SizedBox(height: 12),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: <Widget>[
              for (int i = 0; i < actions.length; i++) ...<Widget>[
                if (i > 0) const SizedBox(width: 12),
                Expanded(child: _QuickAction(data: actions[i])),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _QuickAction extends StatelessWidget {
  const _QuickAction({required this.data});

  final _QuickActionData data;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return _ScaleTap(
      onTap: () => context.push(data.route),
      child: Column(
        children: <Widget>[
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: data.softColor,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: data.color.withValues(alpha: 0.10),
              ),
              boxShadow: c.isDark
                  ? null
                  : <BoxShadow>[
                      BoxShadow(
                        color: data.color.withValues(alpha: 0.10),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Icon(data.icon, size: 24, color: data.color),
          ),
          const SizedBox(height: 8),
          Text(
            data.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
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
}

// ─────────────────────────────────────────────────────────────────────────────
// (4) Top programs
// ─────────────────────────────────────────────────────────────────────────────

class _TopProgramsSection extends StatelessWidget {
  const _TopProgramsSection({
    required this.programs,
    required this.onViewAll,
  });

  final List<_ProgramData> programs;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: _SectionHeader(
            title: 'الأعلى اهتماماً',
            actionText: 'عرض الكل',
            onAction: onViewAll,
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 190,
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: programs.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (BuildContext context, int index) {
                return _TopProgramCard(data: programs[index]);
              },
            ),
          ),
        ),
      ],
    );
  }
}

class _TopProgramCard extends StatelessWidget {
  const _TopProgramCard({required this.data});

  final _ProgramData data;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return SizedBox(
      width: 160,
      child: DecoratedBox(
        decoration: _cardDecoration(c, radius: 20),
        child: Material(
          color: Colors.transparent,
          child: _PressScale(
            onTap: () => context.push('/university/edit-program'),
            radius: 20,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(20),
                  ),
                  child: SizedBox(
                    height: 90,
                    width: double.infinity,
                    child: Stack(
                      fit: StackFit.expand,
                      children: <Widget>[
                        DecoratedBox(
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
                            child: Icon(
                              Icons.school_rounded,
                              color: Colors.white,
                              size: 30,
                            ),
                          ),
                        ),
                        Positioned(
                          top: 8,
                          left: 8,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: c.success,
                              borderRadius: BorderRadius.circular(50),
                            ),
                            child: Text(
                              '↑ ${data.growth}',
                              style: const TextStyle(
                                fontFamily: AppTheme.fontFamily,
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        data.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.visibility,
                            size: 13,
                            color: c.textSecondary,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            data.views,
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 10,
                              color: c.textSecondary,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.star_rounded,
                            size: 14,
                            color: Color(0xFFFBBF24),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            data.rating.toStringAsFixed(1),
                            style: TextStyle(
                              fontFamily: AppTheme.fontFamily,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: c.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ],
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

// ─────────────────────────────────────────────────────────────────────────────
// (5) Interested students
// ─────────────────────────────────────────────────────────────────────────────

class _InterestedStudentsSection extends StatelessWidget {
  const _InterestedStudentsSection({
    required this.students,
    required this.onViewAll,
  });

  final List<_StudentData> students;
  final VoidCallback onViewAll;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(c, radius: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Row(
              children: <Widget>[
                const Expanded(
                  child: _SectionHeader(title: 'طلاب مهتمون بجامعتك'),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    '+12 جديد',
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: c.primary,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            for (int i = 0; i < students.length; i++) ...<Widget>[
              if (i > 0) const SizedBox(height: 12),
              _StudentRow(data: students[i]),
            ],
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: onViewAll,
                style: FilledButton.styleFrom(
                  backgroundColor: c.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'عرض جميع الطلاب',
                      style: TextStyle(
                        fontFamily: AppTheme.fontFamily,
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(width: 6),
                    Icon(Icons.arrow_back_rounded, size: 18),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StudentRow extends StatelessWidget {
  const _StudentRow({required this.data});

  final _StudentData data;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Row(
      children: <Widget>[
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: data.avatarGradient,
            ),
          ),
          child: Text(
            data.initials,
            style: const TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                data.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                data.interest,
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
        const SizedBox(width: 8),
        if (data.isNew)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: c.successSoft,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: c.success,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 4),
                Text(
                  data.time,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: c.success,
                  ),
                ),
              ],
            ),
          )
        else
          Text(
            data.time,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 10,
              color: c.textSecondary,
            ),
          ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared pieces
// ─────────────────────────────────────────────────────────────────────────────

/// Fades and slides a section in as part of the screen's entrance sequence.
class _SectionEntrance extends StatelessWidget {
  const _SectionEntrance({
    required this.opacity,
    required this.slide,
    required this.child,
  });

  final Animation<double> opacity;
  final Animation<Offset> slide;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: opacity,
      child: SlideTransition(position: slide, child: child),
    );
  }
}

/// Adds a subtle press-down scale animation without touching gestures.
class _ScaleTap extends StatefulWidget {
  const _ScaleTap({required this.onTap, required this.child});

  final VoidCallback onTap;
  final Widget child;

  @override
  State<_ScaleTap> createState() => _ScaleTapState();
}

class _ScaleTapState extends State<_ScaleTap> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapCancel: () => setState(() => _pressed = false),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      child: AnimatedScale(
        scale: _pressed ? 0.96 : 1.0,
        duration: const Duration(milliseconds: 130),
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}

/// Ripple + press-scale feedback. To be used inside a [Material] ancestor so
/// the ink splash stays clipped to the widget's bounds.
class _PressScale extends StatefulWidget {
  const _PressScale({
    required this.onTap,
    required this.radius,
    required this.child,
  });

  final VoidCallback onTap;
  final double radius;
  final Widget child;

  @override
  State<_PressScale> createState() => _PressScaleState();
}

class _PressScaleState extends State<_PressScale> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: _pressed ? 0.96 : 1.0,
      duration: const Duration(milliseconds: 130),
      curve: Curves.easeOut,
      child: InkWell(
        onTap: widget.onTap,
        onHighlightChanged: (bool value) {
          if (value != _pressed) setState(() => _pressed = value);
        },
        borderRadius: BorderRadius.circular(widget.radius),
        child: widget.child,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    this.actionText,
    this.onAction,
  });

  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Row(
      children: <Widget>[
        Container(
          width: 4,
          height: 16,
          decoration: BoxDecoration(
            color: c.primary,
            borderRadius: BorderRadius.circular(50),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
        ),
        if (actionText != null)
          InkWell(
            onTap: onAction,
            borderRadius: BorderRadius.circular(50),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: BorderRadius.circular(50),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Text(
                    actionText!,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: c.primary,
                    ),
                  ),
                  const SizedBox(width: 2),
                  Icon(Icons.arrow_back, size: 14, color: c.primary),
                ],
              ),
            ),
          ),
      ],
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
