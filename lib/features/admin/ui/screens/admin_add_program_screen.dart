import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/helpers/hive_storage.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/features/admin/data/models/program_model.dart';
import 'package:nextstep_ai_app/features/admin/data/repos/program_repository.dart';
import 'package:nextstep_ai_app/core/networking/supabase_service.dart';

class AdminAddProgramScreen extends StatefulWidget {
  final bool isEditing;
  final ProgramModel? programData;

  const AdminAddProgramScreen({
    super.key,
    this.isEditing = false,
    this.programData,
  });

  @override
  State<AdminAddProgramScreen> createState() => _AdminAddProgramScreenState();
}

class _AdminAddProgramScreenState extends State<AdminAddProgramScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();

  String? _selectedUniversityId;
  String _selectedType = 'بكالوريوس';
  bool _isLoading = true;
  bool _isSubmitting = false;
  bool _isActive = true;

  final Map<String, double> _dimensions = {
    'programming': 50.0,
    'math': 50.0,
    'communication': 50.0,
    'research': 50.0,
    'practical': 50.0,
    'management': 50.0,
  };

  List<Map<String, dynamic>> _universities = [];
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUniversities();

    if (widget.isEditing && widget.programData != null) {
      _populateFields(widget.programData!);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    super.dispose();
  }

