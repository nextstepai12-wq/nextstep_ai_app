import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nextstep_ai_app/core/helpers/session_helper.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/widgets/app_card.dart';
import 'package:nextstep_ai_app/core/widgets/app_section_header.dart';
import 'package:nextstep_ai_app/features/university/ui/widgets/university_bottom_nav.dart';

/// University settings surface. Profile data lives in
/// [UniversityProfileScreen]; this screen only exposes device-level and
/// account controls that are actually supported today.
class UniversitySettingsScreen extends StatelessWidget {
  const UniversitySettingsScreen({super.key});

  void _onNavChanged(BuildContext context, int index) {
    if (index == 4) return;
    switch (index) {
      case 0:
        context.go('/university');
        break;
      case 1:
        context.go('/university/programs');
        break;
      case 2:
        context.go('/university/analytics');
        break;
      case 3:
        context.go('/university/students');
        break;
    }
  }

  void _showUnavailable(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسجيل الخروج؟'),
        content: const Text(
          'هل أنت متأكد من رغبتك في الخروج من حساب الجامعة؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('إلغاء'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('خروج'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      await logoutToLogin(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final ThemeMode themeMode = AppTheme.themeMode;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        body: SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            children: [
              const AppSectionHeader(
                title: 'الإعدادات',
                subtitle: 'خيارات الحساب والمظهر على هذا الجهاز',
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'إعدادات الحساب',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SettingsTile(
                      icon: Icons.business,
                      label: 'الملف التعريفي للجامعة',
                      value: 'عرض',
                      onTap: () => context.push('/university/profile'),
                    ),
                    _SettingsTile(
                      icon: Icons.apartment,
                      label: 'إدارة الكليات',
                      value: 'فتح',
                      onTap: () => context.push('/university/faculties'),
                    ),
                    _SettingsTile(
                      icon: Icons.notifications_none_rounded,
                      label: 'الإشعارات',
                      value: 'فتح',
                      onTap: () => context.push('/university/notifications'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'المظهر والعرض',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    _ThemeTile(
                      mode: themeMode,
                      onChanged: (mode) => AppTheme.setThemeMode(mode),
                    ),
                    const Divider(height: AppSpacing.xl),
                    _SettingsTile(
                      icon: Icons.language,
                      label: 'لغة التطبيق',
                      value: 'العربية فقط',
                      onTap: () => _showUnavailable(
                        context,
                        'اللغات الأخرى غير متاحة حالياً',
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'الدعم والمساعدة',
                      style: TextStyle(fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    _SettingsTile(
                      icon: Icons.chat_bubble_outline,
                      label: 'تواصل معنا',
                      onTap: () => context.push('/contact-us'),
                    ),
                    _SettingsTile(
                      icon: Icons.description_outlined,
                      label: 'الشروط والأحكام',
                      onTap: () => context.push('/terms-conditions'),
                    ),
                    _SettingsTile(
                      icon: Icons.lock_outline,
                      label: 'سياسة الخصوصية',
                      onTap: () => context.push('/privacy-policy'),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              OutlinedButton.icon(
                onPressed: () => _confirmLogout(context),
                icon: const Icon(Icons.logout, size: 20),
                label: const Text('تسجيل الخروج'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: c.danger,
                  side: BorderSide(color: c.danger.withValues(alpha: 0.4)),
                  minimumSize: const Size.fromHeight(52),
                ),
              ),
            ],
          ),
        ),
        bottomNavigationBar: UniversityBottomNav(
          currentIndex: 4,
          onChanged: (int index) => _onNavChanged(context, index),
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({
    required this.icon,
    required this.label,
    required this.onTap,
    this.value,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final String? value;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icon, color: c.primary),
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (value != null) ...[
            Text(value!, style: context.textStyles.bodySmall),
            const SizedBox(width: 4),
          ],
          Icon(Icons.chevron_left_rounded, color: c.textSecondary, size: 20),
        ],
      ),
      onTap: onTap,
    );
  }
}

class _ThemeTile extends StatelessWidget {
  const _ThemeTile({required this.mode, required this.onChanged});

  final ThemeMode mode;
  final ValueChanged<ThemeMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(Icons.dark_mode_outlined, color: c.primary),
      title: const Text('مظهر التطبيق'),
      subtitle: Text(switch (mode) {
        ThemeMode.light => 'الوضع الفاتح',
        ThemeMode.dark => 'الوضع الداكن',
        ThemeMode.system => 'حسب النظام',
      }),
      trailing: SegmentedButton<ThemeMode>(
        segments: const [
          ButtonSegment(
            value: ThemeMode.light,
            icon: Icon(Icons.light_mode_outlined),
            tooltip: 'فاتح',
          ),
          ButtonSegment(
            value: ThemeMode.system,
            icon: Icon(Icons.settings_brightness_outlined),
            tooltip: 'حسب النظام',
          ),
          ButtonSegment(
            value: ThemeMode.dark,
            icon: Icon(Icons.dark_mode_outlined),
            tooltip: 'داكن',
          ),
        ],
        selected: <ThemeMode>{mode},
        showSelectedIcon: false,
        onSelectionChanged: (selection) => onChanged(selection.first),
      ),
    );
  }
}
