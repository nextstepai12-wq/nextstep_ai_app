import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/scheduler.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/networking/supabase_service.dart';
import 'package:nextstep_ai_app/core/models/student_profile_model.dart';
import 'package:nextstep_ai_app/features/auth/ui/screens/terms_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  String _selectedPath = 'new_student';
  bool _agreedToTerms = false;

  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gpaController = TextEditingController();
  final _universityController = TextEditingController();
  final _majorController = TextEditingController();

  String? _selectedBranch;
  String? _selectedYear;
  String? _selectedPhoneCode = '+970';

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;

  final SupabaseService _supabase = SupabaseService();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _passwordController.addListener(_updatePasswordStrength);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) _animationController.forward();
    });
  }

  void _updatePasswordStrength() {
    final password = _passwordController.text;
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = 0.0;
        _passwordStrengthText = '';
        _passwordStrengthColor = Colors.grey;
      });
      return;
    }

    double strength = 0.0;
    if (password.length >= 6) strength += 0.25;
    if (password.length >= 10) strength += 0.25;
    if (RegExp(r'[A-Z]').hasMatch(password)) strength += 0.25;
    if (RegExp(r'[0-9]').hasMatch(password)) strength += 0.25;

    setState(() {
      _passwordStrength = strength;
      if (strength <= 0.25) {
        _passwordStrengthText = 'ضعيفة';
        _passwordStrengthColor = const Color(0xFFDC2626);
      } else if (strength <= 0.5) {
        _passwordStrengthText = 'متوسطة';
        _passwordStrengthColor = const Color(0xFFF97316);
      } else if (strength <= 0.75) {
        _passwordStrengthText = 'جيدة';
        _passwordStrengthColor = const Color(0xFF3B82F6);
      } else {
        _passwordStrengthText = 'قوية جداً';
        _passwordStrengthColor = const Color(0xFF22C55E);
      }
    });
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _phoneController.dispose();
    _gpaController.dispose();
    _universityController.dispose();
    _majorController.dispose();
    _passwordController.removeListener(_updatePasswordStrength);
    _animationController.dispose();
    super.dispose();
  }

