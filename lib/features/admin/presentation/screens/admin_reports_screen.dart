import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';

class AdminReportsScreen extends StatefulWidget {
  const AdminReportsScreen({super.key});

  @override
  State<AdminReportsScreen> createState() => _AdminReportsScreenState();
}

class _AdminReportsScreenState extends State<AdminReportsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  String _selectedPeriod = 'هذا الشهر';
  String _selectedReportType = 'عام';

  final List<String> _periods = ['هذا الأسبوع', 'هذا الشهر', 'هذا العام', 'كل الوقت'];
  final List<String> _reportTypes = ['عام', 'المستخدمين', 'الجامعات', 'التخصصات'];

  // بيانات إحصائيات
  final Map<String, dynamic> _stats = {
    'total_users': 1250,
    'total_universities': 24,
    'total_programs': 45,
    'total_faculties': 18,
    'active_users': 980,
    'new_users_this_month': 156,
    'growth_rate': '+12.5%',
    'completion_rate': '78%',
  };

  // بيانات الرسم البياني - المستخدمين
  final List<Map<String, dynamic>> _userChartData = [
    {'label': 'يناير', 'value': 850},
    {'label': 'فبراير', 'value': 920},
    {'label': 'مارس', 'value': 980},
    {'label': 'أبريل', 'value': 1050},
    {'label': 'مايو', 'value': 1120},
    {'label': 'يونيو', 'value': 1180},
    {'label': 'يوليو', 'value': 1250},
  ];

  // بيانات الرسم البياني - الجامعات
  final List<Map<String, dynamic>> _universityChartData = [
    {'label': 'يناير', 'value': 18},
    {'label': 'فبراير', 'value': 19},
    {'label': 'مارس', 'value': 20},
    {'label': 'أبريل', 'value': 21},
    {'label': 'مايو', 'value': 22},
    {'label': 'يونيو', 'value': 23},
    {'label': 'يوليو', 'value': 24},
  ];

  // بيانات الجدول - أحدث المستخدمين
  final List<Map<String, dynamic>> _recentUsers = [
    {'name': 'أحمد محمد', 'email': 'ahmed@university.edu', 'role': 'طالب', 'date': '2026-08-14', 'status': 'نشط'},
    {'name': 'الجامعة الإسلامية', 'email': 'info@iugaza.edu', 'role': 'جامعة', 'date': '2026-08-14', 'status': 'نشط'},
    {'name': 'سارة أحمد', 'email': 'sara@university.edu', 'role': 'طالب', 'date': '2026-08-13', 'status': 'نشط'},
    {'name': 'جامعة الأزهر', 'email': 'info@azhar.edu', 'role': 'جامعة', 'date': '2026-08-13', 'status': 'قيد الانتظار'},
    {'name': 'محمد خالد', 'email': 'mohammed@university.edu', 'role': 'طالب', 'date': '2026-08-12', 'status': 'نشط'},
  ];

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

    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _animationController.forward();
        });
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
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                ),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildFilters(),
                        const SizedBox(height: 20),
                        _buildStatsGrid(),
                        const SizedBox(height: 24),
                        _buildChartsSection(),
                        const SizedBox(height: 24),
                        _buildRecentUsersTable(),
                        const SizedBox(height: 24),
                        _buildExportSection(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppTheme.primaryContainer,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'التقارير والإحصائيات',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryContainer,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
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
                  'نظرة عامة على النظام',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'إحصائيات وتقارير',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
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
                Icons.analytics_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilters() {
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
        children: [
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'الفترة',
                  value: _selectedPeriod,
                  items: _periods,
                  onChanged: (value) {
                    setState(() {
                      _selectedPeriod = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  label: 'نوع التقرير',
                  value: _selectedReportType,
                  items: _reportTypes,
                  onChanged: (value) {
                    setState(() {
                      _selectedReportType = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            height: 40,
            child: ElevatedButton(
              onPressed: () {
                _showSnackBar('تم تحديث التقارير');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
              child: const Text(
                'تحديث التقارير',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey.shade200, width: 1.2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppTheme.primaryContainer,
                    ),
                  ),
                );
              }).toList(),
              onChanged: onChanged,
              icon: const Icon(
                Icons.arrow_drop_down_rounded,
                color: AppTheme.primaryContainer,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          title: 'إجمالي المستخدمين',
          value: _stats['total_users'].toString(),
          icon: Icons.people_rounded,
          color: const Color(0xFF3B82F6),
          subtitle: 'نشط: ${_stats['active_users']}',
        ),
        _buildStatCard(
          title: 'الجامعات',
          value: _stats['total_universities'].toString(),
          icon: Icons.business_rounded,
          color: const Color(0xFF22C55E),
          subtitle: 'جديد: 3 هذا الشهر',
        ),
        _buildStatCard(
          title: 'التخصصات',
          value: _stats['total_programs'].toString(),
          icon: Icons.school_rounded,
          color: const Color(0xFF8B5CF6),
          subtitle: 'نشط: 38',
        ),
        _buildStatCard(
          title: 'معدل النمو',
          value: _stats['growth_rate'].toString(),
          icon: Icons.trending_up_rounded,
          color: const Color(0xFFF97316),
          subtitle: 'مستخدمين جدد: ${_stats['new_users_this_month']}',
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
                  fontSize: 22,
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

  Widget _buildChartsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الرسوم البيانية',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 12),
        _buildChartCard(
          title: 'نمو المستخدمين',
          data: _userChartData,
          color: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 12),
        _buildChartCard(
          title: 'نمو الجامعات',
          data: _universityChartData,
          color: const Color(0xFF22C55E),
        ),
      ],
    );
  }
Widget _buildChartCard({
    required String title,
    required List<Map<String, dynamic>> data,
    required Color color,
  }) {
    // ✅ نحسب أعلى قيمة مرة واحدة خارج map بدل حسابها في كل تكرار
    final double maxValue = data.fold<double>(0, (max, d) {
      final v = (d['value'] as num).toDouble();
      return v > max ? v : max;
    });

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
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.bar_chart_rounded,
                  color: color,
                  size: 16,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                title,
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
              children: data.map((item) {
                // ✅ حماية إضافية: لو maxValue = 0 (كل القيم صفر) نتفادى القسمة على صفر
                final double value = (item['value'] as num).toDouble();
                final double height =
                    maxValue == 0 ? 0 : (value / maxValue * 100);

                return Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        item['value'].toString(),
                        style: TextStyle(
                          fontSize: 8,
                          color: Colors.grey.shade500,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 16,
                        height: height * 0.8,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.bottomCenter,
                            end: Alignment.topCenter,
                            colors: [color, color.withValues(alpha: 0.5)],
                          ),
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        item['label'],
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
        ],
      ),
    );
  }

  Widget _buildRecentUsersTable() {
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
                'أحدث المستخدمين',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/admin/users'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.secondary,
                  textStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('عرض الكل'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: DataTable(
              columnSpacing: 12,
              headingRowColor: WidgetStateProperty.all(
                Colors.grey.shade50,
              ),
              columns: const [
                DataColumn(label: Text('الاسم', style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('البريد', style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('الدور', style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('التاريخ', style: TextStyle(fontWeight: FontWeight.w600))),
                DataColumn(label: Text('الحالة', style: TextStyle(fontWeight: FontWeight.w600))),
              ],
              rows: _recentUsers.map((user) {
                return DataRow(
                  cells: [
                    DataCell(Text(user['name'], style: const TextStyle(fontSize: 13))),
                    DataCell(Text(user['email'], style: const TextStyle(fontSize: 13))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primary.withValues(alpha: 0.08),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user['role'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.primary,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(user['date'], style: const TextStyle(fontSize: 13))),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: user['status'] == 'نشط'
                              ? Colors.green.withValues(alpha: 0.1)
                              : Colors.orange.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          user['status'],
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: user['status'] == 'نشط'
                                ? Colors.green.shade700
                                : Colors.orange.shade700,
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportSection() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showSnackBar('تم تصدير التقرير بصيغة PDF'),
            icon: const Icon(Icons.picture_as_pdf_rounded),
            label: const Text('PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryContainer,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showSnackBar('تم تصدير التقرير بصيغة Excel'),
            icon: const Icon(Icons.table_chart_rounded),
            label: const Text('Excel'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryContainer,
              side: BorderSide(color: Colors.grey.shade300),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: ElevatedButton.icon(
            onPressed: () => _showSnackBar('تم تصدير التقرير'),
            icon: const Icon(Icons.download_rounded),
            label: const Text('تصدير'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
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