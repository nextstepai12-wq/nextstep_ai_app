import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';

// ─── Notification Model ──────────────────────────────────────────────────────
enum NotificationType { assessment, recommendation, favorite, system }

class AppNotification {
  final int id;
  final String title;
  final String body;
  final DateTime time;
  bool isRead;
  final NotificationType type;

  AppNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.time,
    this.isRead = false,
    required this.type,
  });

  String get emoji {
    switch (type) {
      case NotificationType.assessment:
        return '\u{1F3AF}';
      case NotificationType.recommendation:
        return '\u{1F393}';
      case NotificationType.favorite:
        return '\u2B50';
      case NotificationType.system:
        return '\u{1F4E2}';
    }
  }

  IconData get icon {
    switch (type) {
      case NotificationType.assessment:
        return Icons.auto_awesome_rounded;
      case NotificationType.recommendation:
        return Icons.school_rounded;
      case NotificationType.favorite:
        return Icons.bookmark_rounded;
      case NotificationType.system:
        return Icons.campaign_rounded;
    }
  }
}

// ─── NotificationsScreen ─────────────────────────────────────────────────────
class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with TickerProviderStateMixin {
  String _selectedFilter = '\u0627\u0644\u0643\u0644';
  List<AppNotification> _notifications = [];
  bool _isLoading = true;
  bool _hasError = false;
  bool _selectMode = false;
  final Set<int> _selectedIds = {};

  static const _filterLabels = [
    '\u0627\u0644\u0643\u0644',
    '\u0627\u0644\u062A\u0642\u064A\u064A\u0645',
    '\u0627\u0644\u062A\u0648\u0635\u064A\u0627\u062A',
    '\u0627\u0644\u0645\u0641\u0636\u0644\u0629',
    '\u0627\u0644\u0646\u0638\u0627\u0645',
  ];
  static const _filterTypes = <String, NotificationType?>{
    '\u0627\u0644\u0643\u0644': null,
    '\u0627\u0644\u062A\u0642\u064A\u064A\u0645': NotificationType.assessment,
    '\u0627\u0644\u062A\u0648\u0635\u064A\u0627\u062A': NotificationType.recommendation,
    '\u0627\u0644\u0645\u0641\u0636\u0644\u0629': NotificationType.favorite,
    '\u0627\u0644\u0646\u0638\u0627\u0645': NotificationType.system,
  };

