import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_box.dart';

/// Mirrors an order card: title + status badge, schedule rows, price, action.
class OrderCardSkeleton extends StatelessWidget {
  const OrderCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(child: ShimmerBox(height: 18.h, radius: 6)),
            SizedBox(width: 40.w),
            ShimmerBox(width: 72.w, height: 24.h, radius: 12),
          ],
        ),
        SizedBox(height: 16.h),
        for (final width in [0.55, 0.4, 0.65]) ...[
          Row(
            children: [
              ShimmerBox.circle(size: 18.r),
              SizedBox(width: 8.w),
              Expanded(
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: width,
                  child: ShimmerBox(height: 12.h, radius: 6),
                ),
              ),
            ],
          ),
          SizedBox(height: 10.h),
        ],
        SizedBox(height: 4.h),
        ShimmerBox(width: 64.w, height: 20.h, radius: 6),
        SizedBox(height: 14.h),
        ShimmerBox(height: 44.h, radius: 12),
      ],
    );
  }
}
