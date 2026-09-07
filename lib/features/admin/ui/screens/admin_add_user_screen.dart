import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';

/// ============================================================
///  شاشة إضافة / تعديل مستخدم — تصميم 2026
///  صفحة كاملة مستقلة (وليست ديالوج منبثق) يُنتقل إليها عبر:
///  context.push('/admin/users/add')
///  أو في وضع التعديل:
///  Navigator.push(context, MaterialPageRoute(builder: (_) =>
///    AdminAddUserScreen(isEditing: true, userData: {...})));
/// ============================================================
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
      color: Color(0xFF3B82F6),
    ),
    _RoleOption(
      value: 'university',
      label: 'جامعة',
      icon: Icons.business_rounded,
      color: Color(0xFF22C55E),
    ),
    _RoleOption(
      value: 'admin',
      label: 'إدارة',
      icon: Icons.admin_panel_settings_rounded,
      color: Color(0xFF8B5CF6),
    ),
  ];

  @override
  void initState() {
    super.initState();

    // ✅ في وضع التعديل: تعبئة الحقول من البيانات الممرَّرة
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
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
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

    // ⚠️ ملاحظة مهمة: إنشاء مستخدم من طرف الأدمن يجب أن يمر عبر مسار آمن
    // (Supabase Edge Function أو Admin API بمفتاح service_role على السيرفر)،
    // وليس مباشرة من تطبيق العميل (Client) الذي لا يملك صلاحيات admin.
    // اربط هنا استدعاء دالتك الفعلية، مثال:
    //
    // await AdminService().createUser(
    //   fullName: _nameController.text.trim(),
    //   email: _emailController.text.trim(),
    //   password: _passwordController.text,
    //   role: _selectedRole,
    // );

    await Future.delayed(const Duration(milliseconds: 900)); // محاكاة الطلب

    if (!mounted) return;
    setState(() => _isSubmitting = false);

    _showResultSnackBar(widget.isEditing ? 'تم حفظ التعديلات بنجاح' : 'تم إنشاء الحساب بنجاح');
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
            _buildSliverHeader(context),
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

  // ============================================================
  //  رأس الصفحة بتدرّج الهوية البصرية (نفس ألوان splash/login)
  // ============================================================
  Widget _buildSliverHeader(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primary,
      expandedHeight: 150,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(right: 56, bottom: 16),
        title: Text(
          widget.isEditing ? 'تعديل بيانات المستخدم' : 'إضافة مستخدم جديد',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.primaryContainer],
            ),
          ),
          child: Align(
            alignment: Alignment.bottomLeft,
            child: Padding(
              padding: const EdgeInsets.only(left: 20, bottom: 14),
              child: Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  widget.isEditing ? Icons.edit_rounded : Icons.person_add_alt_1_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
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
  //  محدد الدور — بطاقات قابلة للاختيار بدل Dropdown تقليدي
  // ============================================================
  Widget _buildRoleSelector() {
    return Row(
      children: _roles.map((role) {
        final isSelected = _selectedRole == role.value;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(
              left: role == _roles.last ? 0 : 10,
            ),
            child: GestureDetector(
              onTap: () => setState(() => _selectedRole = role.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOut,
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: isSelected ? role.color.withValues(alpha: 0.1) : Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? role.color : Colors.grey.shade200,
                    width: isSelected ? 1.8 : 1.2,
                  ),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: role.color.withValues(alpha: 0.18),
                            blurRadius: 16,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Column(
                  children: [
                    Icon(
                      role.icon,
                      color: isSelected ? role.color : Colors.grey.shade400,
                      size: 24,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      role.label,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        color: isSelected ? role.color : Colors.grey.shade500,
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
          _fieldLabel('الاسم الكامل'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _nameController,
            hint: 'مثال: أحمد محمد',
            icon: Icons.person_outline_rounded,
            validator: (v) => (v == null || v.trim().isEmpty) ? 'الرجاء إدخال الاسم' : null,
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
              if (v == null || v.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
              if (!v.contains('@') || !v.contains('.')) return 'بريد إلكتروني غير صحيح';
              return null;
            },
          ),
          const SizedBox(height: 18),
          _fieldLabel(widget.isEditing ? 'كلمة مرور جديدة (اختياري)' : 'كلمة المرور'),
          const SizedBox(height: 8),
          _buildTextField(
            controller: _passwordController,
            hint: widget.isEditing ? 'اتركها فارغة للإبقاء على القديمة' : '••••••••',
            icon: Icons.lock_outline_rounded,
            obscure: _obscurePassword,
            ltr: true,
            suffix: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: Colors.grey.shade500,
                size: 20,
              ),
              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
            ),
            validator: (v) {
              // في وضع التعديل: الحقل اختياري، يُعتمد فقط إذا كُتب فيه شيء
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
              icon: Icon(
                _obscureConfirm ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: Colors.grey.shade500,
                size: 20,
              ),
              onPressed: () => setState(() => _obscureConfirm = !_obscureConfirm),
            ),
            validator: (v) {
              // إذا كانت كلمة المرور فارغة في وضع التعديل، لا داعي للتحقق من التطابق
              if (widget.isEditing && _passwordController.text.isEmpty) return null;
              if (v != _passwordController.text) return 'كلمتا المرور غير متطابقتين';
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
      style: const TextStyle(fontSize: 14, color: AppTheme.primaryContainer),
      validator: validator,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
        filled: true,
        fillColor: const Color(0xFFF7F8FB),
        prefixIcon: Icon(icon, color: AppTheme.onSurfaceVariant, size: 20),
        suffixIcon: suffix,
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
          borderSide: const BorderSide(color: AppTheme.secondary, width: 1.8),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.6),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }

  // ============================================================
  //  زر الحفظ
  // ============================================================
  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submit,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.6),
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
                      widget.isEditing ? 'حفظ التعديلات' : 'إنشاء الحساب',
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

class _RoleOption {
  final String value;
  final String label;
  final IconData icon;
  final Color color;

  const _RoleOption({
    required this.value,
    required this.label,
    required this.icon,
    required this.color,
  });
}