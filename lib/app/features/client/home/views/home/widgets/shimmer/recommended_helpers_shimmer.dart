import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/app_shimmer.dart';
import 'package:working_hiring/app/core/widgets/shimmer/shimmer_box.dart';

/// Compact helper rows: avatar, name, rating line and chevron.
class RecommendedHelpersShimmer extends StatelessWidget {
  const RecommendedHelpersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: Column(
        children: [
          for (var i = 0; i < 3; i++) ...[
            if (i > 0) SizedBox(height: 10.h),
            Padding(
              padding: EdgeInsets.all(12.w),
              child: Row(
                children: [
                  const ShimmerBox.circle(size: 40),
                  SizedBox(width: 15.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ShimmerBox(width: 120.w, height: 14.h, radius: 6),
                        SizedBox(height: 6.h),
                        ShimmerBox(width: 80.w, height: 10.h, radius: 6),
                      ],
                    ),
                  ),
                  ShimmerBox(width: 16.w, height: 16.w, radius: 4),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
