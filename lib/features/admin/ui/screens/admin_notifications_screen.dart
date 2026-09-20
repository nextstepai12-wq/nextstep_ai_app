import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/helpers/hive_storage.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';

class AdminNotificationsScreen extends StatefulWidget {
  const AdminNotificationsScreen({super.key});

  @override
  State<AdminNotificationsScreen> createState() =>
      _AdminNotificationsScreenState();
}

class _AdminNotificationsScreenState extends State<AdminNotificationsScreen>
    with SingleTickerProviderStateMixin {
  bool _isLoading = true;
  String? _errorMessage;
  String _selectedTab = 'الكل';

  int _totalNotifications = 0;
  int _unreadCount = 0;
  int _sentCount = 0;
  int _readCount = 0;

  List<Map<String, dynamic>> _notifications = [];

  final List<String> _tabs = ['الكل', 'غير مقروء', 'مقروء', 'مرسلة'];

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
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

    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final cached =
          await HiveStorage.getData('notifications_cache', 'notifications');

      if (cached != null && cached.isNotEmpty) {
        _notifications = List<Map<String, dynamic>>.from(cached);
        _updateStats();
      } else {
        _notifications = _getMockNotifications();
        await HiveStorage.saveData(
            'notifications_cache', 'notifications', _notifications);
        _updateStats();
      }

      if (mounted) {
        setState(() {
          _isLoading = false;
          _animationController.forward();
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = 'فشل تحميل الإشعارات: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  void _updateStats() {
    _totalNotifications = _notifications.length;
    _unreadCount =
        _notifications.where((n) => n['status'] == 'غير مقروء').length;
    _sentCount = _notifications.where((n) => n['status'] == 'مرسلة').length;
    _readCount = _notifications.where((n) => n['status'] == 'مقروء').length;
  }

  List<Map<String, dynamic>> get _filteredNotifications {
    if (_selectedTab == 'الكل') return _notifications;
    if (_selectedTab == 'غير مقروء') {
      return _notifications.where((n) => n['status'] == 'غير مقروء').toList();
    }
    if (_selectedTab == 'مقروء') {
      return _notifications.where((n) => n['status'] == 'مقروء').toList();
    }
    if (_selectedTab == 'مرسلة') {
      return _notifications.where((n) => n['status'] == 'مرسلة').toList();
    }
    return _notifications;
  }

  List<Map<String, dynamic>> _getMockNotifications() {
    return [
      {
        'id': '1',
        'title': '🎉 ترحيب بالمستخدمين الجدد',
        'message': 'نرحب بجميع الطلاب الجدد في منصة NextStep AI للارشاد الأكاديمي والمهني',
        'type': 'general',
        'target': 'الكل',
        'status': 'مقروء',
        'sentAt': '2026-08-14 10:30',
        'readBy': 45,
        'totalRecipients': 150,
        'priority': 'high',
        'author': 'مدير النظام',
      },
      {
        'id': '2',
        'title': '🚀 تحديث نظام التوصية',
        'message': 'تم تحديث محرك التوصية ليصبح أكثر دقة بنسبة 35% باستخدام تقنيات الذكاء الاصطناعي المتقدمة',
        'type': 'system',
        'target': 'الطلاب',
        'status': 'غير مقروء',
        'sentAt': '2026-08-14 09:15',
        'readBy': 12,
        'totalRecipients': 120,
        'priority': 'urgent',
        'author': 'فريق التطوير',
      },
      {
        'id': '3',
        'title': '🏛️ دعوة للجامعات الشريكة',
        'message': 'ندعو جميع الجامعات الفلسطينية للتسجيل في المنصة والاستفادة من خدمات الإرشاد الذكي',
        'type': 'promotional',
        'target': 'الجامعات',
        'status': 'مقروء',
        'sentAt': '2026-08-13 16:45',
        'readBy': 18,
        'totalRecipients': 24,
        'priority': 'medium',
        'author': 'إدارة المنصة',
      },
      {
        'id': '4',
        'title': '🔧 صيانة النظام',
        'message': 'سيتم إجراء صيانة دورية للنظام يوم الجمعة من الساعة 2:00 صباحاً حتى 4:00 صباحاً',
        'type': 'system',
        'target': 'الكل',
        'status': 'غير مقروء',
        'sentAt': '2026-08-13 14:20',
        'readBy': 30,
        'totalRecipients': 200,
        'priority': 'urgent',
        'author': 'فريق التقنية',
      },
      {
        'id': '5',
        'title': '📊 نتائج التقييم الجديدة',
        'message': 'تم إضافة ميزة عرض نتائج التقييم بشكل رسومي مع تحليلات تفصيلية',
        'type': 'feature',
        'target': 'الطلاب',
        'status': 'مقروء',
        'sentAt': '2026-08-12 11:00',
        'readBy': 78,
        'totalRecipients': 100,
        'priority': 'medium',
        'author': 'فريق التطوير',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _buildAppBar(),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF8B5CF6)),
              )
            : _errorMessage != null
                ? _buildErrorState()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: RefreshIndicator(
                        onRefresh: _loadData,
                        child: Column(
                          children: [
                            _buildStatsRow(),
                            _buildTabs(),
                            Expanded(
                              child: _filteredNotifications.isEmpty
                                  ? _buildEmptyState()
                                  : ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 8,
                                      ),
                                      itemCount: _filteredNotifications.length,
                                      itemBuilder: (context, index) {
                                        final notification =
                                            _filteredNotifications[index];
                                        return _buildNotificationCard(
                                            notification);
                                      },
                                    ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
        floatingActionButton: _buildFAB(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded,
            color: AppTheme.primaryContainer),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'الإشعارات',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryContainer,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.done_all_rounded,
              color: AppTheme.primaryContainer),
          tooltip: 'تحديد الكل كمقروء',
          onPressed: () => _markAllAsRead(),
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: AppTheme.primaryContainer),
          onPressed: _loadData,
        ),
      ],
    );
  }

  Widget _buildStatsRow() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildStatItem(
              label: 'الإجمالي',
              value: _totalNotifications.toString(),
              icon: Icons.notifications_rounded,
              color: const Color(0xFF3B82F6),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF3B82F6), Color(0xFF1D4ED8)],
              ),
            ),
          ),
          Container(width: 1, height: 32, color: Colors.grey.shade200),
          Expanded(
            child: _buildStatItem(
              label: 'غير مقروء',
              value: _unreadCount.toString(),
              icon: Icons.circle_rounded,
              color: const Color(0xFFDC2626),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFDC2626), Color(0xFF991B1B)],
              ),
            ),
          ),
          Container(width: 1, height: 32, color: Colors.grey.shade200),
          Expanded(
            child: _buildStatItem(
              label: 'مقروء',
              value: _readCount.toString(),
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF22C55E),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF22C55E), Color(0xFF16A34A)],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
    required Gradient gradient,
  }) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            gradient: gradient,
            shape: BoxShape.circle,
          ),
          child: Icon(icon, size: 16, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryContainer,
          ),
        ),
        Text(
          label,
          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
        ),
      ],
    );
  }

  Widget _buildTabs() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      height: 36,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: _tabs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final tab = _tabs[index];
          final isSelected = _selectedTab == tab;
          return ChoiceChip(
            label: Text(tab),
            selected: isSelected,
            onSelected: (_) => setState(() => _selectedTab = tab),
            backgroundColor: Colors.white,
            selectedColor: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
            labelStyle: TextStyle(
              fontSize: 13,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade700,
            ),
            side: BorderSide(
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey.shade300,
              width: 1.4,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 6),
          );
        },
      ),
    );
  }

  Widget _buildNotificationCard(Map<String, dynamic> notification) {
    final isUnread = notification['status'] == 'غير مقروء';
    final isSent = notification['status'] == 'مرسلة';
    final priority = notification['priority'] ?? 'normal';

    final typeColors = {
      'general': const Color(0xFF3B82F6),
      'system': const Color(0xFFF97316),
      'promotional': const Color(0xFF22C55E),
      'feature': const Color(0xFF8B5CF6),
    };
    final typeIcons = {
      'general': Icons.info_rounded,
      'system': Icons.settings_rounded,
      'promotional': Icons.campaign_rounded,
      'feature': Icons.star_rounded,
    };
    final typeLabels = {
      'general': 'عام',
      'system': 'نظام',
      'promotional': 'ترويجي',
      'feature': 'ميزة جديدة',
    };

    final color = typeColors[notification['type']] ?? Colors.grey;
    final icon = typeIcons[notification['type']] ?? Icons.notifications_rounded;
    final typeLabel = typeLabels[notification['type']] ?? 'عام';

    Color priorityColor = Colors.grey;
    String priorityLabel = 'عادي';
    if (priority == 'urgent') {
      priorityColor = Colors.red;
      priorityLabel = '🔴 عاجل';
    } else if (priority == 'high') {
      priorityColor = Colors.orange;
      priorityLabel = '🟠 مهم';
    } else if (priority == 'medium') {
      priorityColor = Colors.blue;
      priorityLabel = '🔵 متوسط';
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnread
            ? const Color(0xFFF5F0FF)
            : isSent
                ? Colors.green.shade50
                : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isUnread
              ? const Color(0xFF8B5CF6)
              : isSent
                  ? Colors.green.shade300
                  : Colors.grey.shade200,
          width: isUnread ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: isUnread
                ? const Color(0xFF8B5CF6).withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
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
                              fontSize: 14,
                              fontWeight: isUnread ? FontWeight.w700 : FontWeight.w600,
                              color: AppTheme.primaryContainer,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (isUnread)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF8B5CF6),
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: color.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            typeLabel,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: priorityColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            priorityLabel,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: priorityColor,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '👤 ${notification['author'] ?? 'النظام'}',
                          style: TextStyle(
                            fontSize: 9,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            notification['message'] as String,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade700,
              height: 1.4,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.access_time_rounded,
                    size: 12,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    notification['sentAt'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.visibility_rounded,
                    size: 12,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${notification['readBy']}/${notification['totalRecipients']}',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Icon(
                    Icons.people_rounded,
                    size: 12,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    notification['target'] as String,
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.grey.shade500,
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

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () => _showSendNotificationDialog(context),
      backgroundColor: const Color(0xFF8B5CF6),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'إشعار جديد',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }

  Future<void> _markAllAsRead() async {
    if (_unreadCount == 0) {
      _showSnackBar('جميع الإشعارات مقروءة بالفعل', Colors.blue);
      return;
    }

    setState(() {
      _notifications = _notifications.map((n) {
        if (n['status'] == 'غير مقروء') {
          return {...n, 'status': 'مقروء'};
        }
        return n;
      }).toList();
      _updateStats();
    });

    await HiveStorage.saveData('notifications_cache', 'notifications', _notifications);
    _showSnackBar('✅ تم تحديد جميع الإشعارات كمقروءة', Colors.green);
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: const Color(0xFF8B5CF6).withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.notifications_off_rounded,
                size: 48,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _selectedTab == 'الكل' ? 'لا توجد إشعارات' : 'لا توجد نتائج مطابقة',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _selectedTab == 'الكل'
                  ? 'يمكنك إرسال إشعار جديد باستخدام زر الإضافة'
                  : 'جرب تغيير التبويب لعرض إشعارات أخرى',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSendNotificationDialog(BuildContext context) {
    final titleController = TextEditingController();
    final messageController = TextEditingController();
    String selectedTarget = 'الكل';
    String selectedType = 'general';
    String selectedPriority = 'normal';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) => Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'إرسال إشعار جديد',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primaryContainer,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  decoration: InputDecoration(
                    labelText: 'عنوان الإشعار',
                    hintText: 'مثال: تحديث جديد في المنصة',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                    ),
                    prefixIcon: const Icon(Icons.title_rounded,
                        color: Color(0xFF8B5CF6)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: messageController,
                  textDirection: TextDirection.rtl,
                  textAlign: TextAlign.right,
                  maxLines: 4,
                  decoration: InputDecoration(
                    labelText: 'نص الإشعار',
                    hintText: 'أدخل محتوى الإشعار هنا...',
                    hintStyle: TextStyle(color: Colors.grey.shade400),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                    ),
                    prefixIcon: const Icon(Icons.message_rounded,
                        color: Color(0xFF8B5CF6)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                ),
                const SizedBox(height: 14),
                DropdownButtonFormField<String>(
                  initialValue: selectedTarget,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: 'الفئة المستهدفة',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                    ),
                    prefixIcon: const Icon(Icons.people_rounded,
                        color: Color(0xFF8B5CF6)),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'الكل', child: Row(
                      children: [Icon(Icons.public_rounded, size: 16), SizedBox(width: 6), Text('الكل')],
                    )),
                    DropdownMenuItem(value: 'الطلاب', child: Row(
                      children: [Icon(Icons.school_rounded, size: 16), SizedBox(width: 6), Text('الطلاب')],
                    )),
                    DropdownMenuItem(value: 'الجامعات', child: Row(
                      children: [Icon(Icons.business_rounded, size: 16), SizedBox(width: 6), Text('الجامعات')],
                    )),
                    DropdownMenuItem(value: 'الإدارة', child: Row(
                      children: [Icon(Icons.admin_panel_settings_rounded, size: 16), SizedBox(width: 6), Text('الإدارة')],
                    )),
                  ],
                  onChanged: (value) {
                    if (value != null) selectedTarget = value;
                  },
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'النوع',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                          ),
                          prefixIcon: const Icon(Icons.category_rounded,
                              color: Color(0xFF8B5CF6)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'general', child: Row(
                            children: [Icon(Icons.info_rounded, size: 14, color: Colors.blue), SizedBox(width: 4), Flexible(child: Text('عام'))],
                          )),
                          DropdownMenuItem(value: 'system', child: Row(
                            children: [Icon(Icons.settings_rounded, size: 14, color: Colors.orange), SizedBox(width: 4), Flexible(child: Text('نظام'))],
                          )),
                          DropdownMenuItem(value: 'promotional', child: Row(
                            children: [Icon(Icons.campaign_rounded, size: 14, color: Colors.green), SizedBox(width: 4), Flexible(child: Text('ترويجي'))],
                          )),
                          DropdownMenuItem(value: 'feature', child: Row(
                            children: [Icon(Icons.star_rounded, size: 14, color: Colors.purple), SizedBox(width: 4), Flexible(child: Text('ميزة جديدة'))],
                          )),
                        ],
                        onChanged: (value) {
                          if (value != null) selectedType = value;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        initialValue: selectedPriority,
                        isExpanded: true,
                        decoration: InputDecoration(
                          labelText: 'الأولوية',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide(color: Colors.grey.shade300),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: const BorderSide(color: Color(0xFF8B5CF6), width: 2),
                          ),
                          prefixIcon: const Icon(Icons.flag_rounded,
                              color: Color(0xFF8B5CF6)),
                          filled: true,
                          fillColor: Colors.grey.shade50,
                        ),
                        items: const [
                          DropdownMenuItem(value: 'normal', child: Row(
                            children: [Icon(Icons.flag_rounded, size: 14, color: Colors.grey), SizedBox(width: 4), Flexible(child: Text('عادي'))],
                          )),
                          DropdownMenuItem(value: 'medium', child: Row(
                            children: [Icon(Icons.flag_rounded, size: 14, color: Colors.blue), SizedBox(width: 4), Flexible(child: Text('متوسط'))],
                          )),
                          DropdownMenuItem(value: 'high', child: Row(
                            children: [Icon(Icons.flag_rounded, size: 14, color: Colors.orange), SizedBox(width: 4), Flexible(child: Text('مهم'))],
                          )),
                          DropdownMenuItem(value: 'urgent', child: Row(
                            children: [Icon(Icons.flag_rounded, size: 14, color: Colors.red), SizedBox(width: 4), Flexible(child: Text('عاجل'))],
                          )),
                        ],
                        onChanged: (value) {
                          if (value != null) selectedPriority = value;
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              style: TextButton.styleFrom(
                foregroundColor: Colors.grey.shade600,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (titleController.text.isEmpty || messageController.text.isEmpty) {
                  _showSnackBar('الرجاء ملء جميع الحقول المطلوبة', Colors.orange);
                  return;
                }

                final newNotification = {
                  'id': DateTime.now().millisecondsSinceEpoch.toString(),
                  'title': titleController.text,
                  'message': messageController.text,
                  'type': selectedType,
                  'target': selectedTarget,
                  'priority': selectedPriority,
                  'status': 'مرسلة',
                  'sentAt': DateTime.now().toString().substring(0, 16),
                  'readBy': 0,
                  'totalRecipients': 0,
                  'author': 'مدير النظام',
                };

                final cached = await HiveStorage.getData(
                    'notifications_cache', 'notifications');
                List<Map<String, dynamic>> notifications =
                    cached != null ? List<Map<String, dynamic>>.from(cached) : [];
                notifications.insert(0, newNotification);
                await HiveStorage.saveData(
                    'notifications_cache', 'notifications', notifications);

                if (mounted) {
                  Navigator.pop(dialogContext);
                  _showSnackBar('✅ تم إرسال الإشعار بنجاح', Colors.green);
                  _loadData();
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('إرسال الإشعار'),
            ),
          ],
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        ),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: color,
          content: Text(
            message,
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
