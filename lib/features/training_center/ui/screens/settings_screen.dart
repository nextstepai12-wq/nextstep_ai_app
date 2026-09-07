// lib/features/training_center/ui/screens/settings_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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

  // متغيرات النماذج
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

  // بيانات أعضاء الفريق
  final List<Map<String, dynamic>> _teamMembers = [
    {
      'name': 'أحمد حسن',
      'email': 'ahmed@globaltraining.pro',
      'role': 'مدير (Admin)',
      'roleType': 'admin',
      'status': 'نشط',
      'avatar': 'أح',
    },
    {
      'name': 'سارة محمد',
      'email': 'sara@globaltraining.pro',
      'role': 'محرر محتوى',
      'roleType': 'editor',
      'status': 'نشط',
      'avatar': 'سم',
    },
    {
      'name': 'فيصل القحطاني',
      'email': 'khalid@globaltraining.pro',
      'role': 'محرر محتوى',
      'roleType': 'editor',
      'status': 'قيد الانتظار',
      'avatar': 'في',
    },
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
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
      appBar: _buildAppBar(),
      drawer: const TrainingCenterDrawer(),
      body: _buildBody(),
    );
  }

  // ============================
  //  AppBar
  // ============================
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      leading: IconButton(
        icon: const Icon(Icons.menu_rounded),
        onPressed: () {
          _scaffoldKey.currentState?.openDrawer();
        },
      ),
      title: Row(
        children: [
          Icon(
            Icons.settings_rounded,
            color: Colors.blue.shade700,
            size: 22.sp,
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              'الإعدادات وإدارة الفريق',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.blue.shade900,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(
            Icons.notifications_outlined,
            size: 22.sp,
          ),
          onPressed: () {
            context.push('/training-center/notifications');
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        SizedBox(width: 4.w),
        CircleAvatar(
          radius: 16.r,
          backgroundColor: Colors.grey.shade300,
          child: Icon(
            Icons.person,
            size: 18.sp,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(width: 4.w),
      ],
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.white.withValues(alpha: 0.92),
      bottom: _buildTabBar(),
    );
  }

  // ============================
  //  Tab Bar
  // ============================
  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabs: const [
        Tab(text: 'المركز'),
        Tab(text: 'الفريق'),
      ],
      labelColor: Colors.blue.shade700,
      unselectedLabelColor: Colors.grey.shade600,
      indicatorColor: Colors.blue.shade700,
      indicatorWeight: 3,
      labelStyle: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w400,
      ),
    );
  }

  // ============================
  //  Body
  // ============================
  Widget _buildBody() {
    return TabBarView(
      controller: _tabController,
      children: [
        _buildCenterTab(),
        _buildTeamTab(),
      ],
    );
  }

  // ============================
  //  Center Tab
  // ============================
  Widget _buildCenterTab() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Container(
        padding: EdgeInsets.all(20.r),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade100,
              blurRadius: 8.r,
              offset: Offset(0, 2.h),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('المعلومات القانونية', Icons.gavel_rounded),
            SizedBox(height: 16.h),
            _buildTextField(
              label: 'الاسم القانوني للمركز',
              controller: _centerNameController,
              icon: Icons.business_rounded,
            ),
            SizedBox(height: 16.h),
            _buildRegistrationField(),
            SizedBox(height: 24.h),
            _buildSectionHeader('معلومات الاتصال', Icons.contact_phone_rounded),
            SizedBox(height: 16.h),
            _buildTextField(
              label: 'البريد الإلكتروني الرسمي',
              controller: _emailController,
              icon: Icons.email_rounded,
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16.h),
            _buildTextField(
              label: 'رقم الهاتف الرسمي',
              controller: _phoneController,
              icon: Icons.phone_rounded,
              keyboardType: TextInputType.phone,
            ),
            SizedBox(height: 24.h),
            _buildSectionHeader('الأمان', Icons.security_rounded),
            SizedBox(height: 16.h),
            _buildPasswordField(),
            SizedBox(height: 24.h),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  // ============================
  //  Team Tab
  // ============================
Widget _buildTeamTab() {
  return SingleChildScrollView(
    padding: EdgeInsets.all(12.r),
    physics: const BouncingScrollPhysics(),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ رأس إدارة الأعضاء (محسن)
        Container(
          padding: EdgeInsets.all(12.r),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 6.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'إدارة الأعضاء',
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      'المدير يرى كل شيء، بينما محرر المحتوى يرى الدورات والطلاب فقط.',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              // ✅ زر دعوة عضو جديد
              SizedBox(
                width: 120.w,
                height: 36.h,
                child: ElevatedButton.icon(
                  onPressed: _showInviteDialog,
                  icon: Icon(Icons.person_add_rounded, size: 14.sp),
                  label: Text(
                    'دعوة عضو',
                    style: TextStyle(fontSize: 10.sp),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue.shade700,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 6.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 12.h),

        // ✅ قائمة الأعضاء
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14.r),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade100,
                blurRadius: 6.r,
                offset: Offset(0, 2.h),
              ),
            ],
          ),
          child: _teamMembers.isEmpty
              ? _buildEmptyTeamState()
              : Column(
                  children: _teamMembers.map((member) {
                    return _buildTeamMemberItem(member);
                  }).toList(),
                ),
        ),
      ],
    ),
  );
}
  // ============================
  //  Widgets Helpers
  // ============================

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: Colors.blue.shade700,
          size: 20.sp,
        ),
        SizedBox(width: 8.w),
        Text(
          title,
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
        const Spacer(),
        Container(
          width: 40.w,
          height: 1,
          color: Colors.grey.shade200,
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: controller,
            readOnly: readOnly,
            keyboardType: keyboardType,
            style: TextStyle(
              fontSize: 14.sp,
              color: readOnly ? Colors.grey.shade600 : Colors.grey.shade800,
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(
                icon,
                color: Colors.blue.shade700,
                size: 20.sp,
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
            textDirection: TextDirection.rtl,
          ),
        ),
        if (readOnly)
          Padding(
            padding: EdgeInsets.only(top: 4.h),
            child: Text(
              'ملاحظة: تعديل هذا الحقل يتطلب مراجعة وموافقة من الإدارة.',
              style: TextStyle(
                fontSize: 11.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRegistrationField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'رقم الترخيص (التسجيل)',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.blue.shade200),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_rounded,
                color: Colors.blue.shade700,
                size: 20.sp,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _registrationController.text,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500,
                        color: Colors.grey.shade800,
                      ),
                    ),
                    Text(
                      'ملاحظة: تعديل رقم الترخيص يتطلب مراجعة وموافقة من الإدارة.',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'تغيير كلمة المرور',
          style: TextStyle(
            fontSize: 13.sp,
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 6.h),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextFormField(
            controller: _passwordController,
            obscureText: !_showPassword,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade800,
            ),
            decoration: InputDecoration(
              hintText: 'كلمة المرور الجديدة',
              hintStyle: TextStyle(
                fontSize: 14.sp,
                color: Colors.grey.shade400,
              ),
              prefixIcon: Icon(
                Icons.lock_rounded,
                color: Colors.blue.shade700,
                size: 20.sp,
              ),
              suffixIcon: IconButton(
                icon: Icon(
                  _showPassword ? Icons.visibility_rounded : Icons.visibility_off_rounded,
                  color: Colors.grey.shade500,
                  size: 20.sp,
                ),
                onPressed: () {
                  setState(() {
                    _showPassword = !_showPassword;
                  });
                },
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
            ),
            textDirection: TextDirection.ltr,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveSettings,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue.shade700,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 14.h),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10.r),
          ),
        ),
        child: _isLoading
            ? SizedBox(
                height: 20.h,
                width: 20.w,
                child: const CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : Text(
                'حفظ التغييرات',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

Widget _buildTeamMemberItem(Map<String, dynamic> member) {
  final isActive = member['status'] == 'نشط';
  final isPending = member['status'] == 'قيد الانتظار';
  final isAdmin = member['roleType'] == 'admin';

  return Container(
    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
    decoration: BoxDecoration(
      border: Border(
        bottom: BorderSide(color: Colors.grey.shade100),
      ),
    ),
    child: Row(
      children: [
        // ✅ الصورة الرمزية
        Container(
          width: 32.w,
          height: 32.h,
          decoration: BoxDecoration(
            color: isAdmin ? Colors.blue.shade100 : Colors.grey.shade200,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Center(
            child: Text(
              member['avatar'] ?? 'ع',
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.bold,
                color: isAdmin ? Colors.blue.shade700 : Colors.grey.shade700,
              ),
            ),
          ),
        ),
        SizedBox(width: 8.w),

        // ✅ معلومات العضو
        Expanded(
          flex: 2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member['name'] ?? 'عضو',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                member['email'] ?? 'email@example.com',
                style: TextStyle(
                  fontSize: 9.sp,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        SizedBox(width: 6.w),

        // ✅ الدور
        Flexible(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
            decoration: BoxDecoration(
              color: isAdmin ? Colors.blue.shade50 : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8.r),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isAdmin ? Icons.admin_panel_settings_rounded : Icons.edit_note_rounded,
                  size: 10.sp,
                  color: isAdmin ? Colors.blue.shade700 : Colors.grey.shade600,
                ),
                SizedBox(width: 2.w),
                Text(
                  isAdmin ? 'مدير' : 'محرر',
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: isAdmin ? Colors.blue.shade700 : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ),
        SizedBox(width: 4.w),

        // ✅ الحالة
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 4.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: isActive
                    ? Colors.green.shade700
                    : isPending
                        ? Colors.amber.shade700
                        : Colors.grey.shade500,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: 2.w),
            Text(
              isActive ? 'نشط' : (isPending ? 'قيد الانتظار' : ''),
              style: TextStyle(
                fontSize: 8.sp,
                color: isActive
                    ? Colors.green.shade700
                    : isPending
                        ? Colors.amber.shade700
                        : Colors.grey.shade500,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),

        // ✅ زر الحذف
        IconButton(
          onPressed: () {
            _showDeleteConfirmDialog(member);
          },
          icon: Icon(
            Icons.delete_rounded,
            color: Colors.red.shade400,
            size: 16.sp,
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
      ],
    ),
  );
}

Widget _buildEmptyTeamState() {
  return Container(
    padding: EdgeInsets.all(30.r),
    child: Column(
      children: [
        Icon(
          Icons.group_add_rounded,
          size: 56.sp,
          color: Colors.grey.shade300,
        ),
        SizedBox(height: 12.h),
        Text(
          'لا يوجد أعضاء في الفريق',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
        SizedBox(height: 6.h),
        Text(
          'قم بدعوة زملائك للتعاون في إدارة المركز.',
          style: TextStyle(
            fontSize: 12.sp,
            color: Colors.grey.shade500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 12.h),
        SizedBox(
          width: 140.w,
          height: 40.h,
          child: ElevatedButton.icon(
            onPressed: _showInviteDialog,
            icon: Icon(Icons.person_add_rounded, size: 14.sp),
            label: Text(
              'دعوة أول عضو',
              style: TextStyle(fontSize: 11.sp),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 8.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ),
      ],
    ),
  );
}
  // ============================
  //  Dialogs
  // ============================

 void _showInviteDialog() {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: Row(
              children: [
                Icon(
                  Icons.person_add_rounded,
                  color: Colors.blue.shade700,
                  size: 20.sp,
                ),
                SizedBox(width: 6.w),
                Text(
                  'دعوة عضو جديد',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'البريد الإلكتروني',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 4.h),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextFormField(
                    controller: _inviteEmailController,
                    keyboardType: TextInputType.emailAddress,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade800,
                    ),
                    decoration: InputDecoration(
                      hintText: 'email@example.com',
                      hintStyle: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade400,
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    ),
                    textDirection: TextDirection.ltr,
                  ),
                ),
                SizedBox(height: 12.h),
                Text(
                  'تحديد الصلاحية (الدور)',
                  style: TextStyle(
                    fontSize: 12.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade700,
                  ),
                ),
                SizedBox(height: 6.h),
                // ✅ Row مع Expanded - مسافات أقل
                Row(
                  children: [
                    _buildRoleOption(
                      label: 'مدير',
                      subtitle: 'صلاحيات كاملة',
                      icon: Icons.admin_panel_settings_rounded,
                      value: 'admin',
                      selectedRole: _selectedRole,
                      onTap: () {
                        setState(() {
                          _selectedRole = 'admin';
                        });
                      },
                    ),
                    SizedBox(width: 8.w),
                    _buildRoleOption(
                      label: 'محرر محتوى',
                      subtitle: 'إدارة المحتوى فقط',
                      icon: Icons.edit_note_rounded,
                      value: 'editor',
                      selectedRole: _selectedRole,
                      onTap: () {
                        setState(() {
                          _selectedRole = 'editor';
                        });
                      },
                    ),
                  ],
                ),
              ],
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14.r),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  _inviteEmailController.clear();
                },
                child: Text(
                  'إلغاء',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
                ),
              ),
              ElevatedButton(
                onPressed: _sendInvitation,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue.shade700,
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6.r),
                  ),
                ),
                child: Text(
                  'إرسال الدعوة',
                  style: TextStyle(fontSize: 12.sp),
                ),
              ),
            ],
          );
        },
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
  return Expanded(
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(8.r),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.shade50 : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8.r),
          border: Border.all(
            color: isSelected ? Colors.blue.shade700 : Colors.grey.shade200,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.blue.shade700 : Colors.grey.shade600,
              size: 20.sp,
            ),
            SizedBox(height: 2.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 11.sp,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue.shade700 : Colors.grey.shade700,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: 8.sp,
                color: Colors.grey.shade500,
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

  void _showDeleteConfirmDialog(Map<String, dynamic> member) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف عضو'),
          content: Text(
            'هل أنت متأكد من رغبتك في حذف العضو "${member['name']}"؟',
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إلغاء',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('تم حذف العضو ${member['name']} ✅'),
                    backgroundColor: Colors.red.shade700,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: const Text('تأكيد الحذف'),
            ),
          ],
        );
      },
    );
  }

  // ============================
  //  Actions
  // ============================

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
            content: Text('تم حفظ التغييرات بنجاح ✅'),
            backgroundColor: Colors.green,
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
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم إرسال الدعوة إلى $email 📧'),
        backgroundColor: Colors.green,
      ),
    );
    _inviteEmailController.clear();
    setState(() {
      _selectedRole = 'editor';
    });
  }
}