import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_box.dart';

/// Mirrors a saved helper card: avatar + name/rating/location, chips, rate.
class SavedHelperCardSkeleton extends StatelessWidget {
  const SavedHelperCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ShimmerBox.circle(size: 52.r),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ShimmerBox(width: 130.w, height: 16.h, radius: 6),
                    SizedBox(height: 8.h),
                    ShimmerBox(width: 100.w, height: 12.h, radius: 6),
                    SizedBox(height: 8.h),
                    ShimmerBox(width: 150.w, height: 10.h, radius: 6),
                  ],
                ),
              ),
              ShimmerBox(width: 24.r, height: 24.r, radius: 6),
            ],
          ),
          SizedBox(height: 12.h),
          Wrap(
            spacing: 6.w,
            runSpacing: 4.h,
            children: [
              for (final width in [70.0, 86.0, 60.0])
                ShimmerBox(width: width.w, height: 30.h, radius: 16),
            ],
          ),
          SizedBox(height: 10.h),
          ShimmerBox(width: 80.w, height: 16.h, radius: 6),
        ],
      ),
    );
  }
}
