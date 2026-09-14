import 'package:flutter/material.dart';
// import 'package:nextstep_ai_app/core/theming/app_theme.dart';

class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFFF8F9FF),
            Color(0xFFFFFFFF),
          ],
          stops: [0.0, 0.5],
        ),
      ),
      child: child,
    );
  }
}
