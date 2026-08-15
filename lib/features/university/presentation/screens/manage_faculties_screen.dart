import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';

class ManageFacultiesScreen extends StatefulWidget {
  const ManageFacultiesScreen({super.key});

  @override
  State<ManageFacultiesScreen> createState() => _ManageFacultiesScreenState();
}

class _ManageFacultiesScreenState extends State<ManageFacultiesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  String _searchQuery = '';

  final List<Map<String, dynamic>> _faculties = [
    {
      'id': 1,
      'name': 'كلية الهندسة وتكنولوجيا المعلومات',
      'type': 'كلية',
      'programs_count': 8,
      'students_count': 850,
      'dean': 'د. أحمد الخطيب',
      'email': 'engineering@university.edu',
      'description': 'تقدم برامج متميزة في مجالات الهندسة وتكنولوجيا المعلومات',
    },
    {
      'id': 2,
      'name': 'كلية العلوم الإدارية والمالية',
      'type': 'كلية',
      'programs_count': 5,
      'students_count': 620,
      'dean': 'د. سارة الجمل',
      'email': 'business@university.edu',
      'description': 'تقدم برامج في الإدارة والمالية والمحاسبة',
    },
    {
      'id': 3,
      'name': 'كلية الآداب والعلوم الإنسانية',
      'type': 'كلية',
      'programs_count': 6,
      'students_count': 480,
      'dean': 'د. محمد السيد',
      'email': 'arts@university.edu',
      'description': 'تقدم برامج في اللغات والتاريخ والفلسفة',
    },
    {
      'id': 4,
      'name': 'كلية العلوم الصحية',
      'type': 'كلية',
      'programs_count': 4,
      'students_count': 390,
      'dean': 'د. نادية عزمي',
      'email': 'health@university.edu',
      'description': 'تقدم برامج في التمريض والصحة العامة',
    },
    {
      'id': 5,
      'name': 'عمادة البحث العلمي',
      'type': 'عمادة',
      'programs_count': 0,
      'students_count': 0,
      'dean': 'د. خالد يونس',
      'email': 'research@university.edu',
      'description': 'تهتم بدعم البحث العلمي وتشجيع الابتكار',
    },
  ];

  List<Map<String, dynamic>> get _filteredFaculties {
    if (_searchQuery.isEmpty) return _faculties;
    return _faculties
        .where((f) =>
            f['name'].contains(_searchQuery) ||
            f['type'].contains(_searchQuery) ||
            f['dean'].contains(_searchQuery))
        .toList();
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
                      _buildSearchBar(),
                      _buildStatsRow(),
                      Expanded(
                        child: _filteredFaculties.isEmpty
                            ? _buildEmptyState()
                            : ListView.builder(
                                physics: const BouncingScrollPhysics(),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 8,
                                ),
                                itemCount: _filteredFaculties.length,
                                itemBuilder: (context, index) {
                                  final faculty = _filteredFaculties[index];
                                  return _buildFacultyCard(faculty);
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
        'الكليات والأقسام',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryContainer,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.white,
      child: TextField(
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
        textDirection: TextDirection.rtl,
        textAlign: TextAlign.right,
        decoration: InputDecoration(
          hintText: 'بحث عن كلية...',
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
    );
  }

  Widget _buildStatsRow() {
    final totalStudents =
        _faculties.fold<int>(0, (sum, f) => sum + (f['students_count'] as int));
    final totalPrograms =
        _faculties.fold<int>(0, (sum, f) => sum + (f['programs_count'] as int));

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      color: Colors.white,
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              label: 'الكليات',
              value: _faculties.length.toString(),
              icon: Icons.business_rounded,
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
              label: 'التخصصات',
              value: totalPrograms.toString(),
              icon: Icons.school_rounded,
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
              label: 'الطلاب',
              value: totalStudents.toString(),
              icon: Icons.people_rounded,
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

  // ✅ إصلاح بطاقة الكلية - استخدام Wrap لتجنب Overflow
  Widget _buildFacultyCard(Map<String, dynamic> faculty) {
    final isDeanship = faculty['type'] == 'عمادة';
    final Color accentColor = isDeanship
        ? const Color(0xFFA855F7)
        : const Color(0xFF3B82F6);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isDeanship ? Icons.emoji_objects_rounded : Icons.business_rounded,
                  color: accentColor,
                  size: 22,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      faculty['name'],
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primaryContainer,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            faculty['type'],
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: accentColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          faculty['dean'],
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.grey.shade400,
                ),
                onPressed: () => _showFacultyOptions(faculty),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // ✅ استخدام Wrap بدلاً من Row لحل مشكلة Overflow
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              _buildInfoChip(
                icon: Icons.school_rounded,
                label: '${faculty['programs_count']} تخصص',
                color: const Color(0xFF3B82F6),
              ),
              _buildInfoChip(
                icon: Icons.people_rounded,
                label: '${faculty['students_count']} طالب',
                color: const Color(0xFF22C55E),
              ),
              _buildInfoChip(
                icon: Icons.email_rounded,
                label: faculty['email'],
                color: const Color(0xFFF97316),
              ),
            ],
          ),

          if (faculty['description'] != null && faculty['description'].isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                faculty['description'],
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
        ],
      ),
    );
  }

  // ✅ تحسين InfoChip
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
          Flexible(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: color,
              ),
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
            Icon(
              Icons.business_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty
                  ? 'لا توجد كليات'
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
                  ? 'أضف كلية جديدة باستخدام زر الإضافة'
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
    onPressed: () => Navigator.pushNamed(context, '/university/add-faculty'),
    backgroundColor: AppTheme.primary,
    child: const Icon(
      Icons.add_rounded,
      color: Colors.white,
    ),
  );
}

  void _showAddFacultyDialog() {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController();
    final _deanController = TextEditingController();
    final _emailController = TextEditingController();
    final _descriptionController = TextEditingController();
    String _selectedType = 'كلية';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'إضافة كلية جديدة',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryContainer,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'اسم الكلية',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم الكلية';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'النوع',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'كلية', child: Text('كلية')),
                    DropdownMenuItem(value: 'عمادة', child: Text('عمادة')),
                    DropdownMenuItem(value: 'معهد', child: Text('معهد')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _selectedType = value;
                    }
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء اختيار النوع';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _deanController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'اسم العميد',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم العميد';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال البريد الإلكتروني';
                    }
                    if (!value.contains('@')) {
                      return 'بريد إلكتروني غير صحيح';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'الوصف',
                    hintText: 'وصف الكلية...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                _showSnackBar('تم إضافة الكلية بنجاح');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('إضافة'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  void _showFacultyOptions(Map<String, dynamic> faculty) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildOptionTile(
              icon: Icons.edit_rounded,
              title: 'تعديل',
              color: AppTheme.primary,
              onTap: () {
                Navigator.pop(context);
                _showEditFacultyDialog(faculty);
              },
            ),
            _buildOptionTile(
              icon: Icons.school_rounded,
              title: 'عرض التخصصات',
              color: const Color(0xFF3B82F6),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('تم عرض التخصصات');
              },
            ),
            _buildOptionTile(
              icon: Icons.people_rounded,
              title: 'عرض الطلاب',
              color: const Color(0xFF22C55E),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('تم عرض الطلاب');
              },
            ),
            _buildOptionTile(
              icon: Icons.delete_rounded,
              title: 'حذف',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _showDeleteDialog(faculty);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showEditFacultyDialog(Map<String, dynamic> faculty) {
    final _formKey = GlobalKey<FormState>();
    final _nameController = TextEditingController(text: faculty['name']);
    final _deanController = TextEditingController(text: faculty['dean']);
    final _emailController = TextEditingController(text: faculty['email']);
    final _descriptionController =
        TextEditingController(text: faculty['description'] ?? '');
    String _selectedType = faculty['type'];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'تعديل الكلية',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryContainer,
          ),
        ),
        content: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'اسم الكلية',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'الرجاء إدخال اسم الكلية';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _selectedType,
                  decoration: InputDecoration(
                    labelText: 'النوع',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'كلية', child: Text('كلية')),
                    DropdownMenuItem(value: 'عمادة', child: Text('عمادة')),
                    DropdownMenuItem(value: 'معهد', child: Text('معهد')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      _selectedType = value;
                    }
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _deanController,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'اسم العميد',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    labelText: 'البريد الإلكتروني',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _descriptionController,
                  maxLines: 3,
                  textDirection: TextDirection.rtl,
                  decoration: InputDecoration(
                    labelText: 'الوصف',
                    hintText: 'وصف الكلية...',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                Navigator.pop(context);
                _showSnackBar('تم تعديل الكلية بنجاح');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('حفظ التغييرات'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  void _showDeleteDialog(Map<String, dynamic> faculty) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Text('حذف ${faculty['name']}'),
        content: Text('هل أنت متأكد من رغبتك في حذف ${faculty['name']}؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('تم حذف الكلية بنجاح');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
    return Material(
      color: Colors.transparent,
      child: ListTile(
        leading: Icon(icon, color: color),
        title: Text(
          title,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: onTap,
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