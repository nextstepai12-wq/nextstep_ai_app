import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:nextstep_ai_app/core/helpers/session_helper.dart';

import '../theme/training_colors.dart';

class CenterProfileScreen extends StatelessWidget {
  const CenterProfileScreen({super.key});

  static const String _companyName = 'شركة التدريب التقني';
  static const String _registrationNumber = '1010456789';
  static const String _memberSince = '2021';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrainingColors.background,
      body: ListView(
        padding: EdgeInsets.only(bottom: 32.h),
        physics: const BouncingScrollPhysics(),
        children: [
          _buildHeaderWithStats(context),
          SizedBox(height: 20.h),
          _buildCompletionStrip(context),
          SizedBox(height: 16.h),
          _buildQuickAccess(context),
          SizedBox(height: 20.h),
          _buildManagementSection(context),
          SizedBox(height: 20.h),
          _buildFinanceSection(context),
          SizedBox(height: 24.h),
          _buildLogout(context),
          SizedBox(height: 20.h),
          _buildFooter(),
        ],
      ),
    );
  }

  
  
  

  Widget _buildHeaderWithStats(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 26.h),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          _buildHeader(context),
          Positioned(
            bottom: -26.h,
            left: 16.w,
            right: 16.w,
            child: _buildStatsCard(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    final double topInset = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, topInset + 14.h, 16.w, 46.h),
      decoration: BoxDecoration(
        gradient: TrainingColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24.r)),
        boxShadow: TrainingColors.headerShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -30.h,
            left: -40.w,
            child: Container(
              width: 150.w,
              height: 150.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50.h,
            right: -50.w,
            child: Container(
              width: 170.w,
              height: 170.w,
              decoration: BoxDecoration(
                color: TrainingColors.accent.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            children: [
              Row(
                children: [
                  _headerCircleButton(
                    icon: Icons.settings_rounded,
                    onTap: () => context.push('/training-center/settings'),
                  ),
                  const Spacer(),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 5.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.domain_rounded,
                          size: 15.sp,
                          color: TrainingColors.accent,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'حساب تجريبي',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: TrainingColors.onPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Spacer(),
                  _headerCircleButton(
                    icon: Icons.notifications_none_rounded,
                    showDot: true,
                    onTap: () => context.push('/training-center/notifications'),
                  ),
                ],
              ),
              SizedBox(height: 16.h),
              Stack(
                clipBehavior: Clip.none,
                children: [
                  Container(
                    width: 80.w,
                    height: 80.w,
                    decoration: const BoxDecoration(
                      color: TrainingColors.surface,
                      shape: BoxShape.circle,
                      boxShadow: TrainingColors.softShadow,
                    ),
                    child: Icon(
                      Icons.hub_rounded,
                      size: 38.sp,
                      color: TrainingColors.primary,
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      width: 24.w,
                      height: 24.w,
                      decoration: BoxDecoration(
                        color: TrainingColors.accent,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: TrainingColors.surface,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.verified_rounded,
                        size: 13.sp,
                        color: TrainingColors.onAccent,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Text(
                _companyName,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 19.sp,
                  fontWeight: FontWeight.w800,
                  color: TrainingColors.onPrimary,
                ),
              ),
              SizedBox(height: 4.h),
              Wrap(
                alignment: WrapAlignment.center,
                crossAxisAlignment: WrapCrossAlignment.center,
                spacing: 6.w,
                runSpacing: 2.h,
                children: [
                  Icon(
                    Icons.check_circle_rounded,
                    size: 14.sp,
                    color: const Color(0xFF7FE3B8),
                  ),
                  Text(
                    'حساب شركة موثّق',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5.sp,
                      color: const Color(0xFF9EE9C9),
                    ),
                  ),
                  Text(
                    '•',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 10.sp,
                      color: Colors.white.withValues(alpha: 0.4),
                    ),
                  ),
                  Text(
                    'س.ت: $_registrationNumber',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.5.sp,
                      color: Colors.white.withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 12.h),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 8.w,
                runSpacing: 6.h,
                children: [
                  _trustBadge(
                    icon: Icons.star_rounded,
                    iconColor: const Color(0xFFFFB95F),
                    text: '4.8',
                    trailing: 'تقييم المنشأة',
                  ),
                  _trustBadge(
                    icon: Icons.verified_user_rounded,
                    iconColor: const Color(0xFFACC7FF),
                    text: 'منذ $_memberSince (تجريبي)',
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerCircleButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 20.sp, color: TrainingColors.onPrimary),
            if (showDot)
              Positioned(
                top: 9.h,
                left: 9.w,
                child: Container(
                  width: 9.w,
                  height: 9.w,
                  decoration: BoxDecoration(
                    color: TrainingColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: TrainingColors.primaryContainer,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _trustBadge({
    required IconData icon,
    required Color iconColor,
    required String text,
    String? trailing,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 5.h),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: iconColor),
          SizedBox(width: 4.w),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10.5.sp,
              fontWeight: FontWeight.w700,
              color: TrainingColors.onPrimary,
            ),
          ),
          if (trailing != null) ...[
            SizedBox(width: 4.w),
            Text(
              trailing,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.sp,
                color: Colors.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatsCard() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.cardShadow,
      ),
      child: Row(
        children: [
          _statItem(Icons.menu_book_rounded, '16', 'الدورات'),
          _statDivider(),
          _statItem(Icons.engineering_rounded, '8', 'تدريب ميداني'),
          _statDivider(),
          _statItem(Icons.groups_rounded, '3,240', 'المتدربون'),
          _statDivider(),
          _statItem(Icons.badge_rounded, '12', 'المدربون'),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 30.w,
            height: 30.w,
            decoration: BoxDecoration(
              color: TrainingColors.navySoft,
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(icon, size: 17.sp, color: TrainingColors.primary),
          ),
          SizedBox(height: 6.h),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              height: 1.0,
              color: TrainingColors.primary,
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 10.sp,
              color: TrainingColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _statDivider() {
    return Container(
      width: 1,
      height: 42.h,
      color: TrainingColors.divider,
    );
  }

  
  
  

  Widget _buildCompletionStrip(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: TrainingColors.accentSoft,
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.task_alt_rounded,
                size: 20.sp,
                color: TrainingColors.accent,
              ),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  'اكتمال ملف المنشأة 80%',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: const Color(0xFF7A3E00),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/training-center/settings'),
                behavior: HitTestBehavior.opaque,
                child: Row(
                  children: [
                    Text(
                      'أكمل البيانات',
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5.sp,
                        fontWeight: FontWeight.w700,
                        color: TrainingColors.accent,
                      ),
                    ),
                    Icon(
                      Icons.arrow_back_rounded,
                      size: 15.sp,
                      color: TrainingColors.accent,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          ClipRRect(
            borderRadius: BorderRadius.circular(999.r),
            child: SizedBox(
              height: 8.h,
              child: const Stack(
                children: [
                  Positioned.fill(
                    child: ColoredBox(color: TrainingColors.surface),
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FractionallySizedBox(
                      widthFactor: 0.8,
                      heightFactor: 1,
                      child: ColoredBox(color: TrainingColors.accent),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  
  
  

  Widget _buildQuickAccess(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Row(
        children: [
          Expanded(
            child: _quickCard(
              context,
              title: 'إضافة دورة جديدة',
              subtitle: 'نشر منهج أو جدول تدريبي',
              icon: Icons.add_chart_rounded,
              topTrailing: Container(
                padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: TrainingColors.accentSoft,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Text(
                  'جديد',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 9.5.sp,
                    fontWeight: FontWeight.w800,
                    color: TrainingColors.accent,
                  ),
                ),
              ),
              onTap: () => context.push('/training-center/programs'),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: _quickCard(
              context,
              title: 'الاعتمادات والرخص',
              subtitle: 'تحديث رخصة التدريب المهني',
              icon: Icons.verified_rounded,
              topTrailing: Text(
                'TVTC',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 10.sp,
                  fontWeight: FontWeight.w800,
                  color: TrainingColors.textMuted,
                ),
              ),
              onTap: () => context.push('/training-center/verification'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _quickCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Widget topTrailing,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(12.w),
        decoration: BoxDecoration(
          color: TrainingColors.surface,
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: TrainingColors.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 30.w,
                  height: 30.w,
                  decoration: BoxDecoration(
                    color: TrainingColors.navySoft,
                    borderRadius: BorderRadius.circular(9.r),
                  ),
                  child: Icon(icon, size: 17.sp, color: TrainingColors.primary),
                ),
                const Spacer(),
                topTrailing,
              ],
            ),
            SizedBox(height: 10.h),
            Text(
              title,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 13.sp,
                fontWeight: FontWeight.w800,
                color: TrainingColors.primary,
              ),
            ),
            SizedBox(height: 2.h),
            Text(
              subtitle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.5.sp,
                height: 1.5,
                color: TrainingColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  
  

  Widget _buildManagementSection(BuildContext context) {
    return _menuSection(
      title: 'إدارة المنشأة',
      headerIcon: Icons.corporate_fare_rounded,
      rows: [
        _menuRow(
          context,
          icon: Icons.apartment_rounded,
          title: 'بيانات الشركة القانونية',
          subtitle: 'السجل التجاري، العنوان والتراخيص المهنية',
          onTap: () => context.push('/training-center/settings'),
        ),
        _menuRow(
          context,
          icon: Icons.groups_rounded,
          title: 'المدربون المعتمدون',
          subtitle: 'ملفات المحاضرين، التقييمات والجداول',
          hint: '12 مدرب',
          onTap: () => context.push('/training-center/instructors'),
        ),
        _menuRow(
          context,
          icon: Icons.assignment_rounded,
          title: 'طلبات التسجيل الجديدة',
          subtitle: 'قبول المتدربين واعتماد الفواتير',
          badge: '5 جديد',
          onTap: () => context.push('/training-center/registration-requests'),
        ),
        _menuRow(
          context,
          icon: Icons.query_stats_rounded,
          title: 'التقارير والإحصائيات',
          subtitle: 'أداء البرامج، الحضور ومعدلات الإكمال',
          onTap: () => context.push('/training-center/dashboard'),
        ),
      ],
    );
  }

  Widget _buildFinanceSection(BuildContext context) {
    return _menuSection(
      title: 'المالية والحساب',
      headerIcon: Icons.account_balance_wallet_rounded,
      rows: [
        _menuRow(
          context,
          icon: Icons.payments_rounded,
          title: 'المحفظة المالية للشركة',
          subtitle: 'الرصيد المتاح: 2,450 ر.س',
          iconBackground: TrainingColors.accentSoft,
          iconColor: TrainingColors.accent,
          onTap: () => _comingSoon(context, 'المحفظة المالية'),
        ),
        _menuRow(
          context,
          icon: Icons.account_balance_rounded,
          title: 'طرق الاستلام والتحويل البنكي',
          subtitle: 'الحسابات البنكية المعتمدة للشركة (IBAN)',
          onTap: () => _comingSoon(context, 'طرق الاستلام'),
        ),
        _menuRow(
          context,
          icon: Icons.admin_panel_settings_rounded,
          title: 'إعدادات الحساب والصلاحيات',
          subtitle: 'إدارة مديري النظام وفروع الشركة',
          onTap: () => context.push('/training-center/settings'),
        ),
        _menuRow(
          context,
          icon: Icons.support_agent_rounded,
          title: 'الدعم الفني المخصص للشركات',
          subtitle: 'مدير حساب مخصص 24/7 للمنشآت',
          showDot: true,
          onTap: () => context.push('/training-center/help'),
        ),
      ],
    );
  }

  Widget _menuSection({
    required String title,
    required IconData headerIcon,
    required List<Widget> rows,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(headerIcon, size: 18.sp, color: TrainingColors.primary),
              SizedBox(width: 6.w),
              Text(
                title,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w800,
                  color: TrainingColors.primary,
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Container(
            decoration: BoxDecoration(
              color: TrainingColors.surface,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: TrainingColors.softShadow,
            ),
            child: Column(
              children: [
                for (int i = 0; i < rows.length; i++) ...[
                  rows[i],
                  if (i != rows.length - 1)
                    Divider(
                      height: 1,
                      thickness: 1,
                      color: TrainingColors.divider,
                      indent: 60.w,
                      endIndent: 12.w,
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _menuRow(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    String? hint,
    String? badge,
    bool showDot = false,
    Color? iconBackground,
    Color? iconColor,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        constraints: BoxConstraints(minHeight: 60.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        child: Row(
          children: [
            Container(
              width: 40.w,
              height: 40.w,
              decoration: BoxDecoration(
                color: iconBackground ?? TrainingColors.navySoft,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Icon(
                icon,
                size: 20.sp,
                color: iconColor ?? TrainingColors.primary,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: TrainingColors.textPrimary,
                          ),
                        ),
                      ),
                      if (hint != null) ...[
                        SizedBox(width: 6.w),
                        _pill(
                          hint,
                          background: TrainingColors.surfaceMuted,
                          textColor: TrainingColors.primary,
                        ),
                      ],
                      if (showDot) ...[
                        SizedBox(width: 6.w),
                        Container(
                          width: 7.w,
                          height: 7.w,
                          decoration: const BoxDecoration(
                            color: TrainingColors.accent,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ],
                    ],
                  ),
                  SizedBox(height: 3.h),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 11.sp,
                      color: TrainingColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(width: 8.w),
            if (badge != null) ...[
              _pill(
                badge,
                background: TrainingColors.dangerSoft,
                textColor: TrainingColors.danger,
              ),
              SizedBox(width: 6.w),
            ],
            Icon(
              Icons.chevron_left_rounded,
              size: 20.sp,
              color: TrainingColors.textMuted,
            ),
          ],
        ),
      ),
    );
  }

  Widget _pill(
    String text, {
    required Color background,
    required Color textColor,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(999.r),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 9.5.sp,
          fontWeight: FontWeight.w800,
          color: textColor,
        ),
      ),
    );
  }

  
  
  

  Widget _buildLogout(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: GestureDetector(
        onTap: () => _showLogoutDialog(context),
        child: Container(
          height: 50.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: TrainingColors.dangerSoft,
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.logout_rounded,
                  size: 19.sp,
                  color: TrainingColors.danger,
                ),
                SizedBox(width: 8.w),
                Text(
                  'تسجيل الخروج من حساب المنشأة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w800,
                    color: TrainingColors.danger,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.verified_rounded,
              size: 15.sp,
              color: TrainingColors.textMuted,
            ),
            SizedBox(width: 5.w),
            Text(
              'بوابة المنشآت التدريبية المعتمدة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.sp,
                color: TrainingColors.textMuted,
              ),
            ),
          ],
        ),
        SizedBox(height: 4.h),
        Text(
          'الإصدار 1.0.0 • جميع الحقوق محفوظة لشركة التدريب التقني',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 10.sp,
            color: TrainingColors.textMuted.withValues(alpha: 0.8),
          ),
        ),
      ],
    );
  }

  
  
  

  void _showLogoutDialog(BuildContext context) {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            title: const Text('تسجيل الخروج'),
            content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  Navigator.pop(dialogContext);
                  await logoutToLogin(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: TrainingColors.danger,
                  foregroundColor: Colors.white,
                ),
                child: const Text('تأكيد'),
              ),
            ],
          ),
        );
      },
    );
  }

  void _comingSoon(BuildContext context, String label) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('$label: قريباً'),
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
