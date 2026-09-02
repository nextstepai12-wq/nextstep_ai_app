// lib/features/student/presentation/screens/recommendations_screen.dart
import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';
import 'package:nextstep_ai_app/core/storage/hive_storage.dart';
import 'package:nextstep_ai_app/shared/services/supabase/supabase_service.dart';

/// ============================================================
///  شاشة التوصيات - تعرض التخصصات والجامعات المناسبة
///  بناءً على نتائج التقييم الذكي (الأبعاد الستة)
/// ============================================================
class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  //  المتغيرات
  // ============================================================
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedFilter = 'الكل';

  // نتائج التقييم (الأبعاد الستة)
  Map<String, double> _dimensions = {};

  // قائمة التخصصات الموصى بها
  List<Map<String, dynamic>> _recommendations = [];
  List<Map<String, dynamic>> _allMajors = [];
  List<Map<String, dynamic>> _allUniversities = [];

  final List<String> _filterOptions = ['الكل', 'هندسة', 'علوم', 'إدارة', 'طب'];

  // الأنيميشن
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // ============================================================
  //  دوال مساعدة
  // ============================================================
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

  String _getDimensionIcon(String key) {
    switch (key) {
      case 'programming':
        return '💻';
      case 'math':
        return '📐';
      case 'communication':
        return '🗣️';
      case 'research':
        return '🔬';
      case 'practical':
        return '🔧';
      case 'management':
        return '📊';
      default:
        return '📌';
    }
  }

  Color _getScoreColor(double score) {
    if (score >= 70) return Colors.green;
    if (score >= 40) return Colors.orange;
    return Colors.red;
  }

  // ============================================================
  //  حساب التوافق بين الطالب والتخصص
  // ============================================================
  double _calculateCompatibility(
    Map<String, double> studentDimensions,
    Map<String, dynamic> major,
  ) {
    final majorDimensions = major['dimensions'] ?? {};
    if (majorDimensions.isEmpty) return 0.0;

    double totalScore = 0;
    int count = 0;

    for (var key in studentDimensions.keys) {
      if (majorDimensions.containsKey(key)) {
        final studentValue = studentDimensions[key] ?? 0;
        final majorValue = (majorDimensions[key] as num?)?.toDouble() ?? 0;
        // الفرق بين القيمتين، كلما قل الفرق زاد التوافق
        final difference = (studentValue - majorValue).abs();
        final score = 100 - difference;
        totalScore += score.clamp(0, 100);
        count++;
      }
    }

    return count > 0 ? totalScore / count : 0.0;
  }

  // ============================================================
  //  تحميل البيانات
  // ============================================================
  Future<void> _loadData() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // ✅ 1. جلب نتائج التقييم من Hive
      final savedResults = await HiveStorage.getData('assessment_cache', 'results');
      if (savedResults != null && savedResults.isNotEmpty) {
        _dimensions = Map<String, double>.from(savedResults);
        debugPrint('📊 تم تحميل نتائج التقييم: $_dimensions');
      } else {
        // استخدام قيم افتراضية إذا لم توجد نتائج
        _dimensions = {
          'programming': 60.0,
          'math': 55.0,
          'communication': 70.0,
          'research': 65.0,
          'practical': 50.0,
          'management': 45.0,
        };
        debugPrint('⚠️ استخدام قيم افتراضية للتقييم');
      }

      // ✅ 2. جلب التخصصات من Supabase
      final supabase = SupabaseService();
      final majorsResponse = await supabase.client
          .from('programs')
          .select('*, universities(name, location)')
          .eq('is_active', true)
          .order('name');

      if (majorsResponse != null && majorsResponse.isNotEmpty) {
        _allMajors = List<Map<String, dynamic>>.from(majorsResponse);

        // ✅ 3. حساب التوصيات
        _recommendations = _allMajors.map((major) {
          final compatibility = _calculateCompatibility(_dimensions, major);
          return {
            ...major,
            'compatibility': compatibility,
            'university_name': major['universities']?['name'] ?? 'جامعة غير محددة',
            'university_location': major['universities']?['location'] ?? '',
          };
        }).toList();

        // ترتيب حسب نسبة التوافق (الأعلى أولاً)
        _recommendations.sort((a, b) {
          final aScore = (a['compatibility'] as num?)?.toDouble() ?? 0;
          final bScore = (b['compatibility'] as num?)?.toDouble() ?? 0;
          return bScore.compareTo(aScore);
        });

        debugPrint('📊 تم حساب ${_recommendations.length} توصية');

        // ✅ حفظ في Hive
        await HiveStorage.saveData('recommendations_cache', 'recommendations', _recommendations);
      } else {
        // ✅ استخدام بيانات وهمية
        _recommendations = _getMockRecommendations();
        debugPrint('⚠️ استخدام توصيات افتراضية');
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _animationController.forward();
        });
      }
    } catch (e) {
      debugPrint('❌ خطأ في تحميل التوصيات: $e');

      // ✅ استخدام بيانات وهمية
      _recommendations = _getMockRecommendations();

      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'فشل تحميل التوصيات: ${e.toString()}';
        });
      }
    }
  }

  // ============================================================
  //  توصيات افتراضية
  // ============================================================
  List<Map<String, dynamic>> _getMockRecommendations() {
    return [
      {
        'id': 1,
        'name': 'هندسة الحاسوب',
        'description': 'تخصص يهتم بتصميم وتطوير أنظمة الحاسوب والبرمجيات',
        'type': 'بكالوريوس',
        'duration': 4,
        'university_name': 'الجامعة الإسلامية',
        'university_location': 'غزة، فلسطين',
        'compatibility': 92,
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
        'description': 'تخصص يهتم بتطوير أنظمة ذكية وتعلم الآلة',
        'type': 'بكالوريوس',
        'duration': 4,
        'university_name': 'جامعة الأزهر',
        'university_location': 'غزة، فلسطين',
        'compatibility': 85,
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
        'description': 'تخصص يهتم بتحليل البيانات الضخمة واستخراج المعلومات',
        'type': 'ماجستير',
        'duration': 2,
        'university_name': 'جامعة الأقصى',
        'university_location': 'غزة، فلسطين',
        'compatibility': 78,
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
        'description': 'تخصص يهتم بإدارة المؤسسات والتسويق والموارد البشرية',
        'type': 'بكالوريوس',
        'duration': 4,
        'university_name': 'جامعة فلسطين',
        'university_location': 'غزة، فلسطين',
        'compatibility': 65,
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

  // ============================================================
  //  دورة الحياة
  // ============================================================
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  //  بناء الواجهة
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _buildAppBar(),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: RefreshIndicator(
                    onRefresh: _loadData,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        _buildSliverHeader(),
                        SliverToBoxAdapter(child: _buildDimensionsSummary()),
                        SliverToBoxAdapter(child: _buildFilter()),
                        if (_recommendations.isEmpty)
                          SliverFillRemaining(
                            hasScrollBody: false,
                            child: _buildEmptyState(),
                          )
                        else
                          SliverPadding(
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                            sliver: SliverList(
                              delegate: SliverChildBuilderDelegate(
                                (context, index) =>
                                    _buildRecommendationCard(_recommendations[index]),
                                childCount: _recommendations.length,
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

  // ============================================================
  //  AppBar
  // ============================================================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryContainer),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'التوصيات',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryContainer,
        ),
      ),
      centerTitle: true,
    );
  }

  // ============================================================
  //  رأس الصفحة
  // ============================================================
  Widget _buildSliverHeader() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primary,
      expandedHeight: 120,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(right: 56, bottom: 16),
        centerTitle: false,
        title: const Text(
          'التخصصات المناسبة لك',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        background: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.primaryContainer],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  ملخص الأبعاد
  // ============================================================
  Widget _buildDimensionsSummary() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '📊 ملفك الشخصي',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: _dimensions.keys.map((key) {
              final value = _dimensions[key] ?? 0;
              final color = _getScoreColor(value);
              return Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '${_getDimensionIcon(key)} ${_getDimensionName(key)}: ${value.toInt()}%',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: color,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  فلترة
  // ============================================================
  Widget _buildFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: SizedBox(
        height: 36,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          itemCount: _filterOptions.length,
          separatorBuilder: (_, __) => const SizedBox(width: 8),
          itemBuilder: (context, index) {
            final filter = _filterOptions[index];
            final isSelected = _selectedFilter == filter;
            return ChoiceChip(
              label: Text(filter),
              selected: isSelected,
              onSelected: (_) => setState(() => _selectedFilter = filter),
              backgroundColor: Colors.white,
              selectedColor: AppTheme.primary.withValues(alpha: 0.1),
              labelStyle: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : Colors.grey.shade700,
              ),
              side: BorderSide(
                color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                width: 1.4,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 6),
            );
          },
        ),
      ),
    );
  }

  // ============================================================
  //  بطاقة التوصية
  // ============================================================
  Widget _buildRecommendationCard(Map<String, dynamic> recommendation) {
    final compatibility = (recommendation['compatibility'] as num?)?.toDouble() ?? 0;
    final color = _getScoreColor(compatibility);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            Navigator.pushNamed(
              context,
              '/student/major-detail',
              arguments: recommendation,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '${compatibility.toInt()}%',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recommendation['name'] ?? 'تخصص غير معروف',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryContainer,
                            ),
                          ),
                          Row(
                            children: [
                              Icon(Icons.school_rounded, size: 12, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Text(
                                recommendation['university_name'] ?? 'جامعة غير محددة',
                                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${compatibility.toInt()}%',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  recommendation['description'] ?? '',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: compatibility / 100,
                    minHeight: 4,
                    backgroundColor: Colors.grey.shade200,
                    color: color,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildChip(
                      label: recommendation['type'] ?? 'بكالوريوس',
                      color: const Color(0xFF3B82F6),
                    ),
                    const SizedBox(width: 6),
                    _buildChip(
                      label: '${recommendation['duration'] ?? 4} سنوات',
                      color: const Color(0xFFF97316),
                    ),
                    const SizedBox(width: 6),
                    if (recommendation['university_location'] != null &&
                        recommendation['university_location'] != '')
                      _buildChip(
                        label: recommendation['university_location'],
                        color: const Color(0xFF22C55E),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildChip({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  // ============================================================
  //  حالة فارغة
  // ============================================================
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.recommend_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            const Text(
              'لا توجد توصيات',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'قم بإجراء التقييم الذكي أولاً للحصول على توصيات',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/student/assessment');
              },
              icon: const Icon(Icons.assessment_rounded),
              label: const Text('ابدأ التقييم'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}