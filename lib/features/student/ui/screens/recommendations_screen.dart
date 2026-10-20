import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/helpers/hive_storage.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String _selectedFilter = 'الكل';

  Map<String, double> _dimensions = {};

  List<Map<String, dynamic>> _recommendations = [];
  List<Map<String, dynamic>> _filtered = [];

  final List<String> _filterOptions = ['الكل', 'هندسة', 'علوم', 'إدارة', 'طب'];

  late AnimationController _staggerController;
  late List<Animation<double>> _fadeAnimations;
  late List<Animation<Offset>> _slideAnimations;

  String _getDimensionName(String key) {
    switch (key) {
      case 'programming':
        return 'برمجة';
      case 'math':
        return 'رياضيات';
      case 'communication':
        return 'تواصل';
      case 'research':
        return 'بحث علمي';
      case 'practical':
        return 'عملي';
      case 'management':
        return 'إدارة';
      default:
        return key;
    }
  }

  IconData _getDimensionIcon(String key) {
    switch (key) {
      case 'programming':
        return Icons.code_rounded;
      case 'math':
        return Icons.calculate_rounded;
      case 'communication':
        return Icons.forum_rounded;
      case 'research':
        return Icons.science_rounded;
      case 'practical':
        return Icons.build_rounded;
      case 'management':
        return Icons.analytics_rounded;
      default:
        return Icons.star_rounded;
    }
  }

  Color _getScoreColor(AppColors c, double score) {
    if (score >= 70) return c.success;
    if (score >= 40) return c.accent;
    return c.danger;
  }

  IconData _majorIcon(Map<String, dynamic> rec) {
    final dims = rec['dimensions'] as Map<String, dynamic>?;
    if (dims == null) return Icons.school_rounded;
    String top = 'programming';
    double maxVal = -1;
    dims.forEach((k, v) {
      final val = (v as num?)?.toDouble() ?? 0;
      if (val > maxVal) {
        maxVal = val;
        top = k;
      }
    });
    return _getDimensionIcon(top);
  }

  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final savedResults =
          await HiveStorage.getData('assessment_cache', 'results');
      if (savedResults != null && savedResults.isNotEmpty) {
        _dimensions = Map<String, double>.from(savedResults);
      } else {
        _dimensions = {
          'programming': 60.0,
          'math': 55.0,
          'communication': 70.0,
          'research': 65.0,
          'practical': 50.0,
          'management': 45.0,
        };
      }

      _recommendations = _getMockRecommendations();
      _applyFilter();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _playStaggeredAnimation();
      }
    } catch (e) {
      _recommendations = _getMockRecommendations();
      _applyFilter();

      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        _playStaggeredAnimation();
      }
    }
  }

  void _applyFilter() {
    if (_selectedFilter == 'الكل') {
      _filtered = _recommendations;
      return;
    }
    _filtered = _recommendations.where((r) {
      final category = (r['category'] ?? '').toString();
      return category == _selectedFilter;
    }).toList();
  }

  List<Map<String, dynamic>> _getMockRecommendations() {
    return [
      {
        'id': 1,
        'name': 'هندسة الحاسوب',
        'category': 'هندسة',
        'description': 'تخصص يهتم بتصميم وتطوير أنظمة الحاسوب والبرمجيات',
        'type': 'بكالوريوس',
        'duration': 4,
        'university_name': 'الجامعة الإسلامية',
        'university': 'الجامعة الإسلامية',
        'university_location': 'غزة، فلسطين',
        'compatibility': 92,
        'match': 92,
        'dimensions': {
          'programming': 90,
          'math': 80,
          'communication': 60,
          'research': 70,
          'practical': 85,
          'management': 50,
        },
      },
      {
        'id': 2,
        'name': 'الذكاء الاصطناعي',
        'category': 'علوم',
        'description': 'تخصص يهتم بتطوير أنظمة ذكية وتعلم الآلة',
        'type': 'بكالوريوس',
        'duration': 4,
        'university_name': 'جامعة الأزهر',
        'university': 'جامعة الأزهر',
        'university_location': 'غزة، فلسطين',
        'compatibility': 85,
        'match': 85,
        'dimensions': {
          'programming': 85,
          'math': 90,
          'communication': 50,
          'research': 80,
          'practical': 70,
          'management': 40,
        },
      },
      {
        'id': 3,
        'name': 'علوم البيانات',
        'category': 'علوم',
        'description': 'تخصص يهتم بتحليل البيانات الضخمة واستخراج المعلومات',
        'type': 'ماجستير',
        'duration': 2,
        'university_name': 'جامعة الأقصى',
        'university': 'جامعة الأقصى',
        'university_location': 'غزة، فلسطين',
        'compatibility': 78,
        'match': 78,
        'dimensions': {
          'programming': 75,
          'math': 85,
          'communication': 55,
          'research': 90,
          'practical': 65,
          'management': 45,
        },
      },
      {
        'id': 4,
        'name': 'إدارة الأعمال',
        'category': 'إدارة',
        'description': 'تخصص يهتم بإدارة المؤسسات والتسويق والموارد البشرية',
        'type': 'بكالوريوس',
        'duration': 4,
        'university_name': 'جامعة فلسطين',
        'university': 'جامعة فلسطين',
        'university_location': 'غزة، فلسطين',
        'compatibility': 65,
        'match': 65,
        'dimensions': {
          'programming': 30,
          'math': 40,
          'communication': 85,
          'research': 50,
          'practical': 60,
          'management': 90,
        },
      },
    ];
  }

  @override
  void initState() {
    super.initState();
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _loadData();
  }

  @override
  void dispose() {
    _staggerController.dispose();
    super.dispose();
  }

  void _playStaggeredAnimation() {
    final count = 3 + _filtered.length;
    _fadeAnimations = [];
    _slideAnimations = [];
    for (int i = 0; i < count; i++) {
      final start = (i * 0.09).clamp(0.0, 0.7);
      final end = (start + 0.35).clamp(0.0, 1.0);
      _fadeAnimations.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(start, end, curve: Curves.easeOut),
          ),
        ),
      );
      _slideAnimations.add(
        Tween<Offset>(
          begin: const Offset(0, 0.12),
          end: Offset.zero,
        ).animate(
          CurvedAnimation(
            parent: _staggerController,
            curve: Interval(start, end, curve: Curves.easeOutCubic),
          ),
        ),
      );
    }
    _staggerController.forward(from: 0);
  }

  Widget _animatedItem(int index, Widget child) {
    if (index >= _fadeAnimations.length) return child;
    return FadeTransition(
      opacity: _fadeAnimations[index],
      child: SlideTransition(
        position: _slideAnimations[index],
        child: child,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        body: _isLoading ? _buildLoading(c) : _buildContent(c),
      ),
    );
  }

  

  Widget _buildLoading(AppColors c) {
    return Stack(
      children: [
        _gradientBg(c),
        const Center(
          child: CircularProgressIndicator(color: Color(0xFF2A14B4)),
        ),
      ],
    );
  }

  

  Widget _gradientBg(AppColors c) {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 260,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              c.primarySoft.withValues(alpha: 0.45),
              c.surfaceAlt.withValues(alpha: 0.2),
              c.background,
            ],
          ),
        ),
      ),
    );
  }

  

  Widget _buildContent(AppColors c) {
    return Stack(
      children: [
        _gradientBg(c),
        SafeArea(
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _animatedItem(0, _buildHeader(c)),
                      const SizedBox(height: 16),
                      _animatedItem(1, _buildDimensionsSummary(c)),
                      const SizedBox(height: 16),
                      _animatedItem(2, _buildFilter(c)),
                      const SizedBox(height: 8),
                      if (_filtered.isEmpty)
                        _buildEmptyState(
                          c,
                          isFiltered: _selectedFilter != 'الكل',
                        )
                      else
                        ...List.generate(_filtered.length, (i) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: _animatedItem(
                              3 + i,
                              _buildRecommendationCard(c, _filtered[i]),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  

  Widget _buildHeader(AppColors c) {
    final canPop = ModalRoute.of(context)?.canPop ?? false;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [c.primary, c.primaryContainer, c.purple],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.2),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: canPop
                    ? () => Navigator.pop(context)
                    : () => Scaffold.of(context).openDrawer(),
                child: Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    canPop ? Icons.arrow_forward_rounded : Icons.menu_rounded,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                'التوصيات',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white, size: 14),
                    const SizedBox(width: 6),
                    Text(
                      '${_filtered.length} تخصص',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'التخصصات المناسبة لك',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.3,
            ),
            maxLines: 1,
          ),
          const SizedBox(height: 10),
          Text(
            'تخصصات مطابقة لنتائج تقييمك الذكي عبر 6 أبعاد تحليلية',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.85),
              fontSize: 12,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.25),
              ),
            ),
            child: const Text(
              'بيانات تجريبية',
              style: TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildDimensionsSummary(AppColors c) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: c.surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: c.primary.withValues(alpha: 0.05),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(Icons.person_rounded, color: c.primary, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                'ملفك الشخصي',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: c.textPrimary,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: c.primarySoft,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'NextStep AI',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: c.primary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dimensions.keys.map((key) {
              final value = _dimensions[key] ?? 0;
              final color = _getScoreColor(c, value);
              return Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: color.withValues(alpha: 0.2)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_getDimensionIcon(key), size: 13, color: color),
                    const SizedBox(width: 5),
                    Text(
                      _getDimensionName(key),
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${value.toInt()}%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: color,
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  

  Widget _buildFilter(AppColors c) {
    return Row(
      children: List.generate(_filterOptions.length, (index) {
        final filter = _filterOptions[index];
        final isSelected = _selectedFilter == filter;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilter = filter;
                  _applyFilter();
                });
                _playStaggeredAnimation();
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? c.primary : c.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: isSelected ? c.primary : c.divider,
                    width: isSelected ? 1.6 : 1,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: c.primary.withValues(alpha: 0.25),
                            blurRadius: 10,
                            offset: const Offset(0, 3),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight:
                          isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? Colors.white : c.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }

  

  Widget _buildRecommendationCard(
      AppColors c, Map<String, dynamic> recommendation) {
    final compatibility =
        (recommendation['compatibility'] as num?)?.toDouble() ?? 0;
    final color = _getScoreColor(c, compatibility);
    final icon = _majorIcon(recommendation);

    return GestureDetector(
      onTap: () {
        context.push(
          '/student/major-detail',
          extra: recommendation,
        );
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: c.primary.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(icon, color: color, size: 24),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        recommendation['name'] ?? 'تخصص غير معروف',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: c.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Row(
                        children: [
                          Icon(Icons.school_rounded,
                              size: 12, color: c.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              recommendation['university_name'] ??
                                  'جامعة غير محددة',
                              style: TextStyle(
                                  fontSize: 11, color: c.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                _matchBadge(c: c, percent: compatibility.toInt(), color: color),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              recommendation['description'] ?? '',
              style: TextStyle(
                fontSize: 12,
                color: c.textSecondary,
                height: 1.5,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            _animatedProgressBar(c, compatibility, color),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 6,
              children: [
                _buildChip(
                  c: c,
                  label: recommendation['type'] ?? 'بكالوريوس',
                  color: c.primary,
                  icon: Icons.workspace_premium_rounded,
                ),
                _buildChip(
                  c: c,
                  label: '${recommendation['duration'] ?? 4} سنوات',
                  color: c.purple,
                  icon: Icons.schedule_rounded,
                ),
                if (recommendation['university_location'] != null &&
                    recommendation['university_location'] != '')
                  _buildChip(
                    c: c,
                    label: recommendation['university_location'],
                    color: c.success,
                    icon: Icons.location_on_rounded,
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _animatedProgressBar(AppColors c, double value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'نسبة التوافق',
              style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: c.textSecondary),
            ),
            Text(
              '${value.toInt()}%',
              style: TextStyle(
                  fontSize: 12, fontWeight: FontWeight.w800, color: color),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: value / 100),
            duration: const Duration(milliseconds: 1600),
            curve: Curves.easeOutCubic,
            builder: (context, v, _) => LinearProgressIndicator(
              value: v,
              minHeight: 8,
              backgroundColor: c.surfaceAlt,
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
      ],
    );
  }

  Widget _matchBadge({
    required AppColors c,
    required int percent,
    required Color color,
  }) {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$percent%',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          Text(
            'توافق',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.75),
              fontSize: 8,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChip({
    required AppColors c,
    required String label,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildEmptyState(AppColors c, {required bool isFiltered}) {
    return Padding(
      padding: const EdgeInsets.only(top: 48),
      child: Column(
        children: [
          Container(
            width: 88,
            height: 88,
            decoration: BoxDecoration(
              color: c.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFiltered
                  ? Icons.filter_alt_off_rounded
                  : Icons.recommend_outlined,
              size: 40,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            isFiltered ? 'لا توجد توصيات في هذا التصنيف' : 'لا توجد توصيات',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? 'جرّب تصنيفاً آخر لعرض التخصصات المتاحة'
                : 'قم بإجراء التقييم الذكي أولاً للحصول على توصيات',
            style: TextStyle(fontSize: 13, color: c.textSecondary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: isFiltered
                ? () {
                    setState(() {
                      _selectedFilter = 'الكل';
                      _applyFilter();
                    });
                    _playStaggeredAnimation();
                  }
                : () => context.push('/student/assessment'),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              decoration: BoxDecoration(
                gradient:
                    LinearGradient(colors: [c.primary, c.primaryContainer]),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: c.primary.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isFiltered
                        ? Icons.filter_alt_rounded
                        : Icons.psychology_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isFiltered ? 'عرض كل التوصيات' : 'ابدأ التقييم',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
