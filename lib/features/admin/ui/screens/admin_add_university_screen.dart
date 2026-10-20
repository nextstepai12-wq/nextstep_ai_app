import 'package:flutter/material.dart';

import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/widgets/app_buttons.dart';
import 'package:nextstep_ai_app/core/widgets/app_card.dart';
import 'package:nextstep_ai_app/core/widgets/app_page_header.dart';
import 'package:nextstep_ai_app/core/widgets/app_snack.dart';

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
    _StatusOption(value: 'نشط', icon: Icons.check_circle_rounded),
    _StatusOption(value: 'قيد الانتظار', icon: Icons.hourglass_top_rounded),
    _StatusOption(value: 'محظور', icon: Icons.block_rounded),
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
    ).animate(
        CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
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

    await Future.delayed(const Duration(milliseconds: 900));

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    _showResultSnackBar(
      widget.isEditing
          ? 'تم حفظ تعديلات الجامعة بنجاح'
          : 'تم إضافة الجامعة بنجاح',
    );
    Navigator.pop(context, true);
  }

  void _showResultSnackBar(String message) {
    AppSnack.success(context, message);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            AppSliverPageHeader(
              title: widget.isEditing
                  ? 'تعديل بيانات الجامعة'
                  : 'إضافة جامعة جديدة',
              subtitle: 'بيانات الجامعة وحالة الاعتماد',
              expandedHeight: 140,
            ),
            SliverToBoxAdapter(
              child: FadeTransition(
                opacity: _fadeAnim,
                child: SlideTransition(
                  position: _slideAnim,
                  child: Padding(
                    padding: context.pagePadding.copyWith(
                      top: AppSpacing.lg,
                      bottom: AppSpacing.xxl,
                    ),
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

  Widget _sectionLabel(String text) {
    return Text(
      text,
      style: context.textStyles.labelLarge?.copyWith(
        color: context.appColors.textPrimary,
        fontWeight: FontWeight.w700,
      ),
    );
  }

  Widget _buildStatusSelector() {
    final AppColors c = context.appColors;
    return Row(
      children: _statuses.map((s) {
        final isSelected = _selectedStatus == s.value;
        final Color tone = switch (s.value) {
          'محظور' => c.danger,
          'قيد الانتظار' => c.warning,
          _ => c.success,
        };
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: s == _statuses.last ? 0 : 10,
            ),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: s.value,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _selectedStatus = s.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color:
                        isSelected ? tone.withValues(alpha: 0.1) : c.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isSelected ? tone : c.divider,
                      width: isSelected ? 1.8 : 1.2,
                    ),
                    boxShadow: isSelected
                        ? <BoxShadow>[
                            BoxShadow(
                              color: c.shadow,
                              blurRadius: 16,
                              offset: const Offset(0, 6),
                            ),
                          ]
                        : const <BoxShadow>[],
                  ),
                  child: Column(
                    children: <Widget>[
                      Icon(
                        s.icon,
                        color: isSelected ? tone : c.textSecondary,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        s.value,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.labelSmall?.copyWith(
                          fontWeight: isSelected
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected ? tone : c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildFormCard() {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _fieldLabel('اسم الجامعة'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nameController,
            hint: 'مثال: الجامعة الإسلامية',
            icon: Icons.business_rounded,
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'الرجاء إدخال اسم الجامعة'
                : null,
          ),
          const SizedBox(height: 18),
          _fieldLabel('الموقع (المدينة/الدولة)'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _locationController,
            hint: 'مثال: غزة، فلسطين',
            icon: Icons.location_on_outlined,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'الرجاء إدخال الموقع' : null,
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
              if (v == null || v.isEmpty)
                return 'الرجاء إدخال البريد الإلكتروني';
              if (!v.contains('@') || !v.contains('.'))
                return 'بريد إلكتروني غير صحيح';
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
            validator: (v) => (v == null || v.trim().isEmpty)
                ? 'الرجاء إدخال رقم الهاتف'
                : null,
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
      style: context.textStyles.labelMedium?.copyWith(
        fontWeight: FontWeight.w600,
        color: context.appColors.textPrimary,
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
      style: context.textStyles.bodyMedium,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AppPrimaryButton(
      label: widget.isEditing ? 'حفظ التعديلات' : 'إضافة الجامعة',
      icon: Icons.check_circle_outline_rounded,
      loading: _isSubmitting,
      onPressed: _submit,
    );
  }
}

class _StatusOption {
  final String value;
  final IconData icon;

  const _StatusOption({required this.value, required this.icon});
}
