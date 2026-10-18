import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import '../../data/models/instructor_model.dart';
import '../theme/training_colors.dart';
import '../widgets/training_center_drawer.dart';

class InstructorsScreen extends StatefulWidget {
  const InstructorsScreen({super.key});

  @override
  State<InstructorsScreen> createState() => _InstructorsScreenState();
}

class _InstructorsScreenState extends State<InstructorsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();

  String _searchQuery = '';
  String _selectedStatusFilter = 'all'; // 'all', 'active', 'inactive'

  // Initial list of trainers matching the provided HTML mock data
  final List<InstructorModel> _instructors = [
    const InstructorModel(
      id: '1',
      name: 'د. خالد العتيبي',
      specialty: 'مدرب معتمد — إدارة المشاريع الاحترافية PMP',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida/AEtjO1X5PiQCuXDe_R10li0XXnAS17LvCrIp1qBgoemYJDSIPLdfj1h1TLP84nxpXYi4KHpJXaf09VsTcp-5pmQiQYnR8V30WBo2F_QSNnQ7tSLwXt2ey24ub-PC7X7ohcxu0teBYL3XPtptEZdiTHNQDYseOAN6RIct6yusbtd8r5wsJO9Ccmt-2LMSIYnnaTXJFCfbL4sKhNma1zi2eJiJvUTdSbwyZyMxCnnz28sQ2ePQMrb_y2qfPuLo8Dk',
      rating: 4.8,
      studentCount: 320,
      coursesCount: 5,
      isVerified: true,
      isActive: true,
      email: 'khaled@training.sa',
      phone: '501234567',
    ),
    const InstructorModel(
      id: '2',
      name: 'م. عبد العزيز الشمري',
      specialty: 'خبير ومستشار الأمن السيبراني واختبار الاختراق',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCmRZleopdYd8I3_Wb7wXL7BRWJjZrpXPZdkpcQpR2HT5du4xcqxIO-pm-qP8uD1SWuncSZ7DxpbQYNQqPLGWu71z_5XG4YgFIWGMQWYfZp2IK6-38w1Kuz-nn0psalUqu0AegNbjsaPRAYVfdHt1JZ6vXyRmqPsNugPzin7iHrLlDU5gqKfjrU8EnMvLIrJC2Ng3KctKwnNusHKbHi-h7M4FsYOJ5qD4wsayRmIbw6kPmH8Cbjy4Lt',
      rating: 4.9,
      studentCount: 410,
      coursesCount: 4,
      isVerified: true,
      isActive: true,
      email: 'abdulaziz@training.sa',
      phone: '502345678',
    ),
    const InstructorModel(
      id: '3',
      name: 'أ. نورة القحطاني',
      specialty: 'أخصائية تصميم البرامج التدريبية وتحليل البيانات',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuCS8jQqrM0oKfmTOUHlKv9OMCaaaVtbytzcIbM1U47K2_kBCyyy1TQwKyddv3dDAS8qsZRdcz22UgRUsOM2-XLs9GjZncS_pHEkDwnvmYEEJEtnL1vTGq3ZQIcxNaWzFo-7NrlGwtW9e_Y2vwH2XC3_StvZQLDyj79jrBAZ7HpbhzZJWYejHEdOH0ROKIK8_T2tEcSoFZQ8G0cXDoMHRyLWuarPfP0PKeoRzn3C22UnYslEPXCfZC5B',
      rating: 4.9,
      studentCount: 215,
      coursesCount: 3,
      isVerified: true,
      isActive: true,
      email: 'noura@training.sa',
      phone: '503456789',
    ),
    const InstructorModel(
      id: '4',
      name: 'م. فيصل الدوسري',
      specialty: 'مدرب معتمد — الصيانة الصناعية وخطوط الإنتاج',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida-public/AB6AXuBdnjixUsZFbt61RbTooivxnMvdtXyIkB-K1p_4Y2JNvJDVMJl5HBDAmfLelpqS5OvsbnVZqOm7eivx-dlaLQ3Q7QoIGGUTMVNz0mrmUAQLYd5-fK7vP_0fyA5alF2WTRvu0hJcASQjaXi7hx7ySG4q3uY1GnjrHbV7SxFr5bj54QQkbKwpAo9tr3tFIQiH6CDkLZ0seL8etHUZu2O9Sty5PH5ki4wjS7CTqV6NKEAOHbOIFosHLTIM',
      rating: 4.7,
      studentCount: 145,
      coursesCount: 2,
      isVerified: false,
      isActive: false,
      email: 'faisal@training.sa',
      phone: '504567890',
    ),
    const InstructorModel(
      id: '5',
      name: 'د. سلطان القحطاني',
      specialty: 'استشاري إدارة وضبط جودة المشاريع الإنشائية',
      avatarUrl:
          'https://lh3.googleusercontent.com/aida/AEtjO1X5PiQCuXDe_R10li0XXnAS17LvCrIp1qBgoemYJDSIPLdfj1h1TLP84nxpXYi4KHpJXaf09VsTcp-5pmQiQYnR8V30WBo2F_QSNnQ7tSLwXt2ey24ub-PC7X7ohcxu0teBYL3XPtptEZdiTHNQDYseOAN6RIct6yusbtd8r5wsJO9Ccmt-2LMSIYnnaTXJFCfbL4sKhNma1zi2eJiJvUTdSbwyZyMxCnnz28sQ2ePQMrb_y2qfPuLo8Dk',
      rating: 4.7,
      studentCount: 95,
      coursesCount: 2,
      isVerified: true,
      isActive: true,
      email: 'sultan@training.sa',
      phone: '505678901',
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  int get _totalCount => _instructors.length;
  int get _activeCount => _instructors.where((i) => i.isActive).length;
  int get _inactiveCount => _instructors.where((i) => !i.isActive).length;

  List<InstructorModel> get _filteredInstructors {
    return _instructors.where((instructor) {
      final matchesQuery = _searchQuery.isEmpty ||
          instructor.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          (instructor.specialty ?? '').toLowerCase().contains(_searchQuery.toLowerCase());

      if (_selectedStatusFilter == 'active') {
        return matchesQuery && instructor.isActive;
      } else if (_selectedStatusFilter == 'inactive') {
        return matchesQuery && !instructor.isActive;
      }
      return matchesQuery;
    }).toList();
  }

  void _navigateToAddTrainer([InstructorModel? instructorToEdit]) async {
    final result = await context.push<InstructorModel>(
      '/training-center/instructors/add',
      extra: instructorToEdit,
    );

    if (result != null) {
      setState(() {
        final existingIndex = _instructors.indexWhere((i) => i.id == result.id);
        if (existingIndex >= 0) {
          _instructors[existingIndex] = result;
        } else {
          _instructors.insert(0, result);
        }
      });
    }
  }

  void _openTrainerOptionsModal(InstructorModel instructor) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24.r)),
            boxShadow: const [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 20,
                offset: Offset(0, -4),
              ),
            ],
          ),
          padding: EdgeInsets.all(20.r),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle bar
              Container(
                width: 48.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Container(
                    width: 44.w,
                    height: 44.h,
                    decoration: BoxDecoration(
                      color: TrainingColors.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.manage_accounts_rounded,
                      color: TrainingColors.primary,
                      size: 24.sp,
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          instructor.name,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: TrainingColors.primary,
                            fontFamily: 'Cairo',
                          ),
                        ),
                        Text(
                          'تحديث الصلاحيات، الجدول، أو حالة العمل',
                          style: TextStyle(
                            fontSize: 11.sp,
                            color: TrainingColors.textSecondary,
                            fontFamily: 'Tajawal',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.h),

              // Option 1: Edit profile
              _buildModalOption(
                icon: Icons.edit_rounded,
                iconColor: TrainingColors.primary,
                title: 'تعديل الملف المهني والبيانات',
                onTap: () {
                  Navigator.pop(ctx);
                  _navigateToAddTrainer(instructor);
                },
              ),
              SizedBox(height: 8.h),

              // Option 2: Toggle Active Status / Vacation
              _buildModalOption(
                icon: Icons.pause_circle_rounded,
                iconColor: TrainingColors.accent,
                title: instructor.isActive ? 'تعطيل مؤقت / تعيين كإجازة' : 'إعادة التفعيل والعمل',
                onTap: () {
                  Navigator.pop(ctx);
                  setState(() {
                    final index = _instructors.indexWhere((i) => i.id == instructor.id);
                    if (index >= 0) {
                      _instructors[index] = instructor.copyWith(isActive: !instructor.isActive);
                    }
                  });
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        instructor.isActive
                            ? 'تم تعيين المدرب كإجازة / غير نشط'
                            : 'تم إعادة تفعيل المدرب بنجاح',
                      ),
                      backgroundColor: TrainingColors.primary,
                      duration: const Duration(seconds: 2),
                    ),
                  );
                },
              ),
              SizedBox(height: 8.h),

              // Option 3: Schedule
              _buildModalOption(
                icon: Icons.calendar_month_rounded,
                iconColor: Colors.blue.shade700,
                title: 'جدول المحاضرات والارتباطات',
                onTap: () {
                  Navigator.pop(ctx);
                  _showScheduleDialog(instructor);
                },
              ),
              SizedBox(height: 8.h),

              // Option 4: Delete Trainer
              _buildModalOption(
                icon: Icons.delete_rounded,
                iconColor: Colors.red,
                title: 'حذف المدرب من المنظومة',
                textColor: Colors.red,
                backgroundColor: Colors.red.shade50,
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDeleteTrainer(instructor);
                },
              ),
              SizedBox(height: 16.h),

              // Cancel button
              SizedBox(
                width: double.infinity,
                height: 46.h,
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(ctx),
                  style: OutlinedButton.styleFrom(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    'إلغاء',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: TrainingColors.textSecondary,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        );
      },
    );
  }

  Widget _buildModalOption({
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
    Color? backgroundColor,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        height: 48.h,
        padding: EdgeInsets.symmetric(horizontal: 14.w),
        decoration: BoxDecoration(
          color: backgroundColor ?? TrainingColors.surfaceAlt,
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            Icon(icon, color: iconColor, size: 22.sp),
            SizedBox(width: 12.w),
            Text(
              title,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: textColor ?? TrainingColors.textPrimary,
                fontFamily: 'Tajawal',
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteTrainer(InstructorModel instructor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Text(
          'تأكيد حذف المدرب',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.red,
            fontFamily: 'Cairo',
          ),
        ),
        content: Text(
          'هل أنت تأكد من رغبتك في حذف المدرب (${instructor.name}) نهائياً من المنظومة؟',
          style: TextStyle(fontSize: 13.sp, fontFamily: 'Tajawal'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('إلغاء'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _instructors.removeWhere((i) => i.id == instructor.id);
              });
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('تم حذف المدرب (${instructor.name}) بنجاح'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
            ),
            child: const Text('حذف'),
          ),
        ],
      ),
    );
  }

  void _showScheduleDialog(InstructorModel instructor) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        title: Row(
          children: [
            Icon(Icons.calendar_month_rounded, color: TrainingColors.primary, size: 22.sp),
            SizedBox(width: 8.w),
            Text(
              'جدول المحاضرات — ${instructor.name}',
              style: TextStyle(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
                color: TrainingColors.primary,
                fontFamily: 'Cairo',
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildScheduleRow('الأحد والثلاثاء', '05:00 م - 08:00 م', 'دورة PMP المتقدمة'),
            SizedBox(height: 8.h),
            _buildScheduleRow('الاثنين والأربعاء', '06:30 م - 09:30 م', 'ورشة عمل تحليل البيانات'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(
              backgroundColor: TrainingColors.primary,
              foregroundColor: Colors.white,
            ),
            child: const Text('إغلاق'),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleRow(String days, String time, String course) {
    return Container(
      padding: EdgeInsets.all(10.r),
      decoration: BoxDecoration(
        color: TrainingColors.surfaceAlt,
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(course, style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold, color: TrainingColors.primary)),
          SizedBox(height: 2.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(days, style: TextStyle(fontSize: 11.sp, color: TrainingColors.textSecondary)),
              Text(time, style: TextStyle(fontSize: 11.sp, color: TrainingColors.accent, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }

  void _openFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20.r))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.all(20.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'تصفية نتائج المدربين',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: TrainingColors.primary,
                fontFamily: 'Cairo',
              ),
            ),
            SizedBox(height: 14.h),
            ListTile(
              leading: const Icon(Icons.star_rounded, color: TrainingColors.rating),
              title: const Text('الأعلى تقييماً (4.8+)'),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _searchQuery = '';
                  _selectedStatusFilter = 'all';
                });
              },
            ),
            ListTile(
              leading: const Icon(Icons.verified_rounded, color: Colors.blue),
              title: const Text('المدربين المعتمدين والموثقين فقط'),
              onTap: () {
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filteredList = _filteredInstructors;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: TrainingColors.background,
      drawer: const TrainingCenterDrawer(),
      body: Stack(
        children: [
          Column(
            children: [
              SizedBox(height: MediaQuery.of(context).padding.top),
              _buildSubHeader(),
              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.symmetric(horizontal: 16.w),
                  child: Column(
                    children: [
                      SizedBox(height: 8.h),
                      _buildSearchAndFilterBar(),
                      SizedBox(height: 12.h),
                      _buildSummaryStripCard(),
                      SizedBox(height: 14.h),
                      if (filteredList.isEmpty)
                        _buildEmptyResultsState()
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: filteredList.length,
                          separatorBuilder: (context, index) => SizedBox(height: 12.h),
                          itemBuilder: (context, index) {
                            final trainer = filteredList[index];
                            return _buildTrainerCard(trainer);
                          },
                        ),
                      SizedBox(height: 80.h), // Space for floating bottom button
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Pinned Floating Bottom Action Button matching HTML layout
          Positioned(
            left: 16.w,
            right: 16.w,
            bottom: 12.h,
            child: SafeArea(
              child: GestureDetector(
                onTap: () => _navigateToAddTrainer(),
                child: Container(
                  height: 50.h,
                  decoration: BoxDecoration(
                    gradient: TrainingColors.accentGradient,
                    borderRadius: BorderRadius.circular(14.r),
                    boxShadow: [
                      BoxShadow(
                        color: TrainingColors.accent.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_add_rounded, color: Colors.white, size: 22.sp),
                      SizedBox(width: 8.w),
                      Text(
                        '+ إضافة مدرب جديد',
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubHeader() {
    return Padding(
      padding: EdgeInsets.fromLTRB(16.w, 12.h, 16.w, 4.h),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.pop(),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: TrainingColors.softShadow,
              ),
              child: const Icon(Icons.chevron_right_rounded, color: TrainingColors.primary, size: 24),
            ),
          ),
          SizedBox(width: 10.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'إدارة المدربين',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                    color: TrainingColors.primary,
                    fontFamily: 'Cairo',
                  ),
                ),
                Text(
                  'الكادر الأكاديمي والتدريبي المعتمد',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: TrainingColors.textSecondary,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          InkWell(
            onTap: () => _navigateToAddTrainer(),
            borderRadius: BorderRadius.circular(20.r),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: TrainingColors.accentSoft,
                borderRadius: BorderRadius.circular(20.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.person_add_rounded, color: TrainingColors.accent, size: 16.sp),
                  SizedBox(width: 4.w),
                  Text(
                    '+ إضافة مدرب',
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      color: TrainingColors.accent,
                      fontFamily: 'Tajawal',
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(width: 8.w),
          GestureDetector(
            onTap: () => _scaffoldKey.currentState?.openDrawer(),
            child: Container(
              width: 40.w,
              height: 40.h,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: TrainingColors.softShadow,
              ),
              child: const Icon(Icons.menu_rounded, color: TrainingColors.primary, size: 22),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback(String name) {
    return Container(
      color: TrainingColors.surfaceAlt,
      alignment: Alignment.center,
      child: Text(
        name.trim().isNotEmpty ? name.trim().substring(0, 1) : 'ع',
        style: TextStyle(
          fontSize: 18.sp,
          fontWeight: FontWeight.bold,
          color: TrainingColors.primary,
          fontFamily: 'Cairo',
        ),
      ),
    );
  }

  Widget _buildSearchAndFilterBar() {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 46.h,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14.r),
              boxShadow: TrainingColors.softShadow,
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (val) {
                setState(() => _searchQuery = val);
              },
              style: TextStyle(fontSize: 13.sp, fontFamily: 'Tajawal'),
              decoration: InputDecoration(
                hintText: 'ابحث عن مدرب بالاسم أو التخصص...',
                hintStyle: TextStyle(fontSize: 12.sp, color: Colors.grey.shade400),
                prefixIcon: Icon(Icons.search_rounded, color: Colors.grey.shade400, size: 20.sp),
                border: InputBorder.none,
                contentPadding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
              ),
            ),
          ),
        ),
        SizedBox(width: 10.w),
        GestureDetector(
          onTap: _openFilterBottomSheet,
          child: Container(
            width: 46.w,
            height: 46.h,
            decoration: BoxDecoration(
              color: TrainingColors.surfaceMuted,
              borderRadius: BorderRadius.circular(14.r),
            ),
            child: Icon(Icons.tune_rounded, color: TrainingColors.primary, size: 22.sp),
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryStripCard() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: TrainingColors.surfaceAlt,
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 10.w,
                    height: 10.h,
                    decoration: const BoxDecoration(
                      color: TrainingColors.success,
                      shape: BoxShape.circle,
                    ),
                  ),
                  SizedBox(width: 6.w),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: TrainingColors.textPrimary,
                        fontFamily: 'Tajawal',
                      ),
                      children: [
                        const TextSpan(text: 'لديك '),
                        TextSpan(
                          text: '$_totalCount مدرب',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: TrainingColors.primary,
                          ),
                        ),
                        const TextSpan(text: ' مسجلين'),
                      ],
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  _buildStatusDotCount(TrainingColors.success, '$_activeCount نشط'),
                  SizedBox(width: 8.w),
                  _buildStatusDotCount(Colors.grey.shade400, '$_inactiveCount غير نشط'),
                ],
              ),
            ],
          ),
          SizedBox(height: 12.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: [
                _buildFilterTab('all', 'الكل ($_totalCount)'),
                SizedBox(width: 8.w),
                _buildFilterTab('active', 'نشط ($_activeCount)'),
                SizedBox(width: 8.w),
                _buildFilterTab('inactive', 'غير نشط ($_inactiveCount)'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusDotCount(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 8.w,
          height: 8.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(fontSize: 11.sp, color: TrainingColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildFilterTab(String key, String label) {
    final isSelected = _selectedStatusFilter == key;
    return GestureDetector(
      onTap: () => setState(() => _selectedStatusFilter = key),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: isSelected ? TrainingColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(20.r),
          boxShadow: isSelected ? TrainingColors.softShadow : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12.sp,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
            color: isSelected ? Colors.white : TrainingColors.textSecondary,
            fontFamily: 'Tajawal',
          ),
        ),
      ),
    );
  }

  Widget _buildTrainerCard(InstructorModel instructor) {
    final isActive = instructor.isActive;

    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: isActive ? TrainingColors.cardShadow : TrainingColors.softShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with status dot
              Stack(
                children: [
                  Container(
                    width: 56.w,
                    height: 56.w,
                    clipBehavior: Clip.antiAlias,
                    alignment: Alignment.center,
                    decoration: const BoxDecoration(
                      color: TrainingColors.surfaceAlt,
                      shape: BoxShape.circle,
                    ),
                    child: instructor.avatarUrl != null &&
                            instructor.avatarUrl!.isNotEmpty
                        ? Image.network(
                            instructor.avatarUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _avatarFallback(
                              instructor.name,
                            ),
                          )
                        : _avatarFallback(instructor.name),
                  ),
                  Positioned(
                    bottom: 0,
                    left: 0,
                    child: Container(
                      width: 14.w,
                      height: 14.h,
                      decoration: BoxDecoration(
                        color: isActive ? TrainingColors.success : Colors.grey.shade400,
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2.w),
                      ),
                    ),
                  ),
                ],
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
                            instructor.name,
                            style: TextStyle(
                              fontSize: 15.sp,
                              fontWeight: FontWeight.bold,
                              color: isActive ? TrainingColors.primary : Colors.grey.shade700,
                              fontFamily: 'Cairo',
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (instructor.isVerified) ...[
                          SizedBox(width: 4.w),
                          Icon(
                            Icons.verified_rounded,
                            color: Colors.blue.shade600,
                            size: 18.sp,
                          ),
                        ],
                      ],
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      instructor.specialty ?? 'مدرب معتمد',
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: isActive ? TrainingColors.textSecondary : Colors.grey.shade500,
                        fontFamily: 'Tajawal',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.more_vert_rounded, color: TrainingColors.textMuted),
                onPressed: () => _openTrainerOptionsModal(instructor),
              ),
            ],
          ),
          SizedBox(height: 12.h),

          // Metrics strip
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  _buildMetricItem(Icons.menu_book_rounded, '${instructor.coursesCount ?? 3} دورات'),
                  SizedBox(width: 12.w),
                  _buildMetricItem(Icons.group_rounded, '${instructor.studentCount ?? 150} طالب'),
                  SizedBox(width: 12.w),
                  Row(
                    children: [
                      const Icon(Icons.star_rounded, color: TrainingColors.rating, size: 16),
                      SizedBox(width: 2.w),
                      Text(
                        '${instructor.rating ?? 4.8}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: TrainingColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isActive ? TrainingColors.successSoft : Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(20.r),
                ),
                child: Text(
                  isActive ? 'نشط حالياً' : 'غير نشط / إجازة',
                  style: TextStyle(
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                    color: isActive ? TrainingColors.success : Colors.grey.shade600,
                    fontFamily: 'Tajawal',
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMetricItem(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, color: TrainingColors.primaryContainer, size: 15.sp),
        SizedBox(width: 4.w),
        Text(
          label,
          style: TextStyle(
            fontSize: 11.sp,
            color: TrainingColors.textSecondary,
            fontFamily: 'Tajawal',
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyResultsState() {
    return Container(
      padding: EdgeInsets.all(32.r),
      child: Column(
        children: [
          Container(
            width: 64.w,
            height: 64.h,
            decoration: BoxDecoration(
              color: TrainingColors.surfaceAlt,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.person_search_rounded,
              color: TrainingColors.textMuted,
              size: 32.sp,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'لا توجد نتائج مطابقة',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: TrainingColors.primary,
              fontFamily: 'Cairo',
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'جرّب البحث بكلمة مفتاحية أخرى أو التخصص',
            style: TextStyle(
              fontSize: 12.sp,
              color: TrainingColors.textSecondary,
              fontFamily: 'Tajawal',
            ),
          ),
          SizedBox(height: 16.h),
          OutlinedButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _selectedStatusFilter = 'all';
              });
            },
            style: OutlinedButton.styleFrom(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
            ),
            child: const Text('إعادة ضبط الفلاتر'),
          ),
        ],
      ),
    );
  }
}
