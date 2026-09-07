// lib/features/admin/ui/screens/admin_llm_usage_screen.dart
import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/helpers/hive_storage.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';

/// ============================================================
///  شاشة مراقبة استخدام نموذج اللغة (LLM)
///  مع تخزين محلي Offline-First
/// ============================================================
class AdminLlmUsageScreen extends StatefulWidget {
  const AdminLlmUsageScreen({super.key});

  @override
  State<AdminLlmUsageScreen> createState() => _AdminLlmUsageScreenState();
}

class _AdminLlmUsageScreenState extends State<AdminLlmUsageScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  //  المتغيرات
  // ============================================================
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedPeriod = 'اليوم';

  // بيانات الاستخدام
  int _totalCalls = 0;
  double _estimatedCost = 0.0;
  int _callsToday = 0;
  int _callsThisMonth = 0;

  // الحدود
  int _dailyLimit = 1000;
  int _monthlyLimit = 30000;

  // بيانات الرسم البياني (آخر 7 أيام)
  final List<Map<String, dynamic>> _chartData = const [
    {'day': 'السبت', 'calls': 45, 'tokens': 3200},
    {'day': 'الأحد', 'calls': 52, 'tokens': 4100},
    {'day': 'الإثنين', 'calls': 38, 'tokens': 2800},
    {'day': 'الثلاثاء', 'calls': 67, 'tokens': 5200},
    {'day': 'الأربعاء', 'calls': 55, 'tokens': 4300},
    {'day': 'الخميس', 'calls': 42, 'tokens': 3500},
    {'day': 'الجمعة', 'calls': 71, 'tokens': 5800},
  ];

  // أحدث الاستعلامات
  final List<Map<String, dynamic>> _recentQueries = const [
    {
      'user': 'أحمد محمد',
      'email': 'ahmed@university.edu',
      'query': 'ما هي مساقات الذكاء الاصطناعي؟',
      'tokens': 245,
      'cost': 0.012,
      'time': 'منذ 5 دقائق',
    },
    {
      'user': 'سارة أحمد',
      'email': 'sara@university.edu',
      'query': 'ما هو الفرق بين الأمن السيبراني وعلوم البيانات؟',
      'tokens': 180,
      'cost': 0.009,
      'time': 'منذ 15 دقيقة',
    },
    {
      'user': 'محمد خالد',
      'email': 'mohammed@university.edu',
      'query': 'كيف أختار التخصص المناسب؟',
      'tokens': 320,
      'cost': 0.016,
      'time': 'منذ ساعة',
    },
    {
      'user': 'نور علي',
      'email': 'noor@university.edu',
      'query': 'شرح مادة هندسة الحاسوب',
      'tokens': 150,
      'cost': 0.007,
      'time': 'منذ ساعتين',
    },
    {
      'user': 'عمر حماد',
      'email': 'omar@university.edu',
      'query': 'ما هي فرص العمل لتخصص علم البيانات؟',
      'tokens': 280,
      'cost': 0.014,
      'time': 'منذ 3 ساعات',
    },
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  final List<String> _periods = const ['اليوم', 'هذا الأسبوع', 'هذا الشهر'];

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
  //  تحميل البيانات من Hive
  // ============================================================
  Future<void> _loadData() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // قراءة بيانات استخدام LLM من Hive
      final usageData = await HiveStorage.getData('llm_usage_cache', 'usage');

      if (usageData != null && usageData.isNotEmpty) {
        setState(() {
          _totalCalls = usageData['total_calls'] as int? ?? 0;
          // ✅ تحويل num إلى double بشكل آمن
          final costValue = usageData['estimated_cost'];
          _estimatedCost = costValue is double ? costValue : (costValue as num?)?.toDouble() ?? 0.0;
          _callsToday = usageData['calls_today'] as int? ?? 0;
          _callsThisMonth = usageData['calls_this_month'] as int? ?? 0;
          _dailyLimit = usageData['daily_limit'] as int? ?? 1000;
          _monthlyLimit = usageData['monthly_limit'] as int? ?? 30000;
        });
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _animationController.forward();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'فشل تحميل البيانات: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
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
                child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
              )
            : _errorMessage != null
                ? _buildErrorState()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(),
                              const SizedBox(height: 20),
                              _buildPeriodFilter(),
                              const SizedBox(height: 20),
                              _buildStatsGrid(),
                              const SizedBox(height: 24),
                              _buildChartSection(),
                              const SizedBox(height: 24),
                              _buildUsageProgress(),
                              const SizedBox(height: 24),
                              _buildRecentQueries(),
                            ],
                          ),
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
        'مراقبة استخدام الذكاء الاصطناعي',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryContainer,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryContainer),
          onPressed: _loadData,
        ),
      ],
    );
  }

  // ============================================================
  //  رأس الصفحة
  // ============================================================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF8B5CF6).withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '🤖 استخدام الذكاء الاصطناعي',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'إجمالي المكالمات: $_totalCalls',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Center(
              child: Icon(
                Icons.auto_awesome_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  فلتر الفترة
  // ============================================================
  Widget _buildPeriodFilter() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Text(
            'الفترة:',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          ..._periods.map((period) {
            final isSelected = _selectedPeriod == period;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: ChoiceChip(
                label: Text(period),
                selected: isSelected,
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedPeriod = period);
                  }
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: const Color(0xFF8B5CF6).withValues(alpha: 0.15),
                labelStyle: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade700,
                ),
                side: BorderSide(
                  color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade300,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  // ============================================================
  //  شبكة الإحصائيات
  // ============================================================
  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.2,
      children: [
        _buildStatCard(
          title: 'المكالمات اليومية',
          value: _callsToday.toString(),
          icon: Icons.call_rounded,
          color: const Color(0xFF3B82F6),
          subtitle: 'من $_dailyLimit',
        ),
        _buildStatCard(
          title: 'المكالمات الشهرية',
          value: _callsThisMonth.toString(),
          icon: Icons.analytics_rounded,
          color: const Color(0xFF8B5CF6),
          subtitle: 'من $_monthlyLimit',
        ),
        _buildStatCard(
          title: 'التكلفة المقدرة',
          value: '\$${_estimatedCost.toStringAsFixed(2)}',
          icon: Icons.monetization_on_rounded,
          color: const Color(0xFFF97316),
          subtitle: 'إجمالي',
        ),
        _buildStatCard(
          title: 'نسبة الاستخدام',
          value: _dailyLimit > 0
              ? '${((_callsToday / _dailyLimit) * 100).toStringAsFixed(0)}%'
              : '0%',
          icon: Icons.percent_rounded,
          color: const Color(0xFF22C55E),
          subtitle: 'يومياً',
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required String subtitle,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: 8),
              Text(
                value,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 11,
              color: Colors.grey.shade500,
            ),
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  قسم الرسم البياني
  // ============================================================
  Widget _buildChartSection() {
    final maxCalls = _chartData.fold<int>(
      0,
      (max, item) => (item['calls'] as int) > max ? (item['calls'] as int) : max,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
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
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.bar_chart_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              const Text(
                'المكالمات اليومية (آخر 7 أيام)',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 120,
            child: Row(
              children: _chartData.map((item) {
                final value = (item['calls'] as int).toDouble();
                final height = maxCalls > 0 ? (value / maxCalls * 100) : 0;

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 16,
                        height: height * 0.7,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [
                              const Color(0xFF8B5CF6),
                              const Color(0xFF8B5CF6).withValues(alpha: 0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['day'] as String,
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'إجمالي المكالمات: $_totalCalls',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
              Text(
                'متوسط: ${_totalCalls > 0 ? (_totalCalls / 7).toStringAsFixed(0) : '0'} / يوم',
                style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
              ),
            ],
          ),
        ],
      ),
    );
  }

// ============================================================
//  شريط نسبة الاستخدام (المصحح)
// ============================================================
Widget _buildUsageProgress() {
  // ✅ تحويل num إلى double بشكل آمن
  final dailyPercentage = _dailyLimit > 0
      ? ((_callsToday / _dailyLimit) * 100).clamp(0, 100).toDouble()
      : 0.0;
      
  final monthlyPercentage = _monthlyLimit > 0
      ? ((_callsThisMonth / _monthlyLimit) * 100).clamp(0, 100).toDouble()
      : 0.0;

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade200, width: 1.2),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.02),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'نسبة الاستخدام',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 12),
        _buildProgressItem(
          label: 'الاستخدام اليومي',
          percentage: dailyPercentage, // ✅ الآن من نوع double
          color: dailyPercentage > 80 ? Colors.red : Colors.green,
          current: _callsToday,
          total: _dailyLimit,
        ),
        const SizedBox(height: 12),
        _buildProgressItem(
          label: 'الاستخدام الشهري',
          percentage: monthlyPercentage, // ✅ الآن من نوع double
          color: monthlyPercentage > 80 ? Colors.red : Colors.green,
          current: _callsThisMonth,
          total: _monthlyLimit,
        ),
      ],
    ),
  );
}

  Widget _buildProgressItem({
    required String label,
    required double percentage,
    required Color color,
    required int current,
    required int total,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: AppTheme.primaryContainer),
            ),
            Text(
              '${percentage.toStringAsFixed(0)}%',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: percentage / 100,
            minHeight: 8,
            backgroundColor: Colors.grey.shade200,
            color: color,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          '$current من $total',
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  // ============================================================
  //  أحدث الاستعلامات
  // ============================================================
  Widget _buildRecentQueries() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '📋 أحدث الاستعلامات',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
              TextButton(
                onPressed: () {},
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5CF6),
                  textStyle: const TextStyle(fontSize: 12),
                ),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._recentQueries.map((query) => _buildQueryItem(query)),
        ],
      ),
    );
  }

  Widget _buildQueryItem(Map<String, dynamic> query) {
    // ✅ تحويل cost من num إلى double بأمان
    final costValue = query['cost'];
    final cost = costValue is double ? costValue : (costValue as num?)?.toDouble() ?? 0.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF7F8FB),
        borderRadius: BorderRadius.circular(12),
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
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    (query['user'] as String)[0],
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF8B5CF6),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      query['user'] as String,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.primaryContainer,
                      ),
                    ),
                    Text(
                      query['email'] as String,
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                query['time'] as String,
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.grey.shade400,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            query['query'] as String,
            style: const TextStyle(
              fontSize: 12,
              color: AppTheme.primaryContainer,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _buildQueryChip(
                label: '${query['tokens']} رمز',
                color: const Color(0xFF3B82F6),
              ),
              const SizedBox(width: 8),
              _buildQueryChip(
                label: '\$${cost.toStringAsFixed(3)}',
                color: const Color(0xFFF97316),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQueryChip({
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
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
  //  حالة الخطأ
  // ============================================================
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
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