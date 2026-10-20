import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../theme/training_colors.dart';
import '../widgets/training_center_drawer.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  late TabController _tabController;
  int _previousTab = 0;

  final TextEditingController _centerNameController =
      TextEditingController(text: 'مركز التدريب العالمي المحترف');
  final TextEditingController _registrationController =
      TextEditingController(text: 'TRN-890234-SA');
  final TextEditingController _emailController =
      TextEditingController(text: 'contact@globaltraining.pro');
  final TextEditingController _phoneController =
      TextEditingController(text: '+966 50 123 4567');
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _inviteEmailController = TextEditingController();

  bool _showPassword = false;
  String _selectedRole = 'editor';
  bool _isLoading = false;

  final List<Map<String, dynamic>> _teamMembers = [
    {
      'name': 'أحمد حسن',
      'email': 'ahmed@globaltraining.pro',
      'role': 'مدير',
      'roleType': 'admin',
      'status': 'نشط',
    },
    {
      'name': 'سارة محمد',
      'email': 'sara@globaltraining.pro',
      'role': 'محرر محتوى',
      'roleType': 'editor',
      'status': 'نشط',
    },
    {
      'name': 'فيصل القحطاني',
      'email': 'faisal@globaltraining.pro',
      'role': 'محرر محتوى',
      'roleType': 'editor',
      'status': 'قيد الانتظار',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _centerNameController.dispose();
    _registrationController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _inviteEmailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: TrainingColors.background,
      drawer: const TrainingCenterDrawer(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context),
            SizedBox(height: 36.h),
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 320),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              layoutBuilder: (currentChild, previousChildren) {
                return Stack(
                  alignment: Alignment.topCenter,
                  children: [
                    ...previousChildren,
                    if (currentChild != null) currentChild,
                  ],
                );
              },
              transitionBuilder: (child, animation) {
                final bool toLeft = _previousTab < _tabController.index;
                final Offset begin =
                    toLeft ? const Offset(-0.05, 0) : const Offset(0.05, 0);
                final Animation<Offset> slide = animation.drive(
                  Tween(begin: begin, end: Offset.zero)
                      .chain(CurveTween(curve: Curves.easeOutCubic)),
                );
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: slide,
                    child: child,
                  ),
                );
              },
              child: _tabController.index == 0
                  ? KeyedSubtree(
                      key: const ValueKey<int>(0),
                      child: _buildCenterTab(),
                    )
                  : KeyedSubtree(
                      key: const ValueKey<int>(1),
                      child: _buildTeamTab(),
                    ),
            ),
            SizedBox(height: 32.h),
          ],
        ),
      ),
    );
  }

  
  
  

  Widget _buildHeader(BuildContext context) {
    final double topInset = MediaQuery.of(context).padding.top;

    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16.w, topInset + 12.h, 16.w, 46.h),
          decoration: const BoxDecoration(
            gradient: TrainingColors.headerGradient,
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(24)),
            boxShadow: TrainingColors.headerShadow,
          ),
          child: Stack(
            children: [
              Positioned(
                top: -30.h,
                left: -30.w,
                child: Container(
                  width: 120.w,
                  height: 120.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.06),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Positioned(
                top: -46.h,
                left: -46.w,
                child: Container(
                  width: 150.w,
                  height: 150.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.05),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      _headerIconButton(
                        icon: Icons.menu_rounded,
                        onTap: () => _scaffoldKey.currentState?.openDrawer(),
                      ),
                      SizedBox(width: 10.w),
                      Container(
                        width: 38.w,
                        height: 38.w,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.14),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.25),
                            width: 1.2,
                          ),
                        ),
                        child: Icon(
                          Icons.settings_rounded,
                          size: 19.sp,
                          color: TrainingColors.accent,
                        ),
                      ),
                      SizedBox(width: 8.w),
                      const Text(
                        'الإعدادات',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 16.5,
                          fontWeight: FontWeight.w800,
                          color: TrainingColors.onPrimary,
                        ),
                      ),
                      const Spacer(),
                      _headerIconButton(
                        icon: Icons.notifications_none_rounded,
                        showDot: true,
                        onTap: () =>
                            context.push('/training-center/notifications'),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          left: 16.w,
          right: 16.w,
          bottom: -26.h,
          child: _buildTabSwitcher(),
        ),
      ],
    );
  }

  Widget _headerIconButton({
    required IconData icon,
    required VoidCallback onTap,
    bool showDot = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 40.w,
        height: 40.w,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.12),
          shape: BoxShape.circle,
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            Icon(icon, size: 21.sp, color: TrainingColors.onPrimary),
            if (showDot)
              Positioned(
                top: 9.h,
                right: 9.w,
                child: Container(
                  width: 9.w,
                  height: 9.w,
                  decoration: BoxDecoration(
                    color: TrainingColors.danger,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: TrainingColors.primaryContainer,
                      width: 1.5,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabSwitcher() {
    final tabs = [
      {'label': 'بيانات المركز', 'icon': Icons.business_rounded},
      {'label': 'إدارة الفريق', 'icon': Icons.group_rounded},
    ];

    return Container(
      height: 52.h,
      padding: EdgeInsets.all(5.r),
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(999.r),
        boxShadow: TrainingColors.cardShadow,
      ),
      child: Row(
        children: tabs.asMap().entries.map((entry) {
          final index = entry.key;
          final tab = entry.value;
          final active = _tabController.index == index;
          return Expanded(
            child: GestureDetector(
              onTap: () {
                if (_tabController.index == index) return;
                setState(() {
                  _previousTab = _tabController.index;
                });
                _tabController.animateTo(index);
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                curve: Curves.easeOutCubic,
                alignment: Alignment.center,
                margin: EdgeInsets.symmetric(horizontal: 5.w, vertical: 5.h),
                decoration: BoxDecoration(
                  color: active ? TrainingColors.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(999.r),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      tab['icon'] as IconData,
                      size: 16.sp,
                      color: active
                          ? TrainingColors.onPrimary
                          : TrainingColors.textMuted,
                    ),
                    SizedBox(width: 5.w),
                    Text(
                      tab['label'] as String,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 12.5.sp,
                        fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                        color: active
                            ? TrainingColors.onPrimary
                            : TrainingColors.textMuted,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  
  
  

  Widget _buildCenterTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildCenterProfileCard(),
          SizedBox(height: 20.h),
          _buildSectionHeader('المعلومات القانونية', Icons.gavel_rounded),
          SizedBox(height: 14.h),
          _buildTextField(
            label: 'الاسم القانوني للمركز',
            controller: _centerNameController,
            icon: Icons.business_rounded,
          ),
          SizedBox(height: 14.h),
          _buildRegistrationField(),
          SizedBox(height: 26.h),
          _buildSectionHeader('معلومات الاتصال', Icons.contact_phone_rounded),
          SizedBox(height: 14.h),
          _buildTextField(
            label: 'البريد الإلكتروني الرسمي',
            controller: _emailController,
            icon: Icons.email_rounded,
            keyboardType: TextInputType.emailAddress,
          ),
          SizedBox(height: 14.h),
          _buildTextField(
            label: 'رقم الهاتف الرسمي',
            controller: _phoneController,
            icon: Icons.phone_rounded,
            keyboardType: TextInputType.phone,
          ),
          SizedBox(height: 26.h),
          _buildSectionHeader('الأمان', Icons.security_rounded),
          SizedBox(height: 14.h),
          _buildPasswordField(),
          SizedBox(height: 26.h),
          _buildSaveButton(),
        ],
      ),
    );
  }

  Widget _buildCenterProfileCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.cardShadow,
      ),
      child: Stack(
        children: [
          const Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: SizedBox(
              width: 4,
              child: DecoratedBox(
                decoration: BoxDecoration(color: TrainingColors.accent),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(14.w),
            child: Row(
              children: [
                Container(
                  width: 56.w,
                  height: 56.w,
                  decoration: BoxDecoration(
                    color: TrainingColors.navySoft,
                    borderRadius: BorderRadius.circular(14.r),
                  ),
                  child: Icon(
                    Icons.account_balance_rounded,
                    size: 26.sp,
                    color: TrainingColors.primary,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _centerNameController.text,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 14.sp,
                          fontWeight: FontWeight.w800,
                          color: TrainingColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 8.w,
                              vertical: 2.h,
                            ),
                            decoration: BoxDecoration(
                              color: TrainingColors.successSoft,
                              borderRadius: BorderRadius.circular(999.r),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 6.w,
                                  height: 6.w,
                                  decoration: const BoxDecoration(
                                    color: TrainingColors.success,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                SizedBox(width: 4.w),
                                Text(
                                  'مركز معتمد',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 9.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: TrainingColors.success,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            _registrationController.text,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 10.5.sp,
                              color: TrainingColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Container(
          width: 30.w,
          height: 30.w,
          decoration: BoxDecoration(
            color: TrainingColors.navySoft,
            borderRadius: BorderRadius.circular(9.r),
          ),
          child: Icon(icon, color: TrainingColors.primary, size: 16.sp),
        ),
        SizedBox(width: 10.w),
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 15.sp,
            fontWeight: FontWeight.w800,
            color: TrainingColors.textPrimary,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(right: 2.w, bottom: 6.h),
          child: Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: FontWeight.w700,
              color: TrainingColors.textSecondary,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: TrainingColors.surface,
            borderRadius: BorderRadius.circular(13.r),
            boxShadow: TrainingColors.softShadow,
          ),
          child: TextFormField(
            controller: controller,
            keyboardType: keyboardType,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 13.sp,
              color: TrainingColors.textPrimary,
            ),
            decoration: InputDecoration(
              prefixIcon:
                  Icon(icon, color: TrainingColors.primary, size: 19.sp),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
      ],
    );
  }

  Widget _buildRegistrationField() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: TrainingColors.surfaceAlt,
        borderRadius: BorderRadius.circular(13.r),
        border: Border.all(color: TrainingColors.surfaceMuted),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 44.w,
            height: 52.h,
            color: TrainingColors.navySoft,
            child: Icon(
              Icons.verified_rounded,
              color: TrainingColors.primary,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'رقم الترخيص (التسجيل)',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 10.5.sp,
                    fontWeight: FontWeight.w700,
                    color: TrainingColors.textSecondary,
                  ),
                ),
                Text(
                  _registrationController.text,
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.5.sp,
                    fontWeight: FontWeight.w700,
                    color: TrainingColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 12.w),
            child: Text(
              'تغييره يتطلب موافقة الإدارة',
              style: TextStyle(
                fontFamily: 'Cairo',
                fontSize: 10.sp,
                color: TrainingColors.textMuted,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordField() {
    return Container(
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(13.r),
        boxShadow: TrainingColors.softShadow,
      ),
      child: TextFormField(
        controller: _passwordController,
        obscureText: !_showPassword,
        style: TextStyle(
          fontFamily: 'Cairo',
          fontSize: 13.sp,
          color: TrainingColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: 'كلمة المرور الجديدة',
          hintStyle: TextStyle(
            fontFamily: 'Cairo',
            fontSize: 13.sp,
            color: TrainingColors.textMuted,
          ),
          prefixIcon: Icon(Icons.lock_rounded,
              color: TrainingColors.primary, size: 19.sp),
          suffixIcon: IconButton(
            icon: Icon(
              _showPassword
                  ? Icons.visibility_rounded
                  : Icons.visibility_off_rounded,
              color: TrainingColors.textMuted,
              size: 19.sp,
            ),
            onPressed: () {
              setState(() {
                _showPassword = !_showPassword;
              });
            },
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: 16.w,
            vertical: 14.h,
          ),
        ),
        textDirection: TextDirection.ltr,
      ),
    );
  }

  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isLoading ? null : _saveSettings,
      child: Container(
        height: 50.h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: TrainingColors.accentGradient,
          borderRadius: BorderRadius.circular(13.r),
          boxShadow: [
            BoxShadow(
              color: TrainingColors.accent.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: _isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.check_rounded, size: 19.sp, color: Colors.white),
                  SizedBox(width: 6.w),
                  Text(
                    'حفظ التغييرات',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w800,
                      color: TrainingColors.onAccent,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  
  
  

  Widget _buildTeamTab() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTeamHeaderCard(),
          SizedBox(height: 16.h),
          _buildPermissionsCard(),
          SizedBox(height: 26.h),
          _buildSectionHeader('أعضاء الفريق', Icons.group_rounded),
          SizedBox(height: 14.h),
          if (_teamMembers.isEmpty)
            _buildEmptyTeamState()
          else
            Column(
              children: _teamMembers
                  .map((member) => _buildTeamMemberItem(member))
                  .toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildTeamHeaderCard() {
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        gradient: TrainingColors.headerGradient,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.cardShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: -40.h,
            left: -40.w,
            child: Container(
              width: 120.w,
              height: 120.w,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Row(
              children: [
                Container(
                  width: 46.w,
                  height: 46.w,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.14),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.25),
                      width: 1.2,
                    ),
                  ),
                  child: Icon(
                    Icons.group_rounded,
                    size: 23.sp,
                    color: Colors.white,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'إدارة الفريق',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        '${_teamMembers.length} أعضاء • المدير يرى كل شيء، والمحرر يدير المحتوى والطلاب فقط',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.5.sp,
                          height: 1.4,
                          color: Colors.white.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: _showInviteDialog,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 13.w,
                      vertical: 9.h,
                    ),
                    decoration: BoxDecoration(
                      color: TrainingColors.accent,
                      borderRadius: BorderRadius.circular(12.r),
                      boxShadow: [
                        BoxShadow(
                          color: TrainingColors.accent.withValues(alpha: 0.4),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.person_add_rounded,
                          size: 15.sp,
                          color: TrainingColors.onAccent,
                        ),
                        SizedBox(width: 5.w),
                        Text(
                          'دعوة عضو',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 11.5.sp,
                            fontWeight: FontWeight.w800,
                            color: TrainingColors.onAccent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsCard() {
    return Container(
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: TrainingColors.softShadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38.w,
            height: 38.w,
            decoration: const BoxDecoration(
              color: TrainingColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.privacy_tip_rounded,
              size: 19.sp,
              color: TrainingColors.primary,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'نظام الصلاحيات',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800,
                    color: TrainingColors.textPrimary,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'المدير يرى كل شيء، بينما محرر المحتوى يرى الدورات والطلاب فقط.',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 11.sp,
                    height: 1.5,
                    color: TrainingColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamMemberItem(Map<String, dynamic> member) {
    final isActive = member['status'] == 'نشط';
    final isPending = member['status'] == 'قيد الانتظار';
    final isAdmin = member['roleType'] == 'admin';

    final roleColor = isAdmin ? TrainingColors.primary : TrainingColors.accent;
    final roleBg =
        isAdmin ? TrainingColors.navySoft : TrainingColors.accentSoft;
    final statusColor = isActive
        ? TrainingColors.success
        : isPending
            ? TrainingColors.rating
            : TrainingColors.textMuted;

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: TrainingColors.softShadow,
      ),
      child: Stack(
        children: [
          Positioned(
            top: 0,
            bottom: 0,
            right: 0,
            child: Container(width: 4.w, color: roleColor),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(14.w, 14.h, 18.w, 14.h),
            child: Row(
              children: [
                Container(
                  width: 44.w,
                  height: 44.w,
                  decoration: BoxDecoration(
                    color: roleColor.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _avatarLetters(member['name'] as String),
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w800,
                        color: roleColor,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              member['name'] as String,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.sp,
                                fontWeight: FontWeight.w800,
                                color: TrainingColors.textPrimary,
                              ),
                            ),
                          ),
                          if (isAdmin) ...[
                            SizedBox(width: 6.w),
                            Icon(
                              Icons.verified_rounded,
                              size: 15.sp,
                              color: TrainingColors.primary,
                            ),
                          ],
                        ],
                      ),
                      SizedBox(height: 3.h),
                      Text(
                        member['email'] as String,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 10.5.sp,
                          color: TrainingColors.textMuted,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: roleBg,
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Text(
                        isAdmin ? 'مدير' : 'محرر محتوى',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 9.5.sp,
                          fontWeight: FontWeight.w700,
                          color: roleColor,
                        ),
                      ),
                    ),
                    SizedBox(height: 5.h),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 8.w,
                        vertical: 2.h,
                      ),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(999.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6.w,
                            height: 6.w,
                            decoration: BoxDecoration(
                              color: statusColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            member['status'] as String,
                            style: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 9.sp,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 6.w),
                _memberMenuButton(member, isPending),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _memberMenuButton(Map<String, dynamic> member, bool isPending) {
    return PopupMenuButton<String>(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14.r),
      ),
      color: TrainingColors.surface,
      elevation: 8,
      padding: EdgeInsets.zero,
      onSelected: (value) {
        switch (value) {
          case 'details':
            _showMemberDetails(member);
            break;
          case 'resend':
            _resendInvite(member);
            break;
          case 'remove':
            _showDeleteConfirmDialog(member);
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'details',
          child: Row(
            children: [
              Icon(Icons.visibility_rounded,
                  size: 17.sp, color: TrainingColors.primary),
              SizedBox(width: 8.w),
              Text(
                'عرض التفاصيل',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  color: TrainingColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
        if (isPending)
          PopupMenuItem(
            value: 'resend',
            child: Row(
              children: [
                Icon(Icons.refresh_rounded,
                    size: 17.sp, color: TrainingColors.accent),
                SizedBox(width: 8.w),
                Text(
                  'إعادة إرسال الدعوة',
                  style: TextStyle(
                    fontFamily: 'Cairo',
                    fontSize: 12.sp,
                    color: TrainingColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        PopupMenuItem(
          value: 'remove',
          child: Row(
            children: [
              Icon(Icons.delete_rounded,
                  size: 17.sp, color: TrainingColors.danger),
              SizedBox(width: 8.w),
              Text(
                'إزالة العضو',
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 12.sp,
                  color: TrainingColors.danger,
                ),
              ),
            ],
          ),
        ),
      ],
      child: Container(
        width: 32.w,
        height: 32.w,
        decoration: const BoxDecoration(
          color: TrainingColors.surfaceAlt,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.more_horiz_rounded,
          size: 18.sp,
          color: TrainingColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildEmptyTeamState() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(24.r),
      decoration: BoxDecoration(
        color: TrainingColors.surface,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: TrainingColors.softShadow,
      ),
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.w,
            decoration: const BoxDecoration(
              color: TrainingColors.accentSoft,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.group_add_rounded,
              size: 30.sp,
              color: TrainingColors.accent,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'لا يوجد أعضاء في الفريق',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 15.sp,
              fontWeight: FontWeight.w800,
              color: TrainingColors.textPrimary,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'قم بدعوة زملائك للتعاون في إدارة المركز.',
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              color: TrainingColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  
  
  

  void _showInviteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: StatefulBuilder(
            builder: (dialogContext, setDialogState) {
              return Dialog(
                backgroundColor: TrainingColors.surface,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(20.r),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 40.w,
                            height: 40.w,
                            decoration: const BoxDecoration(
                              color: TrainingColors.accentSoft,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.person_add_rounded,
                              size: 20.sp,
                              color: TrainingColors.accent,
                            ),
                          ),
                          SizedBox(width: 10.w),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'دعوة عضو جديد',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 15.sp,
                                    fontWeight: FontWeight.w800,
                                    color: TrainingColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'سيصل رابط القبول إلى بريده الإلكتروني',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 10.5.sp,
                                    color: TrainingColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        'البريد الإلكتروني',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: TrainingColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w),
                        decoration: BoxDecoration(
                          color: TrainingColors.background,
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: TrainingColors.divider),
                        ),
                        child: TextFormField(
                          controller: _inviteEmailController,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.sp,
                            color: TrainingColors.textPrimary,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            prefixIcon: Icon(
                              Icons.email_rounded,
                              size: 17.sp,
                              color: TrainingColors.primary,
                            ),
                            hintText: 'email@example.com',
                            hintStyle: TextStyle(
                              fontFamily: 'Cairo',
                              fontSize: 12.sp,
                              color: TrainingColors.textMuted,
                            ),
                            border: InputBorder.none,
                            contentPadding:
                                EdgeInsets.symmetric(vertical: 12.h),
                          ),
                          textDirection: TextDirection.ltr,
                        ),
                      ),
                      SizedBox(height: 14.h),
                      Text(
                        'تحديد الصلاحية (الدور)',
                        style: TextStyle(
                          fontFamily: 'Cairo',
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w700,
                          color: TrainingColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Row(
                        children: [
                          _buildRoleOption(
                            label: 'مدير',
                            subtitle: 'صلاحيات كاملة',
                            icon: Icons.admin_panel_settings_rounded,
                            value: 'admin',
                            selectedRole: _selectedRole,
                            onTap: () {
                              setDialogState(() {
                                _selectedRole = 'admin';
                              });
                            },
                          ),
                          SizedBox(width: 10.w),
                          _buildRoleOption(
                            label: 'محرر محتوى',
                            subtitle: 'إدارة المحتوى فقط',
                            icon: Icons.edit_note_rounded,
                            value: 'editor',
                            selectedRole: _selectedRole,
                            onTap: () {
                              setDialogState(() {
                                _selectedRole = 'editor';
                              });
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 20.h),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(dialogContext);
                                _inviteEmailController.clear();
                              },
                              child: Container(
                                height: 46.h,
                                decoration: BoxDecoration(
                                  color: TrainingColors.surfaceAlt,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'إلغاء',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w700,
                                    color: TrainingColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 12.w),
                          Expanded(
                            flex: 2,
                            child: GestureDetector(
                              onTap: () {
                                Navigator.pop(dialogContext);
                                _sendInvitation();
                              },
                              child: Container(
                                height: 46.h,
                                decoration: BoxDecoration(
                                  gradient: TrainingColors.accentGradient,
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                alignment: Alignment.center,
                                child: Text(
                                  'إرسال الدعوة',
                                  style: TextStyle(
                                    fontFamily: 'Cairo',
                                    fontSize: 13.5.sp,
                                    fontWeight: FontWeight.w800,
                                    color: TrainingColors.onAccent,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildRoleOption({
    required String label,
    required String subtitle,
    required IconData icon,
    required String value,
    required String selectedRole,
    required VoidCallback onTap,
  }) {
    final isSelected = selectedRole == value;
    final color =
        value == 'admin' ? TrainingColors.primary : TrainingColors.accent;
    final bg =
        value == 'admin' ? TrainingColors.navySoft : TrainingColors.accentSoft;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: EdgeInsets.all(10.r),
          decoration: BoxDecoration(
            color: isSelected ? bg : TrainingColors.background,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(
              color: isSelected ? color : TrainingColors.divider,
              width: isSelected ? 1.6 : 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                color: isSelected ? color : TrainingColors.textMuted,
                size: 22.sp,
              ),
              SizedBox(height: 4.h),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w800,
                  color: isSelected ? color : TrainingColors.textSecondary,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontFamily: 'Cairo',
                  fontSize: 9.sp,
                  color: TrainingColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  
  

  void _showMemberDetails(Map<String, dynamic> member) {
    final isAdmin = member['roleType'] == 'admin';
    final color = isAdmin ? TrainingColors.primary : TrainingColors.accent;

    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: TrainingColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 64.w,
                      height: 64.w,
                      decoration: BoxDecoration(
                        color: color.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          _avatarLetters(member['name'] as String),
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 20.sp,
                            fontWeight: FontWeight.w800,
                            color: color,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 12.h),
                  Center(
                    child: Text(
                      member['name'] as String,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w800,
                        color: TrainingColors.textPrimary,
                      ),
                    ),
                  ),
                  SizedBox(height: 2.h),
                  Center(
                    child: Text(
                      member['email'] as String,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: 'Cairo',
                        fontSize: 11.5.sp,
                        color: TrainingColors.textMuted,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  _detailRow(
                    icon: Icons.badge_rounded,
                    label: 'الدور',
                    value: isAdmin ? 'مدير (Admin)' : 'محرر محتوى',
                    color: color,
                  ),
                  _detailRow(
                    icon: Icons.toggle_on_rounded,
                    label: 'الحالة',
                    value: member['status'] as String,
                    color: member['status'] == 'نشط'
                        ? TrainingColors.success
                        : TrainingColors.rating,
                  ),
                  _detailRow(
                    icon: Icons.calendar_today_rounded,
                    label: 'تاريخ الانضمام',
                    value: '12 مارس 2025',
                    color: TrainingColors.primary,
                  ),
                  SizedBox(height: 18.h),
                  SizedBox(
                    width: double.infinity,
                    height: 46.h,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(dialogContext),
                      child: Container(
                        decoration: BoxDecoration(
                          color: TrainingColors.surfaceAlt,
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          'إغلاق',
                          style: TextStyle(
                            fontFamily: 'Cairo',
                            fontSize: 13.5.sp,
                            fontWeight: FontWeight.w700,
                            color: TrainingColors.textSecondary,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 8.h),
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: TrainingColors.background,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: TrainingColors.divider),
      ),
      child: Row(
        children: [
          Container(
            width: 34.w,
            height: 34.w,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(9.r),
            ),
            child: Icon(icon, size: 17.sp, color: color),
          ),
          SizedBox(width: 10.w),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.sp,
              fontWeight: FontWeight.w600,
              color: TrainingColors.textMuted,
            ),
          ),
          const Spacer(),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Cairo',
              fontSize: 12.5.sp,
              fontWeight: FontWeight.w700,
              color: TrainingColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmDialog(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: Dialog(
            backgroundColor: TrainingColors.surface,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Padding(
              padding: EdgeInsets.all(20.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 52.w,
                    height: 52.w,
                    decoration: const BoxDecoration(
                      color: TrainingColors.dangerSoft,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.delete_rounded,
                      color: TrainingColors.danger,
                      size: 26.sp,
                    ),
                  ),
                  SizedBox(height: 14.h),
                  Text(
                    'إزالة العضو',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w800,
                      color: TrainingColors.textPrimary,
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    'هل أنت متأكد من رغبتك في إزالة العضو "${member['name']}" من الفريق؟',
                    style: TextStyle(
                      fontFamily: 'Cairo',
                      fontSize: 12.5.sp,
                      color: TrainingColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(dialogContext),
                          child: Container(
                            height: 46.h,
                            decoration: BoxDecoration(
                              color: TrainingColors.surfaceAlt,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'إلغاء',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w700,
                                color: TrainingColors.textSecondary,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            Navigator.pop(dialogContext);
                            setState(() {
                              _teamMembers.removeWhere(
                                (m) => m['email'] == member['email'],
                              );
                            });
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                    'تم إزالة ${member['name']} من الفريق'),
                                backgroundColor: TrainingColors.danger,
                                behavior: SnackBarBehavior.floating,
                                duration: const Duration(seconds: 2),
                              ),
                            );
                          },
                          child: Container(
                            height: 46.h,
                            decoration: BoxDecoration(
                              color: TrainingColors.danger,
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            alignment: Alignment.center,
                            child: Text(
                              'تأكيد الإزالة',
                              style: TextStyle(
                                fontFamily: 'Cairo',
                                fontSize: 13.5.sp,
                                fontWeight: FontWeight.w800,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _saveSettings() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم حفظ التغييرات بنجاح'),
            backgroundColor: TrainingColors.success,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
      }
    });
  }

  void _sendInvitation() {
    final email = _inviteEmailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('الرجاء إدخال البريد الإلكتروني'),
          backgroundColor: TrainingColors.accent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إرسال الدعوة إلى $email'),
        backgroundColor: TrainingColors.success,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
    _inviteEmailController.clear();
    setState(() {
      _selectedRole = 'editor';
    });
  }

  void _resendInvite(Map<String, dynamic> member) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إعادة إرسال الدعوة إلى ${member['email']}'),
        backgroundColor: TrainingColors.primary,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  
  
  

  String _avatarLetters(String name) {
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty) return 'ع';
    if (parts.length == 1) return parts[0].substring(0, 1);
    return '${parts[0].substring(0, 1)}${parts[1].substring(0, 1)}';
  }
}
