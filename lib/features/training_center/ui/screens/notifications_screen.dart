import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:nextstep_ai_app/core/widgets/app_responsive.dart';

import '../theme/training_colors.dart';
import '../widgets/training_center_drawer.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  String _selectedFilter = 'الكل';

  final List<String> _filters = [
    'الكل',
    'الطلاب',
    'الدورات',
    'النظام',
  ];

  final List<Map<String, dynamic>> _notifications = [
    {
      'id': '1',
      'title': 'تسجيل طالب جديد',
      'message': 'قام أحمد محمد بالتسجيل في دورة "مقدمة في الذكاء الاصطناعي".',
      'time': 'منذ 5 دقائق',
      'isRead': false,
      'type': 'students',
      'date': 'اليوم',
      'action': 'عرض الملف الشخصي',
    },
    {
      'id': '2',
      'title': 'تحديث منهج الدورة',
      'message': 'تم إضافة مواد دراسية جديدة لدورة "تحليل البيانات المتقدم".',
      'time': 'منذ ساعتين',
      'isRead': false,
      'type': 'courses',
      'date': 'اليوم',
      'action': 'عرض الدورة',
    },
    {
      'id': '3',
      'title': 'تنبيه النظام: صيانة مجدولة',
      'message':
          'ستتوقف المنصة عن العمل للصيانة الدورية يوم الجمعة القادم لمدة ساعتين.',
      'time': 'أمس، 14:30',
      'isRead': true,
      'type': 'system',
      'date': 'أمس',
      'action': 'التفاصيل',
    },
    {
      'id': '4',
      'title': 'إكمال دورة تدريبية',
      'message': 'قامت سارة عبدالله بإكمال دورة "التسويق الرقمي" بنجاح.',
      'time': 'أمس، 10:15',
      'isRead': true,
      'type': 'students',
      'date': 'أمس',
      'action': 'عرض الشهادة',
    },
    {
      'id': '5',
      'title': 'دورة جديدة مضافة',
      'message': 'تم إضافة دورة "إدارة المشاريع الاحترافية" إلى قائمة البرامج.',
      'time': 'منذ 3 أيام',
      'isRead': true,
      'type': 'courses',
      'date': 'هذا الأسبوع',
      'action': 'عرض الدورة',
    },
    {
      'id': '6',
      'title': 'تقييم جديد',
      'message': 'قام خالد سعيد بتقييم دورة "أساسيات البرمجة" بـ 4.5 نجوم.',
      'time': 'منذ 4 أيام',
      'isRead': true,
      'type': 'system',
      'date': 'هذا الأسبوع',
      'action': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final int unreadCount =
        _notifications.where((n) => n['isRead'] == false).length;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: TrainingColors.background,
      drawer: const TrainingCenterDrawer(),
      body: Column(
        children: [
          _buildHeader(context, unreadCount),
          Padding(
            padding: EdgeInsets.fromLTRB(16.w, 10.h, 16.w, 0),
            child: const Align(
              alignment: AlignmentDirectional.centerStart,
              child: SampleDataBadge(),
            ),
          ),
          SizedBox(height: 10.h),
          _buildFilterTabs(),
          SizedBox(height: 6.h),
          Expanded(child: _buildNotificationsList()),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }

  
  
  

  Widget _buildHeader(BuildContext context, int unreadCount) {
    final double topInset = MediaQuery.of(context).padding.top;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(16.w, topInset + 12.h, 16.w, 16.h),
      decoration: const BoxDecoration(
        gradient: TrainingColors.headerGradient,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
        boxShadow: TrainingColors.headerShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40.h,
            left: -40.w,
            child: Container(
              width: 130.w,
              height: 130.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            bottom: -50.h,
            right: -30.w,
            child: Container(
              width: 110.w,
              height: 110.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _headerIconButton(
                    icon: Icons.menu_rounded,
                    onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  ),
                  SizedBox(width: 10.w),
                  Container(
                    width: 38.w,
                    height: 38.w,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                        width: 1.2,
                      ),
                    ),
                    child: Icon(
                      Icons.notifications_rounded,
                      size: 19.sp,
                      color: TrainingColors.accent,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  const Text(
                    'الإشعارات',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.5,
                      fontWeight: FontWeight.w800,
                      color: TrainingColors.onPrimary,
                    ),
                  ),
                  const Spacer(),
                  _buildMarkAllButton(unreadCount),
                ],
              ),
              SizedBox(height: 12.h),
              Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: unreadCount > 0
                          ? TrainingColors.accent
                          : Colors.white.withValues(alpha: 0.4),
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    unreadCount > 0
                        ? 'لديك $unreadCount إشعارات غير مقروءة'
                        : 'أنت على اطلاع بكل شيء',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: TrainingColors.onPrimary.withValues(alpha: 0.85),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 21.sp, color: TrainingColors.onPrimary),
      ),
    );
  }

  Widget _buildMarkAllButton(int unreadCount) {
    final bool enabled = unreadCount > 0;

    return GestureDetector(
      onTap: enabled ? _markAllAsRead : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: enabled
              ? TrainingColors.accent
              : Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(999.r),
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: TrainingColors.accent.withValues(alpha: 0.4),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.done_all_rounded,
              size: 15.sp,
              color: enabled
                  ? TrainingColors.onAccent
                  : Colors.white.withValues(alpha: 0.4),
            ),
            SizedBox(width: 5.w),
            Text(
              'قراءة الكل',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 11.5.sp,
                fontWeight: FontWeight.w800,
                color: enabled
                    ? TrainingColors.onAccent
                    : Colors.white.withValues(alpha: 0.4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  
  
  

  Widget _buildFilterTabs() {
    return SizedBox(
      height: 36.h,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => SizedBox(width: 8.w),
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final bool active = _selectedFilter == filter;
          final int count = _getFilterCount(filter);

          return GestureDetector(
            onTap: () => setState(() => _selectedFilter = filter),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(horizontal: 14.w),
              decoration: BoxDecoration(
                color: active ? TrainingColors.accent : TrainingColors.surface,
                borderRadius: BorderRadius.circular(999.r),
                border:
                    active ? null : Border.all(color: TrainingColors.divider),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: TrainingColors.accent.withValues(alpha: 0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : TrainingColors.softShadow,
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.sp,
                      fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                      color: active
                          ? TrainingColors.onAccent
                          : TrainingColors.textSecondary,
                    ),
                  ),
                  SizedBox(width: 5.w),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white.withValues(alpha: 0.25)
                          : TrainingColors.surfaceAlt,
                      borderRadius: BorderRadius.circular(999.r),
                    ),
                    child: Text(
                      count.toString(),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 9.5.sp,
                        fontWeight: FontWeight.w700,
                        color: active
                            ? TrainingColors.onAccent
                            : TrainingColors.textMuted,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  int _getFilterCount(String filter) {
    if (filter == 'الكل') return _notifications.length;
    return _notifications.where((n) => n['type'] == filter).length;
  }

  
  
  

  Widget _buildNotificationsList() {
    final filteredNotifications = _notifications.where((notification) {
      if (_selectedFilter == 'الكل') return true;
      return notification['type'] == _selectedFilter;
    }).toList();

    if (filteredNotifications.isEmpty) {
      return _buildEmptyState();
    }

    final groupedNotifications = <String, List<Map<String, dynamic>>>{};
    for (var notification in filteredNotifications) {
      final date = notification['date'] as String;
      groupedNotifications.putIfAbsent(date, () => []).add(notification);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      physics: const BouncingScrollPhysics(),
      itemCount: groupedNotifications.keys.length,
      itemBuilder: (context, index) {
        final date = groupedNotifications.keys.elementAt(index);
        final notifications = groupedNotifications[date]!;
        final isToday = date == 'اليوم';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 10.h),
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.w,
                    decoration: BoxDecoration(
                      color: isToday
                          ? TrainingColors.accent
                          : TrainingColors.textMuted,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    date,
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w800,
                      color: isToday
                          ? TrainingColors.textPrimary
                          : TrainingColors.textMuted,
                    ),
                  ),
                  SizedBox(width: 10.w),
                  Expanded(
                    child: Container(
                      height: 1,
                      color: TrainingColors.divider,
                    ),
                  ),
                ],
              ),
            ),
            ...notifications.map((notification) {
              return _buildNotificationItem(notification);
            }),
            SizedBox(height: 4.h),
          ],
        );
      },
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final bool isRead = notification['isRead'] as bool;
    final IconData icon = _getNotificationIcon(notification['type'] as String);
    final Color color = _getNotificationColor(notification['type'] as String);
    final bool hasAction = notification['action'] != null;

    return Dismissible(
      key: ValueKey<String>(notification['id'] as String),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _dismissNotification(notification),
      background: Container(
        margin: EdgeInsets.only(bottom: 10.h),
        alignment: AlignmentDirectional.centerEnd,
        padding: EdgeInsets.only(left: 20.w),
        decoration: BoxDecoration(
          color: TrainingColors.danger,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Icon(Icons.delete_rounded, size: 22.sp, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: () {
          if (!isRead) {
            setState(() => notification['isRead'] = true);
          }
        },
        child: Container(
          margin: EdgeInsets.only(bottom: 10.h),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: isRead ? TrainingColors.surface : TrainingColors.navySoft,
            borderRadius: BorderRadius.circular(14.r),
            border: isRead
                ? Border.all(color: TrainingColors.divider)
                : Border.all(
                    color: TrainingColors.primary.withValues(alpha: 0.2)),
            boxShadow:
                isRead ? TrainingColors.softShadow : TrainingColors.cardShadow,
          ),
          child: Stack(
            children: [
              if (!isRead)
                const Positioned(
                  top: 0,
                  bottom: 0,
                  right: 0,
                  child: SizedBox(
                    width: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(color: TrainingColors.accent),
                    ),
                  ),
                ),
              Padding(
                padding: EdgeInsets.fromLTRB(14.w, 14.h, 18.w, 14.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44.w,
                      height: 44.w,
                      decoration: BoxDecoration(
                        color: isRead
                            ? color.withValues(alpha: 0.1)
                            : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(icon, color: color, size: 21.sp),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Text(
                                  notification['title'] as String,
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13.sp,
                                    fontWeight: isRead
                                        ? FontWeight.w700
                                        : FontWeight.w800,
                                    color: TrainingColors.textPrimary,
                                  ),
                                ),
                              ),
                              if (!isRead)
                                Container(
                                  width: 8.w,
                                  height: 8.w,
                                  decoration: const BoxDecoration(
                                    color: TrainingColors.accent,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                            ],
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            notification['message'] as String,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 11.5.sp,
                              height: 1.5,
                              color: TrainingColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: 10.h),
                          Row(
                            children: [
                              Icon(
                                Icons.schedule_rounded,
                                size: 13.sp,
                                color: TrainingColors.textMuted,
                              ),
                              SizedBox(width: 4.w),
                              Text(
                                notification['time'] as String,
                                style: TextStyle(
                                  fontFamily: 'Cairo',
                                  fontSize: 10.sp,
                                  color: TrainingColors.textMuted,
                                ),
                              ),
                              const Spacer(),
                              if (hasAction)
                                GestureDetector(
                                  onTap: () => _runAction(
                                      notification['action'] as String),
                                  behavior: HitTestBehavior.opaque,
                                  child: Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 10.w,
                                      vertical: 5.h,
                                    ),
                                    decoration: BoxDecoration(
                                      color: TrainingColors.accentSoft,
                                      borderRadius:
                                          BorderRadius.circular(999.r),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Text(
                                          notification['action'] as String,
                                          style: TextStyle(
                                            fontFamily: 'Cairo',
                                            fontSize: 10.5.sp,
                                            fontWeight: FontWeight.w700,
                                            color: TrainingColors.accent,
                                          ),
                                        ),
                                        SizedBox(width: 3.w),
                                        Icon(
                                          Icons.arrow_back_rounded,
                                          size: 12.sp,
                                          color: TrainingColors.accent,
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 84.w,
            height: 84.w,
            decoration: const BoxDecoration(
              color: TrainingColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_off_rounded,
              size: 38.sp,
              color: TrainingColors.accent,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 16.sp,
              fontWeight: FontWeight.w800,
              color: TrainingColors.textPrimary,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            'ستظهر هنا جميع الإشعارات والتحديثات الجديدة',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              color: TrainingColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  
  
  

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'students':
        return Icons.person_add_rounded;
      case 'courses':
        return Icons.menu_book_rounded;
      case 'system':
        return Icons.system_update_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'students':
        return TrainingColors.success;
      case 'courses':
        return TrainingColors.primary;
      case 'system':
        return TrainingColors.accent;
      default:
        return TrainingColors.textSecondary;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('تم تحديد جميع الإشعارات كمقروءة'),
          backgroundColor: TrainingColors.success,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
  }

  void _dismissNotification(Map<String, dynamic> notification) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == notification['id']);
    });
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('تم حذف إشعار "${notification['title']}"'),
          backgroundColor: TrainingColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }

  void _runAction(String action) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text('تنفيذ: $action'),
          backgroundColor: TrainingColors.primary,
          behavior: SnackBarBehavior.floating,
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
