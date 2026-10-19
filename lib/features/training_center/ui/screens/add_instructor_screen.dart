import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/instructor_model.dart';
import '../theme/training_colors.dart';

class AddInstructorScreen extends StatefulWidget {
  final bool isEditing;
  final InstructorModel? instructor;

  const AddInstructorScreen({
    super.key,
    this.isEditing = false,
    this.instructor,
  });

  @override
  State<AddInstructorScreen> createState() => _AddInstructorScreenState();
}

class _AddInstructorScreenState extends State<AddInstructorScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _fullNameController;
  late TextEditingController _jobTitleController;
  late TextEditingController _bioController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _experienceController;
  late TextEditingController _linkedinController;

  bool _isActive = true;
  bool _isSubmitting = false;
  String? _cvFileName;
  String? _selectedAvatarUrl;
  final List<String> _certifications = [];

  final List<String> _sampleAvatars = [
    'https://lh3.googleusercontent.com/aida-public/AB6AXuBdnjixUsZFbt61RbTooivxnMvdtXyIkB-K1p_4Y2JNvJDVMJl5HBDAmfLelpqS5OvsbnVZqOm7eivx-dlaLQ3Q7QoIGGUTMVNz0mrmUAQLYd5-fK7vP_0fyA5alF2WTRvu0hJcASQjaXi7hx7ySG4q3uY1GnjrHbV7SxFr5bj54QQkbKwpAo9tr3tFIQiH6CDkLZ0seL8etHUZu2O9Sty5PH5ki4wjS7CTqV6NKEAOHbOIFosHLTIM',
    'https://lh3.googleusercontent.com/aida/AEtjO1X5PiQCuXDe_R10li0XXnAS17LvCrIp1qBgoemYJDSIPLdfj1h1TLP84nxpXYi4KHpJXaf09VsTcp-5pmQiQYnR8V30WBo2F_QSNnQ7tSLwXt2ey24ub-PC7X7ohcxu0teBYL3XPtptEZdiTHNQDYseOAN6RIct6yusbtd8r5wsJO9Ccmt-2LMSIYnnaTXJFCfbL4sKhNma1zi2eJiJvUTdSbwyZyMxCnnz28sQ2ePQMrb_y2qfPuLo8Dk',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCmRZleopdYd8I3_Wb7wXL7BRWJjZrpXPZdkpcQpR2HT5du4xcqxIO-pm-qP8uD1SWuncSZ7DxpbQYNQqPLGWu71z_5XG4YgFIWGMQWYfZp2IK6-38w1Kuz-nn0psalUqu0AegNbjsaPRAYVfdHt1JZ6vXyRmqPsNugPzin7iHrLlDU5gqKfjrU8EnMvLIrJC2Ng3KctKwnNusHKbHi-h7M4FsYOJ5qD4wsayRmIbw6kPmH8Cbjy4Lt',
    'https://lh3.googleusercontent.com/aida-public/AB6AXuCS8jQqrM0oKfmTOUHlKv9OMCaaaVtbytzcIbM1U47K2_kBCyyy1TQwKyddv3dDAS8qsZRdcz22UgRUsOM2-XLs9GjZncS_pHEkDwnvmYEEJEtnL1vTGq3ZQIcxNaWzFo-7NrlGwtW9e_Y2vwH2XC3_StvZQLDyj79jrBAZ7HpbhzZJWYejHEdOH0ROKIK8_T2tEcSoFZQ8G0cXDoMHRyLWuarPfP0PKeoRzn3C22UnYslEPXCfZC5B',
  ];

  @override
  void initState() {
    super.initState();
    final inst = widget.instructor;
    _fullNameController = TextEditingController(text: inst?.name ?? '');
    _jobTitleController = TextEditingController(text: inst?.specialty ?? '');
    _bioController = TextEditingController(text: inst?.bio ?? '');
    _emailController = TextEditingController(text: inst?.email ?? '');
    _phoneController = TextEditingController(text: inst?.phone ?? '');
    _experienceController = TextEditingController(
      text: inst?.experienceYears != null ? '${inst!.experienceYears}' : '',
    );
    _linkedinController = TextEditingController(text: inst?.linkedinUrl ?? '');
    _isActive = inst?.isActive ?? true;
    _selectedAvatarUrl = inst?.avatarUrl;
    if (inst?.certifications != null) {
      _certifications.addAll(inst!.certifications!);
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _jobTitleController.dispose();
    _bioController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _experienceController.dispose();
    _linkedinController.dispose();
    super.dispose();
  }

  void _submitForm() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isSubmitting = true);
    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    final newInstructor = InstructorModel(
      id: widget.instructor?.id ??
          DateTime.now().millisecondsSinceEpoch.toString(),
      name: _fullNameController.text.trim(),
      specialty: _jobTitleController.text.trim(),
      bio: _bioController.text.trim(),
      email: _emailController.text.trim(),
      phone: _phoneController.text.trim(),
      experienceYears: int.tryParse(_experienceController.text.trim()),
      linkedinUrl: _linkedinController.text.trim(),
      isActive: _isActive,
      avatarUrl: _selectedAvatarUrl ?? _sampleAvatars.first,
      certifications: List.from(_certifications),
      rating: widget.instructor?.rating ?? 4.8,
      studentCount: widget.instructor?.studentCount ?? 0,
      coursesCount: widget.instructor?.coursesCount ?? 0,
      isVerified: widget.instructor?.isVerified ?? false,
      createdAt: widget.instructor?.createdAt ?? DateTime.now(),
    );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8.w),
            Text(
              widget.isEditing
                  ? 'تم تحديث بيانات المدرب محلياً'
                  : 'تمت إضافة المدرب محلياً (نسخة تجريبية)',
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Tajawal'),
            ),
          ],
        ),
        backgroundColor: TrainingColors.success,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      ),
    );

    context.pop(newInstructor);
  }

  void _addCertificationDialog() {
    final certController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.workspace_premium_rounded,
                color: TrainingColors.accent, size: 22.sp),
            SizedBox(width: 8.w),
            Text(
              'إضافة شهادة أو اعتماد',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: TrainingColors.primary,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        content: TextField(
          controller: certController,
          autofocus: true,
          decoration: InputDecoration(
            hintText: 'مثال: PMP Certified, CISSP, AWS',
            hintStyle: TextStyle(fontSize: 13.sp, color: Colors.grey.shade400),
            filled: true,
            fillColor: TrainingColors.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              final text = certController.text.trim();
              if (text.isNotEmpty) {
                setState(() => _certifications.add(text));
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: TrainingColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.r)),
            ),
            child: const Text('إضافة'),
          ),
        ],
      ),
    );
  }

  void _pickAvatar() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'اختر صورة المدرب الشخصية',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: TrainingColors.primary,
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 14.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: _sampleAvatars.map((url) {
                return GestureDetector(
                  onTap: () {
                    setState(() => _selectedAvatarUrl = url);
                    Navigator.pop(ctx);
                  },
                  child: Container(
                    padding: EdgeInsets.all(2.r),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: _selectedAvatarUrl == url
                            ? TrainingColors.accent
                            : Colors.transparent,
                        width: 3.w,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: 30.r,
                      backgroundImage: NetworkImage(url),
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }

  void _handleCvPick() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('اختيار الملفات غير متاح في النسخة الحالية'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TrainingColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Form(
          key: _formKey,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildTopHeaderBanner(),
                SizedBox(height: 14.h),
                _buildAvatarSection(),
                SizedBox(height: 14.h),
                _buildBasicInfoSection(),
                SizedBox(height: 14.h),
                _buildContactSection(),
                SizedBox(height: 14.h),
                _buildCredentialsSection(),
                SizedBox(height: 14.h),
                _buildStatusSettingsSection(),
                SizedBox(height: 24.h),
                _buildSubmitButtons(),
                SizedBox(height: 32.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: TrainingColors.surface.withValues(alpha: 0.95),
      elevation: 0,
      centerTitle: false,
      leading: IconButton(
        icon: const Icon(Icons.chevron_right_rounded,
            color: TrainingColors.primary, size: 28),
        onPressed: () => context.pop(),
      ),
      title: Row(
        children: [
          Image.asset(
            'assets/images/logo.png',
            height: 28.h,
            errorBuilder: (context, error, stackTrace) => Container(
              width: 28.w,
              height: 28.h,
              decoration: BoxDecoration(
                color: TrainingColors.primary,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: const Icon(Icons.school_rounded,
                  color: Colors.white, size: 18),
            ),
          ),
          SizedBox(width: 8.w),
          Text(
            widget.isEditing ? 'تعديل بيانات المدرب' : 'إضافة مدرب جديد',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: TrainingColors.primary,
              fontFamily: 'Cairo',
            ),
          ),
        ],
      ),
      actions: [
        Padding(
          padding: EdgeInsets.only(left: 12.w),
          child: CircleAvatar(
            radius: 16.r,
            backgroundColor: TrainingColors.primary,
            child: Icon(Icons.person, size: 18.sp, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildTopHeaderBanner() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: TrainingColors.surfaceAlt,
        borderRadius: BorderRadius.circular(14.r),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(Icons.badge_outlined,
                  color: TrainingColors.accent, size: 24.sp),
              SizedBox(width: 10.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.isEditing
                        ? 'تعديل بيانات المدرب'
                        : 'إضافة مدرب جديد',
                    style: TextStyle(
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                      color: TrainingColors.primary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                  Text(
                    'منشأة شركة التدريب التقني',
                    style: TextStyle(
                      fontSize: 11.sp,
                      color: TrainingColors.textSecondary,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: TrainingColors.primaryContainer.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20.r),
            ),
            child: Text(
              'ملف احترافي',
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: TrainingColors.primary,
                fontFamily: 'Tajawal',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAvatarSection() {
    final hasAvatar =
        _selectedAvatarUrl != null && _selectedAvatarUrl!.isNotEmpty;

    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.softShadow,
      ),
      child: Column(
        children: [
          GestureDetector(
            onTap: _pickAvatar,
            child: Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  width: 96.w,
                  height: 96.h,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: TrainingColors.surfaceAlt,
                    border: Border.all(
                        color: TrainingColors.surfaceMuted, width: 2.w),
                    image: hasAvatar
                        ? DecorationImage(
                            image: NetworkImage(_selectedAvatarUrl!),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: !hasAvatar
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.photo_camera_rounded,
                              color: TrainingColors.accent,
                              size: 32.sp,
                            ),
                            Icon(
                              Icons.add_rounded,
                              color: TrainingColors.primary,
                              size: 16.sp,
                            ),
                          ],
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  child: Container(
                    width: 28.w,
                    height: 28.h,
                    decoration: const BoxDecoration(
                      color: TrainingColors.accent,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12,
                          blurRadius: 4,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Icon(
                      Icons.edit_rounded,
                      color: Colors.white,
                      size: 16.sp,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 10.h),
          Text(
            'أضف صورة المدرب الشخصية',
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
              color: TrainingColors.primary,
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(height: 2.h),
          Text(
            'صيغ مدعومة: JPG أو PNG بحد أقصى 5 ميجابايت',
            style: TextStyle(
              fontSize: 11.sp,
              color: TrainingColors.textSecondary,
              fontFamily: 'Tajawal',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.person_outline_rounded,
                  color: TrainingColors.accent, size: 20.sp),
              SizedBox(width: 6.w),
              Text(
                'البيانات الأساسية للمدرب',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: TrainingColors.primary,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _buildFormField(
            label: 'الاسم الكامل',
            required: true,
            controller: _fullNameController,
            placeholder: 'مثال: د. خالد العتيبي',
            icon: Icons.person_rounded,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'يرجى إدخال الاسم الكامل'
                : null,
          ),
          SizedBox(height: 12.h),
          _buildFormField(
            label: 'التخصص والمسمى المهني',
            required: true,
            controller: _jobTitleController,
            placeholder: 'مثال: خبير ومستشار إدارة المشاريع PMP',
            icon: Icons.school_rounded,
            validator: (v) => v == null || v.trim().isEmpty
                ? 'يرجى إدخال التخصص والمسمى المهني'
                : null,
          ),
          SizedBox(height: 12.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text(
                        'نبذة تعريفية وموجز الخبرات',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: TrainingColors.primary,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      Text(' *',
                          style: TextStyle(color: Colors.red, fontSize: 14.sp)),
                    ],
                  ),
                  ValueListenableBuilder<TextEditingValue>(
                    valueListenable: _bioController,
                    builder: (context, value, child) {
                      return Text(
                        '${value.text.length} / 300',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: TrainingColors.textMuted,
                        ),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: 6.h),
              TextFormField(
                controller: _bioController,
                maxLength: 300,
                maxLines: 3,
                style: TextStyle(fontSize: 13.sp, fontFamily: 'Tajawal'),
                decoration: InputDecoration(
                  counterText: '',
                  hintText:
                      'اكتب نبذة مهنية مختصرة تظهر في صفحة الدورة والمنشأة للمتدربين...',
                  hintStyle:
                      TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
                  filled: true,
                  fillColor: TrainingColors.surfaceAlt,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: EdgeInsets.all(12.r),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? 'يرجى إدخال النبذة التعريفية'
                    : null,
              ),
            ],
          ),
          SizedBox(height: 14.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'السيرة الذاتية (CV)',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: TrainingColors.primary,
                  fontFamily: 'Tajawal',
                ),
              ),
              SizedBox(height: 6.h),
              InkWell(
                onTap: _handleCvPick,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  width: double.infinity,
                  padding:
                      EdgeInsets.symmetric(vertical: 14.h, horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: TrainingColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: _cvFileName != null
                          ? TrainingColors.primary
                          : Colors.transparent,
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: TrainingColors.surfaceMuted,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.upload_file_rounded,
                          color: TrainingColors.primary,
                          size: 22.sp,
                        ),
                      ),
                      SizedBox(height: 6.h),
                      Text(
                        _cvFileName ?? 'انقر لرفع ملف السيرة الذاتية (PDF)',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: TrainingColors.primary,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        'أقصى حجم مسموح: 10 ميجابايت',
                        style: TextStyle(
                          fontSize: 10.sp,
                          color: TrainingColors.textSecondary,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactSection() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.contact_phone_rounded,
                  color: TrainingColors.accent, size: 20.sp),
              SizedBox(width: 6.w),
              Text(
                'بيانات التواصل والاعتماد',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: TrainingColors.primary,
                  fontFamily: 'Cairo',
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _buildFormField(
            label: 'البريد الإلكتروني المهني',
            required: true,
            controller: _emailController,
            placeholder: 'trainer@company.com',
            icon: Icons.alternate_email_rounded,
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.emailAddress,
            validator: (v) {
              if (v == null || v.trim().isEmpty)
                return 'يرجى إدخال البريد الإلكتروني';
              if (!v.contains('@')) return 'يرجى إدخال بريد إلكتروني صحيح';
              return null;
            },
          ),
          SizedBox(height: 12.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'رقم الجوال',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: TrainingColors.primary,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                  Text(' *',
                      style: TextStyle(color: Colors.red, fontSize: 14.sp)),
                ],
              ),
              SizedBox(height: 6.h),
              Container(
                height: 48.h,
                decoration: BoxDecoration(
                  color: TrainingColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w),
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: TrainingColors.surfaceMuted,
                        borderRadius: BorderRadius.only(
                          topRight: Radius.circular(12.r),
                          bottomRight: Radius.circular(12.r),
                        ),
                      ),
                      child: Row(
                        children: [
                          Text('🇸🇦', style: TextStyle(fontSize: 14.sp)),
                          SizedBox(width: 4.w),
                          Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              '+966',
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                                color: TrainingColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        keyboardType: TextInputType.phone,
                        textDirection: TextDirection.ltr,
                        style:
                            TextStyle(fontSize: 13.sp, fontFamily: 'Tajawal'),
                        decoration: InputDecoration(
                          hintText: '5X XXX XXXX',
                          hintStyle: TextStyle(
                              fontSize: 12.sp, color: Colors.grey.shade400),
                          border: InputBorder.none,
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 12.w),
                        ),
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'يرجى إدخال رقم الجوال'
                            : null,
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(left: 10.w),
                      child: Icon(Icons.smartphone_rounded,
                          color: Colors.grey.shade400, size: 20.sp),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCredentialsSection() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.verified_rounded,
                      color: TrainingColors.accent, size: 20.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'البيانات المهنية والتراخيص',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: TrainingColors.primary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                decoration: BoxDecoration(
                  color: TrainingColors.surfaceAlt,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  'اختياري',
                  style: TextStyle(
                      fontSize: 10.sp, color: TrainingColors.textMuted),
                ),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          _buildFormField(
            label: 'سنوات الخبرة العملية',
            required: false,
            controller: _experienceController,
            placeholder: 'مثال: 10 سنوات',
            icon: Icons.timelapse_rounded,
            keyboardType: TextInputType.number,
          ),
          SizedBox(height: 12.h),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الشهادات والاعتمادات المهنية',
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.w600,
                  color: TrainingColors.primary,
                  fontFamily: 'Tajawal',
                ),
              ),
              SizedBox(height: 6.h),
              InkWell(
                onTap: _addCertificationDialog,
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  padding:
                      EdgeInsets.symmetric(vertical: 12.h, horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: TrainingColors.surfaceAlt,
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add_circle_outline_rounded,
                          color: TrainingColors.accent, size: 20.sp),
                      SizedBox(width: 6.w),
                      Text(
                        '+ إضافة شهادة أو رخصة معتمدة',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.w600,
                          color: TrainingColors.primary,
                          fontFamily: 'Tajawal',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              if (_certifications.isNotEmpty) ...[
                SizedBox(height: 8.h),
                Wrap(
                  spacing: 6.w,
                  runSpacing: 6.h,
                  children: _certifications.map((cert) {
                    return Chip(
                      label: Text(
                        cert,
                        style: TextStyle(
                            fontSize: 11.sp, color: TrainingColors.primary),
                      ),
                      backgroundColor: TrainingColors.surfaceMuted,
                      deleteIcon: Icon(Icons.close,
                          size: 14.sp, color: Colors.grey.shade600),
                      onDeleted: () {
                        setState(() => _certifications.remove(cert));
                      },
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r)),
                    );
                  }).toList(),
                ),
              ],
            ],
          ),
          SizedBox(height: 12.h),
          _buildFormField(
            label: 'رابط حساب لينكدإن (LinkedIn)',
            required: false,
            controller: _linkedinController,
            placeholder: 'https://linkedin.com/in/username',
            icon: Icons.link_rounded,
            textDirection: TextDirection.ltr,
            keyboardType: TextInputType.url,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSettingsSection() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: TrainingColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.visibility_rounded,
                      color: TrainingColors.accent, size: 20.sp),
                  SizedBox(width: 6.w),
                  Text(
                    'حالة المدرب: نشط ومتاح (التوثيق يُدار منفصلاً)',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.bold,
                      color: TrainingColors.primary,
                      fontFamily: 'Cairo',
                    ),
                  ),
                ],
              ),
              Switch.adaptive(
                value: _isActive,
                activeThumbColor: TrainingColors.accent,
                activeTrackColor: TrainingColors.accent.withValues(alpha: 0.3),
                onChanged: (val) => setState(() => _isActive = val),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            'عند التفعيل، سيتمكن المتدربون ومسؤولو التسجيل من استعراض ملف المدرب واختيار دوراته المعتمدة على الفور.',
            style: TextStyle(
              fontSize: 11.sp,
              color: TrainingColors.textSecondary,
              fontFamily: 'Tajawal',
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButtons() {
    return Column(
      children: [
        GestureDetector(
          onTap: _isSubmitting ? null : _submitForm,
          child: Container(
            height: 50.h,
            decoration: BoxDecoration(
              gradient: TrainingColors.accentGradient,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: [
                BoxShadow(
                  color: TrainingColors.accent.withValues(alpha: 0.35),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isSubmitting) ...[
                  SizedBox(
                    width: 20.w,
                    height: 20.h,
                    child: const CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  ),
                  SizedBox(width: 10.w),
                ] else ...[
                  Icon(Icons.chevron_left_rounded,
                      color: Colors.white, size: 22.sp),
                  SizedBox(width: 4.w),
                ],
                Text(
                  widget.isEditing
                      ? 'تحديث بيانات المدرب'
                      : 'حفظ بيانات المدرب',
                  style: TextStyle(
                    fontSize: 15.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontFamily: 'Cairo',
                  ),
                ),
              ],
            ),
          ),
        ),
        SizedBox(height: 10.h),
        TextButton(
          onPressed: () => context.pop(),
          child: Text(
            'إلغاء والعودة',
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w600,
              color: TrainingColors.textSecondary,
              fontFamily: 'Tajawal',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required String label,
    required bool required,
    required TextEditingController controller,
    required String placeholder,
    required IconData icon,
    TextDirection textDirection = TextDirection.rtl,
    TextInputType keyboardType = TextInputType.text,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: FontWeight.w600,
                color: TrainingColors.primary,
                fontFamily: 'Tajawal',
              ),
            ),
            if (required)
              Text(' *', style: TextStyle(color: Colors.red, fontSize: 14.sp)),
          ],
        ),
        SizedBox(height: 6.h),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textDirection: textDirection,
          style: TextStyle(fontSize: 13.sp, fontFamily: 'Tajawal'),
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
            prefixIcon: textDirection == TextDirection.rtl
                ? null
                : Icon(icon, color: Colors.grey.shade400, size: 20.sp),
            suffixIcon: textDirection == TextDirection.rtl
                ? Icon(icon, color: Colors.grey.shade400, size: 20.sp)
                : null,
            filled: true,
            fillColor: TrainingColors.surfaceAlt,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.r),
              borderSide: BorderSide.none,
            ),
            contentPadding:
                EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
          ),
          validator: validator,
        ),
      ],
    );
  }
}
