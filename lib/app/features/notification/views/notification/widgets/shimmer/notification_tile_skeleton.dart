import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_box.dart';
import 'package:working_hiring/app/core/widgets/shimmer/shimmer_lines.dart';

class NotificationTileSkeleton extends StatelessWidget {
  const NotificationTileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ShimmerBox.circle(size: 48.r),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ShimmerBox(width: 140.w, height: 14.h, radius: 6),
                SizedBox(height: 8.h),
                const ShimmerLines(lines: 2),
              ],
            ),
          ),
          SizedBox(width: 8.w),
          ShimmerBox(width: 60.w, height: 10.h, radius: 6),
        ],
      ),
    );
  }
}
