import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/core/widgets/shimmer/shimmer_box.dart';

/// Mirrors a conversation row in MessageListView: avatar, name + time, preview.
class ChatListTileSkeleton extends StatelessWidget {
  final double nameWidthFactor;

  const ChatListTileSkeleton({super.key, this.nameWidthFactor = 0.45});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      child: Row(
        children: [
          ShimmerBox.circle(size: AppResponsive.icon(28) * 2),
          SizedBox(width: 16.w),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ShimmerBox(
                        width: constraints.maxWidth * nameWidthFactor,
                        height: 14.h,
                        radius: 6,
                      ),
                      const Spacer(),
                      ShimmerBox(width: 28.w, height: 10.h, radius: 5),
                    ],
                  ),
                  SizedBox(height: 10.h),
                  ShimmerBox(
                    width: constraints.maxWidth * 0.75,
                    height: 12.h,
                    radius: 6,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
