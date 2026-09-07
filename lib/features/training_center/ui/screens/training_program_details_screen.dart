// lib/features/training_center/ui/screens/training_program_details_screen.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../logic/training_programs_bloc/training_programs_bloc.dart';

class TrainingProgramDetailsScreen extends StatelessWidget {
  final String programId;

  const TrainingProgramDetailsScreen({super.key, required this.programId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('تفاصيل البرنامج'),
        centerTitle: true,
        backgroundColor: Colors.blue.shade700,
        foregroundColor: Colors.white,
      ),
      body: BlocBuilder<TrainingProgramsBloc, TrainingProgramsState>(
        builder: (context, state) {
          if (state is TrainingProgramsLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('جاري تحميل تفاصيل البرنامج...'),
                ],
              ),
            );
          }

          if (state is TrainingProgramDetailsLoaded) {
            final program = state.program;
            return _buildProgramDetails(context, program);
          }

          if (state is TrainingProgramsLoaded) {
            // إذا كانت الحالة تحوي قائمة البرامج، نبحث عن البرنامج المطلوب
            final program = state.programs.firstWhere(
              (p) => p.id == programId,
              orElse: () => state.programs.first,
            );
            return _buildProgramDetails(context, program);
          }

          if (state is TrainingProgramsError) {
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
                          .read<TrainingProgramsBloc>()
                          .add(LoadProgramDetails(programId));
                    },
                    child: const Text('إعادة المحاولة'),
                  ),
                ],
              ),
            );
          }

          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.info_outline,
                  size: 60,
                  color: Colors.grey,
                ),
                SizedBox(height: 16),
                Text('لا توجد بيانات'),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProgramDetails(BuildContext context, dynamic program) {
    return SingleChildScrollView(
      padding: EdgeInsets.all(16.r),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // صورة البرنامج
          ClipRRect(
            borderRadius: BorderRadius.circular(12.r),
            child: program.imageUrl != null
                ? Image.network(
                    program.imageUrl!,
                    height: 200.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 200.h,
                      color: Colors.blue.shade100,
                      child: Center(
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 60.sp,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    ),
                  )
                : Container(
                    height: 200.h,
                    color: Colors.blue.shade100,
                    child: Center(
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 60.sp,
                        color: Colors.blue.shade700,
                      ),
                    ),
                  ),
          ),
          SizedBox(height: 16.h),

          // عنوان البرنامج
          Text(
            program.title,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8.h),

          // الفئة والمستوى
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: [
              if (program.category != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    program.category!,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.blue.shade700,
                    ),
                  ),
                ),
              if (program.level != null)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'مستوى ${program.level!}',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green.shade700,
                    ),
                  ),
                ),
              if (program.isActive)
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'متاح',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green.shade700,
                    ),
                  ),
                )
              else
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    'غير متاح',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.red.shade700,
                    ),
                  ),
                ),
            ],
          ),
          SizedBox(height: 16.h),

          // التقييم والمدة والسعر
          Row(
            children: [
              if (program.rating != null) ...[
                Icon(
                  Icons.star,
                  color: Colors.amber.shade600,
                  size: 20.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  program.rating.toStringAsFixed(1),
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(width: 16.w),
              ],
              if (program.durationHours != null) ...[
                Icon(
                  Icons.timer,
                  color: Colors.grey.shade600,
                  size: 20.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${program.durationHours} ساعة',
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
                SizedBox(width: 16.w),
              ],
              if (program.price != null) ...[
                Icon(
                  Icons.money,
                  color: Colors.green.shade600,
                  size: 20.sp,
                ),
                SizedBox(width: 4.w),
                Text(
                  '${program.price!.toStringAsFixed(0)} ${program.currency ?? 'SAR'}',
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.green.shade700,
                  ),
                ),
              ],
            ],
          ),
          SizedBox(height: 16.h),

          // الوصف
          if (program.description != null) ...[
            Text(
              'الوصف',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              program.description!,
              style: TextStyle(
                fontSize: 14.sp,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16.h),
          ],

          // المتطلبات الأساسية
          if (program.prerequisites != null && program.prerequisites!.isNotEmpty) ...[
            Text(
              'المتطلبات الأساسية',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            ...program.prerequisites!.map((prereq) {
              return Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '• ',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.blue.shade700,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        prereq,
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ),
                  ],
                ),
              );
            }),
            SizedBox(height: 16.h),
          ],

          // المهارات المكتسبة
          if (program.skillsLearned != null && program.skillsLearned!.isNotEmpty) ...[
            Text(
              'المهارات المكتسبة',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: program.skillsLearned!.map((skill) {
                return Container(
                  padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(20.r),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Text(
                    skill,
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.green.shade700,
                    ),
                  ),
                );
              }).toList(),
            ),
            SizedBox(height: 16.h),
          ],

          // تاريخ البدء والانتهاء
          if (program.startDate != null || program.endDate != null) ...[
            Text(
              'التواريخ',
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8.h),
            if (program.startDate != null)
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.grey.shade600,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'يبدأ: ${_formatDate(program.startDate!)}',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
            if (program.endDate != null) ...[
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(
                    Icons.calendar_today,
                    color: Colors.grey.shade600,
                    size: 18.sp,
                  ),
                  SizedBox(width: 8.w),
                  Text(
                    'ينتهي: ${_formatDate(program.endDate!)}',
                    style: TextStyle(fontSize: 14.sp),
                  ),
                ],
              ),
            ],
            SizedBox(height: 16.h),
          ],

          // زر التقديم
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: program.isActive
                  ? () {
                      context.push(
                        '/training-center/apply',
                        extra: program.id,
                      );
                    }
                  : null,
              icon: const Icon(Icons.send),
              label: Text(
                program.isActive ? 'تقديم طلب' : 'غير متاح حالياً',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    program.isActive ? Colors.blue.shade700 : Colors.grey.shade400,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}