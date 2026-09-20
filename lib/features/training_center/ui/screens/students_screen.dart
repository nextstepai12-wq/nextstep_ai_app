
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../logic/training_center_bloc/training_center_bloc.dart';
import '../widgets/training_center_drawer.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedFilter = 'الكل';
  bool _isDataLoaded = false;

  final List<String> _filters = const [
    'الكل',
    'نشط',
    'مكتمل',
    'منسحب',
    'قيد الانتظار',
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
            Icons.people_rounded,
            color: Colors.blue.shade700,
            size: 22.sp,
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              'الطلاب المسجلون',
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
        Container(
          height: 32.h,
          padding: EdgeInsets.symmetric(horizontal: 10.w),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Row(
            children: [
              Icon(
                Icons.download_rounded,
                size: 16.sp,
                color: Colors.blue.shade700,
              ),
              SizedBox(width: 4.w),
              Text(
                'تصدير CSV',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.blue.shade700,
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

  Widget _buildBody() {
    return Column(
      children: [
        _buildSearchAndFilter(),
        SizedBox(height: 8.h),
        _buildStatsCards(),
        Expanded(
          child: _buildStudentsList(),
        ),
      ],
    );
  }

  Widget _buildSearchAndFilter() {
    return Container(
      padding: EdgeInsets.all(16.r),
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
          Container(
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
                hintText: 'البحث عن اسم الطالب...',
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
          SizedBox(height: 10.h),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _filters.map((filter) {
                final isSelected = _selectedFilter == filter;
                return Padding(
                  padding: EdgeInsets.only(left: 6.w),
                  child: FilterChip(
                    label: Text(
                      filter,
                      style: TextStyle(
                        fontSize: 11.sp,
                        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: Colors.blue.shade100,
                    backgroundColor: Colors.grey.shade50,
                    checkmarkColor: Colors.blue.shade700,
                    side: BorderSide(
                      color: isSelected ? Colors.blue.shade700 : Colors.grey.shade300,
                      width: isSelected ? 2 : 1,
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    return BlocBuilder<TrainingCenterBloc, TrainingCenterState>(
      builder: (context, state) {
        if (state is TrainingCenterLoading) {
          return _buildStatsShimmer();
        }

        if (state is TrainingCenterLoaded) {
          const totalStudents = 156;
          const completionRate = 68;
          const certificatesIssued = 432;

          return Container(
            padding: EdgeInsets.all(12.r),
            child: Row(
              children: [
                _buildStatCard(
                  title: 'إجمالي الطلاب',
                  value: totalStudents.toString(),
                  color: Colors.blue.shade50,
                  iconColor: Colors.blue.shade700,
                  icon: Icons.people_rounded,
                ),
                SizedBox(width: 10.w),
                _buildStatCard(
                  title: 'نسبة الإكمال',
                  value: '$completionRate%',
                  color: Colors.green.shade50,
                  iconColor: Colors.green.shade700,
                  icon: Icons.trending_up_rounded,
                ),
                SizedBox(width: 10.w),
                _buildStatCard(
                  title: 'شهادات صادرة',
                  value: certificatesIssued.toString(),
                  color: Colors.amber.shade50,
                  iconColor: Colors.amber.shade700,
                  icon: Icons.workspace_premium_rounded,
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
    required Color color,
    required Color iconColor,
    required IconData icon,
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
        padding: EdgeInsets.all(12.r),
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

  Widget _buildStudentsList() {
    final students = [
      {
        'name': 'أحمد محمد',
        'email': 'ahmed.m@example.com',
        'course': 'مقدمة في الذكاء الاصطناعي',
        'date': '12 مايو 2024',
        'status': 'نشط',
        'phone': '+966 50 123 4567',
      },
      {
        'name': 'سارة عبدالله',
        'email': 'sara.a@example.com',
        'course': 'تحليل البيانات المتقدم',
        'date': '05 أبريل 2024',
        'status': 'مكتمل',
        'phone': '+966 55 234 5678',
      },
      {
        'name': 'خالد سعيد',
        'email': 'khaled.s@example.com',
        'course': 'أساسيات البرمجة',
        'date': '20 مارس 2024',
        'status': 'منسحب',
        'phone': '+966 54 345 6789',
      },
      {
        'name': 'عمر فاروق',
        'email': 'omar.f@example.com',
        'course': 'تصميم تجربة المستخدم',
        'date': '10 يناير 2024',
        'status': 'مكتمل',
        'phone': '+966 53 456 7890',
      },
      {
        'name': 'نورة خالد',
        'email': 'noura.k@example.com',
        'course': 'التسويق الرقمي',
        'date': '15 فبراير 2024',
        'status': 'نشط',
        'phone': '+966 56 567 8901',
      },
      {
        'name': 'فيصل أحمد',
        'email': 'faisal.a@example.com',
        'course': 'إدارة المشاريع',
        'date': '01 مارس 2024',
        'status': 'قيد الانتظار',
        'phone': '+966 57 678 9012',
      },
    ];

    final filteredStudents = students.where((student) {
      final matchesSearch = student['name']!
          .toLowerCase()
          .contains(_searchQuery.toLowerCase());
      final matchesFilter = _selectedFilter == 'الكل' ||
          student['status'] == _selectedFilter;
      return matchesSearch && matchesFilter;
    }).toList();

    if (filteredStudents.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
      itemCount: filteredStudents.length,
      itemBuilder: (context, index) {
        final student = filteredStudents[index];
        return _buildStudentCard(student);
      },
    );
  }

  Widget _buildStudentCard(Map<String, String> student) {
    final statusColor = _getStatusColor(student['status']!);
    final statusBg = _getStatusBackground(student['status']!);
    final canIssueCertificate = student['status'] == 'مكتمل';

    return Container(
      margin: EdgeInsets.only(bottom: 10.h),
      padding: EdgeInsets.all(14.r),
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
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: Colors.blue.shade100,
                child: Text(
                  student['name']!.substring(0, 1),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student['name']!,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      student['course']!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 3.h),
                decoration: BoxDecoration(
                  color: statusBg,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: statusColor.withValues(alpha: 0.3)),
                ),
                child: Text(
                  student['status']!,
                  style: TextStyle(
                    fontSize: 9.sp,
                    color: statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.calendar_today_rounded,
                    size: 12.sp,
                    color: Colors.grey.shade500,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'تاريخ التسجيل: ${student['date']}',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
              canIssueCertificate
                  ? SizedBox(
                      width: 90.w,
                      height: 28.h,
                      child: ElevatedButton(
                        onPressed: () {
                          _showCertificateDialog(context, student);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue.shade700,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 4.h),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6.r),
                          ),
                          textStyle: TextStyle(
                            fontSize: 9.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        child: const Text('إصدار شهادة'),
                      ),
                    )
                  : SizedBox(
                      width: 90.w,
                      height: 28.h,
                      child: Container(
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(6.r),
                        ),
                        child: Text(
                          'غير متاح',
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.grey.shade500,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا يوجد طلاب مطابقين للبحث',
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
                _selectedFilter = 'الكل';
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

  Color _getStatusColor(String status) {
    switch (status) {
      case 'نشط':
        return Colors.green.shade700;
      case 'مكتمل':
        return Colors.blue.shade700;
      case 'منسحب':
        return Colors.grey.shade600;
      case 'قيد الانتظار':
        return Colors.amber.shade700;
      default:
        return Colors.grey.shade600;
    }
  }

  Color _getStatusBackground(String status) {
    switch (status) {
      case 'نشط':
        return Colors.green.shade50;
      case 'مكتمل':
        return Colors.blue.shade50;
      case 'منسحب':
        return Colors.grey.shade100;
      case 'قيد الانتظار':
        return Colors.amber.shade50;
      default:
        return Colors.grey.shade100;
    }
  }

  void _showCertificateDialog(BuildContext context, Map<String, String> student) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إصدار شهادة'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'هل أنت متأكد من رغبتك في إصدار شهادة للطالب:',
                style: TextStyle(fontSize: 14.sp),
              ),
              SizedBox(height: 8.h),
              Text(
                student['name']!,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade700,
                ),
              ),
              SizedBox(height: 8.h),
              Text(
                'الدورة: ${student['course']}',
                style: TextStyle(fontSize: 14.sp),
              ),
            ],
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
                    content: Text('تم إصدار الشهادة للطالب ${student['name']} بنجاح ✅'),
                    backgroundColor: Colors.green.shade700,
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
              child: const Text('تأكيد الإصدار'),
            ),
          ],
        );
      },
    );
  }
}
