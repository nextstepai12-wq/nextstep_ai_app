// lib/features/admin/presentation/screens/admin_universities_screen.dart
import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';
import 'package:nextstep_ai_app/core/storage/hive_storage.dart';
import 'package:nextstep_ai_app/features/admin/presentation/screens/admin_add_university_screen.dart';
import 'package:nextstep_ai_app/shared/services/supabase/supabase_service.dart';

class AdminUniversitiesScreen extends StatefulWidget {
  const AdminUniversitiesScreen({super.key});

  @override
  State<AdminUniversitiesScreen> createState() =>
      _AdminUniversitiesScreenState();
}

class _AdminUniversitiesScreenState extends State<AdminUniversitiesScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isLoading = true;
  String _searchQuery = '';
  String _selectedFilter = 'الكل';
  String? _errorMessage;

  List<Map<String, dynamic>> _universities = [];

  final List<String> _filterOptions = ['الكل', 'نشط', 'قيد الانتظار', 'محظور'];

  // ============================================================
  //  دوال مساعدة للتعامل مع البيانات
  // ============================================================

  String _getStatusDisplay(String? status) {
    switch (status) {
      case 'active':
        return 'نشط';
      case 'pending':
        return 'قيد الانتظار';
      case 'inactive':
        return 'محظور';
      default:
        return status ?? 'نشط';
    }
  }

  Color _getStatusColor(String? status) {
    switch (status) {
      case 'active':
        return const Color(0xFF22C55E);
      case 'pending':
        return const Color(0xFFF97316);
      case 'inactive':
        return const Color(0xFFDC2626);
      default:
        return const Color(0xFF22C55E);
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

  String _extractEmail(String? contactInfo) {
    if (contactInfo == null || contactInfo.isEmpty) return '-';
    try {
      final emailRegex = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}');
      final match = emailRegex.firstMatch(contactInfo);
      return match?.group(0) ?? contactInfo;
    } catch (_) {
      return contactInfo;
    }
  }

  String _extractPhone(String? contactInfo) {
    if (contactInfo == null || contactInfo.isEmpty) return '-';
    try {
      final phoneRegex = RegExp(r'(\+?[0-9]{1,3}[- ]?)?\(?[0-9]{1,4}\)?[- ]?[0-9]{1,4}[- ]?[0-9]{1,4}');
      final match = phoneRegex.firstMatch(contactInfo);
      return match?.group(0) ?? contactInfo;
    } catch (_) {
      return contactInfo;
    }
  }

  List<Map<String, dynamic>> get _filteredUniversities {
    var filtered = _universities;

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((uni) {
        final name = (uni['name'] ?? '').toString().toLowerCase();
        final location = (uni['location'] ?? '').toString().toLowerCase();
        final description = (uni['description'] ?? '').toString().toLowerCase();
        return name.contains(query) ||
            location.contains(query) ||
            description.contains(query);
      }).toList();
    }

    if (_selectedFilter != 'الكل') {
      filtered = filtered.where((uni) {
        final status = (uni['status'] ?? 'active').toString();
        final statusDisplay = _getStatusDisplay(status);
        return statusDisplay == _selectedFilter || status == _selectedFilter;
      }).toList();
    }

    return filtered;
  }

  // ============================================================
  //  تحميل الجامعات من Supabase
  // ============================================================
  Future<void> _loadUniversities() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('🔄 جاري جلب الجامعات من Supabase...');

      final supabase = SupabaseService();

      // ✅ جلب الجامعات من Supabase
      final response = await supabase.client
          .from('universities')
          .select('*')
          .order('name');

      if (response != null && response.isNotEmpty) {
        final universities = List<Map<String, dynamic>>.from(response);

        debugPrint('📊 عدد الجامعات من Supabase: ${universities.length}');

        // ✅ حفظ في Hive
        try {
          await HiveStorage.saveData('universities_cache', 'universities', universities);
          debugPrint('✅ تم حفظ ${universities.length} جامعة في Hive');
        } catch (e) {
          debugPrint('⚠️ فشل حفظ في Hive: $e');
        }

        if (mounted) {
          setState(() {
            _universities = universities;
            _isLoading = false;
            _errorMessage = null;
          });
          debugPrint('✅ تم تحديث الواجهة بـ ${_universities.length} جامعة');
        }
      } else {
        // ✅ محاولة قراءة من Hive
        try {
          final cached = await HiveStorage.getData('universities_cache', 'universities');
          if (cached != null && (cached as List).isNotEmpty) {
            debugPrint('✅ تم تحميل ${cached.length} جامعة من Hive');
            if (mounted) {
              setState(() {
                _universities = List<Map<String, dynamic>>.from(cached);
                _isLoading = false;
                _errorMessage = 'غير متصل بالإنترنت - عرض البيانات المخزنة محلياً';
              });
            }
            return;
          }
        } catch (_) {}

        if (mounted) {
          setState(() {
            _universities = [];
            _isLoading = false;
            _errorMessage = 'لا توجد جامعات في النظام';
          });
        }
      }
    } catch (e) {
      debugPrint('❌ خطأ في جلب الجامعات: $e');

      // ✅ محاولة قراءة من Hive
      try {
        final cached = await HiveStorage.getData('universities_cache', 'universities');
        if (cached != null && (cached as List).isNotEmpty) {
          debugPrint('✅ تم تحميل ${cached.length} جامعة من Hive');
          if (mounted) {
            setState(() {
              _universities = List<Map<String, dynamic>>.from(cached);
              _isLoading = false;
              _errorMessage = 'غير متصل بالإنترنت - عرض البيانات المخزنة محلياً';
            });
          }
          return;
        }
      } catch (_) {}

      if (mounted) {
        setState(() {
          _universities = [];
          _isLoading = false;
          _errorMessage = 'فشل تحميل الجامعات: ${e.toString()}';
        });
      }
    }
  }

  // ============================================================
  //  تحديث البيانات
  // ============================================================
  Future<void> _refreshUniversities() async {
    await _loadUniversities();
  }

  // ============================================================
  //  التنقل لصفحة إضافة جامعة
  // ============================================================
  Future<void> _goToAddUniversity() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const AdminAddUniversityScreen(),
      ),
    );

    if (result == true && mounted) {
      _showSnackBar('✅ تم إضافة الجامعة بنجاح');
      _loadUniversities();
    }
  }

  // ============================================================
  //  التنقل لتعديل جامعة
  // ============================================================
  Future<void> _goToEditUniversity(Map<String, dynamic> university) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminAddUniversityScreen(
          isEditing: true,
          universityData: university,
        ),
      ),
    );

    if (result == true && mounted) {
      _showSnackBar('✅ تم تحديث بيانات الجامعة');
      _loadUniversities();
    }
  }

  // ============================================================
  //  حذف جامعة
  // ============================================================
  Future<void> _deleteUniversity(Map<String, dynamic> university) async {
    try {
      final supabase = SupabaseService();

      await supabase.client
          .from('universities')
          .delete()
          .eq('id', university['id']);

      final cached = await HiveStorage.getData('universities_cache', 'universities');
      if (cached != null) {
        final List<Map<String, dynamic>> updatedUniversities =
            List<Map<String, dynamic>>.from(cached);
        updatedUniversities.removeWhere((u) => u['id'].toString() == university['id'].toString());
        await HiveStorage.saveData('universities_cache', 'universities', updatedUniversities);
      }

      setState(() {
        _universities.removeWhere((u) => u['id'].toString() == university['id'].toString());
      });

      _showSnackBar('✅ تم حذف الجامعة بنجاح', Colors.green);
    } catch (e) {
      _showSnackBar('❌ خطأ: ${e.toString()}', Colors.red);
    }
  }

  // ============================================================
  //  دورة الحياة
  // ============================================================
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

    _loadUniversities();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: Color(0xFF22C55E)),
              )
            : FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: RefreshIndicator(
                    onRefresh: _refreshUniversities,
                    child: CustomScrollView(
                      physics: const AlwaysScrollableScrollPhysics(
                        parent: BouncingScrollPhysics(),
                      ),
                      slivers: [
                        _buildSliverHeader(),
                        if (_errorMessage != null)
                          SliverToBoxAdapter(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: _errorMessage!.contains('غير متصل')
                                      ? Colors.orange.withValues(alpha: 0.1)
                                      : Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: _errorMessage!.contains('غير متصل')
                                        ? Colors.orange.shade300
                                        : Colors.red.shade300,
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _errorMessage!.contains('غير متصل')
                                          ? Icons.wifi_off_rounded
                                          : Icons.error_outline_rounded,
                                      color: _errorMessage!.contains('غير متصل')
                                          ? Colors.orange.shade700
                                          : Colors.red.shade700,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _errorMessage!,
                                        style: TextStyle(
                                          color: _errorMessage!.contains('غير متصل')
                                              ? Colors.orange.shade700
                                              : Colors.red.shade700,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        SliverToBoxAdapter(child: _buildStatsRow()),
                        SliverToBoxAdapter(child: _buildSearchAndFilter()),
                        _filteredUniversities.isEmpty
                            ? SliverFillRemaining(
                                hasScrollBody: false,
                                child: _buildEmptyState(),
                              )
                            : SliverPadding(
                                padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
                                sliver: SliverList(
                                  delegate: SliverChildBuilderDelegate(
                                    (context, index) =>
                                        _buildUniversityCard(_filteredUniversities[index]),
                                    childCount: _filteredUniversities.length,
                                  ),
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

  // ============================================================
  //  رأس الصفحة
  // ============================================================
  Widget _buildSliverHeader() {
    return SliverAppBar(
      pinned: true,
      elevation: 0,
      backgroundColor: const Color(0xFF22C55E),
      expandedHeight: 128,
      leading: IconButton(
        icon: const Icon(Icons.arrow_forward_rounded, color: Colors.white),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.add_business_rounded, color: Colors.white),
          onPressed: _goToAddUniversity,
          tooltip: 'إضافة جامعة',
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, color: Colors.white),
          onPressed: _refreshUniversities,
          tooltip: 'تحديث',
        ),
        const SizedBox(width: 4),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(right: 56, bottom: 16),
        centerTitle: false,
        title: const Text(
          'إدارة الجامعات',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        background: const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF22C55E), Color(0xFF15803D)],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  شريط الإحصائيات
  // ============================================================
  Widget _buildStatsRow() {
    final total = _universities.length;
    final active = _universities.where((u) {
      final status = (u['status'] ?? 'active').toString();
      return status == 'active' || status == 'نشط';
    }).length;
    final pending = _universities.where((u) {
      final status = (u['status'] ?? '').toString();
      return status == 'pending' || status == 'قيد الانتظار';
    }).length;

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
              value: total.toString(),
              icon: Icons.business_rounded,
              color: const Color(0xFF3B82F6),
            ),
          ),
          Container(width: 1, height: 32, color: Colors.grey.shade200),
          Expanded(
            child: _buildStatItem(
              label: 'نشط',
              value: active.toString(),
              icon: Icons.check_circle_rounded,
              color: const Color(0xFF22C55E),
            ),
          ),
          Container(width: 1, height: 32, color: Colors.grey.shade200),
          Expanded(
            child: _buildStatItem(
              label: 'قيد الانتظار',
              value: pending.toString(),
              icon: Icons.hourglass_top_rounded,
              color: const Color(0xFFF97316),
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
  }) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryContainer,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(label, style: TextStyle(fontSize: 10, color: Colors.grey.shade500)),
      ],
    );
  }

  // ============================================================
  //  البحث والفلاتر
  // ============================================================
  Widget _buildSearchAndFilter() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Column(
        children: [
          TextField(
            onChanged: (value) => setState(() => _searchQuery = value),
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            decoration: InputDecoration(
              hintText: 'بحث عن جامعة...',
              hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 14),
              prefixIcon: const Icon(Icons.search_rounded, color: Colors.grey),
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
                borderSide: const BorderSide(color: Color(0xFF22C55E), width: 1.8),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 36,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: _filterOptions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) {
                final filter = _filterOptions[index];
                final isSelected = _selectedFilter == filter;
                return ChoiceChip(
                  label: Text(filter),
                  selected: isSelected,
                  onSelected: (_) => setState(() => _selectedFilter = filter),
                  backgroundColor: Colors.white,
                  selectedColor: const Color(0xFF22C55E).withValues(alpha: 0.1),
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    color: isSelected ? const Color(0xFF22C55E) : Colors.grey.shade700,
                  ),
                  side: BorderSide(
                    color: isSelected ? const Color(0xFF22C55E) : Colors.grey.shade300,
                    width: 1.4,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  بطاقة جامعة
  // ============================================================
  Widget _buildUniversityCard(Map<String, dynamic> university) {
    final status = (university['status'] ?? 'active').toString();
    final statusDisplay = _getStatusDisplay(status);
    final statusColor = _getStatusColor(status);

    final studentCount = university['students_count'] ?? 0;
    final programCount = university['programs_count'] ?? 0;
    final location = (university['location'] ?? '').toString();
    final description = (university['description'] ?? '').toString();

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showUniversityDetails(university),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Center(
                        child: Icon(Icons.business_rounded, size: 22, color: Color(0xFF22C55E)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            university['name'] ?? '',
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primaryContainer,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 3),
                          Row(
                            children: [
                              Icon(Icons.location_on_rounded, size: 13, color: Colors.grey.shade500),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  location.isNotEmpty ? location : 'لا يوجد موقع',
                                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            statusDisplay,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: statusColor,
                            ),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '$studentCount طالب',
                          style: TextStyle(fontSize: 10, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: Icon(Icons.more_vert_rounded, color: Colors.grey.shade400),
                      onPressed: () => _showUniversityOptions(university),
                      padding: EdgeInsets.zero,
                      constraints: const BoxConstraints(),
                      iconSize: 20,
                    ),
                  ],
                ),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildInfoChip(
                      icon: Icons.school_rounded,
                      label: '$programCount تخصص',
                      color: const Color(0xFF3B82F6),
                    ),
                    if (university['email'] != null && university['email'] != '')
                      _buildInfoChip(
                        icon: Icons.email_rounded,
                        label: university['email'],
                        color: const Color(0xFFF97316),
                      ),
                    if (university['phone'] != null && university['phone'] != '')
                      _buildInfoChip(
                        icon: Icons.phone_rounded,
                        label: university['phone'],
                        color: const Color(0xFF22C55E),
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

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 140),
            child: Text(
              label,
              style: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.business_outlined, size: 64, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _searchQuery.isEmpty ? 'لا توجد جامعات' : 'لا توجد نتائج مطابقة',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryContainer,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isEmpty
                  ? 'أضف جامعة جديدة باستخدام زر الإضافة'
                  : 'جرب تغيير كلمات البحث',
              style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _goToAddUniversity,
      backgroundColor: const Color(0xFF22C55E),
      icon: const Icon(Icons.add_rounded, color: Colors.white),
      label: const Text(
        'إضافة جامعة',
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }

  // ============================================================
  //  خيارات الجامعة (Bottom Sheet)
  // ============================================================
  void _showUniversityOptions(Map<String, dynamic> university) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildOptionTile(
                icon: Icons.remove_red_eye_rounded,
                title: 'عرض التفاصيل',
                color: const Color(0xFF22C55E),
                onTap: () {
                  Navigator.pop(context);
                  _showUniversityDetails(university);
                },
              ),
              _buildOptionTile(
                icon: Icons.edit_rounded,
                title: 'تعديل',
                color: const Color(0xFF3B82F6),
                onTap: () {
                  Navigator.pop(context);
                  _goToEditUniversity(university);
                },
              ),
              _buildOptionTile(
                icon: Icons.delete_rounded,
                title: 'حذف',
                color: const Color(0xFFDC2626),
                onTap: () {
                  Navigator.pop(context);
                  _showDeleteDialog(university);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  //  عرض تفاصيل الجامعة
  // ============================================================
  void _showUniversityDetails(Map<String, dynamic> university) {
    final status = (university['status'] ?? 'active').toString();
    final statusDisplay = _getStatusDisplay(status);
    final statusColor = _getStatusColor(status);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.85),
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
                      color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Icon(Icons.business_rounded, size: 28, color: Color(0xFF22C55E)),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          university['name'] ?? '',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primaryContainer,
                          ),
                        ),
                        Text(
                          university['location'] ?? 'لا يوجد موقع',
                          style: TextStyle(fontSize: 13, color: Colors.grey.shade500),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: statusColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      statusDisplay,
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: statusColor,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _buildDetailRow('الوصف', university['description'] ?? '-'),
              _buildDetailRow('الموقع', university['location'] ?? '-'),
              _buildDetailRow('البريد الإلكتروني', university['email'] ?? '-'),
              _buildDetailRow('رقم الهاتف', university['phone'] ?? '-'),
              _buildDetailRow('الموقع الإلكتروني', university['website_url'] ?? '-'),
              _buildDetailRow('عدد الطلاب', (university['students_count'] ?? 0).toString()),
              _buildDetailRow('عدد التخصصات', (university['programs_count'] ?? 0).toString()),
              _buildDetailRow('الحالة', statusDisplay),
              _buildDetailRow('تاريخ الإنشاء', _formatDate(university['created_at'])),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTheme.primaryContainer,
                        side: BorderSide(color: Colors.grey.shade300),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
                        _goToEditUniversity(university);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF22C55E),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
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
              value,
              style: TextStyle(fontSize: 14, color: AppTheme.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  نافذة تأكيد الحذف
  // ============================================================
  void _showDeleteDialog(Map<String, dynamic> university) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('حذف الجامعة'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('هل أنت متأكد من رغبتك في حذف:'),
            const SizedBox(height: 8),
            Text(
              '${university['name']}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'هذا الإجراء لا يمكن التراجع عنه',
              style: TextStyle(color: Colors.red.shade300, fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteUniversity(university);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDC2626),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('حذف'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
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
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
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
                color == Colors.red ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
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