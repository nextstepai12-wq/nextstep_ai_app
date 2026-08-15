import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';

class AdminUniversitiesScreen extends StatefulWidget {
  const AdminUniversitiesScreen({super.key});

  @override
  State<AdminUniversitiesScreen> createState() =>
      _AdminUniversitiesScreenState();
}

class _AdminUniversitiesScreenState extends State<AdminUniversitiesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'الكل';

  final List<String> _filterOptions = ['الكل', 'نشط', 'قيد الانتظار', 'محظور'];

  // بيانات الجامعات الوهمية (تُستبدل لاحقًا باستدعاء فعلي من Supabase)
  final List<Map<String, dynamic>> _universities = [
    {
      'id': 1,
      'name': 'الجامعة الإسلامية',
      'location': 'غزة، فلسطين',
      'students_count': 1250,
      'programs_count': 24,
      'status': 'نشط',
      'created_at': '2026-08-01',
      'email': 'info@iugaza.edu',
      'phone': '+970 8 1234567',
      'website': 'https://iugaza.edu.ps',
    },
    {
      'id': 2,
      'name': 'جامعة الأزهر',
      'location': 'غزة، فلسطين',
      'students_count': 980,
      'programs_count': 18,
      'status': 'نشط',
      'created_at': '2026-08-03',
      'email': 'info@azhar.edu',
      'phone': '+970 8 2345678',
      'website': 'https://azhar.edu',
    },
    {
      'id': 3,
      'name': 'جامعة القدس',
      'location': 'القدس، فلسطين',
      'students_count': 2100,
      'programs_count': 32,
      'status': 'قيد الانتظار',
      'created_at': '2026-08-05',
      'email': 'info@quds.edu',
      'phone': '+970 2 3456789',
      'website': 'https://quds.edu',
    },
    {
      'id': 4,
      'name': 'جامعة الأقصى',
      'location': 'غزة، فلسطين',
      'students_count': 750,
      'programs_count': 12,
      'status': 'نشط',
      'created_at': '2026-08-07',
      'email': 'info@aqsa.edu',
      'phone': '+970 8 4567890',
      'website': 'https://aqsa.edu',
    },
    {
      'id': 5,
      'name': 'جامعة بيرزيت',
      'location': 'رام الله، فلسطين',
      'students_count': 1800,
      'programs_count': 28,
      'status': 'قيد الانتظار',
      'created_at': '2026-08-09',
      'email': 'info@birzeit.edu',
      'phone': '+970 2 5678901',
      'website': 'https://birzeit.edu',
    },
  ];

  List<Map<String, dynamic>> get _filteredUniversities {
    var filtered = _universities;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((uni) {
        final name = (uni['name'] as String).toLowerCase();
        final location = (uni['location'] as String).toLowerCase();
        return name.contains(query) || location.contains(query);
      }).toList();
    }

    if (_selectedFilter != 'الكل') {
      filtered = filtered.where((uni) => uni['status'] == _selectedFilter).toList();
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

  // ============================================================
  //  التنقل الموحّد لصفحة إضافة جامعة (صفحة كاملة، وليست ديالوج)
  // ============================================================
  Future<void> _goToAddUniversity() async {
    final created = await Navigator.pushNamed(context, '/admin/universities/add');
    if (created == true && mounted) {
      // TODO: استدعاء دالة إعادة تحميل الجامعات من Supabase
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
                child: CircularProgressIndicator(color: Color(0xFF22C55E)),
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
                      _filteredUniversities.isEmpty
                          ? SliverFillRemaining(
                              hasScrollBody: false,
                              child: _buildEmptyState(),
                            )
                          : SliverPadding(
                              padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                              sliver: SliverList(
                                delegate: SliverChildBuilderDelegate(
                                  (context, index) =>
                                      _buildUniversityCard(_filteredUniversities[index]),
                                  childCount: _filteredUniversities.length,
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

  // ============================================================
  //  رأس متدرّج — أخضر (هوية بصرية مخصصة لقسم الجامعات)
  // ============================================================
  Widget _buildSliverHeader() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF22C55E),
      expandedHeight: 128,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_business_rounded, color: Colors.white),
          onPressed: _goToAddUniversity,
          tooltip: 'إضافة جامعة',
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(right: 56, bottom: 16),
        centerTitle: false,
        title: const Text(
          'إدارة الجامعات',
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
              colors: [Color(0xFF22C55E), Color(0xFF15803D)],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  شريط الإحصائيات السريعة
  // ============================================================
  Widget _buildStatsRow() {
    final total = _universities.length;
    final active = _universities.where((u) => u['status'] == 'نشط').length;
    final pending = _universities.where((u) => u['status'] == 'قيد الانتظار').length;

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
              icon: Icons.business_rounded,
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
              label: 'قيد الانتظار',
              value: pending.toString(),
              icon: Icons.hourglass_top_rounded,
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

  // ============================================================
  //  البحث والفلاتر
  // ============================================================
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
              hintText: 'بحث عن جامعة...',
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
                borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.8),
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
                  selectedColor: const Color(0xFF22C55E).withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF22C55E) : Colors.grey.shade700,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF22C55E) : Colors.grey.shade300,
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

  // ============================================================
  //  بطاقة جامعة
  // ============================================================
  Widget _buildUniversityCard(Map<String, dynamic> university) {
    final statusColor = switch (university['status']) {
      'نشط' => const Color(0xFF22C55E),
      'قيد الانتظار' => const Color(0xFFF97316),
      'محظور' => const Color(0xFFDC2626),
      _ => Colors.grey,
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
          onTap: () => _showUniversityDetails(university),
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
                        color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.business_rounded, size: 22, color: Color(0xFF22C55E)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            university['name'],
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
                              Icon(Icons.location_on_rounded, size: 13, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  university['location'],
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                  overflow: TextOverflow.ellipsis,
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
                            university['status'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${university['students_count']} طالب',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
                      onPressed: () => _showUniversityOptions(university),
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
                      icon: Icons.school_rounded,
                      label: '${university['programs_count']} تخصص',
                      color: const Color(0xFF3B82F6),
                    ),
                    _buildInfoChip(
                      icon: Icons.email_rounded,
                      label: university['email'],
                      color: const Color(0xFFF97316),
                    ),
                    _buildInfoChip(
                      icon: Icons.phone_rounded,
                      label: university['phone'],
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
            Icon(Icons.business_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'لا توجد جامعات' : 'لا توجد نتائج مطابقة',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'أضف جامعة جديدة باستخدام زر الإضافة'
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
      onPressed: _goToAddUniversity,
      backgroundColor: const Color(0xFF22C55E),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'إضافة جامعة',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }

  // ============================================================
  //  خيارات الجامعة (Bottom Sheet)
  // ============================================================
  void _showUniversityOptions(Map<String, dynamic> university) {
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
                color: const Color(0xFF22C55E),
                onTap: () {
                  Navigator.pop(context);
                  _showUniversityDetails(university);
                },
              ),
              _buildOptionTile(
                icon: Icons.edit_rounded,
                title: 'تعديل',
                color: const Color(0xFF3B82F6),
                onTap: () async {
                  Navigator.pop(context);
                  final updated = await Navigator.pushNamed(
                    context,
                    '/admin/universities/edit',
                    arguments: university,
                  );
                  if (updated == true) _showSnackBar('تم تحديث بيانات الجامعة');
                },
              ),
              _buildOptionTile(
                icon: Icons.delete_rounded,
                title: 'حذف',
                color: const Color(0xFFDC2626),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(university);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showUniversityDetails(Map<String, dynamic> university) {
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
                      color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.business_rounded, size: 28, color: Color(0xFF22C55E)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          university['name'],
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryContainer,
                          ),
                        ),
                        Text(
                          university['location'],
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('البريد الإلكتروني', university['email']),
              _buildDetailRow('رقم الهاتف', university['phone']),
              _buildDetailRow('الموقع الإلكتروني', university['website'] ?? '-'),
              _buildDetailRow('عدد الطلاب', university['students_count'].toString()),
              _buildDetailRow('عدد التخصصات', university['programs_count'].toString()),
              _buildDetailRow('الحالة', university['status']),
              _buildDetailRow('تاريخ الإنشاء', university['created_at']),
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
                      onPressed: () async {
                        Navigator.pop(context);
                        final updated = await Navigator.pushNamed(
                          context,
                          '/admin/universities/edit',
                          arguments: university,
                        );
                        if (updated == true) _showSnackBar('تم تحديث بيانات الجامعة');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
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

  void _showDeleteDialog(Map<String, dynamic> university) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف الجامعة'),
        content: Text('هل أنت متأكد من رغبتك في حذف ${university['name']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('تم حذف الجامعة بنجاح');
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