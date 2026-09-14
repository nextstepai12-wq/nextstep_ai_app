
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../logic/training_center_bloc/training_center_bloc.dart';
import '../../logic/training_programs_bloc/training_programs_bloc.dart';
import '../widgets/training_center_drawer.dart';

class CenterProfileScreen extends StatefulWidget {
  const CenterProfileScreen({super.key});

  @override
  State<CenterProfileScreen> createState() => _CenterProfileScreenState();
}

class _CenterProfileScreenState extends State<CenterProfileScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _isDataLoaded = false;

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
            Icons.business_center_rounded,
            color: Colors.blue.shade700,
            size: 22.sp,
          ),
          SizedBox(width: 6.w),
          Flexible(
            child: Text(
              'الملف التعريفي',
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
            Icons.edit_rounded,
            size: 22.sp,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('سيتم فتح صفحة تعديل الملف قريباً ✏️'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
          },
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(),
        ),
        SizedBox(width: 4.w),
        IconButton(
          icon: Icon(
            Icons.share_rounded,
            size: 22.sp,
          ),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('جاري مشاركة الملف التعريفي 📤'),
                duration: Duration(seconds: 2),
                behavior: SnackBarBehavior.floating,
              ),
            );
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
    return BlocBuilder<TrainingCenterBloc, TrainingCenterState>(
      builder: (context, state) {
        if (state is TrainingCenterLoading) {
          return _buildLoadingShimmer();
        }

        if (state is TrainingCenterLoaded) {
          if (state.centers.isEmpty) {
            return _buildEmptyState();
          }
          final center = state.centers.first;
          return _buildProfileContent(center);
        }

        if (state is TrainingCenterError) {
          return _buildErrorState(state.message);
        }

        return const Center(child: Text('لا توجد بيانات'));
      },
    );
  }

  Widget _buildProfileContent(dynamic center) {
    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(center),
          SizedBox(height: 16.h),

          _buildProfileInfo(center),
          SizedBox(height: 20.h),

          _buildTrustStats(center),
          SizedBox(height: 20.h),

          _buildCoursesSection(),
          SizedBox(height: 20.h),

          _buildContactSection(center),
          SizedBox(height: 16.h),
        ],
      ),
    );
  }