Future<void> _register() async {
  if (!_formKey.currentState!.validate()) return;
  if (!_agreedToTerms) {
    _showSnack('يرجى الموافقة على الشروط والأحكام', const Color(0xFFF97316));
    return;
  }

  setState(() => _isLoading = true);

  try {

    final authResponse = await _supabase.signUpWithEmail(
      email: _emailController.text.trim(),
      password: _passwordController.text.trim(),
      fullName: _fullNameController.text.trim(),
      role: 'student',
    );

    if (authResponse.user == null) {
      throw Exception('فشل إنشاء الحساب');
    }

    final userId = authResponse.user!.id;

    await _supabase.upsertStudentProfileWithUuid(
      StudentProfileModel(
        userId: userId,
        studentType: _selectedPath,
        phone: _selectedPhoneCode! + _phoneController.text.trim(),
        highSchoolScore: _selectedPath == 'new_student'
            ? double.tryParse(_gpaController.text)
            : null,
        highSchoolBranchId: _selectedPath == 'new_student'
            ? _getBranchId(_selectedBranch)
            : null,
        currentUniversityId: _selectedPath == 'university_student'
            ? int.tryParse(_universityController.text)
            : null,
        currentMajorId: _selectedPath == 'university_student'
            ? int.tryParse(_majorController.text)
            : null,
        academicLevel: _selectedYear,
        gpa: _selectedPath == 'university_student'
            ? double.tryParse(_gpaController.text)
            : null,
      ),
    );

    if (mounted) {
      _showSnack('تم إنشاء الحساب بنجاح!', const Color(0xFF22C55E),
          icon: Icons.check_circle_outline_rounded);
      context.pushReplacement('/login');
    }
  } catch (e) {
    if (mounted) {
      _showSnack(e.toString().replaceFirst('Exception: ', ''),
          const Color(0xFFDC2626));
    }
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
  void _showSnack(String message, Color color, {IconData? icon}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: color,
          content: Row(
            children: [
              Icon(icon ?? Icons.error_outline_rounded,
                  color: Colors.white, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(message,
                    style: const TextStyle(color: Colors.white, fontSize: 13)),
              ),
            ],
          ),
        ),
      );
  }

  int? _getBranchId(String? branch) {
    switch (branch) {
      case 'scientific':
        return 1;
      case 'literary':
        return 2;
      case 'commercial':
        return 3;
      case 'industrial':
        return 4;
      default:
        return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF6F7FB),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: Stack(
          children: [
            _buildBackgroundDecor(size),
            SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        _buildHeader(),
                        const SizedBox(height: 20),
                        _buildPathSelection(),
                        const SizedBox(height: 20),
                        _buildForm(),
                        const SizedBox(height: 20),
                        _buildFooter(),
                        const SizedBox(height: 12),
                      ],
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

  Widget _buildBackgroundDecor(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -size.width * 0.35,
          left: -size.width * 0.3,
          child: Container(
            width: size.width * 0.85,
            height: size.width * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.primary.withValues(alpha: 0.14),
                  AppTheme.primaryContainer.withValues(alpha: 0.04),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -size.width * 0.4,
          right: -size.width * 0.3,
          child: Container(
            width: size.width * 0.8,
            height: size.width * 0.8,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.secondary.withValues(alpha: 0.1),
                  AppTheme.secondary.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.primaryContainer],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.3),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(22),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.school_rounded,
                size: 38,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'إنشاء حساب جديد',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            height: 1.3,
            color: AppTheme.primaryContainer,
            letterSpacing: -0.3,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'اختر مسارك الأكاديمي للحصول على توجيه مخصص',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.75),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

Widget _buildPathSelection() {
  return Row(
    children: [
      Expanded(
        child: _buildPathCard(
          title: 'طالب توجيهي',
          subtitle: 'للذين يتطلعون للالتحاق بالجامعة',
          icon: Icons.school_rounded,
          isSelected: _selectedPath == 'new_student',
          onTap: () => setState(() => _selectedPath = 'new_student'),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(
        child: _buildPathCard(
          title: 'طالب جامعي',
          subtitle: 'لتطوير مسارك الأكاديمي والمهني',
          icon: Icons.local_library_rounded,
          isSelected: _selectedPath == 'university_student',
          onTap: () => setState(() => _selectedPath = 'university_student'),
        ),
      ),
    ],
  );
}

  Widget _buildPathCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOut,
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [AppTheme.primary, AppTheme.primaryContainer],
                )
              : null,
          color: isSelected ? null : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? Colors.transparent
                : const Color(0xFFECEDF3),
            width: 1.4,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.primary.withValues(alpha: 0.28)
                  : Colors.black.withValues(alpha: 0.02),
              blurRadius: isSelected ? 20 : 10,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.2)
                    : AppTheme.primary.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isSelected ? Colors.white : AppTheme.primary,
                size: 22,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                height: 1.3,
                color: isSelected ? Colors.white : AppTheme.primaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 3),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10.5,
                fontWeight: FontWeight.w400,
                height: 1.3,
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.85)
                    : Colors.grey.shade500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: Colors.white.withValues(alpha: 0.6), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryContainer.withValues(alpha: 0.06),
            blurRadius: 36,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildTextField(
              controller: _fullNameController,
              label: 'الاسم الكامل',
              hint: 'أدخل اسمك الرباعي',
              icon: Icons.person_outline_rounded,
              validator: (v) =>
                  (v == null || v.isEmpty) ? 'الرجاء إدخال الاسم الكامل' : null,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              hint: 'user@school.edu',
              icon: Icons.mail_outline_rounded,
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.isEmpty) return 'الرجاء إدخال البريد الإلكتروني';
                if (!v.contains('@') || !v.contains('.')) {
                  return 'الرجاء إدخال بريد إلكتروني صحيح';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            _buildPhoneSection(),
            if (_selectedPath == 'new_student') ...[
              const SizedBox(height: 16),
              _buildBranchDropdown(),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _gpaController,
                label: 'المعدل المتوقع (%)',
                hint: '90.5',
                icon: Icons.analytics_outlined,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'الرجاء إدخال المعدل';
                  final gpa = double.tryParse(v);
                  if (gpa == null || gpa < 50 || gpa > 100) {
                    return 'المعدل بين 50 و 100';
                  }
                  return null;
                },
              ),
            ],
            if (_selectedPath == 'university_student') ...[
              const SizedBox(height: 16),
              _buildTextField(
                controller: _universityController,
                label: 'الجامعة الحالية',
                hint: 'أدخل اسم جامعتك',
                icon: Icons.business_outlined,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'الرجاء إدخال اسم الجامعة' : null,
              ),
              const SizedBox(height: 16),
              _buildTextField(
                controller: _majorController,
                label: 'التخصص',
                hint: 'أدخل تخصصك',
                icon: Icons.book_outlined,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'الرجاء إدخال التخصص' : null,
              ),
              const SizedBox(height: 16),
              _buildYearDropdown(),
            ],
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _passwordController,
              label: 'كلمة المرور',
              icon: Icons.lock_outline_rounded,
              obscureText: _obscurePassword,
              onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
              validator: (v) {
                if (v == null || v.isEmpty) return 'الرجاء إدخال كلمة المرور';
                if (v.length < 6) return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                return null;
              },
              showStrength: true,
            ),
            const SizedBox(height: 16),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'تأكيد كلمة المرور',
              icon: Icons.lock_reset_rounded,
              obscureText: _obscureConfirmPassword,
              onToggle: () => setState(
                  () => _obscureConfirmPassword = !_obscureConfirmPassword),
              validator: (v) {
                if (v == null || v.isEmpty) return 'الرجاء تأكيد كلمة المرور';
                if (v != _passwordController.text) {
                  return 'كلمة المرور غير متطابقة';
                }
                return null;
              },
            ),
            const SizedBox(height: 26),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration({
    required String hint,
    required IconData icon,
    Widget? suffix,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
      hintTextDirection: TextDirection.rtl,
      filled: true,
      fillColor: const Color(0xFFF7F8FB),
      prefixIcon: Icon(icon, color: AppTheme.onSurfaceVariant, size: 21),
      suffixIcon: suffix,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFECEDF3), width: 1.4),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppTheme.secondary, width: 1.8),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.6),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: Color(0xFFDC2626), width: 1.8),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
    );
  }

  Widget _fieldLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          height: 1.3,
          color: AppTheme.primaryContainer,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 14, color: AppTheme.primaryContainer),
          decoration: _fieldDecoration(hint: hint, icon: icon),
          validator: validator,
        ),
      ],
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?)? validator,
    bool showStrength = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel(label),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.right,
          style: const TextStyle(fontSize: 14, color: AppTheme.primaryContainer),
          decoration: _fieldDecoration(
            hint: '••••••••',
            icon: icon,
            suffix: IconButton(
              icon: Icon(
                obscureText
                    ? Icons.visibility_off_rounded
                    : Icons.visibility_rounded,
                color: AppTheme.onSurfaceVariant,
                size: 20,
              ),
              onPressed: onToggle,
            ),
          ),
          validator: validator,
          onChanged: showStrength ? (_) => setState(() {}) : null,
        ),
        if (showStrength && controller.text.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: AnimatedFractionallySizedBox(
                    duration: const Duration(milliseconds: 250),
                    widthFactor: 1,
                    child: LinearProgressIndicator(
                      value: _passwordStrength,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(_passwordStrengthColor),
                      minHeight: 5,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Text(
                _passwordStrengthText,
                style: TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: _passwordStrengthColor,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

InputDecoration _buildDropdownDecoration({required IconData icon}) {
  return _fieldDecoration(hint: '', icon: icon);
}

  Widget _buildPhoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('رقم الهاتف'),
        DropdownButtonFormField<String>(
          initialValue: _selectedPhoneCode,
          decoration: _fieldDecoration(
            hint: 'رمز الدولة',
            icon: Icons.public_rounded,
          ),
          items: const [
            DropdownMenuItem(value: '+970', child: Text('+970 فلسطين')),
            DropdownMenuItem(value: '+972', child: Text('+972 إسرائيل')),
            DropdownMenuItem(value: '+962', child: Text('+962 الأردن')),
            DropdownMenuItem(value: '+966', child: Text('+966 السعودية')),
            DropdownMenuItem(value: '+971', child: Text('+971 الإمارات')),
            DropdownMenuItem(value: '+961', child: Text('+961 لبنان')),
            DropdownMenuItem(value: '+963', child: Text('+963 سوريا')),
            DropdownMenuItem(value: '+964', child: Text('+964 العراق')),
            DropdownMenuItem(value: '+965', child: Text('+965 الكويت')),
            DropdownMenuItem(value: '+968', child: Text('+968 عُمان')),
            DropdownMenuItem(value: '+974', child: Text('+974 قطر')),
            DropdownMenuItem(value: '+973', child: Text('+973 البحرين')),
            DropdownMenuItem(value: '+20', child: Text('+20 مصر')),
            DropdownMenuItem(value: '+212', child: Text('+212 المغرب')),
            DropdownMenuItem(value: '+216', child: Text('+216 تونس')),
            DropdownMenuItem(value: '+213', child: Text('+213 الجزائر')),
            DropdownMenuItem(value: '+249', child: Text('+249 السودان')),
            DropdownMenuItem(value: '+967', child: Text('+967 اليمن')),
          ],
          onChanged: (value) => setState(() => _selectedPhoneCode = value),
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: const TextStyle(fontSize: 14, color: AppTheme.primaryContainer),
          decoration: _fieldDecoration(
            hint: '599 000 000',
            icon: Icons.phone_android_rounded,
          ),
          validator: (v) {
            if (v == null || v.isEmpty) return 'الرجاء إدخال رقم الهاتف';
            if (v.length < 9) return 'رقم الهاتف غير صحيح';
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildBranchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('الفرع الدراسي'),
        DropdownButtonFormField<String>(
          initialValue: _selectedBranch,
          decoration: _fieldDecoration(
            hint: 'اختر الفرع الدراسي',
            icon: Icons.school_outlined,
          ),
          items: const [
            DropdownMenuItem(value: 'scientific', child: Text('علمي')),
            DropdownMenuItem(value: 'literary', child: Text('أدبي')),
            DropdownMenuItem(value: 'commercial', child: Text('ريادة وأعمال')),
            DropdownMenuItem(value: 'industrial', child: Text('صناعي')),
          ],
          onChanged: (value) => setState(() => _selectedBranch = value),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'الرجاء اختيار الفرع الدراسي' : null,
          style: const TextStyle(fontSize: 14, color: AppTheme.primaryContainer),
        ),
      ],
    );
  }

  Widget _buildYearDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _fieldLabel('السنة الدراسية'),
        DropdownButtonFormField<String>(
          initialValue: _selectedYear,
          decoration: _fieldDecoration(
            hint: 'اختر السنة',
            icon: Icons.calendar_today_rounded,
          ),
          items: const [
            DropdownMenuItem(value: '1', child: Text('السنة الأولى')),
            DropdownMenuItem(value: '2', child: Text('السنة الثانية')),
            DropdownMenuItem(value: '3', child: Text('السنة الثالثة')),
            DropdownMenuItem(value: '4', child: Text('السنة الرابعة')),
            DropdownMenuItem(value: '5', child: Text('خريج')),
          ],
          onChanged: (value) => setState(() => _selectedYear = value),
          validator: (v) =>
              (v == null || v.isEmpty) ? 'الرجاء اختيار السنة الدراسية' : null,
          style: const TextStyle(fontSize: 14, color: AppTheme.primaryContainer),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primary, AppTheme.primaryContainer],
          ),
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.32),
              blurRadius: 22,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _isLoading ? null : _register,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: _isLoading
                ? const SizedBox(
                    key: ValueKey('loading'),
                    height: 22,
                    width: 22,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2.4,
                    ),
                  )
                : const Row(
                    key: ValueKey('label'),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'إنشاء الحساب',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          height: 1.2,
                          letterSpacing: 0.2,
                        ),
                      ),
                      SizedBox(width: 10),
                      Icon(Icons.arrow_forward_rounded,
                          size: 20, color: Colors.white),
                    ],
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFECEDF3), width: 1.2),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Checkbox(
                value: _agreedToTerms,
                onChanged: (value) =>
                    setState(() => _agreedToTerms = value ?? false),
                activeColor: AppTheme.primary,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
              ),
              Flexible(
                child: GestureDetector(
                  onTap: () async {
                    final result = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const TermsScreen(),
                      ),
                    );
                    if (result == true) {
                      setState(() => _agreedToTerms = true);
                    }
                  },
                  child: RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.onSurfaceVariant.withValues(alpha: 0.8),
                      ),
                      children: const [
                        TextSpan(text: 'أوافق على '),
                        TextSpan(
                          text: 'الشروط والأحكام',
                          style: TextStyle(
                            color: AppTheme.secondary,
                            fontWeight: FontWeight.w700,
                            decoration: TextDecoration.underline,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: const Color(0xFFECEDF3), width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'هل لديك حساب بالفعل؟',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.5,
                  color: AppTheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 4),
              InkWell(
                onTap: () => context.pushReplacement('/login'),
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                  child: Text(
                    'سجل دخولك هنا',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      height: 1.5,
                      color: AppTheme.secondary,
                      decoration: TextDecoration.underline,
                      decorationColor: AppTheme.secondary.withValues(alpha: 0.3),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
