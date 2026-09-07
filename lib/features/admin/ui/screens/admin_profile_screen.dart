// lib/features/admin/ui/screens/admin_profile_screen.dart
import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/helpers/hive_storage.dart';
import 'package:nextstep_ai_app/core/helpers/token_manager.dart';
import 'package:nextstep_ai_app/core/networking/supabase_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// ============================================================
///  شاشة الملف الشخصي للإدمن
///  مع تخزين محلي Offline-First ومزامنة مع Supabase
/// ============================================================
class AdminProfileScreen extends StatefulWidget {
  const AdminProfileScreen({super.key});

  @override
  State<AdminProfileScreen> createState() => _AdminProfileScreenState();
}

class _AdminProfileScreenState extends State<AdminProfileScreen>
    with SingleTickerProviderStateMixin {
  // ============================================================
  //  المتغيرات
  // ============================================================
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _errorMessage;

  // بيانات المدير
  String _adminId = '';
  String _adminName = '';
  String _adminEmail = '';
  String _adminRole = 'admin';
  String _adminPhone = '';
  String _adminAvatar = '';
  String _adminCreatedAt = '';

  // متغيرات التعديل
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // متغيرات التحكم في عرض كلمة المرور
  bool _obscureOldPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

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

    _loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // ============================================================
  //  تحميل الملف الشخصي
  // ============================================================
  Future<void> _loadProfile() async {
    try {
      if (!mounted) return;
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      // 1. قراءة من TokenManager
      final userData = await TokenManager.getUserData();

      if (userData.isNotEmpty) {
        setState(() {
          _adminId = userData['userId'] ?? '';
          _adminName = userData['name'] ?? '';
          _adminEmail = userData['email'] ?? '';
          _adminRole = userData['role'] ?? 'admin';
          _nameController.text = _adminName;
        });
      }

      // 2. قراءة بيانات إضافية من Hive
      final cached = await HiveStorage.getData('admin_profile_cache', 'profile');
      if (cached != null && cached.isNotEmpty) {
        setState(() {
          _adminPhone = cached['phone'] ?? '';
          _adminAvatar = cached['avatar'] ?? '';
          _adminCreatedAt = cached['created_at'] ?? '';
          _phoneController.text = _adminPhone;
        });
      }

      // 3. جلب بيانات محدثة من Supabase
      if (_adminId.isNotEmpty) {
        try {
          final supabase = SupabaseService();
          final response = await supabase.client
              .from('users')
              .select('*')
              .eq('id', _adminId)
              .single();

          if (response != null) {
            setState(() {
              _adminName = response['name'] ?? _adminName;
              _adminEmail = response['email'] ?? _adminEmail;
              _adminPhone = response['phone'] ?? _adminPhone;
              _adminAvatar = response['avatar'] ?? _adminAvatar;
              _adminCreatedAt = response['created_at'] ?? '';
              _nameController.text = _adminName;
              _phoneController.text = _adminPhone;
            });

            // حفظ في Hive
            await HiveStorage.saveData('admin_profile_cache', 'profile', {
              'name': _adminName,
              'email': _adminEmail,
              'phone': _adminPhone,
              'avatar': _adminAvatar,
              'created_at': _adminCreatedAt,
              'updated_at': DateTime.now().toIso8601String(),
            });
          }
        } catch (e) {
          // تجاهل خطأ Supabase واستخدام البيانات المخزنة
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
          _errorMessage = 'فشل تحميل الملف الشخصي: ${e.toString()}';
          _isLoading = false;
        });
      }
    }
  }

  // ============================================================
  //  حفظ التغييرات
  // ============================================================
  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('الرجاء إدخال الاسم', Colors.orange);
      return;
    }

    setState(() => _isSaving = true);

    try {
      final updatedProfile = {
        'name': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'updated_at': DateTime.now().toIso8601String(),
      };

      // 1. حفظ في Hive
      final cached = await HiveStorage.getData('admin_profile_cache', 'profile');
      final updated = {
        ...?cached,
        ...updatedProfile,
      };
      await HiveStorage.saveData('admin_profile_cache', 'profile', updated);

      // 2. تحديث في Supabase
      if (_adminId.isNotEmpty) {
        try {
          final supabase = SupabaseService();
          await supabase.client
              .from('users')
              .update(updatedProfile)
              .eq('id', _adminId);
        } catch (e) {
          // إضافة للمزامنة المعلقة
          await HiveStorage.addPendingSync({
            'operation': 'update',
            'table': 'users',
            'data': {'id': _adminId, ...updatedProfile},
            'timestamp': DateTime.now().toIso8601String(),
          });
        }
      }

      // 3. تحديث TokenManager
      await TokenManager.saveUserData(
        userId: _adminId,
        role: _adminRole,
        name: _nameController.text.trim(),
        email: _adminEmail,
      );

      setState(() {
        _adminName = _nameController.text.trim();
        _adminPhone = _phoneController.text.trim();
        _isEditing = false;
      });

      _showSnackBar('✅ تم حفظ التغييرات بنجاح', Colors.green);
    } catch (e) {
      _showSnackBar('❌ خطأ: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ============================================================
  //  تغيير كلمة المرور
  // ============================================================
  Future<void> _changePassword() async {
    if (_oldPasswordController.text.isEmpty) {
      _showSnackBar('الرجاء إدخال كلمة المرور الحالية', Colors.orange);
      return;
    }
    if (_newPasswordController.text.length < 6) {
      _showSnackBar('يجب أن تتكون كلمة المرور من 6 أحرف على الأقل', Colors.orange);
      return;
    }
    if (_newPasswordController.text != _confirmPasswordController.text) {
      _showSnackBar('كلمتا المرور غير متطابقتين', Colors.orange);
      return;
    }

    setState(() => _isSaving = true);

    try {
      // تنفيذ تغيير كلمة المرور مع Supabase
      final supabase = SupabaseService();
      await supabase.client.auth.updateUser(
        UserAttributes(
          password: _newPasswordController.text,
        ),
      );

      _oldPasswordController.clear();
      _newPasswordController.clear();
      _confirmPasswordController.clear();

      _showSnackBar('✅ تم تغيير كلمة المرور بنجاح', Colors.green);
      Navigator.pop(context);
    } catch (e) {
      _showSnackBar('❌ خطأ: ${e.toString()}', Colors.red);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  // ============================================================
  //  بناء الواجهة
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: const Color(0xFFF7F8FA),
        appBar: _buildAppBar(),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(color: AppTheme.primary),
              )
            : _errorMessage != null
                ? _buildErrorState()
                : FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: RefreshIndicator(
                        onRefresh: _loadProfile,
                        child: SingleChildScrollView(
                          physics: const AlwaysScrollableScrollPhysics(
                            parent: BouncingScrollPhysics(),
                          ),
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                          child: Column(
                            children: [
                              _buildProfileHeader(),
                              const SizedBox(height: 24),
                              _buildInfoCard(),
                              const SizedBox(height: 20),
                              _buildSecurityCard(),
                              const SizedBox(height: 20),
                              _buildStatsCard(),
                              const SizedBox(height: 28),
                              _buildSaveButton(),
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
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: AppTheme.primaryContainer),
        onPressed: () => Navigator.pop(context),
      ),
      title: const Text(
        'الملف الشخصي',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryContainer,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: Icon(
            _isEditing ? Icons.close_rounded : Icons.edit_rounded,
            color: AppTheme.primary,
          ),
          onPressed: () {
            setState(() {
              _isEditing = !_isEditing;
              if (!_isEditing) {
                _nameController.text = _adminName;
                _phoneController.text = _adminPhone;
              }
            });
          },
        ),
      ],
    );
  }

  // ============================================================
  //  رأس الملف الشخصي
  // ============================================================
  Widget _buildProfileHeader() {
    final initial = _adminName.isNotEmpty ? _adminName[0] : 'A';

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.primary, AppTheme.primaryContainer],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.25),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 3),
                ),
                child: Center(
                  child: Text(
                    initial.toUpperCase(),
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.green,
                    shape: BoxShape.circle,
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
          const SizedBox(height: 16),
          Text(
            _adminName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _adminEmail,
            style: TextStyle(
              fontSize: 14,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _getRoleLabel(_adminRole),
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  بطاقة المعلومات الشخصية
  // ============================================================
  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: AppTheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'المعلومات الشخصية',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildInfoField(
            label: 'الاسم',
            value: _adminName,
            controller: _nameController,
            isEditing: _isEditing,
          ),
          const SizedBox(height: 12),
          _buildInfoField(
            label: 'البريد الإلكتروني',
            value: _adminEmail,
            isEditing: false,
          ),
          const SizedBox(height: 12),
          _buildInfoField(
            label: 'رقم الهاتف',
            value: _adminPhone,
            controller: _phoneController,
            isEditing: _isEditing,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 12),
          _buildInfoField(
            label: 'الدور',
            value: _getRoleLabel(_adminRole),
            isEditing: false,
          ),
          if (_adminCreatedAt.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoField(
              label: 'تاريخ الانضمام',
              value: _formatDate(_adminCreatedAt),
              isEditing: false,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoField({
    required String label,
    required String value,
    TextEditingController? controller,
    bool isEditing = false,
    TextInputType? keyboardType,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
        ),
        Expanded(
          child: isEditing && controller != null
              ? TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryContainer,
                  ),
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: const BorderSide(color: AppTheme.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                  ),
                )
              : Text(
                  value.isNotEmpty ? value : '-',
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppTheme.primaryContainer,
                  ),
                ),
        ),
      ],
    );
  }

  // ============================================================
  //  بطاقة الأمان
  // ============================================================
  Widget _buildSecurityCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.red.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  color: Colors.red,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'الأمان',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.password_rounded, color: Colors.grey),
            title: const Text(
              'تغيير كلمة المرور',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
            subtitle: const Text(
              'تحديث كلمة المرور الخاصة بك',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
            onTap: _showChangePasswordDialog,
          ),
        ],
      ),
    );
  }

  // ============================================================
  //  بطاقة الإحصائيات
  // ============================================================
  Widget _buildStatsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF8B5CF6).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.analytics_rounded,
                  color: Color(0xFF8B5CF6),
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              const Text(
                'إحصائيات سريعة',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primaryContainer,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: Icons.calendar_today_rounded,
                  label: 'عضو منذ',
                  value: _adminCreatedAt.isNotEmpty
                      ? _formatDate(_adminCreatedAt)
                      : 'غير محدد',
                  color: const Color(0xFF3B82F6),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatItem(
                  icon: Icons.admin_panel_settings_rounded,
                  label: 'الدور',
                  value: _getRoleLabel(_adminRole),
                  color: const Color(0xFF8B5CF6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppTheme.primaryContainer,
            ),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
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
  //  نافذة تغيير كلمة المرور
  // ============================================================
  void _showChangePasswordDialog() {
    // إعادة تعيين الحقول
    _oldPasswordController.clear();
    _newPasswordController.clear();
    _confirmPasswordController.clear();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'تغيير كلمة المرور',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.primaryContainer,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // كلمة المرور الحالية
              TextField(
                controller: _oldPasswordController,
                obscureText: _obscureOldPassword,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الحالية',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureOldPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureOldPassword = !_obscureOldPassword;
                      });
                    },
                  ),
                ),
              ),
              const SizedBox(height: 12),
              // كلمة المرور الجديدة
              TextField(
                controller: _newPasswordController,
                obscureText: _obscureNewPassword,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'كلمة المرور الجديدة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_open_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureNewPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureNewPassword = !_obscureNewPassword;
                      });
                    },
                  ),
                  helperText: 'يجب أن تكون 6 أحرف على الأقل',
                  helperStyle: TextStyle(fontSize: 11, color: Colors.grey.shade500),
                ),
              ),
              const SizedBox(height: 12),
              // تأكيد كلمة المرور الجديدة
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  labelText: 'تأكيد كلمة المرور الجديدة',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  prefixIcon: const Icon(Icons.lock_open_rounded),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscureConfirmPassword
                          ? Icons.visibility_off_rounded
                          : Icons.visibility_rounded,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: _isSaving ? null : _changePassword,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
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
                : const Text('تغيير'),
          ),
        ],
        actionsAlignment: MainAxisAlignment.center,
      ),
    );
  }

  // ============================================================
  //  زر الحفظ
  // ============================================================
  Widget _buildSaveButton() {
    if (!_isEditing) return const SizedBox.shrink();

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isSaving ? null : _saveProfile,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primary,
          foregroundColor: Colors.white,
          disabledBackgroundColor: AppTheme.primary.withValues(alpha: 0.6),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        child: _isSaving
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 2.4,
                ),
              )
            : const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.save_rounded, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'حفظ التغييرات',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ],
              ),
      ),
    );
  }

  // ============================================================
  //  حالة الخطأ
  // ============================================================
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
              onPressed: _loadProfile,
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
  //  دوال مساعدة
  // ============================================================
  String _getRoleLabel(String role) {
    switch (role) {
      case 'admin':
        return 'مدير النظام';
      case 'super_admin':
        return 'مدير عام';
      case 'content_manager':
        return 'مدير محتوى';
      default:
        return role;
    }
  }

  String _formatDate(String date) {
    if (date.isEmpty) return '-';
    try {
      final parsed = DateTime.parse(date);
      return '${parsed.year}-${parsed.month.toString().padLeft(2, '0')}-${parsed.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return date;
    }
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