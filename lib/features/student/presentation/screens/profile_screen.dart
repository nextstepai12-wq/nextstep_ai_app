import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/themes/app_theme.dart';
import 'package:nextstep_ai_app/shared/services/supabase/supabase_service.dart';
import 'package:nextstep_ai_app/shared/services/auth/token_manager.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseService _supabase = SupabaseService();

  // حالة الصفحة
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _errorMessage;

  // بيانات المستخدم
  String _userName = '';
  String _userEmail = '';
  String _userRole = '';
  String _userId = '';
  String _phone = '';
  String _city = '';
  String _studentType = '';
  String _highSchoolScore = '';
  String _gpa = '';
  String _university = '';
  String _major = '';
  String _academicYear = '';

  // Controllers
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _cityController = TextEditingController();

  // Animation
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
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
  if (!mounted) return;

  setState(() {
    _isLoading = true;
    _errorMessage = null;
  });

  try {
    final cachedData = await TokenManager.getUserData();
    if (cachedData['name'] != null && cachedData['name']!.isNotEmpty) {
      _userName = cachedData['name']!;
      _nameController.text = _userName;
      _userEmail = cachedData['email'] ?? '';
      _userRole = cachedData['role'] ?? 'student';
      _userId = cachedData['userId'] ?? '';
    }

    final user = _supabase.currentUser;
    if (user != null) {
      final userData = await _supabase.getUser(user.id);
      if (userData != null) {
        setState(() {
          _userName = userData.displayName;
          _userEmail = user.email ?? '';
          _userRole = userData.role ?? 'student';
          _nameController.text = _userName;
        });
      }

      try {
        // ✅ استخدام الدالة الجديدة getStudentProfileByUuid
        final profile = await _supabase.getStudentProfileByUuid(user.id);
        if (profile != null) {
          setState(() {
            _phone = profile.phone ?? '';
            _city = profile.city ?? '';
            _studentType = profile.studentType ?? 'tawjihi';
            _highSchoolScore = profile.highSchoolScore?.toString() ?? '';
            _gpa = profile.gpa?.toString() ?? '';
            _university = profile.currentUniversityId?.toString() ?? '';
            _major = profile.currentMajorId?.toString() ?? '';
            _academicYear = profile.academicLevel ?? ''; // ✅ استخدم academicLevel
            _phoneController.text = _phone;
            _cityController.text = _city;
          });
        }
      } catch (e) {
        debugPrint('❌ خطأ في جلب ملف الطالب: $e');
      }
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
        _errorMessage = 'تعذّر تحميل البيانات';
        _isLoading = false;
      });
    }
  }
}

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSaving = true;
    });

    try {
      await TokenManager.saveUserData(
        userId: _userId,
        role: _userRole,
        name: _nameController.text,
        email: _userEmail,
      );

      final user = _supabase.currentUser;
      if (user != null) {
        // TODO: تحديث بيانات المستخدم في Supabase
        await Future.delayed(const Duration(seconds: 1));
      }

      setState(() {
        _userName = _nameController.text;
        _phone = _phoneController.text;
        _city = _cityController.text;
        _isEditing = false;
        _isSaving = false;
      });

      _showSnackBar('تم حفظ البيانات بنجاح! ✅');
    } catch (e) {
      setState(() {
        _isSaving = false;
      });
      _showSnackBar('حدث خطأ أثناء الحفظ', isSuccess: false);
    }
  }

  void _showSnackBar(String message, {bool isSuccess = true}) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          backgroundColor:
              isSuccess ? const Color(0xFF22C55E) : const Color(0xFFDC2626),
          content: Row(
            children: [
              Icon(
                isSuccess
                    ? Icons.check_circle_outline_rounded
                    : Icons.error_outline_rounded,
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

  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    _animationController.dispose();
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
            ? const Center(
                child: CircularProgressIndicator(
                  color: AppTheme.primary,
                ),
              )
            : _errorMessage != null
                ? _buildErrorState()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              _buildProfileHeader(),
                              const SizedBox(height: 24),
                              _buildStatsSection(),
                              const SizedBox(height: 24),
                              _buildInfoCards(),
                              const SizedBox(height: 24),
                              if (_isEditing) _buildEditActions(),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
      ),
    );
  }

  // ============================================================
  //  AppBar
  // ============================================================
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'الملف الشخصي',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryContainer,
        ),
      ),
      centerTitle: true,
      leading: const SizedBox.shrink(),
      actions: [
        if (!_isEditing)
          IconButton(
            icon: const Icon(
              Icons.edit_rounded,
              color: AppTheme.primaryContainer,
            ),
            onPressed: () {
              setState(() {
                _isEditing = true;
              });
            },
          ),
      ],
    );
  }

  // ============================================================
  //  Error State
  // ============================================================
  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline_rounded,
                size: 56, color: Colors.grey.shade400),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _loadProfileData,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('إعادة المحاولة'),
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
      ),
    );
  }

  // ============================================================
  //  Profile Header (Hero Section)
  // ============================================================
  Widget _buildProfileHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 30,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar
          Stack(
            children: [
              Container(
                width: 90,
                height: 90,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.3),
                    width: 3,
                  ),
                ),
                child: Center(
                  child: Text(
                    _userName.isNotEmpty ? _userName[0].toUpperCase() : 'ط',
                    style: const TextStyle(
                      fontSize: 34,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 14,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Name
          if (_isEditing)
            TextFormField(
              controller: _nameController,
              textDirection: TextDirection.rtl,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'الاسم الكامل',
                hintStyle: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.white.withValues(alpha: 0.3),
                  ),
                ),
                focusedBorder: const UnderlineInputBorder(
                  borderSide: BorderSide(color: Colors.white),
                ),
                errorStyle: TextStyle(
                  color: Colors.red.shade200,
                  fontSize: 12,
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الاسم مطلوب';
                }
                if (value.length < 3) {
                  return 'الاسم قصير جداً';
                }
                return null;
              },
            )
          else
            Text(
              _userName.isNotEmpty ? _userName : 'طالب',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 4),

          // Email
          Text(
            _userEmail.isNotEmpty ? _userEmail : 'student@nextstep.ai',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 10),

          // Role Badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _userRole == 'university'
                      ? Icons.business_rounded
                      : _userRole == 'admin'
                          ? Icons.admin_panel_settings_rounded
                          : Icons.school_rounded,
                  size: 14,
                  color: Colors.white.withValues(alpha: 0.8),
                ),
                const SizedBox(width: 6),
                Text(
                  _userRole == 'university'
                      ? 'جامعة'
                      : _userRole == 'admin'
                          ? 'إدارة'
                          : 'طالب',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  Stats Section
  // ============================================================
  Widget _buildStatsSection() {
    final isTawjihi = _studentType == 'tawjihi';

    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            title: 'نوع الطالب',
            value: isTawjihi ? 'توجيهي' : 'جامعي',
            icon: Icons.assignment_ind_rounded,
            color: const Color(0xFF3B82F6),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            title: isTawjihi ? 'معدل الثانوية' : 'المعدل التراكمي',
            value: isTawjihi
                ? (_highSchoolScore.isNotEmpty ? '$_highSchoolScore%' : '--')
                : (_gpa.isNotEmpty ? '$_gpa / 4.0' : '--'),
            icon: isTawjihi ? Icons.grade_rounded : Icons.analytics_rounded,
            color: isTawjihi ? const Color(0xFF22C55E) : const Color(0xFFF97316),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatCard(
            title: 'التوصيات',
            value: '0',
            icon: Icons.recommend_rounded,
            color: const Color(0xFFA855F7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryContainer,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  Info Cards
  // ============================================================
  Widget _buildInfoCards() {
    final isTawjihi = _studentType == 'tawjihi';

    return Column(
      children: [
        _buildInfoCard(
          title: 'معلومات شخصية',
          icon: Icons.person_outline_rounded,
          color: const Color(0xFF3B82F6),
          children: [
            _buildInfoRow(
              label: 'رقم الهاتف',
              value: _phone,
              icon: Icons.phone_outlined,
              isEditing: _isEditing,
              controller: _phoneController,
              hint: 'أدخل رقم الهاتف',
              validator: (value) {
                if (value == null || value.isEmpty) return null;
                if (value.length < 9) return 'رقم غير صحيح';
                return null;
              },
            ),
            _buildInfoRow(
              label: 'المدينة',
              value: _city,
              icon: Icons.location_city_rounded,
              isEditing: _isEditing,
              controller: _cityController,
              hint: 'أدخل المدينة',
            ),
            _buildInfoRowStatic(
              label: 'البريد الإلكتروني',
              value: _userEmail,
              icon: Icons.email_rounded,
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildInfoCard(
          title: 'معلومات أكاديمية',
          icon: Icons.school_rounded,
          color: const Color(0xFF8B5CF6),
          children: [
            _buildInfoRowStatic(
              label: 'نوع الطالب',
              value: isTawjihi ? 'طالب توجيهي' : 'طالب جامعي',
              icon: Icons.assignment_ind_rounded,
            ),
            if (isTawjihi)
              _buildInfoRowStatic(
                label: 'معدل الثانوية',
                value: _highSchoolScore.isNotEmpty ? '$_highSchoolScore%' : 'غير محدد',
                icon: Icons.grade_rounded,
              )
            else
              _buildInfoRowStatic(
                label: 'المعدل التراكمي',
                value: _gpa.isNotEmpty ? '$_gpa / 4.0' : 'غير محدد',
                icon: Icons.analytics_rounded,
              ),
            if (!isTawjihi && _university.isNotEmpty)
              _buildInfoRowStatic(
                label: 'الجامعة',
                value: _university,
                icon: Icons.business_rounded,
              ),
            if (!isTawjihi && _major.isNotEmpty)
              _buildInfoRowStatic(
                label: 'التخصص',
                value: _major,
                icon: Icons.book_rounded,
              ),
            if (!isTawjihi && _academicYear.isNotEmpty)
              _buildInfoRowStatic(
                label: 'السنة الدراسية',
                value: _academicYear,
                icon: Icons.calendar_today_rounded,
              ),
          ],
        ),

        const SizedBox(height: 16),

        _buildInfoCard(
          title: 'إحصائيات',
          icon: Icons.bar_chart_rounded,
          color: const Color(0xFFF97316),
          children: [
            _buildInfoRowStatic(
              label: 'التخصصات المقترحة',
              value: '0',
              icon: Icons.recommend_rounded,
            ),
            _buildInfoRowStatic(
              label: 'الاستبيانات المكتملة',
              value: '0',
              icon: Icons.assignment_turned_in_rounded,
            ),
            _buildInfoRowStatic(
              label: 'المحادثات',
              value: '0',
              icon: Icons.chat_rounded,
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required Color color,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
              const Spacer(),
              if (title == 'معلومات أكاديمية')
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    'مكتمل',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: const Color(0xFF22C55E),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required String label,
    required String value,
    required IconData icon,
    required bool isEditing,
    required TextEditingController controller,
    required String hint,
    String? Function(String?)? validator,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                isEditing
                    ? TextFormField(
                        controller: controller,
                        textDirection: TextDirection.rtl,
                        textAlign: TextAlign.right,
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppTheme.primaryContainer,
                        ),
                        decoration: InputDecoration(
                          hintText: hint,
                          hintStyle: TextStyle(
                            color: Colors.grey.shade400,
                            fontSize: 13,
                          ),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.zero,
                          isDense: true,
                          errorStyle: TextStyle(
                            fontSize: 11,
                            color: Colors.red.shade700,
                          ),
                        ),
                        validator: validator,
                      )
                    : Text(
                        value.isNotEmpty ? value : 'غير محدد',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: value.isNotEmpty ? FontWeight.w500 : FontWeight.w400,
                          color: value.isNotEmpty
                              ? AppTheme.primaryContainer
                              : Colors.grey.shade400,
                        ),
                      ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRowStatic({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey.shade500),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.grey.shade500,
                  ),
                ),
                Text(
                  value.isNotEmpty ? value : 'غير محدد',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: value.isNotEmpty ? FontWeight.w500 : FontWeight.w400,
                    color: value.isNotEmpty
                        ? AppTheme.primaryContainer
                        : Colors.grey.shade400,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  Edit Actions
  // ============================================================
  Widget _buildEditActions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.grey.shade200, width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _isSaving
                  ? null
                  : () {
                      setState(() {
                        _isEditing = false;
                        _nameController.text = _userName;
                        _phoneController.text = _phone;
                        _cityController.text = _city;
                      });
                    },
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryContainer,
                side: BorderSide(color: Colors.grey.shade300),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: const Text('إلغاء'),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: _isSaving ? null : _saveProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('حفظ التغييرات'),
            ),
          ),
        ],
      ),
    );
  }
}