import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/helpers/hive_storage.dart';
import 'package:nextstep_ai_app/core/helpers/token_manager.dart';
import 'package:nextstep_ai_app/core/widgets/app_snack.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  String _userName = '';
  String _userEmail = '';
  String _userRole = 'student';
  String _userId = '';
  String _phone = '';
  String _age = '18';
  int _assessmentPercent = 0;
  int _favoriteCount = 0;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadProfileData() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final data = await TokenManager.getUserData();
      final savedAnswers =
          await HiveStorage.getData('assessment_cache', 'answers');
      final favorites = await HiveStorage.getAllData('favorites_cache');
      final answered = savedAnswers is Map ? savedAnswers.length : 0;
      if (mounted) {
        setState(() {
          _userName = data['name'] ?? '';
          _userEmail = data['email'] ?? '';
          _userRole = data['role'] ?? 'student';
          _userId = data['userId'] ?? '';
          _phone = data['phone'] ?? '';
          _assessmentPercent = ((answered.clamp(0, 6) / 6) * 100).round();
          _favoriteCount = favorites.length;
          _nameController.text = _userName;
          _emailController.text = _userEmail;
          _phoneController.text = _phone;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await TokenManager.saveUserData(
        userId: _userId,
        role: _userRole,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text.trim(),
      );
      setState(() {
        _userName = _nameController.text;
        _userEmail = _emailController.text;
        _phone = _phoneController.text;
        _isEditing = false;
        _isSaving = false;
      });
      if (mounted) {
        AppSnack.success(context, 'تم حفظ التغييرات على هذا الجهاز');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSaving = false);
        AppSnack.error(context, 'حدث خطأ أثناء الحفظ');
      }
    }
  }

  void _cancelEdit() {
    setState(() {
      _isEditing = false;
      _nameController.text = _userName;
      _emailController.text = _userEmail;
      _phoneController.text = _phone;
    });
  }

  void _showUnavailable(String message) {
    AppSnack.info(context, message);
  }

  @override
  Widget build(BuildContext context) {
    final c = Theme.of(context).extension<AppColors>() ?? AppColors.light;
    final initials = _userName.isNotEmpty ? _userName[0].toUpperCase() : 'ط';
    final roleLabel = _userRole == 'university'
        ? 'جامعة'
        : _userRole == 'admin'
            ? 'إدارة'
            : 'طالب ثانوي متقدم';

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: c.background,
        body: _isLoading
            ? _buildLoading(c)
            : Stack(
                children: [
                  CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(
                          child: _buildHero(c, initials, roleLabel)),
                      SliverToBoxAdapter(child: _buildStats(c)),
                      SliverToBoxAdapter(child: _buildPersonalInfo(c)),
                      SliverToBoxAdapter(child: _buildAcademicInfo(c)),
                      SliverToBoxAdapter(child: _buildCampusCard(c)),
                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  ),
                  if (_isEditing)
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _buildFloatingActionBar(c),
                    ),
                ],
              ),
      ),
    );
  }

  Widget _buildLoading(AppColors c) {
    return Center(child: CircularProgressIndicator(color: c.primary));
  }

  

  Widget _buildHero(AppColors c, String initials, String roleLabel) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(
          20, MediaQuery.of(context).padding.top + 12, 20, 32),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [c.primary, c.primaryContainer, c.background],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              _isEditing
                  ? Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.edit_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text('وضع التعديل',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    )
                  : const SizedBox.shrink(),
              const Spacer(),
              GestureDetector(
                onTap: () => context.push('/settings'),
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child:
                      Icon(Icons.tune_rounded, color: Colors.white, size: 20),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          Stack(
            children: [
              Container(
                width: 96,
                height: 96,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                    colors: [
                      c.primaryContainer,
                      Colors.white.withValues(alpha: 0.15),
                      c.primary
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                        color: c.primaryContainer.withValues(alpha: 0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 8)),
                  ],
                ),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: c.surfaceAlt,
                  ),
                  child: Center(
                    child: Text(initials,
                        style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            color: c.primary)),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                child: GestureDetector(
                  onTap: () => _showUnavailable(
                    'تغيير الصورة الشخصية غير متاح في هذه النسخة',
                  ),
                  child: Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: c.surfaceAlt,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                            color: Colors.black.withValues(alpha: 0.1),
                            blurRadius: 8)
                      ],
                    ),
                    child: Icon(Icons.photo_camera_rounded,
                        color: c.primary, size: 18),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            _userName.isNotEmpty ? _userName : 'طالب',
            style: const TextStyle(
                fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(
            _userEmail.isNotEmpty ? _userEmail : '',
            style: TextStyle(
                fontSize: 13, color: Colors.white.withValues(alpha: 0.7)),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('🎓', style: TextStyle(fontSize: 13)),
                const SizedBox(width: 6),
                Text(roleLabel,
                    style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.9),
                        fontSize: 12,
                        fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildStats(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: c.primary.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 8)),
          ],
        ),
        child: Row(
          children: [
            _statItem(
                c, Icons.analytics_rounded, '--', 'المعدل التراكمي', c.primary),
            Container(width: 1, height: 40, color: c.divider),
            _statItem(c, Icons.psychology_rounded, '$_assessmentPercent%',
                'التقييم الذكي', c.primaryContainer),
            Container(width: 1, height: 40, color: c.divider),
            _statItem(c, Icons.bookmark_rounded, '$_favoriteCount',
                'تخصص محفوظ', c.accent),
          ],
        ),
      ),
    );
  }

  Widget _statItem(
      AppColors c, IconData icon, String value, String label, Color color) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 6),
          Text(value,
              style: TextStyle(
                  fontSize: 20, fontWeight: FontWeight.w800, color: color)),
          const SizedBox(height: 2),
          Text(label,
              style: TextStyle(fontSize: 10, color: c.textSecondary),
              textAlign: TextAlign.center),
        ],
      ),
    );
  }

  

  Widget _buildPersonalInfo(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(
            height: 20,
          ),
          Row(
            children: [
              Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                      color: c.primary,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text('البيانات الشخصية',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary)),
              const Spacer(),
              GestureDetector(
                onTap: () => setState(() => _isEditing = true),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                      color: c.surfaceAlt, shape: BoxShape.circle),
                  child: Icon(Icons.edit_square, color: c.primary, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Form(
            key: _formKey,
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: c.surface,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                      color: c.primary.withValues(alpha: 0.04),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Column(
                children: [
                  _infoRowEditable(c, Icons.badge_rounded, 'الاسم الكامل',
                      _nameController, c.primary,
                      isEditable: true),
                  const SizedBox(height: 8),
                  _infoRowEditable(c, Icons.mail_rounded, 'البريد الإلكتروني',
                      _emailController, c.primaryContainer,
                      isEditable: true, isLtr: true),
                  const SizedBox(height: 8),
                  _infoRowEditable(c, Icons.call_rounded, 'رقم الهاتف',
                      _phoneController, const Color(0xFF10B981),
                      isEditable: true, isLtr: true),
                  const SizedBox(height: 8),
                  _infoRowStatic(c, Icons.cake_rounded, 'العمر وتاريخ الميلاد',
                      '$_age سنة (2006/04/15)', c.surfaceAlt),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowEditable(AppColors c, IconData icon, String label,
      TextEditingController controller, Color iconColor,
      {bool isEditable = false, bool isLtr = false}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceAlt.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: c.textSecondary)),
                const SizedBox(height: 2),
                if (_isEditing)
                  TextFormField(
                    controller: controller,
                    textDirection:
                        isLtr ? TextDirection.ltr : TextDirection.rtl,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      hintText: label,
                      hintStyle:
                          TextStyle(color: c.textSecondary, fontSize: 13),
                    ),
                    validator: isEditable
                        ? (v) => v == null || v.trim().isEmpty ? 'مطلوب' : null
                        : null,
                  )
                else
                  Text(
                    controller.text.isNotEmpty ? controller.text : 'غير محدد',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: controller.text.isNotEmpty
                          ? c.textPrimary
                          : c.textSecondary,
                    ),
                    textDirection:
                        isLtr ? TextDirection.ltr : TextDirection.rtl,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRowStatic(
      AppColors c, IconData icon, String label, String value, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceAlt.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: c.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  

  Widget _buildAcademicInfo(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                  width: 4,
                  height: 20,
                  decoration: BoxDecoration(
                      color: c.primaryContainer,
                      borderRadius: BorderRadius.circular(2))),
              const SizedBox(width: 8),
              Text('المسار الأكاديمي',
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: c.textPrimary)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: c.surface,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                    color: c.primary.withValues(alpha: 0.04),
                    blurRadius: 16,
                    offset: const Offset(0, 4))
              ],
            ),
            child: Column(
              children: [
                _academicRow(
                    c,
                    Icons.school_rounded,
                    'المؤسسة التعليمية',
                    'ثانوية المتفوقين الرسمية',
                    'الفرع الأكاديمي - رام الله',
                    c.primary),
                const SizedBox(height: 8),
                _academicRowWithChip(
                    c,
                    Icons.smart_toy_rounded,
                    'التخصص المستهدف',
                    'هندسة الذكاء الاصطناعي',
                    '94%',
                    c.primaryContainer),
                const SizedBox(height: 8),
                _academicRow(
                    c,
                    Icons.device_hub_rounded,
                    'المسار التوجيهي الحالي',
                    'العلمي / التكنولوجي المتقدم',
                    null,
                    const Color(0xFF00414D)),
                const SizedBox(height: 8),
                _academicRow(c, Icons.event_available_rounded,
                    'سنة التخرج المتوقعة', '2024 / 2025', null, c.surfaceAlt),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _academicRow(AppColors c, IconData icon, String label, String value,
      String? sub, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceAlt.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: c.textSecondary)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: c.textPrimary)),
                if (sub != null) ...[
                  const SizedBox(height: 2),
                  Text(sub,
                      style: TextStyle(fontSize: 11, color: c.textSecondary)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _academicRowWithChip(AppColors c, IconData icon, String label,
      String value, String badge, Color iconColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: c.surfaceAlt.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(fontSize: 11, color: c.textSecondary)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: c.primary,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(value,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: c.success.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text('مطابقة $badge',
                          style: TextStyle(
                              color: c.success,
                              fontSize: 11,
                              fontWeight: FontWeight.w700)),
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

  

  Widget _buildCampusCard(AppColors c) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: c.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: c.primary.withValues(alpha: 0.04),
                blurRadius: 16,
                offset: const Offset(0, 4))
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text('الجامعة الموصى بها لمسارك',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary)),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                      color: c.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(6)),
                  child: Text('الخيار رقم 1',
                      style: TextStyle(
                          color: c.primary,
                          fontSize: 11,
                          fontWeight: FontWeight.w700)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              height: 140,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [c.primaryContainer, c.primary],
                ),
              ),
              child: Stack(
                children: [
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.7)
                          ],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 12,
                    left: 12,
                    right: 12,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('جامعة بوليتكنك المستقبل',
                            style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                                color: Colors.white)),
                        const SizedBox(height: 2),
                        Text('كلية هندسة الحاسوب والذكاء الاصطناعي',
                            style: TextStyle(
                                fontSize: 11,
                                color: Colors.white.withValues(alpha: 0.8))),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  

  Widget _buildFloatingActionBar(AppColors c) {
    return Container(
      padding: EdgeInsets.fromLTRB(
          20, 12, 20, MediaQuery.of(context).padding.bottom + 12),
      decoration: BoxDecoration(
        color: c.surface.withValues(alpha: 0.95),
        boxShadow: [
          BoxShadow(
              color: c.primary.withValues(alpha: 0.1),
              blurRadius: 24,
              offset: const Offset(0, -8))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: _cancelEdit,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  color: c.surfaceAlt,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text('إلغاء',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: c.textPrimary)),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: _isSaving ? null : _saveProfile,
              child: Container(
                height: 48,
                decoration: BoxDecoration(
                  gradient:
                      LinearGradient(colors: [c.primary, c.primaryContainer]),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                        color: c.primary.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4))
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isSaving)
                      const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2))
                    else
                      const Icon(Icons.check_circle_rounded,
                          color: Colors.white, size: 18),
                    const SizedBox(width: 6),
                    const Text('حفظ التغييرات',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
