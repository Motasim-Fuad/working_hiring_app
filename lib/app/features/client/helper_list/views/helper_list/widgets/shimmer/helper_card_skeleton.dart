import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_box.dart';
import 'package:working_hiring/app/core/widgets/shimmer/shimmer_lines.dart';

/// Mirrors a helper list card: category row, profile row, stats, bio, buttons.
class HelperCardSkeleton extends StatelessWidget {
  const HelperCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox(width: 140.w, height: 16.h, radius: 6),
              const Spacer(),
              ShimmerBox(width: 24.r, height: 24.r, radius: 6),
            ],
          ),
          SizedBox(height: 16.h),
          Row(
            children: [
              ShimmerBox.circle(size: 52.r),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 120.w, height: 16.h, radius: 6),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 90.w, height: 12.h, radius: 6),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 150.w, height: 10.h, radius: 6),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              ShimmerBox(width: 70.w, height: 12.h, radius: 6),
              SizedBox(width: 16.w),
              ShimmerBox(width: 64.w, height: 12.h, radius: 6),
              const Spacer(),
              ShimmerBox(width: 56.w, height: 14.h, radius: 6),
            ],
          ),
          SizedBox(height: 12.h),
          const ShimmerLines(lines: 2),
          SizedBox(height: 16.h),
          Row(
            children: [
              Expanded(child: ShimmerBox(height: 48.h, radius: 12)),
              SizedBox(width: 12.w),
              Expanded(child: ShimmerBox(height: 48.h, radius: 12)),
            ],
          ),
        ],
      ),
    );
  }
}
