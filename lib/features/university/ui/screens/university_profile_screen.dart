import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/features/university/ui/widgets/university_bottom_nav.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Dummy data — replace with API models later.
// ─────────────────────────────────────────────────────────────────────────────

class UniversityProfile {
  const UniversityProfile({
    required this.name,
    required this.city,
    required this.facultiesCount,
    required this.programsCount,
    required this.studentsCount,
    required this.rating,
    required this.completion,
    required this.plan,
    required this.renewalDate,
  });

  final String name;
  final String city;
  final int facultiesCount;
  final int programsCount;
  final int studentsCount;
  final double rating;

  /// Profile completion ratio between 0.0 and 1.0.
  final double completion;
  final String plan;
  final String renewalDate;
}

const UniversityProfile _university = UniversityProfile(
  name: 'جامعة العلوم والتكنولوجيا',
  city: 'صنعاء، اليمن',
  facultiesCount: 8,
  programsCount: 24,
  studentsCount: 1250,
  rating: 4.8,
  completion: 0.65,
  plan: 'الخطة المميزة',
  renewalDate: 'تتجدد في 15 مارس 2025',
);

// ─────────────────────────────────────────────────────────────────────────────
// Screen
// ─────────────────────────────────────────────────────────────────────────────

class UniversityProfileScreen extends StatelessWidget {
  const UniversityProfileScreen({super.key});

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
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                _ProfileHeader(
                  onEdit: () => _showMessage(context, 'تعديل الملف الشخصي'),
                ),
                _HeroCard(
                  university: _university,
                  onCameraTap: () =>
                      _showMessage(context, 'تغيير شعار الجامعة'),
                ),
                const _QuickStats(university: _university),
                _SettingsSection(
                  title: 'إعدادات الحساب',
                  tiles: <Widget>[
                    _SettingTile(
                      icon: Icons.business,
                      iconColor: c.primary,
                      iconBackground: c.primarySoft,
                      label: 'إدارة الكليات',
                      value: '${_university.facultiesCount} كليات',
                      onTap: () => _showMessage(context, 'إدارة الكليات'),
                    ),
                    _SettingTile(
                      icon: Icons.account_circle,
                      iconColor: c.purple,
                      iconBackground: c.purpleSoft,
                      label: 'معلومات الجامعة',
                      value: 'تعديل',
                      onTap: () => _showMessage(context, 'معلومات الجامعة'),
                    ),
                    _SettingTile(
                      icon: Icons.notifications,
                      iconColor: c.accent,
                      iconBackground: c.accentSoft,
                      label: 'الإشعارات',
                      value: 'مفعّلة',
                      onTap: () => _showMessage(context, 'إعدادات الإشعارات'),
                    ),
                    _SettingTile(
                      icon: Icons.language,
                      iconColor: c.success,
                      iconBackground: c.successSoft,
                      label: 'اللغة',
                      value: 'العربية',
                      onTap: () => _showMessage(context, 'تغيير اللغة'),
                    ),
                    _SettingTile(
                      icon: Icons.dark_mode,
                      iconColor: c.primary,
                      iconBackground: c.primarySoft,
                      label: 'المظهر',
                      value: _themeModeLabel(themeMode),
                      valueAsPill: true,
                      onTap: () =>
                          AppTheme.setThemeMode(_nextThemeMode(themeMode)),
                    ),
                  ],
                ),
                const _SubscriptionCard(university: _university),
                _SettingsSection(
                  title: 'الدعم والمساعدة',
                  tiles: <Widget>[
                    _SettingTile(
                      icon: Icons.help_outline,
                      iconColor: c.primary,
                      iconBackground: c.primarySoft,
                      label: 'مركز المساعدة',
                      onTap: () => _showMessage(context, 'مركز المساعدة'),
                    ),
                    _SettingTile(
                      icon: Icons.chat_bubble_outline,
                      iconColor: c.purple,
                      iconBackground: c.purpleSoft,
                      label: 'تواصل معنا',
                      onTap: () => _showMessage(context, 'تواصل معنا'),
                    ),
                    _SettingTile(
                      icon: Icons.description,
                      iconColor: c.success,
                      iconBackground: c.successSoft,
                      label: 'الشروط والأحكام',
                      onTap: () => _showMessage(context, 'الشروط والأحكام'),
                    ),
                    _SettingTile(
                      icon: Icons.lock_outline,
                      iconColor: c.accent,
                      iconBackground: c.accentSoft,
                      label: 'سياسة الخصوصية',
                      onTap: () => _showMessage(context, 'سياسة الخصوصية'),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    children: <Widget>[
                      _LogoutButton(onTap: () => _confirmLogout(context)),
                      const SizedBox(height: 16),
                      Text(
                        'NextStep AI — الإصدار 1.0.0',
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 11,
                          color: c.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ],
            ),
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

// ─────────────────────────────────────────────────────────────────────────────
// (1) Header
// ─────────────────────────────────────────────────────────────────────────────

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.onEdit});

  final VoidCallback onEdit;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: <Widget>[
          Text(
            'الملف الشخصي',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const Spacer(),
          DecoratedBox(
            decoration: _cardDecoration(c, radius: 16),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onEdit,
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.edit, size: 20, color: c.primary),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (2) Profile hero card
// ─────────────────────────────────────────────────────────────────────────────

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.university, required this.onCameraTap});

  final UniversityProfile university;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        decoration: _cardDecoration(c, radius: 24),
        child: Column(
          children: <Widget>[
            SizedBox(
              height: 128,
              child: Stack(
                children: <Widget>[
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: ClipRRect(
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(24),
                      ),
                      child: SizedBox(
                        height: 90,
                        child: Stack(
                          children: <Widget>[
                            Positioned.fill(
                              child: DecoratedBox(
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                    colors: <Color>[c.primary, c.purple],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              top: -32,
                              right: -18,
                              child: _glow(
                                  96, Colors.white.withValues(alpha: 0.08)),
                            ),
                            Positioned(
                              bottom: -22,
                              left: -12,
                              child:
                                  _glow(72, c.purple.withValues(alpha: 0.20)),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 52,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: _Avatar(
                        icon: Icons.school,
                        onCameraTap: onCameraTap,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: <Widget>[
                  Text(
                    university.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Icon(Icons.location_on, size: 13, color: c.textSecondary),
                      const SizedBox(width: 4),
                      Text(
                        university.city,
                        style: TextStyle(
                          fontFamily: AppTheme.fontFamily,
                          fontSize: 12,
                          color: c.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      _Pill(
                        text: '✓ جامعة موثقة',
                        background: c.primarySoft,
                        foreground: c.primary,
                      ),
                      const SizedBox(width: 8),
                      _Pill(
                        text: '✦ خطة مميزة',
                        background: c.accentSoft,
                        foreground: c.accent,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            _CompletionCard(completion: university.completion),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _glow(double size, Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.icon, required this.onCameraTap});

  final IconData icon;
  final VoidCallback onCameraTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return SizedBox(
      width: 76,
      height: 76,
      child: Stack(
        clipBehavior: Clip.none,
        children: <Widget>[
          Container(
            width: 76,
            height: 76,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: c.surface,
              shape: BoxShape.circle,
              border: Border.all(color: c.surface, width: 4),
            ),
            child: Icon(icon, size: 34, color: c.primary),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: GestureDetector(
              onTap: onCameraTap,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: c.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: c.surface, width: 2.5),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  size: 13,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CompletionCard extends StatelessWidget {
  const _CompletionCard({required this.completion});

  final double completion;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;
    final int percent = (completion * 100).round();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: c.isDark ? c.surfaceAlt : c.background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                'اكتمال الملف',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: c.textPrimary,
                ),
              ),
              const Spacer(),
              Text(
                '$percent%',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: c.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(50),
            child: SizedBox(
              width: double.infinity,
              height: 8,
              child: Stack(
                children: <Widget>[
                  Positioned.fill(
                    child: ColoredBox(color: c.divider),
                  ),
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: FractionallySizedBox(
                        widthFactor: completion.clamp(0.0, 1.0),
                        heightFactor: 1,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: <Color>[c.primary, c.purple],
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
          const SizedBox(height: 8),
          Text(
            'أضف نبذة وصور الحرم الجامعي لتحصل على ظهور أفضل للطلاب',
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 10,
              height: 1.6,
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (3) Quick stats
// ─────────────────────────────────────────────────────────────────────────────

class _QuickStats extends StatelessWidget {
  const _QuickStats({required this.university});

  final UniversityProfile university;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: _cardDecoration(c, radius: 20),
        child: Row(
          children: <Widget>[
            Expanded(
              child: _StatItem(
                icon: Icons.menu_book,
                color: c.primary,
                background: c.primarySoft,
                value: '${university.programsCount}',
                label: 'تخصص',
              ),
            ),
            _divider(c),
            Expanded(
              child: _StatItem(
                icon: Icons.groups,
                color: c.success,
                background: c.successSoft,
                value: _formatThousands(university.studentsCount),
                label: 'طالب',
              ),
            ),
            _divider(c),
            Expanded(
              child: _StatItem(
                icon: Icons.star,
                color: c.accent,
                background: c.accentSoft,
                value: university.rating.toStringAsFixed(1),
                label: 'التقييم',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider(AppColors c) {
    return Container(width: 1, height: 44, color: c.divider);
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.color,
    required this.background,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color color;
  final Color background;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Column(
      children: <Widget>[
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: background, shape: BoxShape.circle),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: c.textPrimary,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 11,
            color: c.textSecondary,
          ),
        ),
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (4 & 6) Settings / support sections
// ─────────────────────────────────────────────────────────────────────────────

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.title, required this.tiles});

  final String title;
  final List<Widget> tiles;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    final List<Widget> children = <Widget>[];
    for (int i = 0; i < tiles.length; i++) {
      if (i > 0) {
        children.add(
          Divider(height: 1, thickness: 1, indent: 66, color: c.divider),
        );
      }
      children.add(tiles[i]);
    }

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            title,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: _cardDecoration(c, radius: 20),
            clipBehavior: Clip.antiAlias,
            child: Column(children: children),
          ),
        ],
      ),
    );
  }
}

class _SettingTile extends StatelessWidget {
  const _SettingTile({
    required this.icon,
    required this.iconColor,
    required this.iconBackground,
    required this.label,
    this.value,
    this.valueAsPill = false,
    this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final Color iconBackground;
  final String label;
  final String? value;
  final bool valueAsPill;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: <Widget>[
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: iconBackground,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(icon, size: 19, color: iconColor),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: c.textPrimary,
                  ),
                ),
              ),
              if (value != null && valueAsPill)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.primarySoft,
                    borderRadius: BorderRadius.circular(50),
                  ),
                  child: Text(
                    value!,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: c.primary,
                    ),
                  ),
                )
              else if (value != null)
                Text(
                  value!,
                  style: TextStyle(
                    fontFamily: AppTheme.fontFamily,
                    fontSize: 12,
                    color: c.textSecondary,
                  ),
                ),
              const SizedBox(width: 4),
              Icon(Icons.chevron_left, size: 18, color: c.textSecondary),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (5) Subscription
// ─────────────────────────────────────────────────────────────────────────────

class _SubscriptionCard extends StatelessWidget {
  const _SubscriptionCard({required this.university});

  final UniversityProfile university;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(c, radius: 20),
        child: Row(
          children: <Widget>[
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: <Color>[Color(0xFFF59E0B), Color(0xFFF97316)],
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.workspace_premium,
                size: 24,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    university.plan,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: c.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    university.renewalDate,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: AppTheme.fontFamily,
                      fontSize: 11,
                      color: c.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _Pill(
              text: 'إدارة',
              background: c.accentSoft,
              foreground: c.accent,
              horizontalPadding: 12,
              verticalPadding: 6,
              onTap: () => _showMessage(context, 'إدارة الاشتراك'),
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (7) Logout button
// ─────────────────────────────────────────────────────────────────────────────

class _LogoutButton extends StatelessWidget {
  const _LogoutButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: c.dangerSoft,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(Icons.logout, size: 20, color: c.danger),
              const SizedBox(width: 8),
              Text(
                'تسجيل الخروج',
                style: TextStyle(
                  fontFamily: AppTheme.fontFamily,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: c.danger,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// (8) Logout confirmation dialog
// ─────────────────────────────────────────────────────────────────────────────

class _LogoutDialog extends StatelessWidget {
  const _LogoutDialog();

  @override
  Widget build(BuildContext context) {
    final AppColors c = context.appColors;

    return AlertDialog(
      backgroundColor: c.surface,
      surfaceTintColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
      contentPadding: const EdgeInsets.all(24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: c.dangerSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(Icons.logout, size: 28, color: c.danger),
          ),
          const SizedBox(height: 16),
          Text(
            'تسجيل الخروج؟',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: c.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'هل أنت متأكد من رغبتك في الخروج من حساب الجامعة؟',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              height: 1.6,
              color: c.textSecondary,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: <Widget>[
              Expanded(
                child: _DialogButton(
                  label: 'إلغاء',
                  background: c.isDark ? c.surfaceAlt : c.background,
                  foreground: c.textPrimary,
                  onTap: () => Navigator.of(context).pop(false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _DialogButton(
                  label: 'خروج',
                  background: c.danger,
                  foreground: Colors.white,
                  onTap: () => Navigator.of(context).pop(true),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DialogButton extends StatelessWidget {
  const _DialogButton({
    required this.label,
    required this.background,
    required this.foreground,
    required this.onTap,
  });

  final String label;
  final Color background;
  final Color foreground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontFamily: AppTheme.fontFamily,
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: foreground,
            ),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Shared pieces
// ─────────────────────────────────────────────────────────────────────────────

class _Pill extends StatelessWidget {
  const _Pill({
    required this.text,
    required this.background,
    required this.foreground,
    this.horizontalPadding = 12,
    this.verticalPadding = 4,
    this.onTap,
  });

  final String text;
  final Color background;
  final Color foreground;
  final double horizontalPadding;
  final double verticalPadding;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final Widget pill = Container(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: verticalPadding,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(50),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: AppTheme.fontFamily,
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: foreground,
        ),
      ),
    );

    if (onTap == null) return pill;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(50),
        child: pill,
      ),
    );
  }
}

BoxDecoration _cardDecoration(AppColors c, {required double radius}) {
  return BoxDecoration(
    color: c.surface,
    borderRadius: BorderRadius.circular(radius),
    border: c.isDark ? Border.all(color: c.divider) : null,
    boxShadow: c.isDark
        ? null
        : <BoxShadow>[
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
  );
}

String _themeModeLabel(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'الوضع الفاتح';
    case ThemeMode.dark:
      return 'الوضع الداكن';
    case ThemeMode.system:
      return 'النظام';
  }
}

ThemeMode _nextThemeMode(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return ThemeMode.dark;
    case ThemeMode.dark:
      return ThemeMode.system;
    case ThemeMode.system:
      return ThemeMode.light;
  }
}

String _formatThousands(int value) {
  final String digits = value.toString();
  final StringBuffer buffer = StringBuffer();
  for (int i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) {
      buffer.write(',');
    }
    buffer.write(digits[i]);
  }
  return buffer.toString();
}

void _showMessage(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: context.appColors.textPrimary,
        content: Text(
          message,
          style: TextStyle(
            fontFamily: AppTheme.fontFamily,
            fontSize: 13,
            color: context.appColors.background,
          ),
        ),
      ),
    );
}

Future<void> _confirmLogout(BuildContext context) async {
  final bool? confirmed = await showDialog<bool>(
    context: context,
    builder: (BuildContext context) => const _LogoutDialog(),
  );
  if (confirmed == true && context.mounted) {
    _showMessage(context, 'تم تسجيل الخروج بنجاح');
  }
}
