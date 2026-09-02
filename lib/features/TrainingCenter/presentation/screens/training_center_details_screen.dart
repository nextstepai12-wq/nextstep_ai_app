// lib/features/TrainingCenter/presentation/screens/training_center_details_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../blocs/training_center_bloc/training_center_bloc.dart';

class TrainingCenterDetailsScreen extends StatelessWidget {
  final String centerId;

  const TrainingCenterDetailsScreen({super.key, required this.centerId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل المركز'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<TrainingCenterBloc, TrainingCenterState>(
        builder: (context, state) {
          if (state is TrainingCenterLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل البيانات...'),
                ],
              ),
            );
          }

          if (state is TrainingCenterDetailsLoaded) {
            final center = state.center;
            return _buildCenterDetails(context, center);
          }

          if (state is TrainingCenterLoaded) {
            // إذا كانت الحالة تحوي قائمة المراكز، نبحث عن المركز المطلوب
            final center = state.centers.firstWhere(
              (c) => c.id == centerId,
              orElse: () => state.centers.first,
            );
            return _buildCenterDetails(context, center);
          }

          if (state is TrainingCenterError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 60.sp,
                    color: Colors.red.shade400,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    'حدث خطأ: ${state.message}',
                    style: TextStyle(fontSize: 16.sp),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16.h),
                  ElevatedButton(
                    onPressed: () {
                      context
                          .read<TrainingCenterBloc>()
                          .add(LoadTrainingCenterDetails(centerId));
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('لا توجد بيانات'));
        },
      ),
    );
  }

  Widget _buildCenterDetails(BuildContext context, dynamic center) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة المركز
          Center(
            child: CircleAvatar(
              radius: 50.r,
              backgroundImage: center.logoUrl != null
                  ? NetworkImage(center.logoUrl!)
                  : null,
              child: center.logoUrl == null
                  ? Icon(
                      Icons.business,
                      size: 50.sp,
                      color: Colors.grey.shade400,
                    )
                  : null,
            ),
          ),
          SizedBox(height: 16.h),

          // اسم المركز
          Center(
            child: Text(
              center.name,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          SizedBox(height: 8.h),

          // التقييم والطلاب
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (center.rating != null) ...[
                Icon(
                  Icons.star,
                  color: Colors.amber.shade600,
                  size: 18.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  center.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 16.w),
              ],
              if (center.studentCount != null) ...[
                Icon(
                  Icons.people,
                  color: Colors.blue.shade600,
                  size: 18.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${center.studentCount} طالب',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
          if (center.isVerified) ...[
            SizedBox(height: 8.h),
            Center(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: Colors.green.shade100,
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.verified,
                      color: Colors.green.shade700,
                      size: 16.sp,
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      'مركز معتمد',
                      style: TextStyle(
                        color: Colors.green.shade700,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
          SizedBox(height: 16.h),

          // الوصف
          if (center.description != null) ...[
            Text(
              'الوصف',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              center.description!,
              style: TextStyle(fontSize: 14.sp, height: 1.5),
            ),
            SizedBox(height: 16.h),
          ],

          // العنوان
          if (center.address != null) ...[
            Text(
              'العنوان',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: Colors.grey.shade600,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    center.address!,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
          ],

          // الاتصال
          if (center.phone != null || center.email != null) ...[
            Text(
              'معلومات الاتصال',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            if (center.phone != null)
              Row(
                children: [
                  Icon(
                    Icons.phone,
                    color: Colors.grey.shade600,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    center.phone!,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
            if (center.email != null) ...[
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(
                    Icons.email,
                    color: Colors.grey.shade600,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    center.email!,
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
            ],
            SizedBox(height: 16.h),
          ],

          // التخصصات
          if (center.specialties != null && center.specialties!.isNotEmpty) ...[
            Text(
              'التخصصات',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: center.specialties!.map((specialty) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.blue.shade200),
                  ),
                  child: Text(
                    specialty,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
          ],

          // زر عرض البرامج
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(
                  context,
                  '/training-center/programs',
                  arguments: {'centerId': center.id},
                );
              },
              icon: const Icon(Icons.menu_book_rounded),
              label: const Text('عرض برامج المركز'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade700,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(vertical: 14.h),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}