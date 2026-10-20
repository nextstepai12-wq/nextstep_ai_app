import 'package:flutter/material.dart';

import '../theming/app_theme.dart';
import 'app_buttons.dart';


Future<bool> showAppConfirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'تأكيد',
  String cancelLabel = 'إلغاء',
  bool destructive = false,
  IconData? icon,
}) async {
  final AppColors c = context.appColors;
  final bool? result = await showDialog<bool>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: destructive ? c.dangerSoft : c.primarySoft,
          shape: BoxShape.circle,
        ),
        child: Icon(
          icon ??
              (destructive
                  ? Icons.warning_amber_rounded
                  : Icons.help_outline_rounded),
          color: destructive ? c.danger : c.primary,
          size: 26,
        ),
      ),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      actions: <Widget>[
        Row(
          children: <Widget>[
            Expanded(
              child: AppSecondaryButton(
                label: cancelLabel,
                compact: true,
                onPressed: () => Navigator.of(dialogContext).pop(false),
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: AppPrimaryButton(
                label: confirmLabel,
                compact: true,
                danger: destructive,
                onPressed: () => Navigator.of(dialogContext).pop(true),
              ),
            ),
          ],
        ),
      ],
    ),
  );
  return result ?? false;
}


Future<void> showAppInfoDialog(
  BuildContext context, {
  required String title,
  required String message,
  String closeLabel = 'حسناً',
  IconData icon = Icons.info_outline_rounded,
}) {
  final AppColors c = context.appColors;
  return showDialog<void>(
    context: context,
    builder: (dialogContext) => AlertDialog(
      icon: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          color: c.infoSoft,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: c.info, size: 26),
      ),
      title: Text(title, textAlign: TextAlign.center),
      content: Text(message, textAlign: TextAlign.center),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        AppPrimaryButton(
          label: closeLabel,
          compact: true,
          fullWidth: false,
          onPressed: () => Navigator.of(dialogContext).pop(),
        ),
      ],
    ),
  );
}


class AppSheetOption extends StatelessWidget {
  const AppSheetOption({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.subtitle,
    this.color,
    this.destructive = false,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final VoidCallback onTap;
  final Color? color;
  final bool destructive;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final Color tone = destructive ? c.danger : (color ?? c.primary);
    return ListTile(
      onTap: onTap,
      leading: Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: tone.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.sm),
        ),
        child: Icon(icon, color: tone, size: 21),
      ),
      title: Text(
        title,
        style: context.textStyles.titleSmall?.copyWith(
          color: destructive ? c.danger : c.textPrimary,
        ),
      ),
      subtitle: subtitle == null
          ? null
          : Text(subtitle!, style: context.textStyles.bodySmall),
      trailing: Icon(
        Icons.chevron_left_rounded,
        color: c.textHint,
        size: 20,
      ),
    );
  }
}


class AppSheetHeader extends StatelessWidget {
  const AppSheetHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 0, 4, AppSpacing.sm),
      child: Row(
        children: <Widget>[
          if (icon != null) ...<Widget>[
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: c.primarySoft,
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: Icon(icon, color: c.primary, size: 21),
            ),
            const SizedBox(width: AppSpacing.sm),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  title,
                  style: context.textStyles.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (subtitle != null) ...<Widget>[
                  const SizedBox(height: 2),
                  Text(subtitle!, style: context.textStyles.bodySmall),
                ],
              ],
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}


class AppInlineAction extends StatelessWidget {
  const AppInlineAction({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.danger = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: danger ? c.danger : c.primary,
      ),
      icon: icon == null ? const SizedBox.shrink() : Icon(icon, size: 17),
      label: Text(label),
    );
  }
}


class AppCloseButton extends StatelessWidget {
  const AppCloseButton({
    super.key,
    required this.onPressed,
    this.tooltip = 'إغلاق',
    this.onDark = true,
  });

  final VoidCallback onPressed;
  final String tooltip;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return AppIconAction(
      icon: Icons.close_rounded,
      tooltip: tooltip,
      onPressed: onPressed,
      background: onDark ? Colors.white.withValues(alpha: 0.16) : c.surface,
      foreground: onDark ? Colors.white : c.textPrimary,
    );
  }
}
