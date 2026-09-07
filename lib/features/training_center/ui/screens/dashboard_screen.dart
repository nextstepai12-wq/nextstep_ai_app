// lib/features/training_center/ui/screens/dashboard_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../logic/training_center_bloc/training_center_bloc.dart';
import '../../logic/training_programs_bloc/training_programs_bloc.dart';
import '../widgets/training_center_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDataLoaded = false;

  // ✅ بيانات وهمية للإحصائيات (سيتم استبدالها ببيانات حقيقية من الـ API)
  final Map<String, dynamic> _mockStats = {
    'totalCourses': 12,
    'pendingCourses': 3,
    'totalStudents': 156,
    'needsRevision': 1,
    'averageRating': 4.7,
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && !_isDataLoaded) {
        context.read<TrainingCenterBloc>().add(const LoadTrainingCenters());
        context.read<TrainingProgramsBloc>().add(const LoadTrainingPrograms());
        _isDataLoaded = true;
      }
    });
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
            Icons.dashboard_rounded,
            color: Colors.blue.shade700,
            size: 22.sp,
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              'لوحة التحكم',
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
        _buildCenterInfo(),
        SizedBox(width: 6.w),
        _buildCenterAvatar(),
      ],
      centerTitle: false,
      elevation: 0,
      backgroundColor: Colors.white.withValues(alpha: 0.92),
    );
  }

  Widget _buildCenterInfo() {
    return BlocBuilder<TrainingCenterBloc, TrainingCenterState>(
      builder: (context, state) {
        String centerName = 'مركز التدريب';
        String plan = 'باقة أساسية';

        if (state is TrainingCenterLoaded && state.centers.isNotEmpty) {
          centerName = state.centers.first.name;
        }

        return Container(
          padding: EdgeInsets.symmetric(horizontal: 6.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                centerName,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                    child: Text(
                      plan,
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  SizedBox(width: 2.w),
                  TextButton(
                    onPressed: () {},
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'ترقية',
                      style: TextStyle(
                        fontSize: 8.sp,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCenterAvatar() {
    return BlocBuilder<TrainingCenterBloc, TrainingCenterState>(
      builder: (context, state) {
        String? logoUrl;

        if (state is TrainingCenterLoaded && state.centers.isNotEmpty) {
          logoUrl = state.centers.first.logoUrl;
        }

        return Container(
          width: 36.w,
          height: 36.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.shade300),
            image: logoUrl != null
                ? DecorationImage(
                    image: NetworkImage(logoUrl),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: logoUrl == null
              ? Icon(
                  Icons.business_rounded,
                  color: Colors.grey.shade400,
                  size: 18.sp,
                )
              : null,
        );
      },
    );
  }

  // ============================
  //  Body
  // ============================
  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.all(14.r),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeHeader(),
          SizedBox(height: 16.h),
          _buildCapacityAlert(),
          SizedBox(height: 16.h),
          _buildMetricCards(),
          SizedBox(height: 20.h),
          _buildChartsSection(),
          SizedBox(height: 20.h),
          _buildRecentActivity(),
        ],
      ),
    );
  }

  // ============================
  //  Welcome Header
  // ============================
  Widget _buildWelcomeHeader() {
    return BlocBuilder<TrainingCenterBloc, TrainingCenterState>(
      builder: (context, state) {
        String centerName = 'مركز التدريب';

        if (state is TrainingCenterLoaded && state.centers.isNotEmpty) {
          centerName = state.centers.first.name;
        }

        return Container(
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.blue.shade700, Colors.blue.shade400],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً بعودتك 👋',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      centerName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      child: Text(
                        'باقة ${state is TrainingCenterLoaded && state.centers.isNotEmpty ? state.centers.first.subscriptionTier : 'أساسية'}',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.auto_awesome_rounded,
                size: 48.sp,
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ],
          ),
        );
      },
    );
  }

  // ============================
  //  Capacity Alert Banner
  // ============================
  Widget _buildCapacityAlert() {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.amber.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.amber.shade100.withValues(alpha: 0.2),
            blurRadius: 8.r,
            offset: Offset(0, 2.h),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: Colors.amber.shade100,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              Icons.warning_rounded,
              color: Colors.amber.shade700,
              size: 20.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'اقتربت من الحد الأقصى للباقة',
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.amber.shade900,
                  ),
                ),
                Text(
                  'لقد استهلكت 85% من سعة الدورات المسموح بها',
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.amber.shade800,
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            width: 90.w,
            height: 32.h,
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber.shade700,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                textStyle: TextStyle(fontSize: 10.sp),
              ),
              child: const Text('ترقية'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================
  //  Metric Cards
  // ============================
  Widget _buildMetricCards() {
    final stats = _mockStats;

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12.w,
      mainAxisSpacing: 12.h,
      childAspectRatio: 1.1,
      children: [
        _buildMetricCard(
          title: 'الدورات المعتمدة',
          value: stats['totalCourses'].toString(),
          icon: Icons.verified_rounded,
          iconColor: Colors.blue.shade700,
          bgColor: Colors.blue.shade50,
          trend: '+12%',
          trendColor: Colors.green.shade700,
        ),
        _buildMetricCard(
          title: 'بانتظار المراجعة',
          value: stats['pendingCourses'].toString(),
          icon: Icons.pending_actions_rounded,
          iconColor: Colors.amber.shade700,
          bgColor: Colors.amber.shade50,
          trend: '+2',
          trendColor: Colors.amber.shade700,
        ),
        _buildMetricCard(
          title: 'الطلاب المسجلين',
          value: stats['totalStudents'].toString(),
          icon: Icons.group_rounded,
          iconColor: Colors.green.shade700,
          bgColor: Colors.green.shade50,
          trend: '+8%',
          trendColor: Colors.green.shade700,
        ),
        _buildMetricCard(
          title: 'متوسط التقييم',
          value: stats['averageRating'].toString(),
          icon: Icons.star_rounded,
          iconColor: Colors.amber.shade700,
          bgColor: Colors.amber.shade50,
          trend: '+0.3',
          trendColor: Colors.green.shade700,
        ),
      ],
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    String? trend,
    Color? trendColor,
  }) {
    return Container(
      padding: EdgeInsets.all(14.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  icon,
                  color: iconColor,
                  size: 16.sp,
                ),
              ),
              if (trend != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: (trendColor ?? Colors.green.shade700).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10.r),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.arrow_upward_rounded,
                        color: trendColor ?? Colors.green.shade700,
                        size: 10.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        trend,
                        style: TextStyle(
                          fontSize: 8.sp,
                          color: trendColor ?? Colors.green.shade700,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 24.sp,
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
    );
  }

  // ============================
  //  Charts Section
  // ============================
  Widget _buildChartsSection() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'نشاط الدورات',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'هذا الشهر',
                      style: TextStyle(
                        fontSize: 10.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down_rounded,
                      size: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 16.h),
          _buildChartBars(),
        ],
      ),
    );
  }

  Widget _buildChartBars() {
    final data = [
      {'label': 'أسبوع 1', 'value': 65},
      {'label': 'أسبوع 2', 'value': 80},
      {'label': 'أسبوع 3', 'value': 45},
      {'label': 'أسبوع 4', 'value': 90},
    ];

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: data.map((item) {
        final height = (item['value'] as int) / 100 * 100;
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: height.h * 0.7,
              width: 24.w,
              decoration: BoxDecoration(
                color: height > 70 ? Colors.blue.shade700 : Colors.blue.shade300,
                borderRadius: BorderRadius.circular(4.r),
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              item['label'] as String,
              style: TextStyle(
                fontSize: 8.sp,
                color: Colors.grey.shade500,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }

  // ============================
  //  Recent Activity
  // ============================
  Widget _buildRecentActivity() {
    return Container(
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
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
          Text(
            'أحدث الأنشطة',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade800,
            ),
          ),
          SizedBox(height: 12.h),
          _buildActivityItem(
            icon: Icons.person_add_rounded,
            iconColor: Colors.green.shade700,
            bgColor: Colors.green.shade50,
            title: 'طالب جديد مسجل',
            subtitle: 'أحمد محمد سجل في دورة Flutter',
            time: 'منذ 5 دقائق',
          ),
          _buildActivityItem(
            icon: Icons.menu_book_rounded,
            iconColor: Colors.blue.shade700,
            bgColor: Colors.blue.shade50,
            title: 'دورة جديدة مضافة',
            subtitle: 'تم إضافة دورة "إدارة المشاريع"',
            time: 'منذ ساعة',
          ),
          _buildActivityItem(
            icon: Icons.star_rounded,
            iconColor: Colors.amber.shade700,
            bgColor: Colors.amber.shade50,
            title: 'تقييم جديد',
            subtitle: 'سارة عبدالله قيمت الدورة بـ 5 نجوم',
            time: 'منذ 3 ساعات',
          ),
        ],
      ),
    );
  }

  Widget _buildActivityItem({
    required IconData icon,
    required Color iconColor,
    required Color bgColor,
    required String title,
    required String subtitle,
    required String time,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.h),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: Colors.grey.shade100),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36.w,
            height: 36.h,
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 18.sp,
            ),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey.shade800,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),
          Text(
            time,
            style: TextStyle(
              fontSize: 9.sp,
              color: Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}