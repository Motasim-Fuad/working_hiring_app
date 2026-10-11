import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/app_shimmer.dart';
import 'package:working_hiring/app/core/widgets/shimmer/shimmer_box.dart';

/// Order header + status, placed date, then label/value info tiles.
class OrderDetailShimmer extends StatelessWidget {
  const OrderDetailShimmer({super.key});

  Widget _tile(double valueWidth) => Padding(
    padding: EdgeInsets.only(bottom: 16.h),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShimmerBox(width: 90.w, height: 14.h, radius: 6),
        SizedBox(height: 6.h),
        ShimmerBox(width: valueWidth.w, height: 12.h, radius: 6),
      ],
    ),
  );

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ShimmerBox(width: 120.w, height: 18.h, radius: 6),
                ShimmerBox(width: 80.w, height: 22.h, radius: 12),
              ],
            ),
            SizedBox(height: 8.h),
            ShimmerBox(width: 150.w, height: 12.h, radius: 6),
            SizedBox(height: 20.h),
            _tile(180),
            _tile(260),
            Padding(
              padding: EdgeInsets.only(bottom: 16.h),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ShimmerBox(width: 70.w, height: 14.h, radius: 6),
                  ShimmerBox(width: 60.w, height: 18.h, radius: 6),
                ],
              ),
            ),
            for (final width in [200.0, 240.0, 140.0, 140.0, 120.0])
              _tile(width),
          ],
        ),
      ),
    );
  }
}
