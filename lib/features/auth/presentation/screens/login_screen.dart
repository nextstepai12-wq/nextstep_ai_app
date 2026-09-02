import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';
import 'package:nextstep_ai_app/shared/services/supabase/supabase_service.dart';
import 'package:nextstep_ai_app/shared/services/auth/token_manager.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _supabase = SupabaseService();
  final Connectivity _connectivity = Connectivity();

  bool _isLoading = false;
  bool _obscurePassword = true;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  // ============================================================
  //  حسابات التطوير السريعة — تظهر فقط في وضع Debug
  //  ⚠️ لا تُعرض أبدًا في نسخة الإنتاج (Release) بفضل فحص kDebugMode
  // ============================================================
  static const List<_DevAccount> _devAccounts = [
    _DevAccount(
      label: 'طالب',
      email: 'aalhayek7@smail.ucas.edu.ps',
      password: '123456789',
      icon: Icons.school_rounded,
      color: Color(0xFF3B82F6),
    ),
    _DevAccount(
      label: 'جامعة',
      email: 'alhayekahmed045@gmail.com',
      password: '123456789',
      icon: Icons.business_rounded,
      color: Color(0xFF22C55E),
    ),
    _DevAccount(
      label: 'إدارة',
      email: 'nextstepai12@gmail.com',
      password: '123456789',
      icon: Icons.admin_panel_settings_rounded,
      color: Color(0xFF8B5CF6),
    ),
    _DevAccount(
      label: 'مركز تدريب',
      email: 'fatmakh2023@gmail.com',
      password: '123456789',
      icon: Icons.workspace_premium_rounded,
      color: Color(0xFFF97316),
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic));
    _animController.forward();
  }

  // ============================================================
  //  تعبئة الحقول تلقائيًا وتسجيل الدخول مباشرة (وضع التطوير فقط)
  // ============================================================
  void _quickLoginWith(_DevAccount account) {
    setState(() {
      _emailController.text = account.email;
      _passwordController.text = account.password;
    });
    // تأخير بسيط حتى يرى المطور تعبئة الحقول قبل الانتقال فعليًا
    Future.delayed(const Duration(milliseconds: 150), _login);
  }

  // ============================================================
  //  التحقق من الاتصال بالإنترنت
  // ============================================================
  Future<bool> _checkInternet() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  // ============================================================
  //  عرض رسالة عدم الاتصال
  // ============================================================
  void _showNoInternetDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Icon(Icons.wifi_off_rounded, color: Colors.orange.shade700, size: 28),
            const SizedBox(width: 12),
            const Text(
              'لا يوجد اتصال بالإنترنت',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'يبدو أنك غير متصل بالإنترنت. يرجى التحقق من اتصالك والمحاولة مرة أخرى.',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.lightbulb_outline, color: Colors.orange.shade700, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'تأكد من تشغيل الواي فاي أو بيانات الجوال',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange.shade800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('حسناً'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              final hasInternet = await _checkInternet();
              if (!hasInternet) {
                _showNoInternetDialog();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('إعادة المحاولة'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  // ============================================================
  //  عرض رسالة خطأ مخصصة (منبثقة احترافية)
  //  ✅ مُصلَحة: opacity منفصلة عن scale، ومحمية من overflow بالكيبورد
  // ============================================================
  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withValues(alpha: 0.4),
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          tween: Tween<double>(begin: 0.0, end: 1.0),
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          builder: (context, opacityValue, child) {
            return Opacity(
              opacity: opacityValue.clamp(0.0, 1.0),
              child: TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0.7, end: 1.0),
                duration: const Duration(milliseconds: 500),
                curve: Curves.easeOutBack,
                builder: (context, scaleValue, child) {
                  return Transform.scale(scale: scaleValue, child: child);
                },
                child: child,
              ),
            );
          },
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(maxWidth: 400),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(context).size.height * 0.85,
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(32),
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(32),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween<double>(begin: 1.0, end: 1.08),
                        duration: const Duration(milliseconds: 1000),
                        curve: Curves.easeInOut,
                        builder: (context, scale, child) {
                          return Transform.scale(
                            scale: scale,
                            child: Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [Color(0xFFDC2626), Color(0xFFEF4444)],
                                ),
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(0xFFDC2626).withValues(alpha: 0.25),
                                    blurRadius: 40,
                                    spreadRadius: 15,
                                  ),
                                ],
                              ),
                              child: const Center(
                                child: Icon(Icons.close_rounded, size: 48, color: Colors.white),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'فشل تسجيل الدخول',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryContainer,
                          letterSpacing: -0.5,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'نعتذر، حدث خطأ أثناء محاولة تسجيل الدخول',
                        style: TextStyle(fontSize: 13, color: Colors.grey.shade500, height: 1.4),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.red.shade50, Colors.red.shade100.withValues(alpha: 0.5)],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.red.shade200, width: 1.5),
                        ),
                        child: Row(
                          children: [
                            Icon(Icons.error_outline_rounded, size: 22, color: Colors.red.shade700),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                message,
                                style: TextStyle(
                                  fontSize: 14,
                                  height: 1.5,
                                  color: Colors.red.shade800,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Colors.amber.shade50, Colors.orange.shade50],
                          ),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.amber.shade200, width: 1.2),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.shade100,
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.lightbulb_outline_rounded,
                                    size: 16,
                                    color: Colors.amber.shade700,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Text(
                                  'نصيحة',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.amber.shade800,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Padding(
                              padding: const EdgeInsets.only(right: 30),
                              child: Text(
                                _getSuggestion(message),
                                style: TextStyle(
                                  fontSize: 12.5,
                                  color: Colors.amber.shade800,
                                  fontWeight: FontWeight.w500,
                                  height: 1.6,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Navigator.pop(context),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppTheme.primaryContainer,
                                side: BorderSide(color: Colors.grey.shade300),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                              ),
                              child: const Text('إلغاء', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                                _login();
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                elevation: 0,
                              ),
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.refresh_rounded, size: 20),
                                  SizedBox(width: 8),
                                  Text('إعادة المحاولة', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('لا تزال تواجه مشكلة؟', style: TextStyle(fontSize: 13, color: Colors.grey.shade500)),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              Navigator.pushNamed(context, '/contact-us');
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppTheme.secondary,
                              textStyle: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              minimumSize: Size.zero,
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            child: const Text('تواصل مع الدعم'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  نصائح ذكية حسب نوع الخطأ
  // ============================================================
  String _getSuggestion(String errorMessage) {
    if (errorMessage.contains('Invalid login credentials')) {
      return 'تأكد من صحة البريد الإلكتروني وكلمة المرور. يمكنك استخدام "نسيت كلمة المرور" لإعادة تعيينها.';
    } else if (errorMessage.contains('network') || errorMessage.contains('connection')) {
      return 'يبدو أن هناك مشكلة في الاتصال بالإنترنت. تأكد من تشغيل الواي فاي أو بيانات الجوال.';
    } else if (errorMessage.contains('email')) {
      return 'تأكد من إدخال البريد الإلكتروني بشكل صحيح (مثال: user@domain.com)';
    } else if (errorMessage.contains('password')) {
      return 'كلمة المرور يجب أن تكون 8 أحرف على الأقل وتحتوي على حروف وأرقام ورموز.';
    } else if (errorMessage.contains('timeout')) {
      return 'انتهت مهلة الاتصال. قد يكون الاتصال بطيئاً، حاول مرة أخرى بعد قليل.';
    } else if (errorMessage.contains('server')) {
      return 'يبدو أن هناك مشكلة في الخادم. نعمل على حلها، يرجى المحاولة بعد قليل.';
    } else {
      return 'يرجى التحقق من بياناتك والمحاولة مرة أخرى. إذا استمرت المشكلة، فريق الدعم جاهز لمساعدتك.';
    }
  }

  // ============================================================
  //  تحديد المسار حسب الدور
  // ============================================================
  String _getRouteForRole(String role) {
    switch (role) {
      case 'student':
        return '/student';
      case 'university':
        return '/university';
      case 'admin':
        return '/admin';
      case 'training_center':
        return '/training-center';
      default:
        return '/student';
    }
  }

  // ============================================================
  //  تسجيل الدخول
  // ============================================================
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    final hasInternet = await _checkInternet();
    if (!hasInternet) {
      _showNoInternetDialog();
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await _supabase.signInWithEmail(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      if (response.user != null && mounted) {
        final userData = await _supabase.getUser(response.user!.id);
        final role = userData?.role ?? 'student';
        final name = userData?.displayName ?? _emailController.text.trim();

        await TokenManager.saveToken(response.session?.accessToken ?? '');
        await TokenManager.saveUserData(
          userId: response.user!.id,
          role: role,
          name: name,
          email: _emailController.text.trim(),
        );

        if (mounted) {
          Navigator.pushReplacementNamed(context, _getRouteForRole(role));
        }
      }
    } on Exception catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      if (errorMsg.contains('Invalid login credentials')) {
        _showErrorDialog('البريد الإلكتروني أو كلمة المرور غير صحيحة');
      } else if (errorMsg.contains('network') || errorMsg.contains('connection')) {
        _showNoInternetDialog();
      } else {
        _showErrorDialog(errorMsg);
      }
    } catch (e) {
      _showErrorDialog('حدث خطأ غير متوقع. يرجى المحاولة مرة أخرى.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _animController.dispose();
    super.dispose();
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
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: SlideTransition(
                    position: _slideAnim,
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.04),
                        _buildLogoSection(),
                        const SizedBox(height: 28),
                        // ✅ قسم حسابات التطوير — يظهر فقط في وضع Debug
                        if (kDebugMode) ...[
                          _buildDevAccountsSection(),
                          const SizedBox(height: 20),
                        ],
                        _buildGlassCard(),
                        const SizedBox(height: 24),
                        _buildRegisterLink(),
                        const SizedBox(height: 16),
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

  // ============================================================
  //  خلفية زخرفية
  // ============================================================
  Widget _buildBackgroundDecor(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -size.width * 0.35,
          right: -size.width * 0.3,
          child: Container(
            width: size.width * 0.9,
            height: size.width * 0.9,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.primary.withValues(alpha: 0.16),
                  AppTheme.primaryContainer.withValues(alpha: 0.05),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -size.width * 0.4,
          left: -size.width * 0.35,
          child: Container(
            width: size.width * 0.85,
            height: size.width * 0.85,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                colors: [
                  AppTheme.secondary.withValues(alpha: 0.12),
                  AppTheme.secondary.withValues(alpha: 0.02),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ============================================================
  //  الشعار والترحيب
  // ============================================================
  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 84,
          height: 84,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.primaryContainer],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primary.withValues(alpha: 0.35),
                blurRadius: 28,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: Image.asset(
              'assets/images/logo.png',
              fit: BoxFit.contain,
              errorBuilder: (_, __, ___) => const Icon(
                Icons.school_rounded,
                size: 40,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 20),
        const Text(
          'مرحباً بك مجدداً',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.3,
            color: AppTheme.primaryContainer,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 6),
        Text(
          'سجّل دخولك لتكمل رحلتك الأكاديمية',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w400,
            height: 1.5,
            color: AppTheme.onSurfaceVariant.withValues(alpha: 0.75),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  // ============================================================
  //  قسم حسابات التطوير السريعة (Debug فقط)
  // ============================================================
  Widget _buildDevAccountsSection() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFEF3C7),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFDE68A), width: 1.2),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.bug_report_rounded, size: 16, color: Color(0xFFB45309)),
              const SizedBox(width: 6),
              Text(
                'دخول سريع (وضع التطوير فقط)',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFFB45309),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 2.6,
            children: _devAccounts.map((account) {
              return _DevAccountButton(
                account: account,
                onTap: () => _quickLoginWith(account),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  بطاقة الفورم (Glass Card)
  // ============================================================
  Widget _buildGlassCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.6),
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryContainer.withValues(alpha: 0.06),
            blurRadius: 40,
            offset: const Offset(0, 16),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFieldLabel('البريد الإلكتروني'),
            const SizedBox(height: 8),
            _buildEmailField(),
            const SizedBox(height: 18),
            _buildFieldLabel('كلمة المرور'),
            const SizedBox(height: 8),
            _buildPasswordField(),
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushNamed(context, '/forget-password'),
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.secondary,
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                child: const Text('نسيت كلمة المرور؟'),
              ),
            ),
            const SizedBox(height: 20),
            _buildLoginButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFieldLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        height: 1.3,
        color: AppTheme.primaryContainer,
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

  Widget _buildEmailField() {
    return TextFormField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 14, color: AppTheme.primaryContainer),
      decoration: _fieldDecoration(
        hint: 'user@school.edu',
        icon: Icons.mail_outline_rounded,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال البريد الإلكتروني';
        }
        if (!value.contains('@') || !value.contains('.')) {
          return 'الرجاء إدخال بريد إلكتروني صحيح';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField() {
    return TextFormField(
      controller: _passwordController,
      obscureText: _obscurePassword,
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
      style: const TextStyle(fontSize: 14, color: AppTheme.primaryContainer),
      decoration: _fieldDecoration(
        hint: '••••••••',
        icon: Icons.lock_outline_rounded,
        suffix: IconButton(
          icon: Icon(
            _obscurePassword
                ? Icons.visibility_off_rounded
                : Icons.visibility_rounded,
            color: AppTheme.onSurfaceVariant,
            size: 20,
          ),
          onPressed: () =>
              setState(() => _obscurePassword = !_obscurePassword),
        ),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'الرجاء إدخال كلمة المرور';
        }
        if (value.length < 6) {
          return 'كلمة المرور يجب أن تكون 6 أحرف على الأقل';
        }
        return null;
      },
    );
  }

  Widget _buildLoginButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _login,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: AppTheme.onPrimary,
          disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ).copyWith(
          shadowColor: WidgetStateProperty.all(Colors.transparent),
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
                      'تسجيل الدخول',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 20,
                      color: Colors.white,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildRegisterLink() {
    return Container(
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
            'ليس لديك حساب؟',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.5,
              color: AppTheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(width: 4),
          InkWell(
            onTap: () =>
                Navigator.pushReplacementNamed(context, '/register'),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              child: Text(
                'إنشاء حساب جديد',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  height: 1.5,
                  color: AppTheme.secondary,
                  decoration: TextDecoration.underline,
                  decorationColor:
                      AppTheme.secondary.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
//  نموذج بيانات حساب التطوير
// ============================================================
class _DevAccount {
  final String label;
  final String email;
  final String password;
  final IconData icon;
  final Color color;

  const _DevAccount({
    required this.label,
    required this.email,
    required this.password,
    required this.icon,
    required this.color,
  });
}

// ============================================================
//  زر حساب تطوير واحد
// ============================================================
class _DevAccountButton extends StatelessWidget {
  final _DevAccount account;
  final VoidCallback onTap;

  const _DevAccountButton({required this.account, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: account.color.withValues(alpha: 0.3), width: 1.2),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(account.icon, size: 16, color: account.color),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  account.label,
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w700,
                    color: account.color,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}