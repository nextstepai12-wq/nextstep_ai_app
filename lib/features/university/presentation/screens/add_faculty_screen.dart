import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';

class AddFacultyScreen extends StatefulWidget {
  final Map<String, dynamic>? facultyData;
  final bool isEditing;

  const AddFacultyScreen({
    super.key,
    this.facultyData,
    this.isEditing = false,
  });

  @override
  State<AddFacultyScreen> createState() => _AddFacultyScreenState();
}

class _AddFacultyScreenState extends State<AddFacultyScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _isActive = true;

  final _nameController = TextEditingController();
  final _deanController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _visionController = TextEditingController();
  final _missionController = TextEditingController();

  String? _selectedType;
  String? _selectedBuilding;
  String? _selectedFloor;

  final List<String> _facultyTypes = [
    'كلية',
    'عمادة',
    'معهد',
    'مركز',
  ];

  final List<String> _buildings = [
    'المبنى الرئيسي',
    'المبنى الغربي',
    'المبنى الشرقي',
    'مبنى العلوم',
    'مبنى الهندسة',
  ];

  final List<String> _floors = [
    'الطابق الأرضي',
    'الطابق الأول',
    'الطابق الثاني',
    'الطابق الثالث',
    'الطابق الرابع',
    'الطابق الخامس',
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

    if (widget.isEditing && widget.facultyData != null) {
      final data = widget.facultyData!;
      _nameController.text = data['name'] ?? '';
      _deanController.text = data['dean'] ?? '';
      _emailController.text = data['email'] ?? '';
      _phoneController.text = data['phone'] ?? '';
      _descriptionController.text = data['description'] ?? '';
      _visionController.text = data['vision'] ?? '';
      _missionController.text = data['mission'] ?? '';
      _selectedType = data['type'];
      _selectedBuilding = data['building'];
      _selectedFloor = data['floor'];
      _isActive = data['isActive'] ?? true;
    }

    _animationController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _deanController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _descriptionController.dispose();
    _visionController.dispose();
    _missionController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _saveFaculty() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      await Future.delayed(const Duration(seconds: 1));

      if (mounted) {
        _showSnackBar(
          widget.isEditing
              ? 'تم تعديل الكلية بنجاح ✅'
              : 'تم إضافة الكلية بنجاح ✅',
        );
        Navigator.pop(context, true);
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
                    _buildContactInfo(),
                    const SizedBox(height: 16),
                    _buildVisionMission(),
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
        widget.isEditing ? 'تعديل الكلية' : 'إضافة كلية جديدة',
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
      padding: const EdgeInsets.all(24),
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
                  widget.isEditing ? 'تعديل الكلية' : 'كلية جديدة',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.isEditing
                      ? 'قم بتحديث معلومات الكلية'
                      : 'أضف كلية جديدة للجامعة',
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
                Icons.business_rounded,
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
        label: 'اسم الكلية',
        hint: 'أدخل اسم الكلية',
        icon: Icons.business_rounded,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء إدخال اسم الكلية';
          }
          return null;
        },
      ),
      const SizedBox(height: 12),
      _buildDropdownField(
        label: 'نوع الكلية',
        value: _selectedType,
        items: _facultyTypes,
        icon: Icons.category_rounded,
        onChanged: (value) {
          setState(() {
            _selectedType = value;
          });
        },
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'الرجاء اختيار نوع الكلية';
          }
          return null;
        },
      ),
      const SizedBox(height: 12),
      // ✅ إصلاح Row - استخدام Flexible بدلاً من Expanded
      Row(
        children: [
          Flexible(
            flex: 1,
            child: _buildDropdownField(
              label: 'المبنى',
              value: _selectedBuilding,
              items: _buildings,
              icon: Icons.location_city_rounded,
              onChanged: (value) {
                setState(() {
                  _selectedBuilding = value;
                });
              },
            ),
          ),
          const SizedBox(width: 12),
          Flexible(
            flex: 1,
            child: _buildDropdownField(
              label: 'الطابق',
              value: _selectedFloor,
              items: _floors,
              icon: Icons.height_rounded,
              onChanged: (value) {
                setState(() {
                  _selectedFloor = value;
                });
              },
            ),
          ),
        ],
      ),
    ],
  );
}

  Widget _buildContactInfo() {
    return _buildCard(
      title: 'معلومات الاتصال',
      icon: Icons.contact_phone_rounded,
      color: const Color(0xFF22C55E),
      children: [
        _buildTextField(
          controller: _deanController,
          label: 'اسم العميد',
          hint: 'أدخل اسم العميد',
          icon: Icons.person_rounded,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال اسم العميد';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _emailController,
          label: 'البريد الإلكتروني',
          hint: 'dean@university.edu',
          icon: Icons.email_rounded,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال البريد الإلكتروني';
            }
            if (!value.contains('@') || !value.contains('.')) {
              return 'الرجاء إدخال بريد إلكتروني صحيح';
            }
            return null;
          },
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _phoneController,
          label: 'رقم الهاتف',
          hint: '+970 8 1234567',
          icon: Icons.phone_rounded,
          keyboardType: TextInputType.phone,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال رقم الهاتف';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildVisionMission() {
    return _buildCard(
      title: 'الرؤية والرسالة',
      icon: Icons.visibility_rounded,
      color: const Color(0xFF8B5CF6),
      children: [
        _buildTextField(
          controller: _visionController,
          label: 'الرؤية',
          hint: 'رؤية الكلية...',
          icon: Icons.visibility_rounded,
          maxLines: 2,
        ),
        const SizedBox(height: 12),
        _buildTextField(
          controller: _missionController,
          label: 'الرسالة',
          hint: 'رسالة الكلية...',
          icon: Icons.flag_rounded,
          maxLines: 2,
        ),
      ],
    );
  }

  // ✅ إصلاح قسم المعلومات الإضافية
  Widget _buildAdditionalInfo() {
    return _buildCard(
      title: 'معلومات إضافية',
      icon: Icons.settings_rounded,
      color: const Color(0xFFA855F7),
      children: [
        _buildTextField(
          controller: _descriptionController,
          label: 'الوصف',
          hint: 'وصف الكلية...',
          icon: Icons.description_rounded,
          maxLines: 3,
        ),
        const SizedBox(height: 12),
        // ✅ إصلاح SwitchListTile - إضافة Material حولها
        Material(
          color: Colors.transparent,
          child: SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'الكلية نشطة',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryContainer,
              ),
            ),
            subtitle: Text( // ✅ إزالة const
              'عرض الكلية للطلاب والمستخدمين',
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
        onPressed: _isLoading ? null : _saveFaculty,
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
                    widget.isEditing ? 'حفظ التغييرات' : 'إضافة الكلية',
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