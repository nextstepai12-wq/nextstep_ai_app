// lib/features/TrainingCenter/presentation/widgets/program_card.dart

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../data/models/course_model.dart';

class ProgramCard extends StatelessWidget {
  final CourseModel program; // ✅ تغيير النوع إلى CourseModel
  final VoidCallback? onTap;

  const ProgramCard({
    super.key,
    required this.program,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 160.w,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12.r),
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
            ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12.r)),
              child: program.coverImage != null
                  ? Image.network(
                      program.coverImage!,
                      height: 80.h,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        height: 80.h,
                        color: Colors.blue.shade100,
                        child: Icon(
                          Icons.menu_book_rounded,
                          size: 32.sp,
                          color: Colors.blue.shade700,
                        ),
                      ),
                    )
                  : Container(
                      height: 80.h,
                      color: Colors.blue.shade100,
                      child: Icon(
                        Icons.menu_book_rounded,
                        size: 32.sp,
                        color: Colors.blue.shade700,
                      ),
                    ),
            ),
            Padding(
              padding: EdgeInsets.all(8.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.title,
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 2.h),
                  if (program.description != null)
                    Text(
                      program.description!,
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: 4.h),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        program.price > 0
                            ? '${program.price.toStringAsFixed(0)} ريال'
                            : 'مجاني',
                        style: TextStyle(
                          fontSize: 12.sp,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 12.sp,
                            color: Colors.amber.shade600,
                          ),
                          SizedBox(width: 2.w),
                          Text(
                            program.rating?.toStringAsFixed(1) ?? '0.0',
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}