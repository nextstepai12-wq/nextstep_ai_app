import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';

class UniversityStudentsScreen extends StatefulWidget {
  const UniversityStudentsScreen({super.key});

  @override
  State<UniversityStudentsScreen> createState() =>
      _UniversityStudentsScreenState();
}

class _UniversityStudentsScreenState extends State<UniversityStudentsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'الكل';

  final List<String> _filterOptions = ['الكل', 'طلاب', 'خريجين', 'جدد'];

  final List<Map<String, dynamic>> _allStudents = [
    {
      'id': 1,
      'name': 'أحمد محمد',
      'email': 'ahmed@university.edu',
      'major': 'هندسة الحاسوب',
      'year': 'السنة الثالثة',
      'status': 'نشط',
      'gpa': 3.5,
      'phone': '0599123456',
    },
    {
      'id': 2,
      'name': 'سارة أحمد',
      'email': 'sara@university.edu',
      'major': 'الذكاء الاصطناعي',
      'year': 'السنة الثانية',
      'status': 'نشط',
      'gpa': 3.8,
      'phone': '0599123457',
    },
    {
      'id': 3,
      'name': 'محمد خالد',
      'email': 'mohammed@university.edu',
      'major': 'علوم البيانات',
      'year': 'السنة الرابعة',
      'status': 'خريج',
      'gpa': 3.2,
      'phone': '0599123458',
    },
    {
      'id': 4,
      'name': 'نورا علي',
      'email': 'nora@university.edu',
      'major': 'الأمن السيبراني',
      'year': 'السنة الأولى',
      'status': 'جديد',
      'gpa': 3.9,
      'phone': '0599123459',
    },
    {
      'id': 5,
      'name': 'يوسف عمر',
      'email': 'yousef@university.edu',
      'major': 'هندسة الحاسوب',
      'year': 'السنة الثالثة',
      'status': 'نشط',
      'gpa': 2.8,
      'phone': '0599123460',
    },
    {
      'id': 6,
      'name': 'ليلى محمود',
      'email': 'laila@university.edu',
      'major': 'الذكاء الاصطناعي',
      'year': 'السنة الثانية',
      'status': 'نشط',
      'gpa': 3.6,
      'phone': '0599123461',
    },
  ];

  List<Map<String, dynamic>> get _filteredStudents {
    var filtered = _allStudents;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((student) {
        return student['name'].contains(_searchQuery) ||
            student['email'].contains(_searchQuery) ||
            student['major'].contains(_searchQuery);
      }).toList();
    }

    if (_selectedFilter != 'الكل') {
      filtered = filtered.where((student) {
        if (_selectedFilter == 'طلاب') return student['status'] == 'نشط';
        if (_selectedFilter == 'خريجين') return student['status'] == 'خريج';
        if (_selectedFilter == 'جدد') return student['status'] == 'جديد';
        return true;
      }).toList();
    }

    return filtered;
  }

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
                  child: Column(
                    children: [
                      _buildSearchAndFilter(),
                      _buildStatsRow(),
                      Expanded(
                        child: _filteredStudents.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: _filteredStudents.length,
                                itemBuilder: (context, index) {
                                  final student = _filteredStudents[index];
                                  return _buildStudentCard(student);
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
        floatingActionButton: _buildFAB(),
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
        'الطلاب',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryContainer,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: Column(
        children: [
          TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'بحث عن طالب...',
              hintStyle: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 14,
              ),
              prefixIcon: const Icon(
                Icons.search_rounded,
                color: Colors.grey,
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(
                  color: AppTheme.secondary,
                  width: 2,
                ),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 12,
              ),
            ),
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
                    onSelected: (_) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    backgroundColor: Colors.grey.shade100,
                    selectedColor: AppTheme.primary.withValues(alpha: 0.1),
                    labelStyle: TextStyle(
                      fontSize: 13,
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

  Widget _buildStatsRow() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              label: 'الطلاب',
              value: _allStudents.length.toString(),
              icon: Icons.people_rounded,
              color: const Color(0xFF3B82F6),
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildStatItem(
              label: 'نشط',
              value: _allStudents
                  .where((s) => s['status'] == 'نشط')
                  .length
                  .toString(),
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF22C55E),
            ),
          ),
          Container(
            width: 1,
            height: 30,
            color: Colors.grey.shade200,
          ),
          Expanded(
            child: _buildStatItem(
              label: 'خريجين',
              value: _allStudents
                  .where((s) => s['status'] == 'خريج')
                  .length
                  .toString(),
              icon: Icons.school_rounded,
              color: const Color(0xFFF97316),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryContainer,
              ),
            ),
          ],
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }

  // ✅ إصلاح بطاقة الطالب - استخدام Expanded و Flexible
  Widget _buildStudentCard(Map<String, dynamic> student) {
    Color statusColor;
    switch (student['status']) {
      case 'نشط':
        statusColor = Colors.green;
        break;
      case 'خريج':
        statusColor = Colors.orange;
        break;
      case 'جديد':
        statusColor = Colors.blue;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Row(
        children: [
          // ✅ صورة رمزية
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                student['name'][0],
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),

          // ✅ معلومات الطالب (موسعة)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  student['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryContainer,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  student['major'],
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                // ✅ البريد والهاتف في صف واحد
                Row(
                  children: [
                    Icon(
                      Icons.email_rounded,
                      size: 10,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 2),
                    Expanded(
                      child: Text(
                        student['email'],
                        style: TextStyle(
                          fontSize: 9,
                          color: Colors.grey.shade500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Icon(
                      Icons.phone_rounded,
                      size: 10,
                      color: Colors.grey.shade400,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      student['phone'],
                      style: TextStyle(
                        fontSize: 9,
                        color: Colors.grey.shade500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ✅ الحالة والمعدل (مضغوط)
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  student['status'],
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: statusColor,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.amber.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  'GPA: ${student['gpa']}',
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w600,
                    color: Colors.amber.shade700,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.people_outline_rounded,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'لا يوجد طلاب مسجلين'
                  : 'لا توجد نتائج مطابقة',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'سيظهر الطلاب المسجلين هنا'
                  : 'جرب تغيير كلمات البحث',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        // TODO: إضافة طالب جديد
      },
      backgroundColor: AppTheme.primary,
      child: const Icon(
        Icons.add_rounded,
        color: Colors.white,
      ),
    );
  }
}