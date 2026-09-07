// lib/features/training_center/ui/widgets/training_center_drawer.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../logic/training_center_bloc/training_center_bloc.dart';

class TrainingCenterDrawer extends StatelessWidget {
  final VoidCallback? onLogout;

  const TrainingCenterDrawer({super.key, this.onLogout});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 280.w,
      child: Directionality(
        textDirection: TextDirection.rtl,
        child: Column(
          children: [
            // ✅ رأس القائمة - معلومات المركز
            _buildDrawerHeader(context),

            // ✅ قائمة العناصر
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _buildDrawerItem(
                    context,
                    icon: Icons.home_rounded,
                    title: 'الرئيسية',
                    route: '/training-center',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.dashboard_rounded,
                    title: 'لوحة التحكم',
                    route: '/training-center/dashboard',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.book_rounded,
                    title: 'البرامج التدريبية',
                    route: '/training-center/programs',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.people_rounded,
                    title: 'الطلاب',
                    route: '/training-center/students',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.person_rounded,
                    title: 'المدربون',
                    route: '/training-center/instructors',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.business_center_rounded,
                    title: 'الملف التعريفي',
                    route: '/training-center/profile',
                  ),
                  _buildDivider(),
                  _buildDrawerItem(
                    context,
                    icon: Icons.notifications_rounded,
                    title: 'الإشعارات',
                    route: '/training-center/notifications',
                    showBadge: true,
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.settings_rounded,
                    title: 'الإعدادات',
                    route: '/training-center/settings',
                  ),
                  _buildDrawerItem(
                    context,
                    icon: Icons.help_rounded,
                    title: 'المساعدة والدعم',
                    route: '/training-center/help',
                  ),
                  _buildDivider(),
                  _buildDrawerItem(
                    context,
                    icon: Icons.logout_rounded,
                    title: 'تسجيل الخروج',
                    isLogout: true,
                    onTap: () => _showLogoutDialog(context),
                  ),
                ],
              ),
            ),

            // ✅ نسخة التطبيق في الأسفل
            Padding(
              padding: EdgeInsets.all(16.r),
              child: Text(
                'الإصدار 1.0.0',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================
  //  رأس القائمة الجانبية
  // ============================
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
          padding: EdgeInsets.fromLTRB(16.w, 40.h, 16.w, 16.w),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // ✅ شعار المركز
              CircleAvatar(
                radius: 40.r,
                backgroundColor: Colors.white,
                backgroundImage:
                    logoUrl != null ? NetworkImage(logoUrl!) : null,
                child: logoUrl == null
                    ? Icon(
                        Icons.school_rounded,
                        size: 40.sp,
                        color: Colors.blue.shade700,
                      )
                    : null,
              ),
              SizedBox(height: 8.h),

              // ✅ اسم المركز
              if (isLoading)
                Container(
                  width: 100.w,
                  height: 16.h,
                  color: Colors.white.withOpacity(0.3),
                )
              else
                Text(
                  centerName,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              SizedBox(height: 4.h),

              // ✅ حالة المركز
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.shade400,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'نشط',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================
  //  عنصر القائمة
  // ============================
  Widget _buildDrawerItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    String? route,
    VoidCallback? onTap,
    bool isLogout = false,
    bool showBadge = false,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: isLogout ? Colors.red.shade700 : Colors.grey.shade700,
        size: 22.sp,
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 14.sp,
          fontWeight: FontWeight.w500,
          color: isLogout ? Colors.red.shade700 : Colors.grey.shade800,
        ),
      ),
      trailing: showBadge
          ? Container(
              width: 8.w,
              height: 8.h,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
            )
          : null,
      onTap: onTap ??
          () {
            Navigator.pop(context); // إغلاق القائمة
            if (route != null) {
              context.push(route);
            }
          },
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 4.h),
    );
  }

  // ============================
  //  فاصل
  // ============================
  Widget _buildDivider() {
    return Divider(
      height: 1.h,
      thickness: 1,
      color: Colors.grey.shade200,
      indent: 16.w,
      endIndent: 16.w,
    );
  }

  // ============================
  //  حوار تسجيل الخروج
  // ============================
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text('هل أنت متأكد من رغبتك في تسجيل الخروج؟'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                if (onLogout != null) {
                  onLogout!();
                } else {
                  context.pushReplacement('/login');
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: const Text('تأكيد'),
            ),
          ],
        );
      },
    );
  }
}
