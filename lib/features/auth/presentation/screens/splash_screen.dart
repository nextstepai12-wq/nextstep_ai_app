import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';
import 'package:nextstep_ai_app/core/widgets/gradient_background.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeInScale;
  late Animation<Offset> _slideUp1;
  late Animation<Offset> _slideUp2;
  late Animation<double> _fadeInButtons;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    );

    _fadeInScale = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.5, curve: Curves.easeOutBack),
      ),
    );

    _slideUp1 = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 0.6, curve: Curves.easeOut),
      ),
    );

    _slideUp2 = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.35, 0.7, curve: Curves.easeOut),
      ),
    );

    _fadeInButtons = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.5, 0.9, curve: Curves.easeIn),
      ),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
      
      // الانتقال التلقائي بعد 3 ثواني
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/login');
        }
      });
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GradientBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                // spacer صغير في الأعلى
                const SizedBox(height: 20),

                // logo
                AnimatedBuilder(
                  animation: _animationController,
                  builder: (context, child) {
                    return Transform.scale(
                      scale: _fadeInScale.value,
                      child: TweenAnimationBuilder(
                        duration: const Duration(seconds: 3),
                        tween: Tween<double>(begin: -8, end: 8),
                        builder: (context, value, child) {
                          return Transform.translate(
                            offset: Offset(0, value * 0.5),
                            child: Image.asset(
                              'assets/images/logo.png',
                              width: 200,
                              height: 200,
                              fit: BoxFit.contain,
                              errorBuilder: (_, __, ___) {
                                return Container(
                                  width: 180,
                                  height: 180,
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topLeft,
                                      end: Alignment.bottomRight,
                                      colors: [
                                        AppTheme.primary,
                                        AppTheme.primaryContainer,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                  child: const Icon(
                                    Icons.school,
                                    size: 80,
                                    color: Colors.white,
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

                const SizedBox(height: 16),

                // headline 1: NextStep AI
                SlideTransition(
                  position: _slideUp1,
                  child: RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: const TextStyle(
                        fontSize: 48,
                        fontWeight: FontWeight.w700,
                        height: 1.17,
                        letterSpacing: -0.02,
                      ),
                      children: [
                        const TextSpan(
                          text: 'NextStep ',
                          style: TextStyle(
                            color: AppTheme.primary,
                          ),
                        ),
                        TextSpan(
                          text: 'AI',
                          style: TextStyle(
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                            foreground: Paint()
                              ..shader = const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Color(0xFF3EDFAA),
                                  Color(0xFF2B69FD),
                                ],
                              ).createShader(
                                const Rect.fromLTWH(0, 0, 200, 70),
                              ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 8),

                // headline 2
                SlideTransition(
                  position: _slideUp2,
                  child: Text(
                    'مرحباً بك في رحلتك نحو مستقبل أفضل',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      height: 1.3,
                      color: AppTheme.primary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const SizedBox(height: 12),

                // subtitle
                SlideTransition(
                  position: _slideUp2,
                  child: Text(
                    'نساعد كل طالب على اختيار طريقه الصح... بالبيانات، لا بالصدفة',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.onSurfaceVariant,
                          height: 1.8,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ),

                const Spacer(flex: 2),

                // زر ابدأ الآن (مع إزالة النقاط)
                FadeTransition(
                  opacity: _fadeInButtons,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 32),
                    child: SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.pushReplacementNamed(context, '/login');
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: AppTheme.onPrimary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 4,
                          shadowColor: AppTheme.primary.withOpacity(0.3),
                        ),
                        child: const Text(
                          'ابدأ الآن',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            height: 1.14,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}