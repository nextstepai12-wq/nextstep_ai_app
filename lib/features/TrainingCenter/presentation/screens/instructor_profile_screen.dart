// lib/features/TrainingCenter/presentation/screens/instructor_profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../blocs/instructor_bloc/instructor_bloc.dart';

class InstructorProfileScreen extends StatelessWidget {
  final String instructorId;

  const InstructorProfileScreen({super.key, required this.instructorId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ملف المدرب'),
        centerTitle: true,
      ),
      body: BlocBuilder<InstructorBloc, InstructorState>(
        builder: (context, state) {
          if (state is InstructorLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is InstructorLoaded) {
            final instructor = state.instructor;
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 60.r,
                    backgroundImage: instructor.avatarUrl != null
                        ? NetworkImage(instructor.avatarUrl!)
                        : null,
                    child: instructor.avatarUrl == null
                        ? Icon(Icons.person, size: 60.sp)
                        : null,
                  ),
                  SizedBox(height: 16.h),
                  Text(
                    instructor.name,
                    style: TextStyle(
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    instructor.specialty ?? '',
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  if (instructor.bio != null) ...[
                    SizedBox(height: 16.h),
                    Text(
                      instructor.bio!,
                      style: TextStyle(fontSize: 14.sp),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (instructor.experienceYears != null) ...[
                    SizedBox(height: 8.h),
                    Text(
                      'الخبرة: ${instructor.experienceYears} سنوات',
                      style: TextStyle(fontSize: 14.sp),
                    ),
                  ],
                  if (instructor.rating != null) ...[
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.star,
                          color: Colors.amber.shade600,
                          size: 20.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          instructor.rating!.toStringAsFixed(1),
                          style: TextStyle(fontSize: 16.sp),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            );
          }

          if (state is InstructorError) {
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
                          .read<InstructorBloc>()
                          .add(LoadInstructorProfile(instructorId));
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
}