import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';

/// Task title with an optional client rating underneath.
class ChatCardTaskHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  final double? rating;

  const ChatCardTaskHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.rating,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 46.r,
          height: 46.r,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.primary.withValues(alpha: 0.18),
                AppColors.primary.withValues(alpha: 0.06),
              ],
            ),
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Icon(
            Icons.handyman_rounded,
            color: AppColors.primary,
            size: 24.sp,
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textPrimary,
                ),
              ),
              if (subtitle != null || rating != null) SizedBox(height: 4.h),
              Row(
                children: [
                  if (rating != null) ...[
                    Icon(Icons.star_rounded, size: 16.sp, color: Colors.amber),
                    SizedBox(width: 2.w),
                    Text(
                      rating!.toString(),
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    if (subtitle != null) SizedBox(width: 10.w),
                  ],
                  if (subtitle != null)
                    Flexible(
                      child: Text(
                        subtitle!,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
