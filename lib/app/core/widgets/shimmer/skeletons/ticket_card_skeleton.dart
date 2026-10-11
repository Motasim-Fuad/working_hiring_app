import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_box.dart';
import 'package:working_hiring/app/core/widgets/shimmer/shimmer_lines.dart';

/// Mirrors a support ticket card (shared by client and worker history).
class TicketCardSkeleton extends StatelessWidget {
  const TicketCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox.circle(size: 36.r),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 110.w, height: 14.h, radius: 6),
                    SizedBox(height: 6.h),
                    ShimmerBox(width: 70.w, height: 10.h, radius: 6),
                  ],
                ),
              ),
              ShimmerBox(width: 56.w, height: 22.h, radius: 20),
            ],
          ),
          SizedBox(height: 16.h),
          ShimmerBox(width: 200.w, height: 16.h, radius: 6),
          SizedBox(height: 8.h),
          ShimmerBox(width: 90.w, height: 12.h, radius: 6),
          SizedBox(height: 12.h),
          const ShimmerLines(lines: 3),
        ],
      ),
    );
  }
}
