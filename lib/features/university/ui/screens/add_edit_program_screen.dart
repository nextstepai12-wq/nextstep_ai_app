import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';

class AddEditProgramScreen extends StatefulWidget {
  final Map<String, dynamic>? programData;
  final bool isEditing;

  const AddEditProgramScreen({
    super.key,
    this.programData,
    this.isEditing = false,
  });

  @override
  State<AddEditProgramScreen> createState() => _AddEditProgramScreenState();
}

class _AddEditProgramScreenState extends State<AddEditProgramScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _minScoreController = TextEditingController();
  final _feeController = TextEditingController();
  final _creditHoursController = TextEditingController();

  String? _selectedFaculty;
  String? _selectedType;
  bool _isActive = true;

  final List<Map<String, dynamic>> _faculties = [
    {'id': 1, 'name': 'كلية الهندسة وتكنولوجيا المعلومات'},
    {'id': 2, 'name': 'كلية العلوم الإدارية والمالية'},
    {'id': 3, 'name': 'كلية الآداب والعلوم الإنسانية'},
    {'id': 4, 'name': 'كلية العلوم الصحية'},
  ];

  final List<String> _programTypes = [
    'بكالوريوس',
    'ماجستير',
    'دكتوراه',
    'دبلوم',
  ];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    if (widget.isEditing && widget.programData != null) {
      final data = widget.programData!;
      _nameController.text = data['name'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _minScoreController.text = data['minScore']?.toString() ?? '';
      _feeController.text = data['fee']?.toString() ?? '';
      _creditHoursController.text = data['creditHours']?.toString() ?? '';
      _selectedFaculty = data['facultyId']?.toString();
      _selectedType = data['type'];
      _isActive = data['isActive'] ?? true;
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _minScoreController.dispose();
    _feeController.dispose();
    _creditHoursController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveProgram() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        _showSnackBar(
          widget.isEditing
              ? 'تم تعديل التخصص بنجاح ✅'
              : 'تم إضافة التخصص بنجاح ✅',
        );
        Navigator.pop(context);
      }
    } catch (e) {
      _showSnackBar('حدث خطأ أثناء الحفظ', isSuccess: false);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor:
              isSuccess ? const Color(0xFF22C55E) : const Color(0xFFDC2626),
          content: Row(
            children: [
              Icon(
                isSuccess
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _buildAppBar(),
        body: FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 24),
                    _buildBasicInfo(),
                    const SizedBox(height: 16),
                    _buildAcademicInfo(),
                    const SizedBox(height: 16),
                    _buildAdditionalInfo(),
                    const SizedBox(height: 24),
                    _buildSaveButton(),
                  ],
                ),
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
      title: Text(
        widget.isEditing ? 'تعديل تخصص' : 'إضافة تخصص جديد',
        style: const TextStyle(
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
                Text(
                  widget.isEditing ? 'تعديل التخصص' : 'تخصص جديد',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isEditing
                      ? 'قم بتحديث معلومات التخصص'
                      : 'أضف تخصصاً جديداً للجامعة',
                  style: const TextStyle(
                    fontSize: 20,
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
                Icons.school_rounded,
                size: 24,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfo() {
    return _buildCard(
      title: 'المعلومات الأساسية',
      icon: Icons.info_rounded,
      color: const Color(0xFF3B82F6),
      children: [
        _buildTextField(
          controller: _nameController,
          label: 'اسم التخصص',
          hint: 'أدخل اسم التخصص',
          icon: Icons.school_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال اسم التخصص';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          label: 'الكلية',
          value: _selectedFaculty,
          items: _faculties.map((f) => f['name'] as String).toList(),
          icon: Icons.business_rounded,
          onChanged: (value) {
            setState(() {
              _selectedFaculty = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء اختيار الكلية';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildDropdownField(
          label: 'نوع التخصص',
          value: _selectedType,
          items: _programTypes,
          icon: Icons.category_rounded,
          onChanged: (value) {
            setState(() {
              _selectedType = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء اختيار نوع التخصص';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _descriptionController,
          label: 'الوصف',
          hint: 'وصف التخصص...',
          icon: Icons.description_rounded,
          maxLines: 3,
        ),
      ],
    );
  }

  Widget _buildAcademicInfo() {
    return _buildCard(
      title: 'المعلومات الأكاديمية',
      icon: Icons.grade_rounded,
      color: const Color(0xFF22C55E),
      children: [
        _buildTextField(
          controller: _minScoreController,
          label: 'الحد الأدنى (%)',
          hint: '85.0',
          icon: Icons.trending_up_rounded,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال الحد الأدنى';
            }
            final score = double.tryParse(value);
            if (score == null || score < 50 || score > 100) {
              return 'الحد الأدنى بين 50 و 100';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _feeController,
          label: 'رسوم الساعة (₪)',
          hint: '120.0',
          icon: Icons.attach_money_rounded,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال رسوم الساعة';
            }
            final fee = double.tryParse(value);
            if (fee == null || fee < 0) {
              return 'الرجاء إدخال قيمة صحيحة';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _creditHoursController,
          label: 'إجمالي الساعات',
          hint: '132',
          icon: Icons.timer_rounded,
          keyboardType: TextInputType.number,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال إجمالي الساعات';
            }
            final hours = int.tryParse(value);
            if (hours == null || hours < 0) {
              return 'الرجاء إدخال قيمة صحيحة';
            }
            return null;
          },
        ),
      ],
    );
  }
Widget _buildAdditionalInfo() {
  return _buildCard(
    title: 'معلومات إضافية',
    icon: Icons.settings_rounded,
    color: const Color(0xFFA855F7),
    children: [
      SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: const Text(
          'التخصص نشط',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryContainer,
          ),
        ),
        subtitle: Text(
          'عرض التخصص للطلاب',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade500,
          ),
        ),
        value: _isActive,
        onChanged: (value) {
          setState(() {
            _isActive = value;
          });
        },
        activeColor: AppTheme.primary,
      ),
    ],
  );
}
  Widget _buildCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
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
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          maxLines: maxLines,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.primaryContainer,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
            prefixIcon: Icon(icon, color: AppTheme.onSurfaceVariant, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required IconData icon,
    required ValueChanged<String?> onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.onSurfaceVariant, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveProgram,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 4,
          shadowColor: AppTheme.primary.withValues(alpha: 0.3),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.isEditing
                        ? Icons.save_rounded
                        : Icons.add_rounded,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    widget.isEditing ? 'حفظ التغييرات' : 'إضافة التخصص',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}
