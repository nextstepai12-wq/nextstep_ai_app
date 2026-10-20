import 'package:flutter/material.dart';

import '../theming/app_theme.dart';


class AppAvatar extends StatelessWidget {
  const AppAvatar({
    super.key,
    this.name = '',
    this.imageUrl,
    this.size = 48,
    this.backgroundColor,
    this.foregroundColor,
    this.showStatus = false,
    this.statusColor,
  });

  final String name;
  final String? imageUrl;
  final double size;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final bool showStatus;
  final Color? statusColor;

  String get _initials {
    final List<String> parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((String p) => p.isNotEmpty)
        .toList();
    if (parts.isEmpty) return '؟';
    if (parts.length == 1) {
      final String value = parts.first;
      return value.length > 2 ? value.substring(0, 2) : value;
    }
    return '${parts.first[0]}${parts[1][0]}';
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final Color bg = backgroundColor ?? c.primarySoft;
    final Color fg = foregroundColor ?? c.primary;

    final Widget fallback = Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: Border.all(color: fg.withValues(alpha: 0.16)),
      ),
      child: Text(
        _initials,
        maxLines: 1,
        overflow: TextOverflow.clip,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: size * 0.33,
          fontWeight: FontWeight.w800,
          color: fg,
          height: 1,
        ),
      ),
    );

    final Widget avatar = imageUrl == null || imageUrl!.isEmpty
        ? fallback
        : ClipOval(
            child: Image.network(
              imageUrl!,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => fallback,
            ),
          );

    if (!showStatus) return avatar;

    final Color dot = statusColor ?? c.success;
    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        avatar,
        PositionedDirectional(
          bottom: 0,
          end: 0,
          child: Container(
            width: size * 0.28,
            height: size * 0.28,
            decoration: BoxDecoration(
              color: dot,
              shape: BoxShape.circle,
              border: Border.all(color: c.surface, width: 2),
            ),
          ),
        ),
      ],
    );
  }
}
