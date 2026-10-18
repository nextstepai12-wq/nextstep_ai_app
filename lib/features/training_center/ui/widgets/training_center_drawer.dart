
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../logic/training_center_bloc/training_center_bloc.dart';
import '../theme/training_colors.dart';

class TrainingCenterDrawer extends StatelessWidget {
  final VoidCallback? onLogout;

  const TrainingCenterDrawer({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    String currentLocation = '';
    try {
      currentLocation = GoRouterState.of(context).matchedLocation;
    } catch (_) {
      currentLocation = '';
    }

    return Drawer(
      width: 285.w,
      backgroundColor: TrainingColors.background,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            _buildDrawerHeader(context),

            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 14.h),
                children: [
                  _sectionLabel('القائمة الرئيسية'),
                  _drawerItem(
                    context,
                    icon: Icons.home_rounded,
                    title: 'الرئيسية',
                    route: '/training-center',
                    currentLocation: currentLocation,
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.dashboard_rounded,
                    title: 'لوحة التحكم',
                    route: '/training-center/dashboard',
                    currentLocation: currentLocation,
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.book_rounded,
                    title: 'البرامج التدريبية',
                    route: '/training-center/programs',
                    currentLocation: currentLocation,
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.people_rounded,
                    title: 'الطلاب',
                    route: '/training-center/students',
                    currentLocation: currentLocation,
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.person_rounded,
                    title: 'المدربون',
                    route: '/training-center/instructors',
                    currentLocation: currentLocation,
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.business_center_rounded,
                    title: 'الملف التعريفي',
                    route: '/training-center/profile',
                    currentLocation: currentLocation,
                  ),
                  SizedBox(height: 10.h),
                  _sectionLabel('التنبيهات والإعدادات'),
                  _drawerItem(
                    context,
                    icon: Icons.notifications_rounded,
                    title: 'الإشعارات',
                    route: '/training-center/notifications',
                    currentLocation: currentLocation,
                    showBadge: true,
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.settings_rounded,
                    title: 'الإعدادات',
                    route: '/training-center/settings',
                    currentLocation: currentLocation,
                  ),
                  _drawerItem(
                    context,
                    icon: Icons.help_rounded,
                    title: 'المساعدة والدعم',
                    route: '/training-center/help',
                    currentLocation: currentLocation,
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(12.w, 0, 12.w, 8.h),
              child: _drawerItem(
                context,
                icon: Icons.logout_rounded,
                title: 'تسجيل الخروج',
                isLogout: true,
                onTap: () => _showLogoutDialog(context),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(bottom: 12.h),
              child: Text(
                'الإصدار 1.0.0',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.sp,
                  color: TrainingColors.textMuted,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerHeader(BuildContext context) {
    return BlocBuilder<TrainingCenterBloc, TrainingCenterState>(
      builder: (context, state) {
        String centerName = 'مركز التدريب';
        String? logoUrl;
        bool isLoading = false;

        if (state is TrainingCenterLoaded && state.centers.isNotEmpty) {
          final center = state.centers.first;
          centerName = center.name;
          logoUrl = center.logoUrl;
        } else if (state is TrainingCenterLoading) {
          isLoading = true;
        }

        return Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(20.w, 52.h, 20.w, 20.w),
          decoration: const BoxDecoration(
            gradient: TrainingColors.headerGradient,
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(28),
              bottomLeft: Radius.circular(28),
            ),
            boxShadow: TrainingColors.headerShadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 60.w,
                    height: 60.w,
                    padding: EdgeInsets.all(2.w),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.4),
                        width: 1.5,
                      ),
                    ),
                    child: ClipOval(
                      child: logoUrl != null
                          ? Image.network(
                              logoUrl,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => _defaultLogo(),
                            )
                          : _defaultLogo(),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isLoading)
                          Container(
                            width: 110.w,
                            height: 16.h,
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(6.r),
                            ),
                          )
                        else
                          Text(
                            centerName,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        SizedBox(height: 4.h),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 3.h,
                          ),
                          decoration: BoxDecoration(
                            color: TrainingColors.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(999.r),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 6.w,
                                height: 6.w,
                                decoration: const BoxDecoration(
                                  color: TrainingColors.success,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              SizedBox(width: 5.w),
                              Text(
                                'مركز معتمد ونشط',
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10.sp,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 14.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14.sp,
                      color: TrainingColors.accent,
                    ),
                    SizedBox(width: 6.w),
                    Expanded(
                      child: Text(
                        'الرياض، المملكة العربية السعودية',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 11.sp,
                          color: Colors.white.withValues(alpha: 0.9),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _defaultLogo() {
    return Container(
      color: Colors.white,
      alignment: Alignment.center,
      child: Icon(
        Icons.school_rounded,
        size: 30.sp,
        color: TrainingColors.primary,
      ),
    );
  }

  Widget _sectionLabel(String label) {
    return Padding(
      padding: EdgeInsets.fromLTRB(12.w, 8.h, 12.w, 8.h),
      child: Row(
        children: [
          Container(
            width: 4.w,
            height: 14.h,
            decoration: BoxDecoration(
              color: TrainingColors.accent,
              borderRadius: BorderRadius.circular(4.r),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: TrainingColors.textMuted,
            ),
          ),
        ],
      ),
    );
  }

  Widget _drawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    String currentLocation = '',
    VoidCallback? onTap,
    bool isLogout = false,
    bool showBadge = false,
  }) {
    final isActive = route != null &&
        !isLogout &&
        (currentLocation == route ||
            (route != '/training-center' &&
                currentLocation.startsWith('$route/')));

    final activeColor = isLogout ? TrainingColors.danger : TrainingColors.primary;
    final iconBg = isLogout
        ? TrainingColors.dangerSoft
        : isActive
            ? TrainingColors.primary
            : TrainingColors.surfaceAlt;
    final iconColor = isLogout
        ? TrainingColors.danger
        : isActive
            ? Colors.white
            : TrainingColors.textSecondary;

    return Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(14.r),
          onTap: onTap ??
              () {
                Navigator.pop(context);
                if (route != null && route != currentLocation) {
                  context.pushReplacement(route);
                }
              },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
            decoration: BoxDecoration(
              color: isActive
                  ? TrainingColors.primary.withValues(alpha: 0.08)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(14.r),
              border: Border.all(
                color: isActive
                    ? TrainingColors.primary.withValues(alpha: 0.25)
                    : Colors.transparent,
                width: 1.2,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 40.w,
                  height: 40.w,
                  decoration: BoxDecoration(
                    color: iconBg,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Icon(icon, color: iconColor, size: 20.sp),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.5.sp,
                      fontWeight:
                          isActive || isLogout ? FontWeight.w700 : FontWeight.w500,
                      color: isActive || isLogout
                          ? activeColor
                          : TrainingColors.textPrimary,
                    ),
                  ),
                ),
                if (showBadge)
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: TrainingColors.danger,
                      shape: BoxShape.circle,
                    ),
                  )
                else if (isActive)
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: const BoxDecoration(
                      color: TrainingColors.primary,
                      shape: BoxShape.circle,
                    ),
                  )
                else if (!isLogout)
                  Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 12.sp,
                    color: TrainingColors.textMuted.withValues(alpha: 0.6),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            backgroundColor: TrainingColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            contentPadding: EdgeInsets.all(20.r),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 52.w,
                  height: 52.w,
                  decoration: const BoxDecoration(
                    color: TrainingColors.dangerSoft,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.logout_rounded,
                    color: TrainingColors.danger,
                    size: 26.sp,
                  ),
                ),
                SizedBox(height: 14.h),
                Text(
                  'تسجيل الخروج',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 17.sp,
                    fontWeight: FontWeight.w800,
                    color: TrainingColors.textPrimary,
                  ),
                ),
                SizedBox(height: 6.h),
                Text(
                  'هل أنت متأكد من رغبتك في تسجيل الخروج من حساب المركز؟',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    color: TrainingColors.textSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20.h),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(dialogContext),
                        child: Container(
                          height: 46.h,
                          decoration: BoxDecoration(
                            color: TrainingColors.surfaceAlt,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w600,
                                color: TrainingColors.textPrimary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: GestureDetector(
                        onTap: () {
                          Navigator.pop(dialogContext);
                          if (onLogout != null) {
                            onLogout!();
                          } else {
                            context.pushReplacement('/login');
                          }
                        },
                        child: Container(
                          height: 46.h,
                          decoration: BoxDecoration(
                            color: TrainingColors.danger,
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Text(
                              'تأكيد الخروج',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
