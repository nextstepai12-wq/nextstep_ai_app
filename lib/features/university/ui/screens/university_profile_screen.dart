import 'package:flutter/material.dart';
import 'package:nextstep_ai_app/core/theming/app_theme.dart';
import 'package:nextstep_ai_app/core/networking/supabase_service.dart';
import 'package:nextstep_ai_app/core/helpers/token_manager.dart';

class UniversityProfileScreen extends StatefulWidget {
  const UniversityProfileScreen({super.key});

  @override
  State<UniversityProfileScreen> createState() =>
      _UniversityProfileScreenState();
}

class _UniversityProfileScreenState extends State<UniversityProfileScreen>
    with SingleTickerProviderStateMixin {
  final SupabaseService _supabase = SupabaseService();

  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;
  String? _errorMessage;

  // بيانات الجامعة
  String _universityName = '';
  String _userEmail = '';
  String _location = '';
  String _description = '';
  String _website = '';
  String _contactInfo = '';
  String _visionMission = '';
  String _logo = '';

  // Controllers
  final _nameController = TextEditingController();
  final _locationController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _websiteController = TextEditingController();
  final _contactController = TextEditingController();
  final _visionController = TextEditingController();

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
        _universityName = cachedData['name']!;
        _nameController.text = _universityName;
        _userEmail = cachedData['email'] ?? '';
      }

      final user = _supabase.currentUser;
      if (user != null) {
        final userData = await _supabase.getUser(user.id);
        if (userData != null) {
          setState(() {
            _universityName = userData.displayName;
            _userEmail = user.email ?? '';
            _nameController.text = _universityName;
          });
        }

        try {
          // TODO: جلب بيانات الجامعة من Supabase
          final universityData = {
            'name': 'الجامعة الإسلامية',
            'location': 'غزة، فلسطين',
            'description':
                'جامعة رائدة في التعليم العالي، تقدم برامج أكاديمية متميزة',
            'website': 'https://iugaza.edu.ps',
            'contact': '+970 8 1234567',
            'vision_mission':
                'الريادة في التعليم والبحث العلمي وخدمة المجتمع',
            'logo': '',
          };

          setState(() {
            _location = universityData['location'] ?? '';
            _description = universityData['description'] ?? '';
            _website = universityData['website'] ?? '';
            _contactInfo = universityData['contact'] ?? '';
            _visionMission = universityData['vision_mission'] ?? '';
            _locationController.text = _location;
            _descriptionController.text = _description;
            _websiteController.text = _website;
            _contactController.text = _contactInfo;
            _visionController.text = _visionMission;
          });
        } catch (_) {}
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
    setState(() {
      _isSaving = true;
    });

    try {
      await TokenManager.saveUserData(
        userId: '',
        role: 'university',
        name: _nameController.text,
        email: _userEmail,
      );

      // TODO: تحديث بيانات الجامعة في Supabase
      await Future.delayed(const Duration(seconds: 1));

      setState(() {
        _universityName = _nameController.text;
        _location = _locationController.text;
        _description = _descriptionController.text;
        _website = _websiteController.text;
        _contactInfo = _contactController.text;
        _visionMission = _visionController.text;
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
    _locationController.dispose();
    _descriptionController.dispose();
    _websiteController.dispose();
    _contactController.dispose();
    _visionController.dispose();
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
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_rounded,
          color: AppTheme.primaryContainer,
        ),
        onPressed: () => Navigator.pop(context),
      ),
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

  Widget _buildErrorState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 56,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
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
  //  Profile Header
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
          // ✅ شعار الجامعة
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 3,
              ),
            ),
            child: Center(
              child: Text(
                _universityName.isNotEmpty ? _universityName[0] : 'ج',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),

          // ✅ اسم الجامعة
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
                hintText: 'اسم الجامعة',
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
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'الاسم مطلوب';
                }
                return null;
              },
            )
          else
            Text(
              _universityName.isNotEmpty ? _universityName : 'الجامعة',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          const SizedBox(height: 4),

          // ✅ البريد الإلكتروني
          Text(
            _userEmail.isNotEmpty ? _userEmail : 'university@nextstep.ai',
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withValues(alpha: 0.7),
            ),
          ),
          const SizedBox(height: 8),

          // ✅ نوع الحساب
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Text(
              'جامعة',
              style: TextStyle(
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
  //  Info Cards
  // ============================================================
  Widget _buildInfoCards() {
    return Column(
      children: [
        _buildInfoCard(
          title: 'معلومات الجامعة',
          icon: Icons.business_rounded,
          color: const Color(0xFF3B82F6),
          children: [
            _buildInfoRow(
              label: 'الموقع',
              value: _location,
              icon: Icons.location_on_rounded,
              isEditing: _isEditing,
              controller: _locationController,
              hint: 'أدخل موقع الجامعة',
            ),
            _buildInfoRow(
              label: 'الموقع الإلكتروني',
              value: _website,
              icon: Icons.language_rounded,
              isEditing: _isEditing,
              controller: _websiteController,
              hint: 'https://...',
            ),
            _buildInfoRow(
              label: 'معلومات الاتصال',
              value: _contactInfo,
              icon: Icons.phone_rounded,
              isEditing: _isEditing,
              controller: _contactController,
              hint: 'رقم الهاتف أو البريد',
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildInfoCard(
          title: 'الرؤية والرسالة',
          icon: Icons.visibility_rounded,
          color: const Color(0xFF8B5CF6),
          children: [
            _buildInfoRow(
              label: 'الرؤية والرسالة',
              value: _visionMission,
              icon: Icons.flag_rounded,
              isEditing: _isEditing,
              controller: _visionController,
              hint: 'رؤية ورسالة الجامعة',
              maxLines: 3,
            ),
          ],
        ),

        const SizedBox(height: 16),

        _buildInfoCard(
          title: 'نبذة عن الجامعة',
          icon: Icons.description_rounded,
          color: const Color(0xFF22C55E),
          children: [
            _buildInfoRow(
              label: 'الوصف',
              value: _description,
              icon: Icons.text_snippet_rounded,
              isEditing: _isEditing,
              controller: _descriptionController,
              hint: 'وصف الجامعة...',
              maxLines: 4,
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
    int maxLines = 1,
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
                        maxLines: maxLines,
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
                        validator: (value) {
                          if (label == 'الموقع الإلكتروني' &&
                              value != null &&
                              value.isNotEmpty &&
                              !value.startsWith('http')) {
                            return 'يجب أن يبدأ بـ https://';
                          }
                          return null;
                        },
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
                        _nameController.text = _universityName;
                        _locationController.text = _location;
                        _descriptionController.text = _description;
                        _websiteController.text = _website;
                        _contactController.text = _contactInfo;
                        _visionController.text = _visionMission;
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