import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';
import 'package:nextstep_ai_app/shared/services/supabase/supabase_service.dart';
import 'package:nextstep_ai_app/shared/services/auth/token_manager.dart';
import 'package:nextstep_ai_app/features/student/presentation/screens/major_detail_screen.dart';

class RecommendationsScreen extends StatefulWidget {
  const RecommendationsScreen({super.key});

  @override
  State<RecommendationsScreen> createState() => _RecommendationsScreenState();
}

class _RecommendationsScreenState extends State<RecommendationsScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseService _supabase = SupabaseService();

  bool _isLoading = true;
  String? _errorMessage;
  String _userName = '';

  // بيانات التوصيات
  List<Map<String, dynamic>> _topRecommendations = [];
  List<Map<String, dynamic>> _allRecommendations = [];
  List<Map<String, dynamic>> _filteredRecommendations = [];
  String _selectedFilter = 'الكل';
  bool _showFavorites = false;

  // مؤقت للتصميم
  final List<String> _filterOptions = ['الكل', 'هندسة', 'طب', 'علوم', 'آداب', 'إدارة'];

  // قائمة المفضلة
  Set<int> _favoriteIds = {};

  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _loadRecommendations();
  }

  Future<void> _loadRecommendations() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // جلب اسم المستخدم
      final cachedData = await TokenManager.getUserData();
      if (cachedData['name'] != null && cachedData['name']!.isNotEmpty) {
        _userName = cachedData['name']!;
      }

      // ✅ جلب التوصيات من قاعدة البيانات
      // TODO: استدعاء API لجلب التوصيات الفعلية
      await Future.delayed(const Duration(seconds: 1));

      // بيانات تجريبية
      _topRecommendations = [
        {
          'id': 1,
          'name': 'هندسة الحاسوب',
          'university': 'الجامعة الإسلامية',
          'match': 92,
          'description':
              'تخصص يهتم بتصميم وتطوير أنظمة الحاسوب والبرمجيات والشبكات.',
          'career': 'مهندس برمجيات، مطور تطبيقات، مهندس شبكات',
          'duration': '4 سنوات',
          'category': 'هندسة',
          'isFavorite': false,
        },
        {
          'id': 2,
          'name': 'الذكاء الاصطناعي',
          'university': 'جامعة الأزهر',
          'match': 85,
          'description':
              'تخصص يهتم بتطوير أنظمة ذكية قادرة على التعلم واتخاذ القرارات.',
          'career': 'مهندس ذكاء اصطناعي، عالم بيانات، مطور روبوتات',
          'duration': '4 سنوات',
          'category': 'علوم',
          'isFavorite': false,
        },
        {
          'id': 3,
          'name': 'علوم البيانات',
          'university': 'جامعة الأقصى',
          'match': 78,
          'description':
              'تخصص يهتم بتحليل البيانات الضخمة واستخراج الأنماط والمعلومات.',
          'career': 'عالم بيانات، محلل بيانات، مهندس تعلم آلة',
          'duration': '4 سنوات',
          'category': 'علوم',
          'isFavorite': false,
        },
        {
          'id': 4,
          'name': 'الهندسة الطبية',
          'university': 'جامعة القدس',
          'match': 72,
          'description': 'تخصص يدمج بين الهندسة والطب لتطوير الأجهزة الطبية.',
          'career': 'مهندس طبي، مطور أجهزة طبية، باحث',
          'duration': '5 سنوات',
          'category': 'طب',
          'isFavorite': false,
        },
        {
          'id': 5,
          'name': 'إدارة الأعمال',
          'university': 'جامعة بيرزيت',
          'match': 65,
          'description': 'تخصص يهتم بإدارة المؤسسات والشركات واتخاذ القرارات.',
          'career': 'مدير أعمال، مستشار إداري، رائد أعمال',
          'duration': '4 سنوات',
          'category': 'إدارة',
          'isFavorite': false,
        },
      ];

      _allRecommendations = _topRecommendations;
      _filteredRecommendations = _topRecommendations;

      if (mounted) {
        setState(() {
          _isLoading = false;
          _animationController.forward();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'تعذّر تحميل التوصيات';
          _isLoading = false;
        });
      }
    }
  }

  void _toggleFavorite(int id) {
    setState(() {
      if (_favoriteIds.contains(id)) {
        _favoriteIds.remove(id);
      } else {
        _favoriteIds.add(id);
      }
    });
  }

  void _filterRecommendations(String filter) {
    setState(() {
      _selectedFilter = filter;
      if (filter == 'الكل') {
        _filteredRecommendations = _allRecommendations;
      } else {
        _filteredRecommendations =
            _allRecommendations
                .where((item) => item['category'] == filter)
                .toList();
      }
    });
  }

  void _toggleFavoritesFilter() {
    setState(() {
      _showFavorites = !_showFavorites;
      if (_showFavorites) {
        _filteredRecommendations =
            _allRecommendations
                .where((item) => _favoriteIds.contains(item['id']))
                .toList();
      } else {
        _filteredRecommendations = _allRecommendations;
        if (_selectedFilter != 'الكل') {
          _filterRecommendations(_selectedFilter);
        }
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'التوصيات المقترحة',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryContainer,
        ),
      ),
      centerTitle: true,
leading: const SizedBox.shrink(),
      actions: [
        IconButton(
          icon: Icon(
            _showFavorites ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            color: _showFavorites ? Colors.red : AppTheme.primaryContainer,
          ),
          onPressed: _toggleFavoritesFilter,
        ),
      ],
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          color: AppTheme.primary,
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.error_outline_rounded,
                  size: 56, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                _errorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadRecommendations,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('إعادة المحاولة'),
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

    if (_allRecommendations.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.recommend_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'لا توجد توصيات حالياً',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أكمل الاستبيان للحصول على توصيات مخصصة',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/assessment'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('اذهب إلى الاستبيان'),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Filter Section
        _buildFilterSection(),
        // Results
        Expanded(
          child: _showFavorites && _filteredRecommendations.isEmpty
              ? _buildEmptyFavorites()
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  physics: const BouncingScrollPhysics(),
                  itemCount: _filteredRecommendations.length,
                  itemBuilder: (context, index) {
                    final item = _filteredRecommendations[index];
                    final isFavorite = _favoriteIds.contains(item['id']);
                    return _buildRecommendationCard(item, isFavorite);
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'عدد النتائج: ${_filteredRecommendations.length}',
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
              if (_showFavorites)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'المفضلة',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _filterOptions.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: const EdgeInsets.only(left: 8),
                  child: FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (_) => _filterRecommendations(filter),
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: AppTheme.primary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                      color: isSelected ? AppTheme.primary : Colors.grey.shade700,
                    ),
                    side: BorderSide(
                      color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                      width: 1.5,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationCard(Map<String, dynamic> item, bool isFavorite) {
    final matchColor = _getMatchColor(item['match'] as int);

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: matchColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      (item['name'] as String).substring(0, 1),
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: matchColor,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item['name'],
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primaryContainer,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item['university'],
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(
                    isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    color: isFavorite ? Colors.red : Colors.grey.shade400,
                    size: 24,
                  ),
                  onPressed: () => _toggleFavorite(item['id']),
                ),
              ],
            ),
          ),

          // Description
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              item['description'],
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Tags
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _buildTag(
                  label: '${item['match']}% توافق',
                  color: matchColor,
                ),
                _buildTag(
                  label: item['duration'],
                  color: Colors.blue,
                ),
                _buildTag(
                  label: item['category'],
                  color: Colors.purple,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Career
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(
                  Icons.work_outline_rounded,
                  size: 16,
                  color: Colors.grey.shade500,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    item['career'],
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Bottom Actions
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
onPressed: () {
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => MajorDetailScreen(
        majorData: item,
      ),
    ),
  );
},
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: BorderSide(color: AppTheme.primary.withValues(alpha: 0.3)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('تفاصيل أكثر'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: حفظ التخصص المختار
                      _showSnackBar('تم حفظ التخصص ${item['name']}');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primary,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                    ),
                    child: const Text('اختيار'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag({required String label, required Color color}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getMatchColor(int match) {
    if (match >= 80) return const Color(0xFF22C55E);
    if (match >= 60) return const Color(0xFFF97316);
    return const Color(0xFFDC2626);
  }

  Widget _buildEmptyFavorites() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.favorite_outline_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              'لا توجد تخصصات مفضلة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'أضف تخصصات إلى المفضلة بالنقر على القلب ❤️',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showDetailsDialog(Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text(
          item['name'],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryContainer,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الجامعة: ${item['university']}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryContainer,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                item['description'],
                style: const TextStyle(
                  fontSize: 14,
                  height: 1.5,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'المدة: ${item['duration']}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'مجال العمل: ${item['career']}',
                style: const TextStyle(
                  fontSize: 13,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: _getMatchColor(item['match']).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'نسبة التوافق: ${item['match']}%',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: _getMatchColor(item['match']),
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إغلاق'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('تم اختيار تخصص ${item['name']}');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('اختيار'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: const Color(0xFF22C55E),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
  }
}