import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/features/admin/data/models/program_model.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_add_program_screen.dart';

class AdminProgramsScreen extends StatefulWidget {
  const AdminProgramsScreen({super.key});

  @override
  State<AdminProgramsScreen> createState() => _AdminProgramsScreenState();
}

class _AdminProgramsScreenState extends State<AdminProgramsScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'الكل';

  final List<String> _filterOptions = ['الكل', 'نشط', 'غير نشط'];

  final List<Map<String, dynamic>> _programs = [
    {
      'id': 1,
      'name': 'هندسة الحاسوب',
      'university': 'الجامعة الإسلامية',
      'faculty': 'كلية الهندسة',
      'type': 'بكالوريوس',
      'status': 'نشط',
      'students_count': 120,
      'created_at': '2026-08-01',
      'description': 'تخصص يهتم بتصميم وتطوير أنظمة الحاسوب',
    },
    {
      'id': 2,
      'name': 'الذكاء الاصطناعي',
      'university': 'الجامعة الإسلامية',
      'faculty': 'كلية الهندسة',
      'type': 'بكالوريوس',
      'status': 'نشط',
      'students_count': 85,
      'created_at': '2026-08-03',
      'description': 'تخصص يهتم بتطوير أنظمة ذكية',
    },
    {
      'id': 3,
      'name': 'علوم البيانات',
      'university': 'جامعة الأزهر',
      'faculty': 'كلية العلوم',
      'type': 'ماجستير',
      'status': 'نشط',
      'students_count': 45,
      'created_at': '2026-08-05',
      'description': 'تخصص يهتم بتحليل البيانات الضخمة',
    },
    {
      'id': 4,
      'name': 'الأمن السيبراني',
      'university': 'جامعة القدس',
      'faculty': 'كلية تكنولوجيا المعلومات',
      'type': 'بكالوريوس',
      'status': 'قيد الانتظار',
      'students_count': 0,
      'created_at': '2026-08-07',
      'description': 'تخصص يهتم بأمن المعلومات',
    },
    {
      'id': 5,
      'name': 'الهندسة الطبية',
      'university': 'جامعة الأقصى',
      'faculty': 'كلية الهندسة',
      'type': 'بكالوريوس',
      'status': 'نشط',
      'students_count': 60,
      'created_at': '2026-08-09',
      'description': 'تخصص يدمج بين الهندسة والطب',
    },
    {
      'id': 6,
      'name': 'إدارة الأعمال',
      'university': 'جامعة بيرزيت',
      'faculty': 'كلية الإدارة',
      'type': 'بكالوريوس',
      'status': 'غير نشط',
      'students_count': 30,
      'created_at': '2026-08-11',
      'description': 'تخصص يهتم بإدارة المؤسسات',
    },
  ];

  List<Map<String, dynamic>> get _filteredPrograms {
    var filtered = _programs;

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((prog) {
        return prog['name'].contains(_searchQuery) ||
            prog['university'].contains(_searchQuery);
      }).toList();
    }

    if (_selectedFilter != 'الكل') {
      filtered = filtered
          .where((prog) => prog['status'] == _selectedFilter)
          .toList();
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

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => _isLoading = false);
        _animationController.forward();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _goToAddProgram() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminAddProgramScreen(),
      ),
    );

    if (result == true && mounted) {
      _showSnackBar('✅ تم إضافة التخصص بنجاح');
    }
  }

  Future<void> _goToEditProgram(Map<String, dynamic> program) async {
    final programData = ProgramModel(
      id: program['id'].toString(),
      name: program['name'],
      description: program['description'],
      type: program['type'],
      duration: 4,
      universityId: program['university_id'] ?? '1',
      isActive: program['status'] == 'نشط',
      dimensions: null,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminAddProgramScreen(
          isEditing: true,
          programData: programData,
        ),
      ),
    );

    if (result == true && mounted) {
      _showSnackBar('✅ تم تحديث بيانات التخصص');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildSliverHeader(),
                      SliverToBoxAdapter(child: _buildStatsRow()),
                      SliverToBoxAdapter(child: _buildSearchAndFilter()),
                      _filteredPrograms.isEmpty
                          ? SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmptyState(),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) =>
                                      _buildProgramCard(_filteredPrograms[index]),
                                  childCount: _filteredPrograms.length,
                                ),
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

  Widget _buildSliverHeader() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF8B5CF6),
      expandedHeight: 128,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_rounded, color: Colors.white),
          onPressed: _goToAddProgram,
          tooltip: 'إضافة تخصص',
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(right: 56, bottom: 16),
        centerTitle: false,
        title: const Text(
          'إدارة التخصصات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        background: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow() {
    final total = _programs.length;
    final active = _programs.where((p) => p['status'] == 'نشط').length;
    final inactive = _programs.where((p) => p['status'] == 'غير نشط').length;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 14),
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
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              label: 'الإجمالي',
              value: total.toString(),
              icon: Icons.school_rounded,
              color: const Color(0xFF3B82F6),
            ),
          ),
          Container(width: 1, height: 32, color: Colors.grey.shade200),
          Expanded(
            child: _buildStatItem(
              label: 'نشط',
              value: active.toString(),
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF22C55E),
            ),
          ),
          Container(width: 1, height: 32, color: Colors.grey.shade200),
          Expanded(
            child: _buildStatItem(
              label: 'غير نشط',
              value: inactive.toString(),
              icon: Icons.cancel_rounded,
              color: const Color(0xFFDC2626),
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
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'بحث عن تخصص...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
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
                  selectedColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade700,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade300,
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgramCard(Map<String, dynamic> program) {
    final statusColor = switch (program['status']) {
      'نشط' => const Color(0xFF22C55E),
      'غير نشط' => const Color(0xFFDC2626),
      _ => const Color(0xFFF97316),
    };

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
          onTap: () => _showProgramDetails(program),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.school_rounded, size: 22, color: Color(0xFF8B5CF6)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            program['name'],
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryContainer,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Text(
                                program['university'],
                                style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF97316).withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  program['type'],
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFF97316),
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
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            program['status'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${program['students_count']} طالب',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
                      onPressed: () => _showProgramOptions(program),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildInfoChip(
                      icon: Icons.business_rounded,
                      label: program['faculty'],
                      color: const Color(0xFF3B82F6),
                    ),
                    _buildInfoChip(
                      icon: Icons.calendar_today_rounded,
                      label: program['created_at'],
                      color: const Color(0xFFF97316),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  program['description'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
              overflow: TextOverflow.ellipsis,
            ),
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
            Icon(Icons.school_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'لا توجد تخصصات' : 'لا توجد نتائج مطابقة',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'أضف تخصص جديد باستخدام زر الإضافة'
                  : 'جرب تغيير كلمات البحث',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _goToAddProgram,
      backgroundColor: const Color(0xFF8B5CF6),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'إضافة تخصص',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }

  void _showProgramOptions(Map<String, dynamic> program) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile(
                icon: Icons.remove_red_eye_rounded,
                title: 'عرض التفاصيل',
                color: const Color(0xFF8B5CF6),
                onTap: () {
                  Navigator.pop(context);
                  _showProgramDetails(program);
                },
              ),
              _buildOptionTile(
                icon: Icons.edit_rounded,
                title: 'تعديل',
                color: const Color(0xFF3B82F6),
                onTap: () {
                  Navigator.pop(context);
                  _goToEditProgram(program);
                },
              ),
              _buildOptionTile(
                icon: Icons.delete_rounded,
                title: 'حذف',
                color: const Color(0xFFDC2626),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(program);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showProgramDetails(Map<String, dynamic> program) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.school_rounded, size: 28, color: Color(0xFF8B5CF6)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          program['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryContainer,
                          ),
                        ),
                        Text(
                          program['university'],
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('النوع', program['type']),
              _buildDetailRow('الكلية', program['faculty']),
              _buildDetailRow('عدد الطلاب', program['students_count'].toString()),
              _buildDetailRow('الحالة', program['status']),
              _buildDetailRow('تاريخ الإنشاء', program['created_at']),
              _buildDetailRow('الوصف', program['description']),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryContainer,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('إغلاق'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _goToEditProgram(program);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8B5CF6),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('تعديل'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryContainer,
            ),
          ),
          Expanded(
            child: Text(value, style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> program) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف التخصص'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من رغبتك في حذف:'),
            const SizedBox(height: 8),
            Text(
              '${program['name']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'هذا الإجراء لا يمكن التراجع عنه',
              style: TextStyle(color: Colors.red.shade300, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('✅ تم حذف التخصص بنجاح');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('حذف'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: const Color(0xFF22C55E),
          content: Row(
            children: [
              const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
        ),
      );
  }
}
