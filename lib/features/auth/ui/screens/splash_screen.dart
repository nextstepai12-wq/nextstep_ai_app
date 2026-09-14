import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter/scheduler.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/widgets/gradient_background.dart';
import 'package:nextstep_ai_app/core/helpers/token_manager.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _entrance;

  late final AnimationController _ambient;

  late final Animation<double> _logoScale;
  late final Animation<double> _logoRotation;
  late final Animation<double> _logoOpacity;
  late final Animation<double> _glowPulse;
  late final Animation<double> _logoFloat;

  late final Animation<double> _titleOpacity;
  late final Animation<Offset> _titleSlide;

  late final Animation<double> _subtitleOpacity;
  late final Animation<Offset> _subtitleSlide;

  late final Animation<double> _descOpacity;
  late final Animation<Offset> _descSlide;

  late final Animation<double> _buttonOpacity;
  late final Animation<Offset> _buttonSlide;
  late final Animation<double> _buttonScale;

  late final Animation<double> _progressOpacity;

  bool _pressed = false;

  @override
  void initState() {
    super.initState();

    _entrance = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    _ambient = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4200),
    )..repeat();

    _logoScale = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.4, end: 1.08)
            .chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.08, end: 1.0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.0, 0.45, curve: Curves.linear),
      ),
    );

    _logoRotation = Tween<double>(begin: -0.35, end: 0.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.0, 0.45, curve: Curves.easeOutCubic),
      ),
    );

    _logoOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.0, 0.3, curve: Curves.easeOut),
      ),
    );

    _glowPulse = Tween<double>(begin: 0.55, end: 1.0).animate(
      CurvedAnimation(parent: _ambient, curve: Curves.easeInOut),
    );

    _logoFloat = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _ambient, curve: Curves.easeInOut),
    );

    _titleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.28, 0.58, curve: Curves.easeOut),
      ),
    );
    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 0.45),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.28, 0.62, curve: Curves.easeOutCubic),
      ),
    );
    _subtitleOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.42, 0.7, curve: Curves.easeOut),
      ),
    );
    _subtitleSlide = Tween<Offset>(
      begin: const Offset(0, 0.35),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.42, 0.72, curve: Curves.easeOutCubic),
      ),
    );

    _descOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.52, 0.8, curve: Curves.easeOut),
      ),
    );
    _descSlide = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.52, 0.82, curve: Curves.easeOutCubic),
      ),
    );

    _buttonOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.66, 0.92, curve: Curves.easeOut),
      ),
    );
    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.66, 0.95, curve: Curves.easeOutCubic),
      ),
    );
    _buttonScale = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.7, 1.0, curve: Curves.easeOutBack),
      ),
    );

    _progressOpacity = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entrance,
        curve: const Interval(0.85, 1.0, curve: Curves.easeIn),
      ),
    );

    SchedulerBinding.instance.addPostFrameCallback((_) {
      _entrance.forward();

      Future.delayed(const Duration(milliseconds: 3400), () {
        if (mounted) _goToLogin();
      });
    });
  }

  void _goToLogin() async {
    try {
      final isLoggedIn = await TokenManager.isLoggedIn();
      if (!isLoggedIn) {
        if (mounted) context.pushReplacement('/login');
        return;
      }
      final userData = await TokenManager.getUserData();
      final role = userData['role'] ?? 'student';
      final route = switch (role) {
        'university' => '/university',
        'admin' => '/admin',
        'training_center' => '/training-center',
        _ => '/student',
      };
      if (mounted) context.pushReplacement(route);
    } catch (e) {
      if (mounted) context.pushReplacement('/login');
    }
  }

  @override
  void dispose() {
    _entrance.dispose();
    _ambient.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GradientBackground(
        child: Stack(
          children: [
            AnimatedBuilder(
              animation: _ambient,
              builder: (context, _) => IgnorePointer(
                child: CustomPaint(
                  size: Size(size.width, size.height),
                  painter: _ParticlesPainter(
                    progress: _ambient.value,
                    color: AppTheme.primary,
                  ),
                ),
              ),
            ),

            SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const Spacer(flex: 3),

                    AnimatedBuilder(
                      animation: Listenable.merge([_entrance, _ambient]),
                      builder: (context, child) {
                        return Opacity(
                          opacity: _logoOpacity.value,
                          child: Transform.translate(
                            offset: Offset(0, _logoFloat.value),
                            child: Transform.rotate(
                              angle: _logoRotation.value,
                              child: Transform.scale(
                                scale: _logoScale.value,
                                child: child,
                              ),
                            ),
                          ),
                        );
                      },
                      child: AnimatedBuilder(
                        animation: _glowPulse,
                        builder: (context, child) {
                          return Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.primary
                                      .withOpacity(0.35 * _glowPulse.value),
                                  blurRadius: 60 * _glowPulse.value,
                                  spreadRadius: 6 * _glowPulse.value,
                                ),
                                BoxShadow(
                                  color: const Color(0xFF3EDFAA)
                                      .withOpacity(0.25 * _glowPulse.value),
                                  blurRadius: 90 * _glowPulse.value,
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: child,
                          );
                        },
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(36),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: 168,
                            height: 168,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => Container(
                              width: 168,
                              height: 168,
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                  colors: [
                                    Color(0xFF3EDFAA),
                                    Color(0xFF2B69FD),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(36),
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                size: 72,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 36),

                    AnimatedBuilder(
                      animation: _entrance,
                      builder: (context, child) {
                        return Opacity(
                          opacity: _titleOpacity.value,
                          child: Transform.translate(
                            offset: Offset(
                              0,
                              _titleSlide.value.dy *
                                  MediaQuery.of(context).size.height *
                                  0.06,
                            ),
                            child: child,
                          ),
                        );
                      },
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: const TextStyle(
                            fontSize: 44,
                            fontWeight: FontWeight.w800,
                            height: 1.15,
                            letterSpacing: -0.5,
                          ),
                          children: [
                            const TextSpan(
                              text: 'NextStep ',
                              style: TextStyle(color: AppTheme.primary),
                            ),
                            TextSpan(
                              text: 'AI',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                foreground: Paint()
                                  ..shader = const LinearGradient(
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                    colors: [
                                      Color(0xFF3EDFAA),
                                      Color(0xFF2B69FD),
                                    ],
                                  ).createShader(
                                    const Rect.fromLTWH(0, 0, 180, 60),
                                  ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    FadeTransition(
                      opacity: _subtitleOpacity,
                      child: SlideTransition(
                        position: _subtitleSlide,
                        child: ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [
                              AppTheme.primary,
                              Color(0xFF2B69FD),
                            ],
                          ).createShader(bounds),
                          child: const Text(
                            'مرحباً بك في رحلتك نحو مستقبل أفضل',
                            style: TextStyle(
                              fontSize: 19,
                              fontWeight: FontWeight.w700,
                              height: 1.3,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    FadeTransition(
                      opacity: _descOpacity,
                      child: SlideTransition(
                        position: _descSlide,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'نساعد كل طالب على اختيار طريقه الصح... بالبيانات، لا بالصدفة',
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(
                                  color: AppTheme.onSurfaceVariant,
                                  height: 1.8,
                                  fontSize: 15,
                                ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),

                    const Spacer(flex: 4),

                    FadeTransition(
                      opacity: _progressOpacity,
                      child: const _DotsLoader(),
                    ),

                    const SizedBox(height: 20),

                    FadeTransition(
                      opacity: _buttonOpacity,
                      child: SlideTransition(
                        position: _buttonSlide,
                        child: ScaleTransition(
                          scale: _buttonScale,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 28),
                            child: GestureDetector(
                              onTapDown: (_) =>
                                  setState(() => _pressed = true),
                              onTapCancel: () =>
                                  setState(() => _pressed = false),
                              onTapUp: (_) {
                                setState(() => _pressed = false);
                                _goToLogin();
                              },
                              child: AnimatedScale(
                                scale: _pressed ? 0.97 : 1.0,
                                duration: const Duration(milliseconds: 120),
                                curve: Curves.easeOut,
                                child: Container(
                                  width: double.infinity,
                                  height: 58,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                      colors: [
                                        Color(0xFF2B69FD),
                                        Color(0xFF3EDFAA),
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(18),
                                    boxShadow: [
                                      BoxShadow(
                                        color:
                                            AppTheme.primary.withOpacity(0.4),
                                        blurRadius: 24,
                                        offset: const Offset(0, 10),
                                      ),
                                    ],
                                  ),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.center,
                                    children: const [
                                      Text(
                                        'ابدأ الآن',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w700,
                                          color: Colors.white,
                                          height: 1.14,
                                        ),
                                      ),
                                      SizedBox(width: 8),
                                      Icon(
                                        Icons.arrow_back_rounded,
                                        color: Colors.white,
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
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
          ],
        ),
      ),
    );
  }
}

class _DotsLoader extends StatefulWidget {
  const _DotsLoader();

  @override
  State<_DotsLoader> createState() => _DotsLoaderState();
}

class _DotsLoaderState extends State<_DotsLoader>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1100),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (i) {
            final t = (_controller.value - (i * 0.2)) % 1.0;
            final scale = 0.6 + 0.5 * math.sin(t * math.pi).abs();
            final opacity = 0.4 + 0.6 * math.sin(t * math.pi).abs();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 9,
                  height: 9,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.primary.withOpacity(opacity),
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

class _ParticlesPainter extends CustomPainter {
  _ParticlesPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  static final List<Offset> _seeds = List.generate(
    18,
    (i) => Offset(
      (i * 53 % 100) / 100,
      (i * 37 % 100) / 100,
    ),
  );

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    for (var i = 0; i < _seeds.length; i++) {
      final seed = _seeds[i];
      final phase = (progress + i / _seeds.length) % 1.0;
      final dy = (seed.dy - phase * 0.15) % 1.0;
      final dx = seed.dx + 0.02 * math.sin((progress * 2 * math.pi) + i);

      final radius = 1.4 + (i % 3) * 0.9;
      final opacity = 0.06 + 0.05 * math.sin(phase * math.pi);

      paint.color = color.withOpacity(opacity.clamp(0.0, 0.14));
      canvas.drawCircle(
        Offset(dx * size.width, dy * size.height),
        radius,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _ParticlesPainter oldDelegate) =>
      oldDelegate.progress != progress;
}