  late AnimationController _staggerController;
  late List<Animation<double>> _cardFadeAnims;
  late List<Animation<Offset>> _cardSlideAnims;
  late AnimationController _multiSelectAnim;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadNotifications();
  }

  void _initAnimations() {
    _staggerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _cardFadeAnims = [];
    _cardSlideAnims = [];
    for (int i = 0; i < 12; i++) {
      final start = (i * 0.06).clamp(0.0, 1.0);
      final end = (start + 0.35).clamp(0.0, 1.0);
      _cardFadeAnims.add(
        Tween<double>(begin: 0, end: 1).animate(
          CurvedAnimation(parent: _staggerController, curve: Interval(start, end, curve: Curves.easeOut)),
        ),
      );
      _cardSlideAnims.add(
        Tween<Offset>(begin: const Offset(0, 0.12), end: Offset.zero).animate(
          CurvedAnimation(parent: _staggerController, curve: Interval(start, end, curve: Curves.easeOutCubic)),
        ),
      );
    }
    _multiSelectAnim = AnimationController(vsync: this, duration: const Duration(milliseconds: 350));
  }

  @override
  void dispose() {
    _staggerController.dispose();
    _multiSelectAnim.dispose();
    super.dispose();
  }

  // ── Data ───────────────────────────────────────────────────────────────────

  Future<void> _loadNotifications() async {
    setState(() { _isLoading = true; _hasError = false; });
    try {
      await Future.delayed(const Duration(milliseconds: 900));
      _notifications = _dummyNotifications();
      if (mounted) {
        setState(() => _isLoading = false);
        _staggerController.forward(from: 0);
      }
    } catch (e) {
      if (mounted) setState(() { _isLoading = false; _hasError = true; });
    }
  }

  Future<void> _refreshNotifications() async {
    HapticFeedback.mediumImpact();
    await Future.delayed(const Duration(milliseconds: 1200));
    _notifications = _dummyNotifications();
    if (mounted) {
      setState(() {});
      _staggerController.forward(from: 0);
    }
  }

  List<AppNotification> get _filteredNotifications {
    final type = _filterTypes[_selectedFilter];
    if (type == null) return _notifications;
    return _notifications.where((n) => n.type == type).toList();
  }

  int get _unreadCount => _notifications.where((n) => !n.isRead).length;

  int _filterCount(String f) {
    final t = _filterTypes[f];
    return t == null ? _notifications.length : _notifications.where((n) => n.type == t).length;
  }

  int _filterUnread(String f) {
    final t = _filterTypes[f];
    return t == null ? _unreadCount : _notifications.where((n) => !n.isRead && n.type == t).length;
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  void _markAsRead(int id) {
    setState(() { _notifications.firstWhere((e) => e.id == id).isRead = true; });
  }

  void _markAllAsRead() {
    setState(() {
      for (var n in _notifications) {
        n.isRead = true;
      }
    });
    _showSnackBar('تم تحديد الكل كمقروء');
  }

  void _deleteNotification(int id) {
    setState(() { _notifications.removeWhere((n) => n.id == id); _selectedIds.remove(id); });
    _showSnackBar('تم حذف الإشعار');
  }

  void _deleteSelected() {
    final count = _selectedIds.length;
    setState(() {
      _notifications.removeWhere((n) => _selectedIds.contains(n.id));
      _selectedIds.clear();
      _selectMode = false;
    });
    _multiSelectAnim.reverse();
    _showSnackBar('تم حذف $count إشعار');
  }

  void _toggleSelectMode() {
    setState(() {
      _selectMode = !_selectMode;
      if (!_selectMode) _selectedIds.clear();
    });
    _selectMode ? _multiSelectAnim.forward() : _multiSelectAnim.reverse();
  }

  void _toggleSelection(int id) {
    setState(() {
      if (_selectedIds.contains(id)) {
        _selectedIds.remove(id);
        if (_selectedIds.isEmpty) {
          _selectMode = false;
          _multiSelectAnim.reverse();
        }
      } else {
        _selectedIds.add(id);
      }
    });
  }

  void _showSnackBar(String message) {
    final c = context.appColors;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: c.success,
        duration: const Duration(seconds: 2),
        content: Row(children: [
          const Icon(Icons.check_circle_outline_rounded, color: Colors.white, size: 20),
          const SizedBox(width: 10),
          Expanded(child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 13, fontFamily: 'Cairo'))),
        ]),
      ));
  }

  void _showDeleteAllDialog() {
    final c = context.appColors;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        backgroundColor: c.surface,
        title: Row(children: [
          Container(
            width: 40, height: 40,
            decoration: BoxDecoration(color: c.danger.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.delete_outline_rounded, color: c.danger, size: 22),
          ),
          const SizedBox(width: 12),
          const Text('حذف جميع الإشعارات', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, fontFamily: 'Cairo')),
        ]),
        content: Text(
          'هل أنت متأكد من حذف جميع الإشعارات؟ لا يمكن التراجع عن هذا الإجراء.',
          style: TextStyle(fontSize: 14, color: c.textSecondary, fontFamily: 'Cairo', height: 1.6),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('إلغاء', style: TextStyle(color: c.textSecondary, fontFamily: 'Cairo'))),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() { _notifications.clear(); _selectMode = false; _selectedIds.clear(); });
              _showSnackBar('تم حذف جميع الإشعارات');
            },
            style: FilledButton.styleFrom(backgroundColor: c.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('حذف الكل', style: TextStyle(fontFamily: 'Cairo')),
          ),
        ],
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        body: Stack(
          children: [
            Column(children: [
              _buildHeader(c),
              _buildFilterChips(c),
              Expanded(
                child: _isLoading
                    ? _buildSkeleton(c)
                    : _hasError
                        ? _buildErrorState(c)
                        : _filteredNotifications.isEmpty
                            ? _buildEmptyState(c)
                            : _buildNotificationsList(c),
              ),
            ]),
            if (_selectMode) _buildMultiSelectBar(c),
          ],
        ),
      ),
    );
  }

  // ── Header ─────────────────────────────────────────────────────────────────

  Widget _buildHeader(AppColors c) {
    return Container(
      padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top + 8, left: 16, right: 16, bottom: 12),
      decoration: BoxDecoration(
        color: c.background,
        border: Border(bottom: BorderSide(color: c.divider.withValues(alpha: 0.3), width: 0.5)),
      ),
      child: Row(children: [
        _iconBtn(icon: Icons.arrow_back_ios_new_rounded, onTap: () => Navigator.pop(context), c: c),
        const SizedBox(width: 12),
        Expanded(
          child: Row(children: [
            Text('الإشعارات', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: c.textPrimary, fontFamily: 'Cairo')),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: [c.gradientStart, c.gradientEnd]),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.25), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
                  const SizedBox(width: 4),
                  Text('$_unreadCount جديدة', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Cairo')),
                ]),
              ),
            ],
          ]),
        ),
        if (!_selectMode)
          PopupMenuButton<String>(
            icon: Container(
              width: 40, height: 40,
              decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: BorderRadius.circular(12)),
              child: Icon(Icons.more_vert_rounded, color: c.textSecondary, size: 20),
            ),
            onSelected: (v) {
              if (v == 'mark_all') {
                _markAllAsRead();
              } else if (v == 'delete_all') {
                _showDeleteAllDialog();
              } else if (v == 'select') {
                _toggleSelectMode();
              }
            },
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            color: c.surface,
            elevation: 4,
            itemBuilder: (_) => [
              _popupItem(c, 'select', Icons.checklist_rounded, 'تحديد متعدد'),
              _popupItem(c, 'mark_all', Icons.done_all_rounded, 'تحديد الكل كمقروء'),
              _popupItem(c, 'delete_all', Icons.delete_outline_rounded, 'مسح جميع الإشعارات', destructive: true),
            ],
          ),
      ]),
    );
  }

  PopupMenuItem<String> _popupItem(AppColors c, String v, IconData icon, String label, {bool destructive = false}) {
    return PopupMenuItem(
      value: v,
      child: Row(children: [
        Icon(icon, size: 20, color: destructive ? c.danger : c.textSecondary),
        const SizedBox(width: 12),
        Text(label, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: destructive ? c.danger : c.textPrimary, fontFamily: 'Cairo')),
      ]),
    );
  }

  Widget _iconBtn({required IconData icon, required VoidCallback onTap, required AppColors c}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 42, height: 42,
        decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: BorderRadius.circular(12)),
        child: Icon(icon, size: 20, color: c.textPrimary),
      ),
    );
  }

  // ── Filter Chips ───────────────────────────────────────────────────────────

  Widget _buildFilterChips(AppColors c) {
    return SizedBox(
      height: 56,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: _filterLabels.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, i) {
          final label = _filterLabels[i];
          final sel = _selectedFilter == label;
          final unread = _filterUnread(label);
          final count = _filterCount(label);
          return GestureDetector(
            onTap: () {
              setState(() => _selectedFilter = label);
              HapticFeedback.lightImpact();
              _staggerController.forward(from: 0);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: sel ? LinearGradient(colors: [c.gradientStart, c.gradientEnd]) : null,
                color: sel ? null : c.surface,
                borderRadius: BorderRadius.circular(20),
                border: sel ? null : Border.all(color: c.divider.withValues(alpha: 0.4), width: 1),
                boxShadow: sel
                    ? [BoxShadow(color: c.primary.withValues(alpha: 0.2), blurRadius: 8, offset: const Offset(0, 2))]
                    : [],
              ),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                if (sel)
                  Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white70, shape: BoxShape.circle)),
                if (sel) const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: sel ? FontWeight.w700 : FontWeight.w500,
                    color: sel ? Colors.white : c.textSecondary,
                    fontFamily: 'Cairo',
                  ),
                ),
                if (count > 0) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                    decoration: BoxDecoration(
                      color: sel ? Colors.white.withValues(alpha: 0.25) : c.surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '$count',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: sel ? Colors.white : c.textSecondary,
                        fontFamily: 'Cairo',
                      ),
                    ),
                  ),
                ],
                if (!sel && unread > 0) ...[
                  const SizedBox(width: 4),
                  Container(width: 7, height: 7, decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle)),
                ],
              ]),
            ),
          );
        },
      ),
    );
  }

  // ── Notifications List ─────────────────────────────────────────────────────

  Widget _buildNotificationsList(AppColors c) {
    final grouped = _groupByTime(_filteredNotifications);
    final keys = grouped.keys.toList();
    final items = <Widget>[];
    int idx = 0;

    for (final key in keys) {
      final notifs = grouped[key]!;
      items.add(_sectionHeader(key, notifs.length, c));
      for (final n in notifs) {
        final ai = idx.clamp(0, _cardFadeAnims.length - 1);
        items.add(FadeTransition(
          opacity: _cardFadeAnims[ai],
          child: SlideTransition(position: _cardSlideAnims[ai], child: _notificationCard(n, c)),
        ));
        items.add(const SizedBox(height: 10));
        idx++;
      }
    }

    return RefreshIndicator(
      onRefresh: _refreshNotifications,
      color: c.primary,
      backgroundColor: c.surface,
      strokeWidth: 2.5,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        padding: EdgeInsets.only(left: 16, right: 16, top: 4, bottom: MediaQuery.of(context).padding.bottom + 100),
        children: items,
      ),
    );
  }

  Map<String, List<AppNotification>> _groupByTime(List<AppNotification> list) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = today.subtract(const Duration(days: 1));
    final weekAgo = today.subtract(const Duration(days: 7));

    final map = <String, List<AppNotification>>{};
    for (final n in list) {
      final d = DateTime(n.time.year, n.time.month, n.time.day);
      String key;
      if (!d.isBefore(today)) {
        key = 'اليوم';
      } else if (!d.isBefore(yesterday)) {
        key = 'أمس';
      } else if (!d.isBefore(weekAgo)) {
        key = 'هذا الأسبوع';
      } else {
        key = 'الأقدم';
      }
      map.putIfAbsent(key, () => []).add(n);
    }
    return map;
  }

  Widget _sectionHeader(String title, int count, AppColors c) {
    final now = DateTime.now();
    String sub = '';
    if (title == 'اليوم') {
      sub = _arabicDate(now);
    } else if (title == 'أمس') {
      sub = _arabicDate(now.subtract(const Duration(days: 1)));
    }

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Row(children: [
        Text(title, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: c.textPrimary, fontFamily: 'Cairo')),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(color: c.primarySoft, borderRadius: BorderRadius.circular(10)),
          child: Text('$count', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c.primary, fontFamily: 'Cairo')),
        ),
        const Spacer(),
        if (sub.isNotEmpty) Text(sub, style: TextStyle(fontSize: 12, color: c.textSecondary, fontFamily: 'Cairo')),
      ]),
    );
  }

  String _arabicDate(DateTime d) {
    const days = ['', 'الإثنين', 'الثلاثاء', 'الأربعاء', 'الخميس', 'الجمعة', 'السبت', 'الأحد'];
    const months = ['', 'يناير', 'فبراير', 'مارس', 'أبريل', 'مايو', 'يونيو', 'يوليو', 'أغسطس', 'سبتمبر', 'أكتوبر', 'نوفمبر', 'ديسمبر'];
    return '${days[d.weekday]}، ${d.day} ${months[d.month]}';
  }

  // ── Notification Card ──────────────────────────────────────────────────────

  Widget _notificationCard(AppNotification n, AppColors c) {
    final isSel = _selectedIds.contains(n.id);
    Color bgColor;
    Color iconBg;
    Color iconColor;
    switch (n.type) {
      case NotificationType.assessment:
        bgColor = n.isRead ? c.surface : const Color(0xFFF0EDFF);
        iconBg = const Color(0xFFE3DFFF);
        iconColor = c.primary;
        break;
      case NotificationType.recommendation:
        bgColor = n.isRead ? c.surface : const Color(0xFFEAF0FF);
        iconBg = const Color(0xFFE0E0FF);
        iconColor = c.purple;
        break;
      case NotificationType.favorite:
        bgColor = n.isRead ? c.surface : const Color(0xFFFFF8E8);
        iconBg = const Color(0xFFFFF3CD);
        iconColor = c.accent;
        break;
      case NotificationType.system:
        bgColor = n.isRead ? c.surface : const Color(0xFFE8F8F0);
        iconBg = const Color(0xFFD4EDDA);
        iconColor = c.success;
        break;
    }

    return Dismissible(
      key: Key(n.id.toString()),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.only(left: 24),
        decoration: BoxDecoration(color: c.danger.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Icon(Icons.delete_outline_rounded, color: c.danger, size: 24),
          const SizedBox(height: 2),
          Text('حذف', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: c.danger, fontFamily: 'Cairo')),
        ]),
      ),
      confirmDismiss: (_) async {
        return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: c.surface,
            title: const Text('حذف الإشعار', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w700)),
            content: Text('هل تريد حذف هذا الإشعار؟', style: TextStyle(fontFamily: 'Cairo', color: c.textSecondary)),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text('إلغاء', style: TextStyle(fontFamily: 'Cairo', color: c.textSecondary))),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: c.danger, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                child: const Text('حذف', style: TextStyle(fontFamily: 'Cairo')),
              ),
            ],
          ),
        ) ?? false;
      },
      onDismissed: (_) => _deleteNotification(n.id),
      child: GestureDetector(
        onTap: () {
          if (_selectMode) {
            _toggleSelection(n.id);
            HapticFeedback.mediumImpact();
          } else {
            if (!n.isRead) {
              _markAsRead(n.id);
              HapticFeedback.lightImpact();
            }
          }
        },
        onLongPress: () {
          if (!_selectMode) {
            HapticFeedback.heavyImpact();
            _toggleSelectMode();
            _toggleSelection(n.id);
          }
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSel ? c.primary : (n.isRead ? c.divider.withValues(alpha: 0.3) : c.divider.withValues(alpha: 0.15)),
              width: isSel ? 2 : 1,
            ),
            boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: n.isRead ? 0.02 : 0.04), blurRadius: 12, offset: const Offset(0, 4))],
          ),
          child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            if (_selectMode) ...[
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                width: 24, height: 24,
                decoration: BoxDecoration(
                  color: isSel ? c.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: isSel ? c.primary : c.divider, width: 2),
                ),
                child: isSel ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
              ),
              const SizedBox(width: 10),
            ],
            Stack(children: [
              Container(
                width: 48, height: 48,
                decoration: BoxDecoration(color: iconBg, borderRadius: BorderRadius.circular(16)),
                child: Icon(n.icon, color: iconColor, size: 24),
              ),
              if (!n.isRead && !_selectMode)
                Positioned(
                  top: -2, right: -2,
                  child: Container(
                    width: 12, height: 12,
                    decoration: BoxDecoration(
                      color: c.primary,
                      shape: BoxShape.circle,
                      border: Border.all(color: c.background, width: 2),
                      boxShadow: [BoxShadow(color: c.primary.withValues(alpha: 0.4), blurRadius: 4)],
                    ),
                  ),
                ),
              Positioned(
                bottom: -3, left: -3,
                child: Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    color: c.surface,
                    shape: BoxShape.circle,
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 4)],
                  ),
                  child: Center(child: Text(n.emoji, style: const TextStyle(fontSize: 12))),
                ),
              ),
            ]),
            const SizedBox(width: 12),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  n.title,
                  style: TextStyle(fontSize: 14, fontWeight: n.isRead ? FontWeight.w600 : FontWeight.w700, color: c.textPrimary, fontFamily: 'Cairo'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  n.body,
                  style: TextStyle(fontSize: 13, color: c.textSecondary, fontFamily: 'Cairo', height: 1.5),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(children: [
                  Icon(Icons.schedule_rounded, size: 14, color: c.textSecondary.withValues(alpha: 0.6)),
                  const SizedBox(width: 4),
                  Text(_formatTime(n.time), style: TextStyle(fontSize: 11, color: c.textSecondary, fontFamily: 'Cairo')),
                ]),
              ]),
            ),
          ]),
        ),
      ),
    );
  }

  // ── Empty State ────────────────────────────────────────────────────────────

  Widget _buildEmptyState(AppColors c) {
    final isFiltered = _selectedFilter != 'الكل';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          TweenAnimationBuilder(
            tween: Tween<double>(begin: 0.8, end: 1.0),
            duration: const Duration(milliseconds: 800),
            builder: (context, value, child) {
              return Transform.scale(
                scale: value,
                child: Container(
                  width: 120, height: 120,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topRight,
                      end: Alignment.bottomLeft,
                      colors: [c.primarySoft, c.surfaceAlt],
                    ),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Icon(
                      isFiltered ? Icons.filter_list_off_rounded : Icons.notifications_off_rounded,
                      size: 56,
                      color: c.textSecondary.withValues(alpha: 0.5),
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Text(
            isFiltered ? 'لا إشعارات في هذا القسم' : 'لا توجد إشعارات بعد',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary, fontFamily: 'Cairo'),
          ),
          const SizedBox(height: 8),
          Text(
            isFiltered
                ? 'لم تصل إشعارات جديدة في هذا التصنيف'
                : 'سنخبرك فور توفر جديد لك',
            style: TextStyle(fontSize: 14, color: c.textSecondary, fontFamily: 'Cairo'),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          if (isFiltered)
            FilledButton.icon(
              onPressed: () {
                setState(() => _selectedFilter = 'الكل');
                HapticFeedback.lightImpact();
                _staggerController.forward(from: 0);
              },
              icon: const Icon(Icons.visibility_rounded, size: 18),
              label: const Text('عرض الكل', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
              style: FilledButton.styleFrom(
                backgroundColor: c.primary,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
        ]),
      ),
    );
  }

  // ── Error State ────────────────────────────────────────────────────────────

  Widget _buildErrorState(AppColors c) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            width: 100, height: 100,
            decoration: BoxDecoration(color: c.danger.withValues(alpha: 0.08), shape: BoxShape.circle),
            child: Icon(Icons.wifi_off_rounded, size: 48, color: c.danger.withValues(alpha: 0.6)),
          ),
          const SizedBox(height: 24),
          Text('فشل تحميل الإشعارات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: c.textPrimary, fontFamily: 'Cairo')),
          const SizedBox(height: 8),
          Text('تحقق من اتصال الإنترنت وحاول مرة أخرى', style: TextStyle(fontSize: 14, color: c.textSecondary, fontFamily: 'Cairo'), textAlign: TextAlign.center),
          const SizedBox(height: 24),
          FilledButton.icon(
            onPressed: _loadNotifications,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('إعادة المحاولة', style: TextStyle(fontFamily: 'Cairo', fontWeight: FontWeight.w600)),
            style: FilledButton.styleFrom(
              backgroundColor: c.primary,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
            ),
          ),
        ]),
      ),
    );
  }

  // ── Skeleton Loading ───────────────────────────────────────────────────────

  Widget _buildSkeleton(AppColors c) {
    return ListView.builder(
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: 4,
      itemBuilder: (context, i) {
        return ShimmerWidget(
          delay: i * 0.15,
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: c.surfaceAlt.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Container(width: 48, height: 48, decoration: BoxDecoration(color: c.divider.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(16))),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(height: 14, width: 180, decoration: BoxDecoration(color: c.divider.withValues(alpha: 0.3), borderRadius: BorderRadius.circular(8))),
                  const SizedBox(height: 8),
                  Container(height: 12, width: double.infinity, decoration: BoxDecoration(color: c.divider.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8))),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 120, decoration: BoxDecoration(color: c.divider.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(8))),
                  const SizedBox(height: 8),
                  Container(height: 10, width: 80, decoration: BoxDecoration(color: c.divider.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(8))),
                ]),
              ),
            ]),
          ),
        );
      },
    );
  }

  // ── Multi-Select Bar ───────────────────────────────────────────────────────

  Widget _buildMultiSelectBar(AppColors c) {
    return Positioned(
      bottom: 0, left: 0, right: 0,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero).animate(
          CurvedAnimation(parent: _multiSelectAnim, curve: Curves.easeOutCubic),
        ),
        child: FadeTransition(
          opacity: _multiSelectAnim,
          child: Container(
            padding: EdgeInsets.only(
              left: 16, right: 16, top: 16,
              bottom: MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: c.surface,
              boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, -4))],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: c.primary, shape: BoxShape.circle),
                child: Center(child: Text('${_selectedIds.length}', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: Colors.white, fontFamily: 'Cairo'))),
              ),
              const SizedBox(width: 12),
              Text('محددة', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: c.textPrimary, fontFamily: 'Cairo')),
              const Spacer(),
              _selectActionBtn(c, Icons.done_all_rounded, 'مقروء', c.primary, () {
                for (var id in _selectedIds) { _notifications.firstWhere((e) => e.id == id).isRead = true; }
                setState(() { _selectedIds.clear(); _selectMode = false; });
                _multiSelectAnim.reverse();
                _showSnackBar('تم تحديد المحددة كمقروءة');
              }),
              const SizedBox(width: 8),
              _selectActionBtn(c, Icons.delete_rounded, 'حذف', c.danger, _deleteSelected),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: _toggleSelectMode,
                child: Container(
                  width: 40, height: 40,
                  decoration: BoxDecoration(color: c.surfaceAlt, borderRadius: BorderRadius.circular(12)),
                  child: Icon(Icons.close_rounded, size: 20, color: c.textSecondary),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _selectActionBtn(AppColors c, IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 16, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white, fontFamily: 'Cairo')),
        ]),
      ),
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) return 'الآن';
    if (diff.inHours < 1) return 'منذ ${diff.inMinutes} دقيقة';
    if (diff.inDays < 1) {
      final h = time.hour > 12 ? time.hour - 12 : time.hour;
      final m = time.minute.toString().padLeft(2, '0');
      final period = time.hour >= 12 ? 'م' : 'ص';
      return 'أمس \u2022 ${h == 0 ? 12 : h}:$m $period';
    }
    if (diff.inDays < 7) return 'منذ ${diff.inDays} يوم';
    if (diff.inDays < 30) return 'منذ ${(diff.inDays / 7).round()} أسبوع';
    return 'منذ ${(diff.inDays / 30).round()} شهر';
  }

  List<AppNotification> _dummyNotifications() {
    final now = DateTime.now();
    return [
      AppNotification(
        id: 1,
        title: 'اكتمل تحليل ميولك الأكاديمية بنجاح',
        body: 'أظهرت نتائج التقييم توافقاً استثنائياً بنسبة 98% مع تخصص هندسة أنظمة الذكاء الاصطناعي. اضغط لاستعراض تقرير الميول الشامل.',
        time: now.subtract(const Duration(minutes: 5)),
        isRead: false,
        type: NotificationType.assessment,
      ),
      AppNotification(
        id: 2,
        title: 'توصية أكاديمية متوافقة مع معدلك',
        body: 'تم فتح باب التسجيل المبكر لمنح كلية تكنولوجيا المعلومات والذكاء الاصطناعي بالجامعة الإسلامية لبرامج التفوق.',
        time: now.subtract(const Duration(hours: 2)),
        isRead: false,
        type: NotificationType.recommendation,
      ),
      AppNotification(
        id: 3,
        title: 'تم حفظ 3 تخصصات في قائمتك المفضلة',
        body: 'أضفت هندسة البرمجيات، الحوسبة السحابية، وعلوم البيانات إلى مسارك المهني.',
        time: now.subtract(const Duration(hours: 4)),
        isRead: false,
        type: NotificationType.favorite,
      ),
      AppNotification(
        id: 4,
        title: 'تحديث جديد لمحرك الذكاء الاصطناعي',
        body: 'أضفنا بيانات القبول ومعايير التنسيق لعام 2025 لجامعات الأزهر، الأقصى، والقدس المفتوحة لتوفير دقة أكبر.',
        time: now.subtract(const Duration(days: 1, hours: 3)),
        isRead: true,
        type: NotificationType.system,
      ),
      AppNotification(
        id: 5,
        title: 'إجابة جديدة من المستشار الأكاديمي',
        body: 'قام المستشار بالرد على استفسارك حول مجالات وفرص العمل عن بُعد لهندسة المخرجات وهندسة الأوامر الرقمية.',
        time: now.subtract(const Duration(days: 1, hours: 8)),
        isRead: true,
        type: NotificationType.recommendation,
      ),
      AppNotification(
        id: 6,
        title: 'تقييمك الأكاديمي جاهز للإرسال',
        body: 'يمكنك الآن إرسال تقرير تقييم الميول إلى الجهة التعليمية المختارة مباشرة من التطبيق.',
        time: now.subtract(const Duration(days: 3)),
        isRead: true,
        type: NotificationType.assessment,
      ),
    ];
  }
}

// ─── Shimmer Widget ──────────────────────────────────────────────────────────

class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final double delay;

  const ShimmerWidget({super.key, required this.child, this.delay = 0});

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1500));
    Future.delayed(Duration(milliseconds: (widget.delay * 1000).toInt()), () {
      if (mounted) _controller.repeat();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.appColors;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1.0 + 2.0 * _controller.value, 0),
              end: Alignment(-0.5 + 2.0 * _controller.value, 0),
              colors: [
                c.divider.withValues(alpha: 0.1),
                c.surfaceAlt.withValues(alpha: 0.6),
                c.divider.withValues(alpha: 0.1),
              ],
            ).createShader(bounds);
          },
          child: widget.child,
        );
      },
      child: widget.child,
    );
  }
}
