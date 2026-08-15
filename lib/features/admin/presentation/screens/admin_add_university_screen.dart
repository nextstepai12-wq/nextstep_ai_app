import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';

/// ============================================================
///  شاشة إضافة / تعديل جامعة — تصميم 2026
///  صفحة كاملة مستقلة (وليست ديالوج منبثق) يُنتقل إليها عبر:
///  Navigator.pushNamed(context, '/admin/universities/add')
/// ============================================================
class AdminAddUniversityScreen extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? universityData;

  const AdminAddUniversityScreen({
    super.key,
    this.isEditing = false,
    this.universityData,
  });

  @override
  State<AdminAddUniversityScreen> createState() =>
      _AdminAddUniversityScreenState();
}

class _AdminAddUniversityScreenState extends State<AdminAddUniversityScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _websiteController = TextEditingController();

  String _selectedStatus = 'نشط';
  bool _isSubmitting = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  static const List<_StatusOption> _statuses = [
    _StatusOption(value: 'نشط', icon: Icons.check_circle_rounded, color: Color(0xFF22C55E)),
    _StatusOption(value: 'قيد الانتظار', icon: Icons.hourglass_top_rounded, color: Color(0xFFF97316)),
    _StatusOption(value: 'محظور', icon: Icons.block_rounded, color: Color(0xFFDC2626)),
  ];

  @override
  void initState() {
    super.initState();

    if (widget.isEditing && widget.universityData != null) {
      final d = widget.universityData!;
      _nameController.text = (d['name'] ?? '').toString();
      _locationController.text = (d['location'] ?? '').toString();
      _emailController.text = (d['email'] ?? '').toString();
      _phoneController.text = (d['phone'] ?? '').toString();
      _websiteController.text = (d['website'] ?? '').toString();
      _selectedStatus = (d['status'] ?? 'نشط').toString();
    }

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _locationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _websiteController.dispose();
    _animController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    // TODO: اربط هنا الاستدعاء الفعلي لإنشاء/تحديث الجامعة عبر Supabase
    // مثال:
    // await UniversityService().save(
    //   name: _nameController.text.trim(),
    //   location: _locationController.text.trim(),
    //   email: _emailController.text.trim(),
    //   phone: _phoneController.text.trim(),
    //   website: _websiteController.text.trim(),
    //   status: _selectedStatus,
    //   isEditing: widget.isEditing,
    // );

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    _showResultSnackBar(
      widget.isEditing ? 'تم حفظ تعديلات الجامعة بنجاح' : 'تم إضافة الجامعة بنجاح',
    );
    Navigator.pop(context, true);
  }

  void _showResultSnackBar(String message) {
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

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverHeader(),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _sectionLabel('حالة الجامعة'),
                          const SizedBox(height: 10),
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
      backgroundColor: const Color(0xFF22C55E),
      expandedHeight: 150,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(right: 56, bottom: 16),
        title: Text(
          widget.isEditing ? 'تعديل بيانات الجامعة' : 'إضافة جامعة جديدة',
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
              colors: [Color(0xFF22C55E), Color(0xFF15803D)],
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

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: AppTheme.primaryContainer,
      ),
    );
  }

  // ============================================================
  //  محدد الحالة — بطاقات قابلة للاختيار
  // ============================================================
  Widget _buildStatusSelector() {
    return Row(
      children: _statuses.map((s) {
        final isSelected = _selectedStatus == s.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: s == _statuses.last ? 0 : 10),
            child: GestureDetector(
              onTap: () => setState(() => _selectedStatus = s.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: isSelected ? s.color.withValues(alpha: 0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? s.color : Colors.grey.shade200,
                    width: isSelected ? 1.8 : 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: s.color.withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Icon(s.icon, color: isSelected ? s.color : Colors.grey.shade400, size: 22),
                    const SizedBox(height: 6),
                    Text(
                      s.value,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? s.color : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ============================================================
  //  بطاقة الحقول
  // ============================================================
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
          _fieldLabel('اسم الجامعة'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nameController,
            hint: 'مثال: الجامعة الإسلامية',
            icon: Icons.business_rounded,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال اسم الجامعة' : null,
          ),
          const SizedBox(height: 18),
          _fieldLabel('الموقع (المدينة/الدولة)'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _locationController,
            hint: 'مثال: غزة، فلسطين',
            icon: Icons.location_on_outlined,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال الموقع' : null,
          ),
          const SizedBox(height: 18),
          _fieldLabel('البريد الإلكتروني'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailController,
            hint: 'info@university.edu',
            icon: Icons.mail_outline_rounded,
            keyboardType: TextInputType.emailAddress,
            ltr: true,
            validator: (v) {
              if (v == null || v.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
              if (!v.contains('@') || !v.contains('.')) return 'بريد إلكتروني غير صحيح';
              return null;
            },
          ),
          const SizedBox(height: 18),
          _fieldLabel('رقم الهاتف'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _phoneController,
            hint: '+970 8 1234567',
            icon: Icons.phone_outlined,
            keyboardType: TextInputType.phone,
            ltr: true,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال رقم الهاتف' : null,
          ),
          const SizedBox(height: 18),
          _fieldLabel('الموقع الإلكتروني (اختياري)'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _websiteController,
            hint: 'https://university.edu',
            icon: Icons.language_rounded,
            keyboardType: TextInputType.url,
            ltr: true,
            validator: (_) => null,
          ),
        ],
      ),
    );
  }

  Widget _fieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12.5,
        fontWeight: FontWeight.w600,
        color: AppTheme.primaryContainer,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType? keyboardType,
    bool ltr = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
      textAlign: ltr ? TextAlign.left : TextAlign.right,
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
          borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF22C55E),
          foregroundColor: Colors.white,
          disabledBackgroundColor: const Color(0xFF22C55E).withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ).copyWith(
          shadowColor: WidgetStateProperty.all(Colors.transparent),
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: _isSubmitting
              ? const SizedBox(
                  key: ValueKey('loading'),
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.4),
                )
              : Row(
                  key: const ValueKey('label'),
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_circle_outline_rounded, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      widget.isEditing ? 'حفظ التعديلات' : 'إضافة الجامعة',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
        ),
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
      child: const Icon(Icons.business_rounded, color: Colors.white, size: 22),
    );
  }
}

class _StatusOption {
  final String value;
  final IconData icon;
  final Color color;

  const _StatusOption({required this.value, required this.icon, required this.color});
}