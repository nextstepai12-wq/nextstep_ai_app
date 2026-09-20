
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';

import '../../logic/training_center_bloc/training_center_bloc.dart';
import '../../logic/training_programs_bloc/training_programs_bloc.dart';
import '../widgets/program_card.dart';
import '../widgets/center_stat_card.dart';
import '../widgets/training_center_drawer.dart';
import '../screens/notifications_screen.dart' as training;

class TrainingCenterHomeScreen extends StatefulWidget {
  const TrainingCenterHomeScreen({super.key});

  @override
  State<TrainingCenterHomeScreen> createState() =>
      _TrainingCenterHomeScreenState();
}

class _TrainingCenterHomeScreenState extends State<TrainingCenterHomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  final Map<String, dynamic> _mockStats = {
    'programsCount': 12,
    'studentsCount': 156,
    'averageRating': 4.7,
  };

  @override
  void initState() {
    super.initState();
    context.read<TrainingCenterBloc>().add(const LoadTrainingCenters());
    context.read<TrainingProgramsBloc>().add(const LoadTrainingPrograms());
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
        Image.asset(
          'assets/images/logo.png',
          height: 28.h,
          errorBuilder: (_, __, ___) => Icon(
            Icons.school_rounded,
            size: 24.sp,
            color: Colors.blue.shade700,
          ),
        ),
        SizedBox(width: 6.w),
        Text(
          'مركز التدريب',
          style: TextStyle(
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
            color: Colors.blue.shade900,
          ),
        ),
      ],
    ),
    actions: [
      Stack(
        children: [
          IconButton(
            icon: Icon(Icons.notifications_outlined, size: 22.sp),
            onPressed: () {
              context.push('/training-center/notifications');
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Positioned(
            top: 2.h,
            right: 2.w,
            child: Container(
              width: 14.w,
              height: 14.h,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  '3',
                  style: TextStyle(
                    fontSize: 8.sp,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      SizedBox(width: 4.w),
      CircleAvatar(
        radius: 18.r,
        backgroundColor: Colors.grey.shade300,
        child: Icon(
          Icons.person,
          size: 20.sp,
          color: Colors.grey.shade700,
        ),
      ),
      SizedBox(width: 6.w),
    ],
    centerTitle: false,
    elevation: 0,
    backgroundColor: Colors.white.withValues(alpha: 0.92),
  );
}

  Widget _buildBody() {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildWelcomeSection(),
          SizedBox(height: 14.h),
          _buildStatisticsSection(),
          SizedBox(height: 18.h),
          _buildProgramsSection(),
          SizedBox(height: 18.h),
          _buildRecommendedCentersSection(),
          SizedBox(height: 10.h),
        ],
      ),
    );
  }

  Widget _buildWelcomeSection() {
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
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحباً بك 👋',
                      style: TextStyle(
                        fontSize: 18.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2.h),
                    Text(
                      centerName,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.white.withValues(alpha: 0.9),
                      ),
                    ),
                    SizedBox(height: 8.h),
                    ElevatedButton(
                      onPressed: () {
                        context.push(
                          '/training-center/programs',
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.white,
                        foregroundColor: Colors.blue.shade700,
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 6.h,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        textStyle: TextStyle(fontSize: 12.sp),
                      ),
                      child: const Text('استعراض البرامج'),
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

  Widget _buildStatisticsSection() {
    final stats = _mockStats;

    return Row(
      children: [
        Expanded(
          child: CenterStatCard(
            icon: Icons.menu_book_rounded,
            label: 'البرامج',
            value: stats['programsCount'].toString(),
            color: Colors.blue.shade100,
            iconColor: Colors.blue.shade700,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: CenterStatCard(
            icon: Icons.people_rounded,
            label: 'الطلاب',
            value: stats['studentsCount'].toString(),
            color: Colors.green.shade100,
            iconColor: Colors.green.shade700,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: CenterStatCard(
            icon: Icons.star_rounded,
            label: 'التقييم',
            value: stats['averageRating'].toStringAsFixed(1),
            color: Colors.amber.shade100,
            iconColor: Colors.amber.shade700,
          ),
        ),
      ],
    );
  }

  Widget _buildProgramsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'البرامج التدريبية',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            TextButton(
              onPressed: () {
                context.push('/training-center/programs');
              },
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                minimumSize: Size.zero,
                tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              ),
              child: Text(
                'عرض الكل',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.blue.shade700,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        BlocBuilder<TrainingProgramsBloc, TrainingProgramsState>(
          builder: (context, state) {
            if (state is TrainingProgramsLoading) {
              return _buildProgramsShimmer();
            }

            if (state is TrainingProgramsLoaded) {
              final programs = state.programs;
              if (programs.isEmpty) {
                return _buildEmptyProgramsState();
              }

              return SizedBox(
                height: 210.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: programs.length > 5 ? 5 : programs.length,
                  itemBuilder: (context, index) {
                    final program = programs[index];
                    return Padding(
                      padding: EdgeInsets.only(left: 8.w),
                      child: ProgramCard(
                        program: program,
                        onTap: () {
                          context.push(
                            '/training-center/program-details',
                            extra: program.id,
                          );
                        },
                      ),
                    );
                  },
                ),
              );
            }

            if (state is TrainingProgramsError) {
              return Container(
                padding: EdgeInsets.all(16.r),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: Colors.red.shade200),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline_rounded,
                      color: Colors.red.shade700,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'حدث خطأ: ${state.message}',
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.red.shade700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        context
                            .read<TrainingProgramsBloc>()
                            .add(const LoadTrainingPrograms());
                      },
                      child: Text(
                        'إعادة المحاولة',
                        style: TextStyle(
                          fontSize: 11.sp,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          },
        ),
      ],
    );
  }

  Widget _buildEmptyProgramsState() {
    return Container(
      height: 140.h,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.info_outline_rounded,
              size: 36.sp,
              color: Colors.grey.shade400,
            ),
            SizedBox(height: 6.h),
            Text(
              'لا توجد برامج تدريبية حالياً',
              style: TextStyle(
                fontSize: 13.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgramsShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SizedBox(
        height: 190.h,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: 3,
          itemBuilder: (context, index) {
            return Container(
              width: 150.w,
              margin: EdgeInsets.only(right: 8.w),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12.r),
              ),
            );
          },
        ),
      ),
    );
  }

Widget _buildRecommendedCentersSection() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        'مراكز تدريب موصى بها',
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.bold,
          color: Colors.grey.shade800,
        ),
      ),
      SizedBox(height: 8.h),
      BlocBuilder<TrainingCenterBloc, TrainingCenterState>(
        builder: (context, state) {
          if (state is TrainingCenterLoading) {
            return _buildRecommendedCentersShimmer();
          }

          if (state is TrainingCenterLoaded) {
            final centers = state.centers;
            if (centers.isEmpty) {
              return _buildEmptyCentersState();
            }

            return SizedBox(
              height: 85.h,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: centers.length > 5 ? 5 : centers.length,
                padding: EdgeInsets.symmetric(horizontal: 2.w),
                itemBuilder: (context, index) {
                  final center = centers[index];
                  return _buildRecommendedCenterItem(center);
                },
              ),
            );
          }

          if (state is TrainingCenterError) {
            return Container(
              padding: EdgeInsets.all(12.r),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.red.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline_rounded,
                    color: Colors.red.shade700,
                    size: 16.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      'حدث خطأ: ${state.message}',
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.red.shade700,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    ],
  );
}

Widget _buildRecommendedCenterItem(dynamic center) {
  return Container(
    width: 120.w,
    margin: EdgeInsets.only(left: 8.w),
    padding: EdgeInsets.all(8.r),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade100,
          blurRadius: 4.r,
          offset: Offset(0, 2.h),
        ),
      ],
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 16.r,
          backgroundColor: Colors.grey.shade200,
          backgroundImage: center.logoUrl != null
              ? NetworkImage(center.logoUrl!)
              : null,
          child: center.logoUrl == null
              ? Icon(
                  Icons.business_rounded,
                  size: 16.sp,
                  color: Colors.grey.shade600,
                )
              : null,
        ),
        SizedBox(height: 2.h),
        Flexible(
          child: Text(
            center.name ?? 'مركز تدريب',
            style: TextStyle(
              fontSize: 9.sp,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade800,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
          ),
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.star_rounded,
              size: 8.sp,
              color: Colors.amber.shade600,
            ),
            SizedBox(width: 1.w),
            Text(
              '4.5',
              style: TextStyle(
                fontSize: 8.sp,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

Widget _buildEmptyCentersState() {
  return Container(
    height: 75.h,
    padding: EdgeInsets.symmetric(horizontal: 12.w),
    decoration: BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(10.r),
      border: Border.all(color: Colors.grey.shade200),
    ),
    child: Center(
      child: Text(
        'لا توجد مراكز تدريب موصى بها',
        style: TextStyle(
          fontSize: 12.sp,
          color: Colors.grey.shade600,
        ),
      ),
    ),
  );
}

Widget _buildRecommendedCentersShimmer() {
  return Shimmer.fromColors(
    baseColor: Colors.grey.shade300,
    highlightColor: Colors.grey.shade100,
    child: SizedBox(
      height: 75.h,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: 3,
        padding: EdgeInsets.symmetric(horizontal: 2.w),
        itemBuilder: (context, index) {
          return Container(
            width: 110.w,
            margin: EdgeInsets.only(left: 8.w),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10.r),
            ),
          );
        },
      ),
    ),
  );
}

}
