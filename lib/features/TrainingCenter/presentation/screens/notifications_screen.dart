// lib/features/TrainingCenter/presentation/screens/notifications_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
      'isRead': true,
      'type': 'courses',
      'date': 'اليوم',
      'action': null,
    },
    {
      'id': '3',
      'title': 'تنبيه النظام: صيانة مجدولة',
      'message': 'ستتوقف المنصة عن العمل للصيانة الدورية يوم الجمعة القادم لمدة ساعتين.',
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
    final unreadCount = _notifications.where((n) => n['isRead'] == false).length;

    return Scaffold(
      key: _scaffoldKey,
      appBar: _buildAppBar(unreadCount),
      drawer: const TrainingCenterDrawer(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar(int unreadCount) {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Row(
        children: [
          Icon(
            Icons.notifications_rounded,
            color: Colors.blue.shade700,
            size: 22.sp,
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              'الإشعارات',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (unreadCount > 0) ...[
            SizedBox(width: 8.w),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
              decoration: BoxDecoration(
                color: Colors.red.shade700,
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Text(
                unreadCount.toString(),
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ],
      ),
      actions: [
        if (unreadCount > 0)
          TextButton(
            onPressed: () {
              _markAllAsRead();
            },
            style: TextButton.styleFrom(
              padding: EdgeInsets.symmetric(horizontal: 8.w),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.done_all_rounded,
                  size: 18.sp,
                  color: Colors.blue.shade700,
                ),
                SizedBox(width: 4.w),
                Text(
                  'تحديد الكل كمقروء',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        SizedBox(width: 4.w),
        CircleAvatar(
          radius: 16.r,
          backgroundColor: Colors.grey.shade300,
          child: Icon(
            Icons.person,
            size: 18.sp,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(width: 4.w),
      ],
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.white.withValues(alpha: 0.92),
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildPageHeader(),
        SizedBox(height: 8.h),
        _buildFilterTabs(),
        SizedBox(height: 8.h),
        Expanded(
          child: _buildNotificationsList(),
        ),
      ],
    );
  }

  Widget _buildPageHeader() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الإشعارات',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Text(
                'ابق على اطلاع بأحدث التحديثات والأنشطة.',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.done_all_rounded,
                  size: 16.sp,
                  color: Colors.blue.shade700,
                ),
                SizedBox(width: 4.w),
                Text(
                  'تحديد الكل كمقروء',
                  style: TextStyle(
                    fontSize: 10.sp,
                    color: Colors.blue.shade700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterTabs() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      height: 44.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _filters.length,
        itemBuilder: (context, index) {
          final filter = _filters[index];
          final isSelected = _selectedFilter == filter;
          final count = _getFilterCount(filter);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = filter;
              });
            },
            child: Container(
              margin: EdgeInsets.only(left: 8.w),
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade50,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                  width: isSelected ? 2 : 1,
                ),
              ),
              child: Row(
                children: [
                  Text(
                    filter,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected ? Colors.white : Colors.grey.shade700,
                    ),
                  ),
                  if (count > 0) ...[
                    SizedBox(width: 4.w),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 1.h),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.white : Colors.grey.shade300,
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Text(
                        count.toString(),
                        style: TextStyle(
                          fontSize: 10.sp,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
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
      if (!groupedNotifications.containsKey(date)) {
        groupedNotifications[date] = [];
      }
      groupedNotifications[date]!.add(notification);
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
      itemCount: groupedNotifications.keys.length,
      itemBuilder: (context, index) {
        final date = groupedNotifications.keys.elementAt(index);
        final notifications = groupedNotifications[date]!;
        final isToday = date == 'اليوم';

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Row(
                children: [
                  Container(
                    width: 8.w,
                    height: 8.h,
                    decoration: BoxDecoration(
                      color: isToday ? Colors.blue.shade700 : Colors.grey.shade400,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    date,
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: isToday ? Colors.blue.shade700 : Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            ...notifications.map((notification) {
              return _buildNotificationItem(notification);
            }).toList(),
            SizedBox(height: 8.h),
          ],
        );
      },
    );
  }

  // ✅ دالة _buildNotificationItem المصححة
  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final icon = _getNotificationIcon(notification['type']);
    final iconColor = _getNotificationColor(notification['type']);
    final hasAction = notification['action'] != null;

    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: isRead ? Colors.white : Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16.r),
        // ✅ إضافة الحد فقط للإشعارات غير المقروءة
        border: isRead
            ? null
            : Border(
                right: BorderSide(
                  color: Colors.blue.shade700,
                  width: 4.w,
                ),
              ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48.w,
            height: 48.h,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 24.sp,
            ),
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
                        notification['title'],
                        style: TextStyle(
                          fontSize: 14.sp,
                          fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                    if (!isRead)
                      Container(
                        width: 8.w,
                        height: 8.h,
                        decoration: const BoxDecoration(
                          color: Colors.blue,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                SizedBox(height: 4.h),
                Text(
                  notification['message'],
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      notification['time'],
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade400,
                      ),
                    ),
                    if (hasAction)
                      TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('تنفيذ: ${notification['action']}'),
                              duration: const Duration(seconds: 2),
                            ),
                          );
                        },
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          backgroundColor: Colors.grey.shade100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                        ),
                        child: Text(
                          notification['action'],
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.w600,
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
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off_rounded,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا توجد إشعارات',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'ستظهر هنا جميع الإشعارات والتحديثات الجديدة',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
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
        return Colors.green.shade700;
      case 'courses':
        return Colors.blue.shade700;
      case 'system':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم تحديد جميع الإشعارات كمقروءة ✅'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }
}