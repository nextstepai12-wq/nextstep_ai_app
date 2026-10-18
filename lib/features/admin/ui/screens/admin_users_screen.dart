import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/helpers/hive_storage.dart';
import 'package:nextstep_ai_app/features/admin/ui/screens/admin_add_user_screen.dart';
import 'package:nextstep_ai_app/core/networking/supabase_service.dart';

class AdminUsersScreen extends StatefulWidget {
  const AdminUsersScreen({super.key});

  @override
  State<AdminUsersScreen> createState() => _AdminUsersScreenState();
}

enum _SortMode { newest, oldest, nameAsc }

class _AdminUsersScreenState extends State<AdminUsersScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  String _searchQuery = '';
  String? _errorMessage;

  // Filters
  String _roleFilter = 'all'; // all | student | university | admin
  String _statusFilter = 'all'; // all | verified | unverified
  _SortMode _sortMode = _SortMode.newest;
  bool _isTableView = false;

  // Search debounce
  Timer? _debounce;

  // Bulk selection
  final Set<String> _selectedIds = {};

  // Pagination
  int _rowsPerPage = 10;
  int _currentPage = 0;

  List<Map<String, dynamic>> _users = [];

  final TextEditingController _searchController = TextEditingController();

  final List<String> _roleOptions = const ['الكل', 'طلاب', 'جامعات', 'إدارة'];

  String _getRoleLabel(String role) {
    switch (role) {
      case 'student':
        return 'طالب';
      case 'university':
        return 'جامعة';
      case 'admin':
        return 'إدارة';
      default:
        return role;
    }
  }

  String _getRoleFilterValue(String filter) {
    switch (filter) {
      case 'طلاب':
        return 'student';
      case 'جامعات':
        return 'university';
      case 'إدارة':
        return 'admin';
      default:
        return '';
    }
  }

  Color _getRoleColor(String role) {
    switch (role) {
      case 'student':
        return const Color(0xFF3B82F6);
      case 'university':
        return const Color(0xFF22C55E);
      case 'admin':
        return const Color(0xFF8B5CF6);
      default:
        return Colors.grey;
    }
  }

  IconData _getRoleIcon(String role) {
    switch (role) {
      case 'student':
        return Icons.school_rounded;
      case 'university':
        return Icons.business_rounded;
      case 'admin':
        return Icons.admin_panel_settings_rounded;
      default:
        return Icons.person_rounded;
    }
  }

  String _formatDate(dynamic date) {
    if (date == null) return '-';
    try {
      if (date is String) {
        try {
          final parsed = DateTime.parse(date);
          return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
        } catch (_) {
          return date.split('T')[0];
        }
      }
      if (date is DateTime) {
        return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      }
      return date.toString().split(' ')[0];
    } catch (_) {
      return '-';
    }
  }

  DateTime? _parseDate(dynamic date) {
    if (date == null) return null;
    try {
      if (date is String) return DateTime.tryParse(date);
      if (date is DateTime) return date;
    } catch (_) {}
    return null;
  }

  // ─────────────────────────────────────────────────────────────
  // Filtering / Sorting / Pagination
  // ─────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get _filteredUsers {
    var filtered = _users;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((user) {
        final name = (user['name'] ?? '').toString().toLowerCase();
        final email = (user['email'] ?? '').toString().toLowerCase();
        return name.contains(query) || email.contains(query);
      }).toList();
    }

    if (_roleFilter != 'all') {
      filtered = filtered
          .where((u) => (u['role'] ?? '').toString() == _roleFilter)
          .toList();
    }

    if (_statusFilter != 'all') {
      filtered = filtered.where((u) {
        final verified = u['email_confirmed'] == true;
        return _statusFilter == 'verified' ? verified : !verified;
      }).toList();
    }

    switch (_sortMode) {
      case _SortMode.newest:
        filtered.sort((a, b) {
          final ad = _parseDate(a['created_at']) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bd = _parseDate(b['created_at']) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return bd.compareTo(ad);
        });
        break;
      case _SortMode.oldest:
        filtered.sort((a, b) {
          final ad = _parseDate(a['created_at']) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          final bd = _parseDate(b['created_at']) ??
              DateTime.fromMillisecondsSinceEpoch(0);
          return ad.compareTo(bd);
        });
        break;
      case _SortMode.nameAsc:
        filtered.sort((a, b) => (a['name'] ?? '')
            .toString()
            .toLowerCase()
            .compareTo((b['name'] ?? '').toString().toLowerCase()));
        break;
    }

    return filtered;
  }

  bool get _hasActiveFilters =>
      _searchQuery.isNotEmpty ||
      _roleFilter != 'all' ||
      _statusFilter != 'all';

  void _resetFilters() {
    _debounce?.cancel();
    _searchController.clear();
    setState(() {
      _searchQuery = '';
      _roleFilter = 'all';
      _statusFilter = 'all';
      _sortMode = _SortMode.newest;
      _currentPage = 0;
      _selectedIds.clear();
    });
  }

  // ─────────────────────────────────────────────────────────────
  // Data loading (Supabase + Hive cache fallback)
  // ─────────────────────────────────────────────────────────────

  Future<void> _loadUsers() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final users = await SupabaseService().getAuthUsers();

      if (users.isNotEmpty) {
        try {
          await HiveStorage.saveData('users_cache', 'users', users);
        } catch (_) {}

        if (mounted) {
          setState(() {
            _users = List<Map<String, dynamic>>.from(users);
            _isLoading = false;
            _errorMessage = null;
            _currentPage = 0;
          });
        }
      } else {
        try {
          final cached = await HiveStorage.getData('users_cache', 'users');
          if (cached != null && (cached as List).isNotEmpty) {
            if (mounted) {
              setState(() {
                _users = List<Map<String, dynamic>>.from(cached);
                _isLoading = false;
                _errorMessage = 'غير متصل بالإنترنت - عرض البيانات المخزنة محلياً';
              });
            }
            return;
          }
        } catch (_) {}

        if (mounted) {
          setState(() {
            _users = [];
            _isLoading = false;
            _errorMessage = 'لا يوجد مستخدمين مسجلين في النظام';
          });
        }
      }
    } catch (e) {
      try {
        final cached = await HiveStorage.getData('users_cache', 'users');
        if (cached != null && (cached as List).isNotEmpty) {
          if (mounted) {
            setState(() {
              _users = List<Map<String, dynamic>>.from(cached);
              _isLoading = false;
              _errorMessage = 'غير متصل بالإنترنت - عرض البيانات المخزنة محلياً';
            });
          }
          return;
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _users = [];
          _isLoading = false;
          _errorMessage = 'فشل تحميل المستخدمين: ${e.toString()}';
        });
      }
    }
  }

  Future<void> _refreshUsers() async {
    await _loadUsers();
  }

  // ─────────────────────────────────────────────────────────────
  // Navigation & actions
  // ─────────────────────────────────────────────────────────────

  Future<void> _goToAddUser() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminAddUserScreen(),
      ),
    );

    if (result == true && mounted) {
      _showSnackBar('✅ تم إضافة المستخدم بنجاح');
      _loadUsers();
    }
  }

  Future<void> _goToEditUser(Map<String, dynamic> user) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminAddUserScreen(
          isEditing: true,
          userData: user,
        ),
      ),
    );

    if (result == true && mounted) {
      _showSnackBar('✅ تم تحديث بيانات المستخدم', Colors.green);
      _loadUsers();
    }
  }

  Future<void> _deleteUser(Map<String, dynamic> user) async {
    try {
      await SupabaseService().deleteAuthUser(user['id']);

      final cached = await HiveStorage.getData('users_cache', 'users');
      if (cached != null) {
        final List<Map<String, dynamic>> updatedUsers =
            List<Map<String, dynamic>>.from(cached);
        updatedUsers.removeWhere(
            (u) => u['id'].toString() == user['id'].toString());
        await HiveStorage.saveData('users_cache', 'users', updatedUsers);
      }

      setState(() {
        _users.removeWhere(
            (u) => u['id'].toString() == user['id'].toString());
        _selectedIds.remove(user['id'].toString());
      });

      if (mounted) {
        _showSnackBar('✅ تم حذف المستخدم بنجاح', Colors.green);
      }
    } catch (e) {
      if (mounted) _showSnackBar('❌ خطأ: ${e.toString()}', Colors.red);
    }
  }

  void _confirmDeleteUser(Map<String, dynamic> user) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: const Color(0xFFDC2626).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete_forever_rounded,
                  size: 28, color: Color(0xFFDC2626)),
            ),
            const SizedBox(height: 14),
            const Text(
              'حذف المستخدم',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppTheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'هل أنت متأكد من رغبتك في حذف',
              style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
            ),
            const SizedBox(height: 4),
            Text(
              '${user['name'] ?? ''}',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                color: AppTheme.primaryContainer,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'هذا الإجراء لا يمكن التراجع عنه',
              style: TextStyle(
                  color: Colors.red.shade400,
                  fontSize: 12,
                  fontWeight: FontWeight.w600),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppTheme.primaryContainer,
                    side: BorderSide(color: Colors.grey.shade300),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('إلغاء'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                    _deleteUser(user);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDC2626),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14)),
                  ),
                  child: const Text('حذف'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showExportSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'تصدير بيانات المستخدمين',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 4),
              _buildOptionTile(
                icon: Icons.table_view_rounded,
                title: 'تصدير كملف Excel (CSV)',
                color: const Color(0xFF22C55E),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('⏳ جاري تجهيز ملف Excel...');
                },
              ),
              _buildOptionTile(
                icon: Icons.picture_as_pdf_rounded,
                title: 'تصدير كملف PDF',
                color: const Color(0xFF3B82F6),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('⏳ جاري تجهيز ملف PDF...');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Lifecycle
  // ─────────────────────────────────────────────────────────────

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

    _loadUsers();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: _isLoading
            ? _buildSkeletonLoading()
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: RefreshIndicator(
                    onRefresh: _refreshUsers,
                    child: Stack(
                      children: [
                        CustomScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          slivers: [
                            _buildSliverHeader(),
                            if (_errorMessage != null)
                              SliverToBoxAdapter(
                                  child: _buildErrorBanner(_errorMessage!)),
                            SliverToBoxAdapter(child: _buildStatsRow()),
                            SliverToBoxAdapter(child: _buildSearchAndFilter()),
                            _filteredUsers.isEmpty
                                ? SliverFillRemaining(
                                    hasScrollBody: false,
                                    child: _buildEmptyState(),
                                  )
                                : SliverPadding(
                                    padding:
                                        const EdgeInsets.fromLTRB(16, 4, 16, 140),
                                    sliver: _isTableView
                                        ? _buildTableBody()
                                        : _buildCardsBody(),
                                  ),
                          ],
                        ),
                        if (_selectedIds.isNotEmpty) _buildBulkActionsBar(),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────────────────────

  Widget _buildSliverHeader() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: AppTheme.primary,
      expandedHeight: 128,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.ios_share_rounded, color: Colors.white),
          onPressed: _showExportSheet,
          tooltip: 'تصدير',
        ),
        IconButton(
          icon: const Icon(Icons.person_add_alt_1_rounded, color: Colors.white),
          onPressed: _goToAddUser,
          tooltip: 'إضافة مستخدم',
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: _refreshUsers,
          tooltip: 'تحديث',
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: const FlexibleSpaceBar(
        titlePadding: EdgeInsets.only(right: 56, bottom: 16),
        centerTitle: false,
        title: Text(
          'إدارة المستخدمين',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        background: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppTheme.primary, AppTheme.primaryContainer],
            ),
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Stats strip
  // ─────────────────────────────────────────────────────────────

  Widget _buildStatsRow() {
    final total = _users.length;
    final verified = _users.where((u) => u['email_confirmed'] == true).length;
    final unverified = total - verified;
    final admins = _users.where((u) => u['role'] == 'admin').length;

    return Container(
      height: 90,
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        children: [
          Expanded(
            child: _buildStatCard(
              label: 'الإجمالي',
              value: total.toString(),
              icon: Icons.groups_rounded,
              color: const Color(0xFF3B82F6),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              label: 'موثق',
              value: verified.toString(),
              icon: Icons.verified_rounded,
              color: const Color(0xFF22C55E),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              label: 'غير موثق',
              value: unverified.toString(),
              icon: Icons.warning_rounded,
              color: const Color(0xFFDC2626),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildStatCard(
              label: 'الإدارة',
              value: admins.toString(),
              icon: Icons.shield_rounded,
              color: const Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            children: [
              Container(
                width: 22,
                height: 22,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 13, color: color),
              ),
              const Spacer(),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w800,
                  color: color.withValues(alpha: 0.85),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Search + Filters toolbar
  // ─────────────────────────────────────────────────────────────

  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Column(
        children: [
          // Search field (with clear button)
          TextField(
            controller: _searchController,
            onChanged: (value) {
              _debounce?.cancel();
              _debounce = Timer(const Duration(milliseconds: 300), () {
                if (mounted) {
                  setState(() {
                    _searchQuery = value;
                    _currentPage = 0;
                  });
                }
              });
            },
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'بحث بالاسم أو البريد الإلكتروني...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 18),
                      onPressed: () {
                        _debounce?.cancel();
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _currentPage = 0;
                        });
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide: BorderSide(color: Colors.grey.shade200, width: 1.2),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
                borderSide:
                    const BorderSide(color: AppTheme.secondary, width: 1.8),
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          // Role filter chips + toggle
          SizedBox(
            height: 36,
            child: Row(
              children: [
                Expanded(
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    physics: const BouncingScrollPhysics(),
                    itemCount: _roleOptions.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, index) {
                      final filter = _roleOptions[index];
                      final filterValue = _getRoleFilterValue(filter);
                      final isSelected = _roleFilter ==
                          (filterValue.isEmpty ? 'all' : filterValue);
                      return ChoiceChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (_) => setState(() {
                          _roleFilter =
                              filterValue.isEmpty ? 'all' : filterValue;
                          _currentPage = 0;
                        }),
                        backgroundColor: Colors.white,
                        selectedColor: AppTheme.primary.withValues(alpha: 0.1),
                        labelStyle: TextStyle(
                          fontSize: 13,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? AppTheme.primary
                              : Colors.grey.shade700,
                        ),
                        side: BorderSide(
                          color: isSelected
                              ? AppTheme.primary
                              : Colors.grey.shade300,
                          width: 1.4,
                        ),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          // Status / sort / view toggle row
          Row(
            children: [
              // Status dropdown
              Expanded(
                child: _buildDropdown(
                  value: _statusFilter,
                  items: const [
                    ('all', 'الحالة: الكل'),
                    ('verified', 'الحالة: موثق'),
                    ('unverified', 'الحالة: غير موثق'),
                  ],
                  onChanged: (v) => setState(() {
                    _statusFilter = v;
                    _currentPage = 0;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              // Sort dropdown
              Expanded(
                child: _buildDropdown<_SortMode>(
                  value: _sortMode,
                  items: const [
                    (_SortMode.newest, 'الأحدث'),
                    (_SortMode.oldest, 'الأقدم'),
                    (_SortMode.nameAsc, 'الاسم أ-ي'),
                  ],
                  onChanged: (v) => setState(() {
                    _sortMode = v;
                    _currentPage = 0;
                  }),
                ),
              ),
              const SizedBox(width: 8),
              // View toggle
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade200, width: 1.2),
                ),
                padding: const EdgeInsets.all(3),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildViewToggleBtn(
                      icon: Icons.grid_view_rounded,
                      selected: !_isTableView,
                      onTap: () => setState(() => _isTableView = false),
                    ),
                    _buildViewToggleBtn(
                      icon: Icons.table_rows_rounded,
                      selected: _isTableView,
                      onTap: () => setState(() => _isTableView = true),
                    ),
                  ],
                ),
              ),
            ],
          ),
          // Reset filters button (only when active)
          if (_hasActiveFilters)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: TextButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.restart_alt_rounded, size: 16),
                label: const Text('إعادة تعيين الفلاتر',
                    style: TextStyle(fontSize: 12)),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDropdown<T>({
    required T value,
    required List<(T, String)> items,
    required ValueChanged<T> onChanged,
  }) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          isExpanded: true,
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              size: 18, color: Colors.grey.shade600),
          dropdownColor: Colors.white,
          borderRadius: BorderRadius.circular(12),
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
          items: items
              .map((item) => DropdownMenuItem<T>(
                    value: item.$1,
                    child: Text(item.$2, overflow: TextOverflow.ellipsis),
                  ))
              .toList(),
          onChanged: (v) {
            if (v != null) onChanged(v);
          },
        ),
      ),
    );
  }

  Widget _buildViewToggleBtn({
    required IconData icon,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        width: 32,
        height: 30,
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          size: 18,
          color: selected ? AppTheme.primary : Colors.grey.shade500,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // List bodies (table & cards) + pagination
  // ─────────────────────────────────────────────────────────────

  List<Map<String, dynamic>> get _pagedUsers {
    final filtered = _filteredUsers;
    final totalPages =
        (filtered.length / _rowsPerPage).ceil().clamp(1, double.maxFinite.toInt());
    if (_currentPage >= totalPages) _currentPage = totalPages - 1;
    final start = _currentPage * _rowsPerPage;
    return filtered.skip(start).take(_rowsPerPage).toList();
  }

  int get _totalPages => (_filteredUsers.length / _rowsPerPage)
      .ceil()
      .clamp(1, double.maxFinite.toInt());

  Widget _buildCardsBody() {
    final paged = _pagedUsers;
    final start = _currentPage * _rowsPerPage + 1;
    final end = start + paged.length - 1;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: _buildSelectAllHeader(paged)),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            (context, index) => _buildUserCard(paged[index]),
            childCount: paged.length,
          ),
        ),
        SliverToBoxAdapter(
          child: _buildPaginationFooter(start, end, _filteredUsers.length),
        ),
      ],
    );
  }

  Widget _buildTableBody() {
    final paged = _pagedUsers;
    final start = _currentPage * _rowsPerPage + 1;
    final end = start + paged.length - 1;

    return SliverMainAxisGroup(
      slivers: [
        SliverToBoxAdapter(child: _buildSelectAllHeader(paged)),
        SliverPadding(
          padding: const EdgeInsets.only(bottom: 12),
          sliver: SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey.shade200, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: List.generate(paged.length, (i) {
                  return _buildUserRow(paged[i], i == paged.length - 1);
                }),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: _buildPaginationFooter(start, end, _filteredUsers.length),
        ),
      ],
    );
  }

  Widget _buildSelectAllHeader(List<Map<String, dynamic>> paged) {
    final allSelected = paged.isNotEmpty &&
        paged.every((u) => _selectedIds.contains(u['id'].toString()));
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 8, 4, 8),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            height: 22,
            child: Checkbox(
              value: allSelected,
              onChanged: (value) {
                setState(() {
                  if (value == true) {
                    _selectedIds
                        .addAll(paged.map((u) => u['id'].toString()));
                  } else {
                    _selectedIds
                        .removeAll(paged.map((u) => u['id'].toString()));
                  }
                });
              },
              activeColor: AppTheme.primary,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5)),
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            'تحديد الكل (الصفحة)',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade600,
            ),
          ),
          const Spacer(),
          Text(
            'تم التحديث الآن',
            style: TextStyle(fontSize: 11, color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }

  // ── Table row (desktop-density look within card container) ──

  Widget _buildUserRow(Map<String, dynamic> user, bool isLast) {
    final role = (user['role'] ?? 'student').toString();
    final roleColor = _getRoleColor(role);
    final roleLabel = _getRoleLabel(role);
    final id = user['id'].toString();
    final isSelected = _selectedIds.contains(id);
    final verified = user['email_confirmed'] == true;

    return InkWell(
      onTap: () => _showUserDetails(user),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.secondary.withValues(alpha: 0.04) : null,
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(color: Colors.grey.shade100, width: 1)),
        ),
        child: Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: Checkbox(
                value: isSelected,
                onChanged: (v) => setState(() {
                  v == true ? _selectedIds.add(id) : _selectedIds.remove(id);
                }),
                activeColor: AppTheme.primary,
                shape:
                    RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
            ),
            const SizedBox(width: 10),
            _buildAvatar(user, size: 36),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    user['name'] ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primaryContainer,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    user['email'] ?? '',
                    style:
                        TextStyle(fontSize: 11, color: Colors.grey.shade500),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _buildRoleBadge(role, roleLabel, roleColor),
            const SizedBox(width: 6),
            _buildStatusBadge(verified),
            const SizedBox(width: 8),
            _buildRowActions(user),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleBadge(String role, String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_getRoleIcon(role), size: 10, color: color),
          const SizedBox(width: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(bool verified) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: (verified ? Colors.green : Colors.orange).withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(verified ? Icons.check_circle_rounded : Icons.error_rounded,
              size: 10, color: verified ? Colors.green : Colors.orange),
          const SizedBox(width: 2),
          Text(
            verified ? 'موثق' : 'غير موثق',
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w600,
              color: verified ? Colors.green : Colors.orange,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowActions(Map<String, dynamic> user) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildActionIcon(
          icon: Icons.remove_red_eye_rounded,
          color: Colors.grey.shade600,
          tooltip: 'عرض',
          onTap: () => _showUserDetails(user),
        ),
        _buildActionIcon(
          icon: Icons.edit_rounded,
          color: Colors.grey.shade600,
          tooltip: 'تعديل',
          onTap: () => _goToEditUser(user),
        ),
        _buildActionIcon(
          icon: Icons.delete_rounded,
          color: const Color(0xFFDC2626),
          tooltip: 'حذف',
          onTap: () => _confirmDeleteUser(user),
        ),
      ],
    );
  }

  Widget _buildActionIcon({
    required IconData icon,
    required Color color,
    required String tooltip,
    required VoidCallback onTap,
  }) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(5),
          child: Icon(icon, size: 17, color: color),
        ),
      ),
    );
  }

  // ── Card item ──

  Widget _buildUserCard(Map<String, dynamic> user) {
    final role = (user['role'] ?? 'student').toString();
    final roleColor = _getRoleColor(role);
    final roleLabel = _getRoleLabel(role);
    final id = user['id'].toString();
    final isSelected = _selectedIds.contains(id);
    final verified = user['email_confirmed'] == true;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isSelected ? AppTheme.primary.withValues(alpha: 0.4) : Colors.grey.shade200,
          width: 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showUserDetails(user),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 22,
                      height: 22,
                      child: Checkbox(
                        value: isSelected,
                        onChanged: (v) => setState(() {
                          v == true
                              ? _selectedIds.add(id)
                              : _selectedIds.remove(id);
                        }),
                        activeColor: AppTheme.primary,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(5)),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                      ),
                    ),
                    const SizedBox(width: 10),
                    _buildAvatar(user, size: 44),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryContainer,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user['email'] ?? '',
                            style: TextStyle(
                                fontSize: 11, color: Colors.grey.shade500),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    _buildRowActions(user),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _buildRoleBadge(role, roleLabel, roleColor),
                    const SizedBox(width: 6),
                    _buildStatusBadge(verified),
                    const Spacer(),
                    Icon(Icons.calendar_today_rounded,
                        size: 11, color: Colors.grey.shade400),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(user['created_at']),
                      style: TextStyle(
                          fontSize: 10, color: Colors.grey.shade500),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar(Map<String, dynamic> user, {double size = 44}) {
    final role = (user['role'] ?? 'student').toString();
    final roleColor = _getRoleColor(role);
    final name = (user['name'] ?? '').toString().trim();
    final initial = name.isNotEmpty ? name[0] : '?';
    final verified = user['email_confirmed'] == true;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: roleColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
          ),
          child: Center(
            child: Text(
              initial,
              style: TextStyle(
                fontSize: size * 0.4,
                fontWeight: FontWeight.w700,
                color: roleColor,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -2,
          left: -2,
          child: Container(
            width: size * 0.36,
            height: size * 0.36,
            decoration: BoxDecoration(
              color: verified ? const Color(0xFF22C55E) : Colors.orange,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Icon(
              verified ? Icons.check_rounded : Icons.close_rounded,
              size: size * 0.22,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  // ── Pagination ──

  Widget _buildPaginationFooter(int start, int end, int total) {
    final isFirst = _currentPage == 0;
    final isLast = _currentPage >= _totalPages - 1;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text.rich(
                  TextSpan(
                    text: 'عرض ',
                    style: TextStyle(
                        fontSize: 12, color: Colors.grey.shade600),
                    children: [
                      TextSpan(
                        text: '$start–$end ',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryContainer,
                        ),
                      ),
                      TextSpan(
                        text: 'من ',
                        style: TextStyle(
                            fontSize: 12, color: Colors.grey.shade600),
                      ),
                      TextSpan(
                        text: '$total',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.primaryContainer,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'عدد الصفوف',
                  style: TextStyle(
                      fontSize: 10, color: Colors.grey.shade500),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // Rows per page
          Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<int>(
                value: _rowsPerPage,
                icon: Icon(Icons.keyboard_arrow_down_rounded,
                    size: 16, color: Colors.grey.shade600),
                borderRadius: BorderRadius.circular(10),
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
                items: const [10, 25, 50]
                    .map((n) => DropdownMenuItem<int>(
                          value: n,
                          child: Text('$n'),
                        ))
                    .toList(),
                onChanged: (v) {
                  if (v != null) {
                    setState(() {
                      _rowsPerPage = v;
                      _currentPage = 0;
                    });
                  }
                },
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Prev / next
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              children: [
                _buildPageArrow(
                  icon: Icons.chevron_right_rounded,
                  enabled: !isFirst,
                  onTap: () => setState(() => _currentPage--),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: Text(
                    '${_currentPage + 1} / $_totalPages',
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.primaryContainer,
                    ),
                  ),
                ),
                _buildPageArrow(
                  icon: Icons.chevron_left_rounded,
                  enabled: !isLast,
                  onTap: () => setState(() => _currentPage++),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageArrow({
    required IconData icon,
    required bool enabled,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: enabled ? onTap : null,
      borderRadius: BorderRadius.circular(10),
      child: Padding(
        padding: const EdgeInsets.all(6),
        child: Icon(
          icon,
          size: 18,
          color: enabled ? AppTheme.primaryContainer : Colors.grey.shade300,
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Bulk actions floating bar
  // ─────────────────────────────────────────────────────────────

  Widget _buildBulkActionsBar() {
    return Positioned(
      left: 16,
      right: 16,
      bottom: 24,
      child: TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: 1),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        builder: (context, t, child) =>
            Transform.translate(
          offset: Offset(0, 40 * (1 - t)),
          child: Opacity(opacity: t.clamp(0.0, 1.0), child: child),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E293B),
            borderRadius: BorderRadius.circular(18),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.25),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: const BoxDecoration(
                  color: Color(0xFF3EDFAA),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '${_selectedIds.length} مستخدم محدد',
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const Spacer(),
              TextButton.icon(
                onPressed: () {
                  _showSnackBar('⏳ جاري تصدير المستخدمين المحددين...');
                },
                icon: const Icon(Icons.download_rounded,
                    size: 16, color: Colors.white),
                label: const Text('تصدير',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                ),
              ),
              TextButton.icon(
                onPressed: () {
                  _showSnackBar('⏳ جاري حذف ${_selectedIds.length} مستخدم...');
                  // TODO: implement bulk delete
                },
                icon: const Icon(Icons.delete_rounded,
                    size: 16, color: Color(0xFFFCA5A5)),
                label: const Text('حذف',
                    style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFCA5A5))),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  minimumSize: Size.zero,
                ),
              ),
              IconButton(
                onPressed: () => setState(() => _selectedIds.clear()),
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: Colors.white70),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Skeleton / error / empty
  // ─────────────────────────────────────────────────────────────

  Widget _buildSkeletonLoading() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 140, 16, 16),
      child: Column(
        children: [
          // Stats skeleton
          Row(
            children: List.generate(
              4,
              (i) => Expanded(
                child: Container(
                  height: 90,
                  margin: EdgeInsets.only(right: i < 3 ? 8 : 0),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Container(
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          const SizedBox(height: 12),
          ...List.generate(
            5,
            (_) => Container(
              height: 90,
              margin: const EdgeInsets.only(bottom: 12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorBanner(String message) {
    final isOffline = message.contains('غير متصل');
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isOffline
              ? Colors.orange.withValues(alpha: 0.1)
              : Colors.red.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isOffline ? Colors.orange.shade300 : Colors.red.shade300,
          ),
        ),
        child: Row(
          children: [
            Icon(
              isOffline
                  ? Icons.wifi_off_rounded
                  : Icons.error_outline_rounded,
              color: isOffline ? Colors.orange.shade700 : Colors.red.shade700,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: isOffline ? Colors.orange.shade700 : Colors.red.shade700,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    final hasFilters = _hasActiveFilters;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.person_search_rounded, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              hasFilters ? 'لا توجد نتائج مطابقة' : 'لا يوجد مستخدمين',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              hasFilters
                  ? 'جرب تعديل الفلاتر أو البحث بكلمات أخرى'
                  : 'أضف مستخدم جديد باستخدام زر الإضافة',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
            if (hasFilters) ...[
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _resetFilters,
                icon: const Icon(Icons.restart_alt_rounded, size: 18),
                label: const Text('إعادة تعيين الفلاتر'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14)),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────
  // Details bottom sheet
  // ─────────────────────────────────────────────────────────────

  void _showUserDetails(Map<String, dynamic> user) {
    final role = (user['role'] ?? 'student').toString();
    final roleColor = _getRoleColor(role);
    final verified = user['email_confirmed'] == true;
    final name = (user['name'] ?? '').toString().trim();
    final initial = name.isNotEmpty ? name[0] : '?';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
        ),
        padding: EdgeInsets.only(
          left: 24,
          right: 24,
          top: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
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
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: roleColor.withValues(alpha: 0.08),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: roleColor,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          user['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryContainer,
                          ),
                        ),
                        Text(
                          user['email'] ?? '',
                          style: TextStyle(
                              fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: (verified ? Colors.green : Colors.orange)
                          .withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      verified ? 'موثق' : 'غير موثق',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color:
                            verified ? Colors.green : Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('الدور', _getRoleLabel(role)),
              _buildDetailRow('البريد الإلكتروني', user['email'] ?? '-'),
              _buildDetailRow('تاريخ الإنشاء', _formatDate(user['created_at'])),
              _buildDetailRow('آخر دخول', _formatDate(user['last_login'])),
              _buildDetailRow('توثيق البريد', verified ? 'نعم' : 'لا'),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryContainer,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('إغلاق'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _goToEditUser(user);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primary,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: const Text('تعديل'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Text(
            '$label: ',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryContainer,
            ),
          ),
          Expanded(
            child: Text(
              value.isNotEmpty ? value : '-',
              style: const TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: color),
      title:
          Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
      onTap: onTap,
    );
  }

  void _showSnackBar(String message, [Color? color]) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          backgroundColor: color ?? const Color(0xFF22C55E),
          content: Row(
            children: [
              Icon(
                color == Colors.red
                    ? Icons.error_outline_rounded
                    : Icons.check_circle_outline_rounded,
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
          duration: const Duration(seconds: 2),
        ),
      );
  }
}
