import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';
import 'dart:async';

class UniversityNotificationsScreen extends StatefulWidget {
  const UniversityNotificationsScreen({super.key});

  @override
  State<UniversityNotificationsScreen> createState() =>
      _UniversityNotificationsScreenState();
}

class _UniversityNotificationsScreenState
    extends State<UniversityNotificationsScreen>
    with TickerProviderStateMixin {
  late AnimationController _animationController;
  late AnimationController _pulseController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  String _selectedFilter = 'الكل';
  final List<String> _filters = ['الكل', 'غير مقروء', 'مقروء', 'مهمة'];

  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;
  bool _selectMode = false;
  final List<int> _selectedIds = [];
  bool _isRefreshing = false;

  final List<Map<String, dynamic>> _dummyNotifications = [
    {
      'id': 1,
      'title': 'طالب جديد! 🎓',
      'body': 'تم تسجيل طالب جديد في تخصص هندسة الحاسوب',
      'time': DateTime.now().subtract(const Duration(minutes: 5)),
      'isRead': false,
      'isImportant': true,
      'type': 'student',
      'icon': Icons.person_add_rounded,
      'color': const Color(0xFF3B82F6),
    },
    {
      'id': 2,
      'title': 'تحديث التخصصات',
      'body': 'تم إضافة 3 تخصصات جديدة للعام الدراسي القادم',
      'time': DateTime.now().subtract(const Duration(hours: 2)),
      'isRead': false,
      'isImportant': false,
      'type': 'program',
      'icon': Icons.school_rounded,
      'color': const Color(0xFF22C55E),
    },
    {
      'id': 3,
      'title': 'طلب استشارة',
      'body': 'طالب يطلب استشارة أكاديمية حول تخصص الذكاء الاصطناعي',
      'time': DateTime.now().subtract(const Duration(days: 1)),
      'isRead': true,
      'isImportant': false,
      'type': 'consultation',
      'icon': Icons.chat_rounded,
      'color': const Color(0xFFF97316),
    },
    {
      'id': 4,
      'title': 'تحديث بيانات الجامعة',
      'body': 'تم تحديث معلومات الجامعة بنجاح في المنصة',
      'time': DateTime.now().subtract(const Duration(days: 2)),
      'isRead': true,
      'isImportant': true,
      'type': 'update',
      'icon': Icons.update_rounded,
      'color': const Color(0xFF8B5CF6),
    },
    {
      'id': 5,
      'title': 'مرحباً في NextStep AI',
      'body': 'نرحب بجامعتكم في منصة الإرشاد الأكاديمي',
      'time': DateTime.now().subtract(const Duration(days: 3)),
      'isRead': true,
      'isImportant': false,
      'type': 'welcome',
      'icon': Icons.waving_hand_rounded,
      'color': const Color(0xFFA855F7),
    },
  ];

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await Future.delayed(const Duration(seconds: 1));
      _notifications = _dummyNotifications;

      setState(() {
        _isLoading = false;
        _animationController.forward();
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshNotifications() async {
    setState(() {
      _isRefreshing = true;
    });

    await Future.delayed(const Duration(seconds: 1));

    final newNotification = {
      'id': DateTime.now().millisecondsSinceEpoch,
      'title': 'إشعار جديد! 🔔',
      'body': 'تم إضافة طالب جديد إلى نظامك',
      'time': DateTime.now(),
      'isRead': false,
      'isImportant': false,
      'type': 'new',
      'icon': Icons.notifications_active_rounded,
      'color': const Color(0xFFDC2626),
    };

    setState(() {
      _notifications.insert(0, newNotification);
      _isRefreshing = false;
    });
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    var filtered = _notifications;

    if (_selectedFilter == 'غير مقروء') {
      filtered = filtered.where((n) => !n['isRead']).toList();
    } else if (_selectedFilter == 'مقروء') {
      filtered = filtered.where((n) => n['isRead']).toList();
    } else if (_selectedFilter == 'مهمة') {
      filtered = filtered.where((n) => n['isImportant'] as bool).toList();
    }

    return filtered;
  }

  int get _unreadCount {
    return _notifications.where((n) => !n['isRead']).length;
  }

  void _markAsRead(int id) {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
  }

  void _markAllAsRead() {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    _showSnackBar('تم تحديد جميع الإشعارات كمقروءة');
  }

  void _deleteNotification(int id) {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
    _showSnackBar('تم حذف الإشعار');
  }

  void _deleteAllNotifications() {
    setState(() {
      _notifications.clear();
      _selectMode = false;
      _selectedIds.clear();
    });
    _showSnackBar('تم حذف جميع الإشعارات');
  }

  void _toggleSelectMode() {
    setState(() {
      _selectMode = !_selectMode;
      if (!_selectMode) {
        _selectedIds.clear();
      }
    });
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _deleteSelected() {
    setState(() {
      _notifications.removeWhere((n) => _selectedIds.contains(n['id']));
      _selectedIds.clear();
      _selectMode = false;
    });
    _showSnackBar('تم حذف الإشعارات المحددة');
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor: const Color(0xFF22C55E),
          duration: const Duration(seconds: 2),
          content: Row(
            children: [
              const Icon(
                Icons.check_circle_outline_rounded,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  message,
                  style: const TextStyle(color: Colors.white, fontSize: 13),
                ),
              ),
            ],
          ),
        ),
      );
  }

  @override
  void dispose() {
    _animationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _buildAppBar(),
        body: _isLoading
            ? _buildLoadingState()
            : RefreshIndicator(
                onRefresh: _refreshNotifications,
                color: AppTheme.primary,
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Column(
                      children: [
                        _buildFilterSection(),
                        Expanded(
                          child: _filteredNotifications.isEmpty
                              ? _buildEmptyState()
                              : ListView.builder(
                                  physics: const AlwaysScrollableScrollPhysics(
                                    parent: BouncingScrollPhysics(),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 8,
                                  ),
                                  itemCount: _filteredNotifications.length,
                                  itemBuilder: (context, index) {
                                    final notification =
                                        _filteredNotifications[index];
                                    return _buildNotificationCard(notification);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        floatingActionButton: _unreadCount > 0 && !_selectMode
            ? _buildFAB()
            : null,
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: _selectMode
          ? IconButton(
              icon: const Icon(
                Icons.close_rounded,
                color: AppTheme.primaryContainer,
              ),
              onPressed: _toggleSelectMode,
            )
          : Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: AppTheme.primaryContainer,
                ),
                onPressed: () => Navigator.pop(context),
                splashRadius: 24,
              ),
            ),
      title: _selectMode
          ? Text(
              'اختيار (${_selectedIds.length})',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryContainer,
              ),
            )
          : Row(
              children: [
                const Text(
                  'الإشعارات',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryContainer,
                  ),
                ),
                const SizedBox(width: 8),
                if (_unreadCount > 0)
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '$_unreadCount',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
              ],
            ),
      centerTitle: true,
      actions: [
        if (!_selectMode)
          PopupMenuButton<String>(
            icon: const Icon(
              Icons.more_vert_rounded,
              color: AppTheme.primaryContainer,
            ),
            onSelected: (value) {
              if (value == 'mark_all_read') {
                _markAllAsRead();
              } else if (value == 'delete_all') {
                _showDeleteAllDialog();
              } else if (value == 'select') {
                _toggleSelectMode();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'select',
                child: Row(
                  children: [
                    Icon(Icons.checklist_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('تحديد'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'mark_all_read',
                child: Row(
                  children: [
                    Icon(Icons.done_all_rounded, size: 20),
                    SizedBox(width: 8),
                    Text('تحديد الكل كمقروء'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_outline_rounded, size: 20, color: Colors.red),
                    SizedBox(width: 8),
                    Text('حذف الكل', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        if (_selectMode && _selectedIds.isNotEmpty)
          IconButton(
            icon: const Icon(
              Icons.delete_rounded,
              color: Colors.red,
            ),
            onPressed: _deleteSelected,
          ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppTheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'جاري تحميل الإشعارات...',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: Colors.white,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        child: Row(
          children: _filters.map((filter) {
            final isSelected = _selectedFilter == filter;
            return Padding(
              padding: const EdgeInsets.only(left: 8),
              child: FilterChip(
                label: Text(filter),
                selected: isSelected,
                onSelected: (_) {
                  setState(() {
                    _selectedFilter = filter;
                  });
                  HapticFeedback.lightImpact();
                },
                backgroundColor: Colors.grey.shade100,
                selectedColor: AppTheme.primary.withValues(alpha: 0.1),
                labelStyle: TextStyle(
                  fontSize: 13,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  color: isSelected ? AppTheme.primary : Colors.grey.shade700,
                ),
                side: BorderSide(
                  color: isSelected ? AppTheme.primary : Colors.grey.shade300,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: isSelected ? 2 : 0,
                shadowColor: AppTheme.primary.withValues(alpha: 0.2),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isSelected = _selectedIds.contains(notification['id']);
    final isRead = notification['isRead'] as bool;
    final isImportant = notification['isImportant'] as bool;

    return Dismissible(
      key: Key(notification['id'].toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(
          Icons.delete_rounded,
          color: Colors.red,
          size: 28,
        ),
      ),
      onDismissed: (_) {
        _deleteNotification(notification['id']);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          gradient: isRead
              ? null
              : LinearGradient(
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                  colors: [
                    Colors.blue.shade50,
                    Colors.white,
                  ],
                ),
          color: isRead ? Colors.white : null,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppTheme.primary : Colors.grey.shade200,
            width: isSelected ? 2 : 1.2,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.03),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () {
              if (_selectMode) {
                _toggleSelection(notification['id']);
                HapticFeedback.mediumImpact();
              } else {
                if (!isRead) {
                  _markAsRead(notification['id']);
                  HapticFeedback.lightImpact();
                }
                _showNotificationDetail(notification);
              }
            },
            onLongPress: () {
              if (!_selectMode) {
                HapticFeedback.heavyImpact();
                _toggleSelectMode();
                _toggleSelection(notification['id']);
              }
            },
            borderRadius: BorderRadius.circular(16),
            splashColor: AppTheme.primary.withValues(alpha: 0.08),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Stack(
                    children: [
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: notification['color'].withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: notification['color'].withValues(alpha: 0.2),
                            width: 1.5,
                          ),
                        ),
                        child: Icon(
                          notification['icon'],
                          color: notification['color'],
                          size: 24,
                        ),
                      ),
                      if (!isRead && !_selectMode)
                        Positioned(
                          top: -2,
                          right: -2,
                          child: AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 12 + _pulseController.value * 4,
                                height: 12 + _pulseController.value * 4,
                                decoration: BoxDecoration(
                                  color: Colors.blue,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 2,
                                  ),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.blue.withValues(alpha: 0.4),
                                      blurRadius: 8,
                                      spreadRadius: 2,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      if (isImportant)
                        Positioned(
                          bottom: -4,
                          left: -4,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.star_rounded,
                              size: 14,
                              color: Colors.amber,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 14),
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
                                  fontSize: 14,
                                  fontWeight: isRead ? FontWeight.w600 : FontWeight.w700,
                                  color: AppTheme.primaryContainer,
                                ),
                              ),
                            ),
                            if (!_selectMode)
                              IconButton(
                                icon: Icon(
                                  Icons.more_vert_rounded,
                                  size: 18,
                                  color: Colors.grey.shade400,
                                ),
                                onPressed: () {
                                  _showNotificationMenu(notification);
                                },
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(
                          notification['body'],
                          style: TextStyle(
                            fontSize: 13,
                            color: isRead ? Colors.grey.shade600 : AppTheme.onSurfaceVariant,
                            height: 1.5,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              Icons.access_time_rounded,
                              size: 14,
                              color: Colors.grey.shade400,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatTime(notification['time']),
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.grey.shade500,
                              ),
                            ),
                            if (!isRead)
                              Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Container(
                                  width: 6,
                                  height: 6,
                                  decoration: BoxDecoration(
                                    color: Colors.blue,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                              ),
                            if (isImportant)
                              Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.amber.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Text(
                                    'مهم',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.amber,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  if (_selectMode)
                    Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: isSelected ? AppTheme.primary : Colors.grey.shade200,
                        border: Border.all(
                          color: isSelected ? AppTheme.primary : Colors.grey.shade400,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check_rounded,
                              size: 16,
                              color: Colors.white,
                            )
                          : null,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(
                      Icons.notifications_off_rounded,
                      size: 60,
                      color: Colors.grey,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == 'الكل'
                ? '📭 لا توجد إشعارات'
                : '🔍 لا توجد إشعارات في هذا الفلتر',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryContainer,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == 'الكل'
                ? 'سنخبرك عندما تصل إشعارات جديدة'
                : 'جرب تغيير الفلتر لمشاهدة إشعارات أخرى',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 24),
          if (_selectedFilter != 'الكل')
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'الكل';
                });
                HapticFeedback.lightImpact();
              },
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('عرض الكل'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFAB() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 56 + _pulseController.value * 8,
              height: 56 + _pulseController.value * 8,
              decoration: BoxDecoration(
                color: Colors.blue.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
            ),
            FloatingActionButton(
              onPressed: () {
                setState(() {
                  _selectedFilter = 'غير مقروء';
                });
                HapticFeedback.mediumImpact();
              },
              backgroundColor: Colors.blue,
              child: const Icon(
                Icons.mark_email_unread_rounded,
                color: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  void _showDeleteAllDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('حذف جميع الإشعارات'),
        content: const Text('هل أنت متأكد من رغبتك في حذف جميع الإشعارات؟'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAllNotifications();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('حذف الكل'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  void _showNotificationDetail(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: notification['color'].withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    notification['icon'],
                    color: notification['color'],
                    size: 28,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    notification['title'],
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              notification['body'],
              style: const TextStyle(
                fontSize: 14,
                height: 1.6,
                color: AppTheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  size: 14,
                  color: Colors.grey.shade400,
                ),
                const SizedBox(width: 4),
                Text(
                  _formatTime(notification['time']),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      if (!notification['isRead']) {
                        _markAsRead(notification['id']);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primary,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      notification['isRead'] ? 'مقروء' : 'تحديد كمقروء',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _deleteNotification(notification['id']);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text('حذف'),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  void _showNotificationMenu(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildMenuItem(
              icon: Icons.remove_red_eye_rounded,
              title: 'تحديد كمقروء',
              onTap: () {
                Navigator.pop(context);
                if (!notification['isRead']) {
                  _markAsRead(notification['id']);
                }
              },
            ),
            _buildMenuItem(
              icon: Icons.star_border_rounded,
              title: notification['isImportant'] ? 'إزالة من المهمة' : 'تحديد كمهم',
              onTap: () {
                Navigator.pop(context);
                setState(() {
                  final index = _notifications
                      .indexWhere((n) => n['id'] == notification['id']);
                  if (index != -1) {
                    _notifications[index]['isImportant'] =
                        !(_notifications[index]['isImportant'] as bool);
                  }
                });
              },
            ),
            _buildMenuItem(
              icon: Icons.delete_rounded,
              title: 'حذف',
              color: Colors.red,
              onTap: () {
                Navigator.pop(context);
                _deleteNotification(notification['id']);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    Color? color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? AppTheme.primary),
      title: Text(
        title,
        style: TextStyle(
          color: color ?? AppTheme.primaryContainer,
        ),
      ),
      onTap: onTap,
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inDays < 1) return 'منذ ${diff.inHours} ساعة';
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    return 'منذ ${(diff.inDays / 7).round()} أسبوع';
  }
}