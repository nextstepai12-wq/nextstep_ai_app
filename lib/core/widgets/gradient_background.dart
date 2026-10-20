import 'package:flutter/material.dart';

import '../theming/app_theme.dart';


class GradientBackground extends StatelessWidget {
  final Widget child;

  const GradientBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: <Color>[
            c.background,
            c.primarySoft,
            c.background,
          ],
          stops: const <double>[0.0, 0.55, 1.0],
        ),
      ),
      child: child,
    );
  }
}


class AppBackgroundOrb extends StatelessWidget {
  const AppBackgroundOrb({
    super.key,
    required this.size,
    this.color,
    this.opacity = 0.14,
    this.alignment = AlignmentDirectional.topEnd,
  });

  final double size;
  final Color? color;
  final double opacity;
  final AlignmentGeometry alignment;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return Align(
      alignment: alignment,
      child: IgnorePointer(
        child: Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: RadialGradient(
              colors: <Color>[
                (color ?? c.primary).withValues(alpha: opacity),
                (color ?? c.primary).withValues(alpha: 0.0),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
