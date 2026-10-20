import 'package:flutter/material.dart';

import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/widgets/app_buttons.dart';
import 'package:nextstep_ai_app/core/widgets/app_card.dart';
import 'package:nextstep_ai_app/core/widgets/app_page_header.dart';
import 'package:nextstep_ai_app/core/widgets/app_snack.dart';

class AdminAddUserScreen extends StatefulWidget {
  final bool isEditing;
  final Map<String, dynamic>? userData;

  const AdminAddUserScreen({
    super.key,
    this.isEditing = false,
    this.userData,
  });

  @override
  State<AdminAddUserScreen> createState() => _AdminAddUserScreenState();
}

class _AdminAddUserScreenState extends State<AdminAddUserScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  String _selectedRole = 'student';
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _isSubmitting = false;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  static const List<_RoleOption> _roles = [
    _RoleOption(
      value: 'student',
      label: 'طالب',
      icon: Icons.school_rounded,
    ),
    _RoleOption(
      value: 'university',
      label: 'جامعة',
      icon: Icons.business_rounded,
    ),
    _RoleOption(
      value: 'admin',
      label: 'إدارة',
      icon: Icons.admin_panel_settings_rounded,
    ),
  ];

  @override
  void initState() {
    super.initState();

    if (widget.isEditing && widget.userData != null) {
      final data = widget.userData!;
      _nameController.text = (data['name'] ?? '').toString();
      _emailController.text = (data['email'] ?? '').toString();
      _selectedRole = (data['role'] ?? 'student').toString();
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
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
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
        widget.isEditing ? 'تم حفظ التعديلات بنجاح' : 'تم إنشاء الحساب بنجاح');
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
                  ? 'تعديل بيانات المستخدم'
                  : 'إضافة مستخدم جديد',
              subtitle: 'إدارة حساب المستخدم وصلاحياته',
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
                          _sectionLabel('الدور'),
                          const SizedBox(height: 10),
                          _buildRoleSelector(),
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

  Widget _buildRoleSelector() {
    final AppColors c = context.appColors;
    return Row(
      children: _roles.map((role) {
        final isSelected = _selectedRole == role.value;
        final Color roleColor = switch (role.value) {
          'university' => c.success,
          'admin' => c.purple,
          _ => c.info,
        };
        return Expanded(
          child: Padding(
            padding: EdgeInsetsDirectional.only(
              start: role == _roles.last ? 0 : 10,
            ),
            child: Semantics(
              button: true,
              selected: isSelected,
              label: role.label,
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => setState(() => _selectedRole = role.value),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? roleColor.withValues(alpha: 0.1)
                        : c.surface,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isSelected ? roleColor : c.divider,
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
                        role.icon,
                        color: isSelected ? roleColor : c.textSecondary,
                        size: 24,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        role.label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: context.textStyles.labelMedium?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected ? roleColor : c.textSecondary,
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
          _fieldLabel('الاسم الكامل'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nameController,
            hint: 'مثال: أحمد محمد',
            icon: Icons.person_outline_rounded,
            validator: (v) =>
                (v == null || v.trim().isEmpty) ? 'الرجاء إدخال الاسم' : null,
          ),
          const SizedBox(height: 18),
          _fieldLabel('البريد الإلكتروني'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _emailController,
            hint: 'user@example.com',
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
          _fieldLabel(
              widget.isEditing ? 'كلمة مرور جديدة (اختياري)' : 'كلمة المرور'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passwordController,
            hint: widget.isEditing
                ? 'اتركها فارغة للإبقاء على القديمة'
                : '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePassword,
            ltr: true,
            suffix: IconButton(
              tooltip: _obscurePassword
                  ? 'إظهار كلمة المرور'
                  : 'إخفاء كلمة المرور',
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: context.appColors.textSecondary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              if (widget.isEditing && (v == null || v.isEmpty)) return null;
              if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة المرور';
              if (v.length < 6) return 'يجب أن تكون 6 أحرف على الأقل';
              return null;
            },
          ),
          const SizedBox(height: 18),
          _fieldLabel('تأكيد كلمة المرور'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _confirmPasswordController,
            hint: '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscureConfirm,
            ltr: true,
            suffix: IconButton(
              tooltip: _obscureConfirm
                  ? 'إظهار كلمة المرور'
                  : 'إخفاء كلمة المرور',
              icon: Icon(
                _obscureConfirm
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: context.appColors.textSecondary,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: (v) {
              if (widget.isEditing && _passwordController.text.isEmpty)
                return null;
              if (v != _passwordController.text)
                return 'كلمتا المرور غير متطابقتين';
              return null;
            },
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
    bool obscure = false,
    bool ltr = false,
    Widget? suffix,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textDirection: ltr ? TextDirection.ltr : TextDirection.rtl,
      textAlign: ltr ? TextAlign.left : TextAlign.right,
      style: context.textStyles.bodyMedium,
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon, size: 20),
        suffixIcon: suffix,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  Widget _buildSubmitButton() {
    return AppPrimaryButton(
      label: widget.isEditing ? 'حفظ التعديلات' : 'إنشاء الحساب',
      icon: Icons.check_circle_outline_rounded,
      loading: _isSubmitting,
      onPressed: _submit,
    );
  }
}

class _RoleOption {
  final String value;
  final String label;
  final IconData icon;

  const _RoleOption({
    required this.value,
    required this.label,
    required this.icon,
  });
}