Widget _buildHeroSection(dynamic center) {
  return Stack(
    children: [
      Container(
        height: 200.h,
        width: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: ShaderMask(
          shaderCallback: (rect) {
            return LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.black.withValues(alpha: 0.3), Colors.transparent],
            ).createShader(rect);
          },
          blendMode: BlendMode.darken,
          child: Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: NetworkImage(
                  'https://images.unsplash.com/photo-1544531585-f9848d68c8b4?w=800&h=400&fit=crop',
                ),
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      ),
      Positioned(
        bottom: -40.h,
        left: 16.w,
        child: Container(
          width: 100.w,
          height: 100.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 4.w),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 12.r,
                offset: Offset(0, 4.h),
              ),
            ],
            image: center.logoUrl != null
                ? DecorationImage(
                    image: NetworkImage(center.logoUrl!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: center.logoUrl == null
              ? Icon(
                  Icons.business_rounded,
                  size: 50.sp,
                  color: Colors.blue.shade700,
                )
              : null,
        ),
      ),
      Positioned(
        bottom: -40.h,
        right: 16.w,
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade300,
                blurRadius: 8.r,
                offset: Offset(0, 4.h),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.star_rounded,
                color: Colors.amber.shade600,
                size: 16.sp,
              ),
              SizedBox(width: 4.w),
              Text(
                center.rating?.toStringAsFixed(1) ?? '4.8',
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              SizedBox(width: 2.w),
              Text(
                '(${center.studentCount ?? 120})',
                style: TextStyle(
                  fontSize: 10.sp,
                  color: Colors.grey.shade500,
                ),
              ),
            ],
          ),
        ),
      ),
    ],
  );
}
Widget _buildProfileInfo(dynamic center) {
  return Container(
    margin: EdgeInsets.symmetric(horizontal: 16.w),
    padding: EdgeInsets.only(top: 48.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                center.name ?? 'مركز التدريب',
                style: TextStyle(
                  fontSize: 22.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.green.shade200),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.verified_rounded,
                    color: Colors.green.shade700,
                    size: 14.sp,
                  ),
                  SizedBox(width: 4.w),
                  Text(
                    'مركز موثق',
                    style: TextStyle(
                      fontSize: 10.sp,
                      color: Colors.green.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 6.h),

        if (center.description != null)
          Text(
            center.description!,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade600,
              height: 1.6,
            ),
          ),
        SizedBox(height: 12.h),

        if (center.specialties != null && center.specialties!.isNotEmpty)
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: center.specialties!.map<Widget>((specialty) {
              return Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  specialty,
                  style: TextStyle(
                    fontSize: 11.sp,
                    color: Colors.blue.shade700,
                  ),
                ),
              );
            }).toList(),
          ),
        SizedBox(height: 12.h),

        Row(
          children: [
            _buildInfoChip(
              icon: Icons.location_on_rounded,
              label: center.location ?? 'العنوان غير محدد',
            ),
            SizedBox(width: 12.w),
            _buildInfoChip(
              icon: Icons.calendar_today_rounded,
              label: 'تأسس: ${center.createdAt?.year ?? 2022}',
            ),
          ],
        ),
      ],
    ),
  );
}

  Widget _buildInfoChip({
    required IconData icon,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
        decoration: BoxDecoration(
          color: Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 14.sp,
              color: Colors.grey.shade600,
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 11.sp,
                  color: Colors.grey.shade600,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrustStats(dynamic center) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.r),
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
      child: Row(
        children: [
          _buildStatItem(
            icon: Icons.menu_book_rounded,
            iconColor: Colors.blue.shade700,
            value: center.programsCount?.toString() ?? '12',
            label: 'دورة متاحة',
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: Icons.groups_rounded,
            iconColor: Colors.green.shade700,
            value: center.studentCount?.toString() ?? '1,500',
            label: 'طالب خريج',
          ),
          _buildStatDivider(),
          _buildStatItem(
            icon: Icons.verified_user_rounded,
            iconColor: Colors.purple.shade700,
            value: center.createdAt?.year.toString() ?? '2022',
            label: 'عضو موثق منذ',
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(8.r),
            decoration: BoxDecoration(
              color: iconColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10.r),
            ),
            child: Icon(
              icon,
              color: iconColor,
              size: 22.sp,
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
            label,
            style: TextStyle(
              fontSize: 10.sp,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatDivider() {
    return Container(
      width: 1,
      height: 50.h,
      color: Colors.grey.shade200,
    );
  }

  Widget _buildCoursesSection() {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'الدورات المتاحة',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              TextButton(
                onPressed: () {
                  context.push('/training-center/programs');
                },
                child: Text(
                  'عرض الكل',
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.blue.shade700,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          BlocBuilder<TrainingProgramsBloc, TrainingProgramsState>(
            builder: (context, state) {
              if (state is TrainingProgramsLoading) {
                return _buildCoursesShimmer();
              }

              if (state is TrainingProgramsLoaded) {
                final programs = state.programs.take(3).toList();
                if (programs.isEmpty) {
                  return Container(
                    padding: EdgeInsets.all(24.r),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    child: Center(
                      child: Text(
                        'لا توجد دورات متاحة حالياً',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade500,
                        ),
                      ),
                    ),
                  );
                }
                return Column(
                  children: programs.map((program) {
                    return _buildCourseCard(program);
                  }).toList(),
                );
              }

              return const SizedBox.shrink();
            },
          ),
        ],
      ),
    );
  }

Widget _buildCourseCard(dynamic program) {
  return Container(
    margin: EdgeInsets.only(bottom: 10.h),
    padding: EdgeInsets.all(12.r),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12.r),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.shade100,
          blurRadius: 4.r,
          offset: Offset(0, 2.h),
        ),
      ],
    ),
    child: Row(
      children: [
        Container(
          width: 80.w,
          height: 60.h,
          decoration: BoxDecoration(
            color: Colors.blue.shade50,
            borderRadius: BorderRadius.circular(8.r),
            image: program.coverImage != null
                ? DecorationImage(
                    image: NetworkImage(program.coverImage!),
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: program.coverImage == null
              ? Icon(
                  Icons.menu_book_rounded,
                  color: Colors.blue.shade300,
                  size: 28.sp,
                )
              : null,
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                program.title,
                style: TextStyle(
                  fontSize: 13.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Row(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade100,
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      program.category ?? 'عام',
                      style: TextStyle(
                        fontSize: 9.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ),
                  SizedBox(width: 6.w),
                  Text(
                    'مستوى ${program.level ?? 'مبتدئ'}',
                    style: TextStyle(
                      fontSize: 9.sp,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.star_rounded,
                        color: Colors.amber.shade600,
                        size: 12.sp,
                      ),
                      SizedBox(width: 2.w),
                      Text(
                        program.rating?.toStringAsFixed(1) ?? '4.8',
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.w500,
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    program.price > 0
                        ? '${program.price.toStringAsFixed(0)} ريال'
                        : 'مجاني',
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

  Widget _buildContactSection(dynamic center) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      padding: EdgeInsets.all(16.r),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade700, Colors.indigo.shade500],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'تواصل معنا',
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 4.h),
          Text(
            'نحن هنا لمساعدتك في رحلتك التعليمية',
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.white.withValues(alpha: 0.8),
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              _buildContactButton(
                icon: Icons.language_rounded,
                label: 'الموقع',
                onTap: () {},
              ),
              SizedBox(width: 10.w),
              _buildContactButton(
                icon: Icons.email_rounded,
                label: 'البريد',
                onTap: () {
                  if (center.email != null) {
                    _launchEmail(center.email!);
                  }
                },
              ),
              SizedBox(width: 10.w),
              _buildContactButton(
                icon: Icons.chat_rounded,
                label: 'دردشة',
                onTap: () {},
              ),
              SizedBox(width: 10.w),
              _buildContactButton(
                icon: Icons.phone_rounded,
                label: 'اتصال',
                onTap: () {
                  if (center.phone != null) {
                    _launchPhone(center.phone!);
                  }
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildContactButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 8.h),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: Colors.white,
                size: 20.sp,
              ),
              SizedBox(height: 2.h),
              Text(
                label,
                style: TextStyle(
                  fontSize: 9.sp,
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: SingleChildScrollView(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            Container(
              height: 200.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              height: 100.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              height: 80.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
            SizedBox(height: 16.h),
            Container(
              height: 150.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16.r),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoursesShimmer() {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade100,
      child: Column(
        children: List.generate(
          3,
          (index) => Container(
            height: 80.h,
            margin: EdgeInsets.only(bottom: 10.h),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.business_center_rounded,
            size: 80.sp,
            color: Colors.grey.shade300,
          ),
          SizedBox(height: 16.h),
          Text(
            'لا يوجد مركز تدريب',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            'لم يتم إعداد الملف التعريفي للمركز بعد',
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () {
              context
                  .read<TrainingCenterBloc>()
                  .add(const LoadTrainingCenters());
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 80.sp,
            color: Colors.red.shade400,
          ),
          SizedBox(height: 16.h),
          Text(
            'حدث خطأ',
            style: TextStyle(
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade700,
            ),
          ),
          SizedBox(height: 8.h),
          Text(
            message,
            style: TextStyle(
              fontSize: 14.sp,
              color: Colors.grey.shade500,
            ),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 16.h),
          ElevatedButton.icon(
            onPressed: () {
              context
                  .read<TrainingCenterBloc>()
                  .add(const LoadTrainingCenters());
            },
            icon: const Icon(Icons.refresh_rounded),
            label: const Text('إعادة المحاولة'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _launchEmail(String email) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (await canLaunchUrl(emailUri)) {
      await launchUrl(emailUri);
    }
  }

  Future<void> _launchPhone(String phone) async {
    final Uri phoneUri = Uri(
      scheme: 'tel',
      path: phone,
    );
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }
}