Future<void> _loadUniversities() async {
  try {
    if (!mounted) return;
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final cached = await HiveStorage.getData('universities_cache', 'universities');

    if (cached != null && (cached as List).isNotEmpty) {
      if (mounted) {
        setState(() {
          _universities = List<Map<String, dynamic>>.from(cached);
          _isLoading = false;
        });
      }
      return;
    }

    final supabase = SupabaseService();
    final response = await supabase.client
        .from('universities')
        .select('id, name, status')
        .eq('status', 'active');

    if (response != null && response.isNotEmpty) {
      final data = List<Map<String, dynamic>>.from(response);
      await HiveStorage.saveData('universities_cache', 'universities', data);

      if (mounted) {
        setState(() {
          _universities = data;
          _isLoading = false;
        });
      }
    } else {
      if (mounted) {
        setState(() {
          _errorMessage = 'لا توجد جامعات نشطة';
          _isLoading = false;
        });
      }
    }
  } catch (e) {
    if (mounted) {
      setState(() {
        _errorMessage = 'فشل تحميل الجامعات: ${e.toString()}';
        _isLoading = false;
      });
    }
  }
}

  void _populateFields(ProgramModel program) {
    _nameController.text = program.name;
    _descriptionController.text = program.description;
    _durationController.text = program.duration.toString();
    _selectedUniversityId = program.universityId;
    _selectedType = program.type;
    _isActive = program.isActive;

    if (program.dimensions != null) {
      _dimensions['programming'] = program.dimensions!['programming'] ?? 50.0;
      _dimensions['math'] = program.dimensions!['math'] ?? 50.0;
      _dimensions['communication'] = program.dimensions!['communication'] ?? 50.0;
      _dimensions['research'] = program.dimensions!['research'] ?? 50.0;
      _dimensions['practical'] = program.dimensions!['practical'] ?? 50.0;
      _dimensions['management'] = program.dimensions!['management'] ?? 50.0;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUniversityId == null) {
      _showSnackBar('الرجاء اختيار الجامعة', Colors.orange);
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final program = ProgramModel(
        id: widget.isEditing
            ? widget.programData!.id
            : DateTime.now().millisecondsSinceEpoch.toString(),
        name: _nameController.text.trim(),
        description: _descriptionController.text.trim(),
        type: _selectedType,
        duration: int.parse(_durationController.text.trim()),
        universityId: _selectedUniversityId!,
        isActive: _isActive,
        dimensions: _dimensions,
        createdAt:
            widget.isEditing ? widget.programData!.createdAt : DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final repository = ProgramRepository();

      if (widget.isEditing) {
        await repository.updateProgram(program);
        if (mounted) {
          _showSnackBar('✅ تم تحديث التخصص بنجاح', Colors.green);
        }
      } else {
        await repository.createProgram(program);
        if (mounted) {
          _showSnackBar('✅ تم إضافة التخصص بنجاح', Colors.green);
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('❌ خطأ: ${e.toString()}', Colors.red);
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
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
            : _errorMessage != null
                ? _buildErrorState()
                : CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      _buildSliverHeader(),
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildStatusSelector(),
                                const SizedBox(height: 22),
                                _buildFormCard(),
                                const SizedBox(height: 28),
                                _buildSubmitButton(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
      ),
    );
  }

  Widget _buildSliverHeader() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF8B5CF6),
      expandedHeight: 150,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(right: 56, bottom: 16),
        title: Text(
          widget.isEditing ? 'تعديل التخصص' : 'إضافة تخصص جديد',
          style: const TextStyle(
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
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: EdgeInsets.only(left: 20, bottom: 14),
              child: _HeaderIcon(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatusSelector() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isActive = true),
            child: _buildStatusCard('نشط', true, const Color(0xFF22C55E)),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: GestureDetector(
            onTap: () => setState(() => _isActive = false),
            child: _buildStatusCard('غير نشط', false, const Color(0xFFDC2626)),
          ),
        ),
      ],
    );
  }

  Widget _buildStatusCard(String label, bool value, Color color) {
    final isSelected = _isActive == value;
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: isSelected ? color.withValues(alpha: 0.1) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? color : Colors.grey.shade200,
          width: isSelected ? 1.8 : 1.2,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: color.withValues(alpha: 0.18),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ]
            : [],
      ),
      child: Center(
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? color : Colors.grey.shade500,
          ),
        ),
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildTextField(
            controller: _nameController,
            label: 'اسم التخصص',
            hint: 'مثال: علم البيانات والذكاء الاصطناعي',
            icon: Icons.school_rounded,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'الرجاء إدخال اسم التخصص' : null,
          ),
          const SizedBox(height: 16),
          _buildTextField(
            controller: _descriptionController,
            label: 'وصف التخصص',
            hint: 'وصف مختصر عن التخصص ومجالاته',
            icon: Icons.description_rounded,
            maxLines: 3,
            validator: (v) =>
                (v == null || v.isEmpty) ? 'الرجاء إدخال وصف التخصص' : null,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'نوع التخصص',
                  value: _selectedType,
                  items: const ['بكالوريوس', 'ماجستير', 'دكتوراه', 'دبلوم'],
                  onChanged: (value) => setState(() => _selectedType = value!),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildTextField(
                  controller: _durationController,
                  label: 'المدة (بالسنوات)',
                  hint: '4',
                  icon: Icons.timer_rounded,
                  keyboardType: TextInputType.number,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'الرجاء إدخال المدة';
                    if (int.tryParse(v) == null) return 'الرجاء إدخال رقم صحيح';
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildUniversityDropdown(),
          const SizedBox(height: 16),
          _buildDimensionsSection(),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    int maxLines = 1,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12.5,
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
          style: const TextStyle(fontSize: 14, color: AppTheme.primaryContainer),
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
            filled: true,
            fillColor: const Color(0xFFF7F8FB),
            prefixIcon: Icon(icon, color: AppTheme.onSurfaceVariant, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFECEDF3), width: 1.4),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 1.8),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.6),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          ),
        ),
      ],
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
          style: const TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFECEDF3), width: 1.4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down_rounded,
                  color: AppTheme.primaryContainer),
              items: items.map((item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(item,
                      style: const TextStyle(
                          fontSize: 14, color: AppTheme.primaryContainer)),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUniversityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الجامعة',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            color: const Color(0xFFF7F8FB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
                color: _selectedUniversityId == null
                    ? const Color(0xFFECEDF3)
                    : const Color(0xFF22C55E),
                width: 1.4),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedUniversityId,
              hint: const Text('اختر الجامعة',
                  style: TextStyle(color: Colors.grey, fontSize: 14)),
              isExpanded: true,
              icon: const Icon(Icons.business_rounded,
                  color: AppTheme.primaryContainer),
              items: [
                ..._universities.map((uni) {
                  return DropdownMenuItem<String>(
                    value: uni['id'],
                    child: Row(
                      children: [
                        Text(uni['name'],
                            style: const TextStyle(
                                fontSize: 14,
                                color: AppTheme.primaryContainer)),
                        const SizedBox(width: 8),
                        if (uni['status'] == 'pending')
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Text('قيد الانتظار',
                                style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.orange)),
                          ),
                      ],
                    ),
                  );
                }),
              ],
              onChanged: (value) => setState(() => _selectedUniversityId = value),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDimensionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'الأبعاد الستة للتخصص (Weighted Matching)',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'تحدد هذه الأبعاد ملف التخصص للمقارنة مع الطالب',
          style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
        ),
        const SizedBox(height: 12),
        ..._dimensions.keys.map((key) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        ProgramModel.getDimensionName(key),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primaryContainer,
                        ),
                      ),
                      Text(
                        '${_dimensions[key]!.round()}%',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF8B5CF6),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Slider(
                    value: _dimensions[key]!,
                    min: 0,
                    max: 100,
                    divisions: 20,
                    activeColor: const Color(0xFF8B5CF6),
                    inactiveColor: Colors.grey.shade200,
                    label: '${_dimensions[key]!.round()}%',
                    onChanged: (value) => setState(() {
                      _dimensions[key] = value;
                    }),
                  ),
                ],
              ),
            )),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF8B5CF6),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF8B5CF6).withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.check_circle_outline_rounded, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    widget.isEditing ? 'حفظ التعديلات' : 'إضافة التخصص',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }

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
              onPressed: _loadUniversities,
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

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: color,
          content: Text(message,
              style: const TextStyle(color: Colors.white, fontSize: 13)),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}

class _HeaderIcon extends StatelessWidget {
  const _HeaderIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(Icons.school_rounded, color: Colors.white, size: 22),
    );
  }
}
