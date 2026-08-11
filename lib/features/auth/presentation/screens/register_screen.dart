import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';
import 'package:nextstep_ai_app/shared/services/supabase/supabase_service.dart';
import 'package:nextstep_ai_app/shared/models/student_profile_model.dart';
import 'package:nextstep_ai_app/features/auth/presentation/screens/terms_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with SingleTickerProviderStateMixin {
  String _selectedPath = 'tawjihi';
  bool _agreedToTerms = false;

  // Controllers
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _gpaController = TextEditingController();
  final _universityController = TextEditingController();
  final _majorController = TextEditingController();

  // Selected values
  String? _selectedBranch;
  String? _selectedYear;
  String? _selectedPhoneCode = '+970';

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  // Animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  // Password strength
  double _passwordStrength = 0.0;
  String _passwordStrengthText = '';
  Color _passwordStrengthColor = Colors.grey;

  // Supabase
  final SupabaseService _supabase = SupabaseService();

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _passwordController.addListener(_updatePasswordStrength);

    SchedulerBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _animationController.forward();
      }
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
        _passwordStrengthColor = Colors.red;
      } else if (strength <= 0.5) {
        _passwordStrengthText = 'متوسطة';
        _passwordStrengthColor = Colors.orange;
      } else if (strength <= 0.75) {
        _passwordStrengthText = 'جيدة';
        _passwordStrengthColor = Colors.blue;
      } else {
        _passwordStrengthText = 'قوية جداً';
        _passwordStrengthColor = Colors.green;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('يرجى الموافقة على الشروط والأحكام'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ إنشاء حساب في Supabase Auth
      final authResponse = await _supabase.signUpWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        userMetadata: {
          'full_name': _fullNameController.text.trim(),
          'role': 'student',
        },
      );

      if (authResponse.user == null) {
        throw Exception('فشل إنشاء الحساب');
      }

      final userId = int.parse(authResponse.user!.id);

      // 2️⃣ إنشاء ملف الطالب في جدول student_profiles
      await _supabase.upsertStudentProfile(
        StudentProfileModel(
          userId: userId,
          studentType: _selectedPath,
          phone: _selectedPhoneCode! + _phoneController.text.trim(),
          highSchoolScore: _selectedPath == 'tawjihi'
              ? double.tryParse(_gpaController.text)
              : null,
          highSchoolBranchId: _selectedPath == 'tawjihi'
              ? _getBranchId(_selectedBranch)
              : null,
          currentUniversityId: _selectedPath == 'university'
              ? int.tryParse(_universityController.text)
              : null,
          currentMajorId: _selectedPath == 'university'
              ? int.tryParse(_majorController.text)
              : null,
          academicYear: _selectedYear,
          gpa: _selectedPath == 'university'
              ? double.tryParse(_gpaController.text)
              : null,
        ),
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ تم إنشاء الحساب بنجاح!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pushReplacementNamed(context, '/login');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Column(
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 12),
                    _buildPathSelection(),
                    const SizedBox(height: 24),
                    _buildForm(),
                    const SizedBox(height: 24),
                    _buildFooter(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.15),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Image.asset(
            'assets/images/logo.png',
            width: 130,
            height: 130,
            fit: BoxFit.contain,
            errorBuilder: (_, __, ___) {
              return Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.primary,
                      AppTheme.primaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primary.withValues(alpha: 0.3),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.school,
                  size: 55,
                  color: Colors.white,
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'إنشاء حساب جديد',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            height: 1.3,
            color: AppTheme.primaryContainer,
            letterSpacing: -0.5,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          'اختر مسارك الأكاديمي للحصول على توجيه مخصص',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.8),
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
            icon: Icons.school_outlined,
            isSelected: _selectedPath == 'tawjihi',
            onTap: () {
              setState(() {
                _selectedPath = 'tawjihi';
              });
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildPathCard(
            title: 'طالب جامعي',
            subtitle: 'لتطوير مسارك الأكاديمي والمهني',
            icon: Icons.local_library_outlined,
            isSelected: _selectedPath == 'university',
            onTap: () {
              setState(() {
                _selectedPath = 'university';
              });
            },
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
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isSelected ? const Color(0xFFF0F7FF) : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected ? const Color(0xFF003E2C) : AppTheme.borderSubtle,
          width: isSelected ? 2 : 1,
        ),
        boxShadow: isSelected
            ? [
                BoxShadow(
                  color: const Color(0xFF003E2C).withValues(alpha: 0.08),
                  blurRadius: 12,
                  spreadRadius: 2,
                ),
              ]
            : const [],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFF003E2C).withValues(alpha: 0.1)
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: isSelected ? const Color(0xFF003E2C) : Colors.grey.shade500,
                size: 22,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                height: 1.3,
                color: isSelected ? const Color(0xFF003E2C) : AppTheme.primaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w400,
                height: 1.3,
                color: Colors.grey.shade500,
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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppTheme.borderSubtle.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            _buildAnimatedTextField(
              controller: _fullNameController,
              label: 'الاسم الكامل',
              hint: 'أدخل اسمك الرباعي',
              icon: Icons.person_outline,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال الاسم الكامل';
                }
                return null;
              },
            ),
            const SizedBox(height: 14),
            _buildAnimatedTextField(
              controller: _emailController,
              label: 'البريد الإلكتروني',
              hint: 'user@school.edu',
              icon: Icons.mail_outline,
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
            const SizedBox(height: 14),
            _buildPhoneSection(),
            if (_selectedPath == 'tawjihi') ...[
              const SizedBox(height: 14),
              _buildBranchDropdown(),
              const SizedBox(height: 14),
              _buildAnimatedTextField(
                controller: _gpaController,
                label: 'المعدل المتوقع (%)',
                hint: '90.5',
                icon: Icons.analytics_outlined,
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال المعدل';
                  }
                  final gpa = double.tryParse(value);
                  if (gpa == null || gpa < 50 || gpa > 100) {
                    return 'المعدل بين 50 و 100';
                  }
                  return null;
                },
              ),
            ],
            if (_selectedPath == 'university') ...[
              const SizedBox(height: 14),
              _buildAnimatedTextField(
                controller: _universityController,
                label: 'الجامعة الحالية',
                hint: 'أدخل اسم جامعتك',
                icon: Icons.business_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال اسم الجامعة';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildAnimatedTextField(
                controller: _majorController,
                label: 'التخصص',
                hint: 'أدخل تخصصك',
                icon: Icons.book_outlined,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'الرجاء إدخال التخصص';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),
              _buildYearDropdown(),
            ],
            const SizedBox(height: 14),
            _buildPasswordField(
              controller: _passwordController,
              label: 'كلمة المرور',
              icon: Icons.lock_outline,
              obscureText: _obscurePassword,
              onToggle: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء إدخال كلمة المرور';
                }
                if (value.length < 6) {
                  return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
                }
                return null;
              },
              showStrength: true,
              strength: _passwordStrength,
              strengthText: _passwordStrengthText,
              strengthColor: _passwordStrengthColor,
            ),
            const SizedBox(height: 14),
            _buildPasswordField(
              controller: _confirmPasswordController,
              label: 'تأكيد كلمة المرور',
              icon: Icons.lock_reset_outlined,
              obscureText: _obscureConfirmPassword,
              onToggle: () {
                setState(() {
                  _obscureConfirmPassword = !_obscureConfirmPassword;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الرجاء تأكيد كلمة المرور';
                }
                if (value != _passwordController.text) {
                  return 'كلمة المرور غير متطابقة';
                }
                return null;
              },
              showStrength: false,
            ),
            const SizedBox(height: 24),
            _buildRegisterButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPhoneSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رقم الهاتف',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedPhoneCode,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            prefixIcon: const Icon(
              Icons.phone_outlined,
              color: AppTheme.onSurfaceVariant,
            ),
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
          onChanged: (value) {
            setState(() {
              _selectedPhoneCode = value;
            });
          },
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _phoneController,
          keyboardType: TextInputType.phone,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.left,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.primaryContainer,
          ),
          decoration: InputDecoration(
            hintText: '599 000 000',
            hintStyle: TextStyle(
              color: Colors.grey.shade400,
              fontSize: 13,
            ),
            prefixIcon: const Icon(
              Icons.phone_android_outlined,
              color: AppTheme.onSurfaceVariant,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء إدخال رقم الهاتف';
            }
            if (value.length < 9) {
              return 'رقم الهاتف غير صحيح';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAnimatedTextField({
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
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
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
            hintTextDirection: TextDirection.rtl,
            prefixIcon: Icon(icon, color: AppTheme.onSurfaceVariant),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
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

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required bool obscureText,
    required VoidCallback onToggle,
    required String? Function(String?)? validator,
    bool showStrength = false,
    double strength = 0.0,
    String strengthText = '',
    Color strengthColor = Colors.grey,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.primaryContainer,
          ),
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: AppTheme.onSurfaceVariant),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: AppTheme.onSurfaceVariant,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: validator,
        ),
        if (showStrength && controller.text.isNotEmpty) ...[
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: strength,
                    backgroundColor: Colors.grey.shade200,
                    valueColor: AlwaysStoppedAnimation<Color>(strengthColor),
                    minHeight: 4,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                strengthText,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w500,
                  color: strengthColor,
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }

  Widget _buildBranchDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'الفرع الدراسي',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedBranch,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: const Icon(
              Icons.school_outlined,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          hint: const Text(
            'اختر الفرع الدراسي',
            style: TextStyle(color: Colors.grey),
          ),
          items: const [
            DropdownMenuItem(value: 'scientific', child: Text('علمي')),
            DropdownMenuItem(value: 'literary', child: Text('أدبي')),
            DropdownMenuItem(value: 'commercial', child: Text('ريادة وأعمال')),
            DropdownMenuItem(value: 'industrial', child: Text('صناعي')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedBranch = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء اختيار الفرع الدراسي';
            }
            return null;
          },
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.primaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildYearDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'السنة الدراسية',
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            height: 1.3,
            color: AppTheme.primaryContainer,
          ),
        ),
        const SizedBox(height: 6),
        DropdownButtonFormField<String>(
          initialValue: _selectedYear,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.borderSubtle),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: AppTheme.secondary, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            prefixIcon: const Icon(
              Icons.calendar_today_outlined,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          hint: const Text(
            'اختر السنة',
            style: TextStyle(color: Colors.grey),
          ),
          items: const [
            DropdownMenuItem(value: '1', child: Text('السنة الأولى')),
            DropdownMenuItem(value: '2', child: Text('السنة الثانية')),
            DropdownMenuItem(value: '3', child: Text('السنة الثالثة')),
            DropdownMenuItem(value: '4', child: Text('السنة الرابعة')),
            DropdownMenuItem(value: '5', child: Text('خريج')),
          ],
          onChanged: (value) {
            setState(() {
              _selectedYear = value;
            });
          },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'الرجاء اختيار السنة الدراسية';
            }
            return null;
          },
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.primaryContainer,
          ),
        ),
      ],
    );
  }

  Widget _buildRegisterButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primary,
            AppTheme.primaryContainer,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 2,
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
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.5,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'إنشاء الحساب',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.2,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(width: 10),
                  Icon(
                    Icons.arrow_forward_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        // ✅ موافقة على الشروط والأحكام مع رابط
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Checkbox(
              value: _agreedToTerms,
              onChanged: (value) {
                setState(() {
                  _agreedToTerms = value ?? false;
                });
              },
              activeColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
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
                    setState(() {
                      _agreedToTerms = true;
                    });
                  }
                },
                child: RichText(
                  text: TextSpan(
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.onSurfaceVariant.withValues(alpha: 0.7),
                    ),
                    children: const [
                      TextSpan(text: 'أوافق على '),
                      TextSpan(
                        text: 'الشروط والأحكام',
                        style: TextStyle(
                          color: AppTheme.secondary,
                          fontWeight: FontWeight.w600,
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
        const SizedBox(height: 12),
        // ✅ رابط تسجيل الدخول
        Row(
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
              onTap: () {
                Navigator.pushReplacementNamed(context, '/login');
              },
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
      ],
    );
  }
}