import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/app_shimmer.dart';
import 'package:working_hiring/app/core/widgets/shimmer/shimmer_box.dart';
import 'package:working_hiring/app/core/widgets/shimmer/shimmer_lines.dart';

/// Helper/worker profile layout: centred avatar header, bio, pricing card,
/// availability day strip, skill chips and a review summary.
class ProfilePageSkeleton extends StatelessWidget {
  final double avatarSize;
  final EdgeInsetsGeometry padding;

  const ProfilePageSkeleton({
    super.key,
    required this.avatarSize,
    required this.padding,
  });

  Widget _sectionTitle() => Padding(
    padding: EdgeInsets.only(bottom: 12.h),
    child: ShimmerBox(width: 120.w, height: 18.h, radius: 6),
  );

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  ShimmerBox.circle(size: avatarSize),
                  SizedBox(height: 16.h),
                  ShimmerBox(width: 160.w, height: 22.h, radius: 6),
                  SizedBox(height: 10.h),
                  ShimmerBox(width: 120.w, height: 12.h, radius: 6),
                ],
              ),
            ),
            SizedBox(height: 32.h),
            _sectionTitle(),
            const ShimmerLines(lines: 3),
            SizedBox(height: 32.h),
            _sectionTitle(),
            ShimmerBox(height: 96.h, radius: 14),
            SizedBox(height: 32.h),
            _sectionTitle(),
            Row(
              children: [
                for (var i = 0; i < 5; i++) ...[
                  if (i > 0) SizedBox(width: 10.w),
                  ShimmerBox(width: 52.w, height: 64.h, radius: 12),
                ],
              ],
            ),
            SizedBox(height: 32.h),
            _sectionTitle(),
            Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                for (final width in [80.0, 64.0, 96.0, 72.0])
                  ShimmerBox(width: width.w, height: 34.h, radius: 20),
              ],
            ),
            SizedBox(height: 32.h),
            _sectionTitle(),
            ShimmerBox(height: 120.h, radius: 16),
          ],
        ),
      ),
    );
  }
}
