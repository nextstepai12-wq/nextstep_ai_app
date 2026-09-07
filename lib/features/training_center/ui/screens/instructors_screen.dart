// lib/features/training_center/ui/screens/instructors_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../logic/training_center_bloc/training_center_bloc.dart';
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
  String _selectedDepartment = 'الكل';
  bool _isDataLoaded = false;

  final List<String> _departments = [
    'الكل',
    'الذكاء الاصطناعي',
    'إدارة الأعمال',
    'تقنية المعلومات',
    'التسويق',
    'التصميم',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDataLoaded) {
        context.read<TrainingCenterBloc>().add(const LoadTrainingCenters());
        _isDataLoaded = true;
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
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
            Icons.psychology_rounded,
            color: Colors.blue.shade700,
            size: 22.sp,
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              'إدارة المدربين',
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
        // زر إضافة مدرب
        Container(
          height: 32.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            color: Colors.blue.shade700,
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.add_rounded,
                size: 16.sp,
                color: Colors.white,
              ),
              SizedBox(width: 4.w),
              Text(
                'إضافة مدرب',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        SizedBox(width: 4.w),
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
    );
  }

  // ============================
  //  Body
  // ============================
  Widget _buildBody() {
    return Column(
      children: [
        // ✅ بطاقات الإحصائيات
        _buildStatsCards(),
        SizedBox(height: 8.h),

        // ✅ شريط البحث والفلاتر
        _buildSearchAndFilter(),
        SizedBox(height: 8.h),

        // ✅ قائمة المدربين
        Expanded(
          child: _buildInstructorsList(),
        ),
      ],
    );
  }

  // ============================
  //  Stats Cards
  // ============================
  Widget _buildStatsCards() {
    return BlocBuilder<TrainingCenterBloc, TrainingCenterState>(
      builder: (context, state) {
        if (state is TrainingCenterLoading) {
          return _buildStatsShimmer();
        }

        if (state is TrainingCenterLoaded) {
          final totalInstructors = 124;
          final activeInstructors = 98;
          final avgRating = 4.8;

          return Container(
            padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
            child: Row(
              children: [
                _buildStatCard(
                  title: 'إجمالي المدربين',
                  value: totalInstructors.toString(),
                  icon: Icons.group_rounded,
                  color: Colors.blue.shade50,
                  iconColor: Colors.blue.shade700,
                ),
                SizedBox(width: 10.w),
                _buildStatCard(
                  title: 'المدربين النشطين',
                  value: activeInstructors.toString(),
                  icon: Icons.how_to_reg_rounded,
                  color: Colors.green.shade50,
                  iconColor: Colors.green.shade700,
                ),
                SizedBox(width: 10.w),
                _buildStatCard(
                  title: 'متوسط التقييم',
                  value: avgRating.toString(),
                  icon: Icons.star_rounded,
                  color: Colors.amber.shade50,
                  iconColor: Colors.amber.shade700,
                ),
              ],
            ),
          );
        }

        if (state is TrainingCenterError) {
          return Padding(
            padding: EdgeInsets.all(16.r),
            child: Text(
              'حدث خطأ: ${state.message}',
              style: TextStyle(color: Colors.red.shade700),
            ),
          );
        }

        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildStatCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    required Color iconColor,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.all(10.r),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(4.r),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(6.r),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 14.sp,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              value,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 10.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
        child: Row(
          children: List.generate(
            3,
            (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: 10.w),
                height: 70.h,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14.r),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ============================
  //  Search and Filter
  // ============================
  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(12.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16.r)),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Container(
                  height: 44.h,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'البحث عن مدرب أو تخصص...',
                      hintStyle: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.grey.shade400,
                      ),
                      prefixIcon: Icon(
                        Icons.search_rounded,
                        color: Colors.grey.shade400,
                        size: 18.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 14.w),
                    ),
                    textDirection: TextDirection.rtl,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // فلتر الأقسام
              Container(
                height: 44.h,
                padding: EdgeInsets.symmetric(horizontal: 12.w),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: DropdownButton<String>(
                  value: _selectedDepartment,
                  items: _departments.map((department) {
                    return DropdownMenuItem(
                      value: department,
                      child: Text(
                        department,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedDepartment = value;
                      });
                    }
                  },
                  underline: const SizedBox(),
                  icon: Icon(
                    Icons.arrow_drop_down_rounded,
                    color: Colors.grey.shade600,
                    size: 20.sp,
                  ),
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade700,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              // زر الفلتر
              Container(
                height: 44.h,
                width: 44.w,
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: IconButton(
                  icon: Icon(
                    Icons.filter_list_rounded,
                    color: Colors.grey.shade600,
                    size: 20.sp,
                  ),
                  onPressed: () {},
                  padding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================
  //  Instructors List
  // ============================
  Widget _buildInstructorsList() {
    final instructors = [
      {
        'name': 'د. أحمد محمود',
        'specialty': 'خبير ذكاء اصطناعي',
        'rating': 4.9,
        'reviews': 120,
        'courses': 3,
        'status': 'نشط',
        'image': '',
      },
      {
        'name': 'سارة الكعبي',
        'specialty': 'إدارة أعمال',
        'rating': 4.7,
        'reviews': 85,
        'courses': 5,
        'status': 'نشط',
        'image': '',
      },
      {
        'name': 'د. خالد المنصور',
        'specialty': 'تقنية المعلومات',
        'rating': 4.8,
        'reviews': 95,
        'courses': 4,
        'status': 'نشط',
        'image': '',
      },
      {
        'name': 'نورة القحطاني',
        'specialty': 'التسويق الرقمي',
        'rating': 4.6,
        'reviews': 70,
        'courses': 3,
        'status': 'غير نشط',
        'image': '',
      },
      {
        'name': 'د. فيصل الحربي',
        'specialty': 'الذكاء الاصطناعي',
        'rating': 4.9,
        'reviews': 150,
        'courses': 6,
        'status': 'نشط',
        'image': '',
      },
      {
        'name': 'منى الشمري',
        'specialty': 'تصميم واجهات',
        'rating': 4.5,
        'reviews': 60,
        'courses': 2,
        'status': 'نشط',
        'image': '',
      },
    ];

    final filteredInstructors = instructors.where((instructor) {
// ✅ صحيح - تحويل إلى String باستخدام .toString()
      final matchesSearch = instructor['name']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase()) ||
          instructor['specialty']
              .toString()
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
      final matchesDepartment = _selectedDepartment == 'الكل' ||
          instructor['specialty'] == _selectedDepartment;
      return matchesSearch && matchesDepartment;
    }).toList();

    if (filteredInstructors.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      itemCount: filteredInstructors.length,
      itemBuilder: (context, index) {
        final instructor = filteredInstructors[index];
        return _buildInstructorCard(instructor);
      },
    );
  }

  // ============================
  //  Instructor Card
  // ============================
  Widget _buildInstructorCard(Map<String, dynamic> instructor) {
    final isActive = instructor['status'] == 'نشط';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
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
          // ✅ رأس البطاقة
          Row(
            children: [
              // صورة المدرب
              Container(
                width: 56.w,
                height: 56.h,
                decoration: BoxDecoration(
                  color: Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(14.r),
                ),
                child: Center(
                  child: Text(
                    instructor['name']!.substring(0, 1),
                    style: TextStyle(
                      fontSize: 22.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              // معلومات المدرب
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      instructor['name']!,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 2.h),
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Text(
                        instructor['specialty']!,
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              // زر المزيد
              IconButton(
                onPressed: () {},
                icon: Icon(
                  Icons.more_vert_rounded,
                  color: Colors.grey.shade400,
                  size: 20.sp,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // ✅ التقييم والدورات
          Row(
            children: [
              // التقييم
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.star_rounded,
                      color: Colors.amber.shade600,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      instructor['rating'].toString(),
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '(${instructor['reviews']})',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 10.w),
              // عدد الدورات
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(10.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      color: Colors.blue.shade600,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      '${instructor['courses']} دورات',
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),

          // ✅ الحالة والأزرار
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // حالة المدرب
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isActive ? Colors.green.shade50 : Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(
                    color:
                        isActive ? Colors.green.shade300 : Colors.grey.shade300,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6.w,
                      height: 6.h,
                      decoration: BoxDecoration(
                        color: isActive
                            ? Colors.green.shade700
                            : Colors.grey.shade500,
                        shape: BoxShape.circle,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      instructor['status']!,
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: isActive
                            ? Colors.green.shade700
                            : Colors.grey.shade600,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              // أزرار الإجراءات
              Row(
                children: [
                  IconButton(
                    onPressed: () {
                      _showInstructorDetails(context, instructor);
                    },
                    icon: Icon(
                      Icons.visibility_rounded,
                      color: Colors.grey.shade500,
                      size: 18.sp,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                  SizedBox(width: 8.w),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(
                      Icons.edit_rounded,
                      color: Colors.grey.shade500,
                      size: 18.sp,
                    ),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ============================
  //  Empty State
  // ============================
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_off_rounded,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا يوجد مدربين مطابقين للبحث',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'يرجى تعديل خيارات التصفية أو محاولة البحث باستخدام كلمات مفتاحية مختلفة.',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _searchController.clear();
                _searchQuery = '';
                _selectedDepartment = 'الكل';
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey.shade200,
              foregroundColor: Colors.grey.shade700,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
            child: const Text('مسح الفلاتر'),
          ),
        ],
      ),
    );
  }

  // ============================
  //  Instructor Details Dialog
  // ============================
  void _showInstructorDetails(
      BuildContext context, Map<String, dynamic> instructor) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Row(
            children: [
              CircleAvatar(
                radius: 24.r,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  instructor['name']!.substring(0, 1),
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    instructor['name']!,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    instructor['specialty']!,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildDetailRow('التخصص', instructor['specialty']),
              _buildDetailRow('التقييم',
                  '${instructor['rating']} ★ (${instructor['reviews']} تقييم)'),
              _buildDetailRow('عدد الدورات', instructor['courses'].toString()),
              _buildDetailRow('الحالة', instructor['status']),
              _buildDetailRow('البريد الإلكتروني',
                  '${instructor['name']!.replaceAll(' ', '.').toLowerCase()}@example.com'),
              _buildDetailRow('رقم الهاتف', '+966 50 000 0000'),
            ],
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.r),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'إغلاق',
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        'تم إرسال رسالة إلى المدرب ${instructor['name']} 📩'),
                    backgroundColor: Colors.blue.shade700,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
              child: const Text('مراسلة'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade600,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 13.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
          ),
        ],
      ),
    );
  }
}
