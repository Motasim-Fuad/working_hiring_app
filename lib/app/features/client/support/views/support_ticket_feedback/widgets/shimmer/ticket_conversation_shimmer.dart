import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/app_shimmer.dart';
import 'package:working_hiring/app/core/widgets/shimmer/shimmer_box.dart';
import 'package:working_hiring/app/core/widgets/shimmer/shimmer_lines.dart';
import 'package:working_hiring/app/core/widgets/shimmer/skeletons/ticket_card_skeleton.dart';

/// Ticket summary card followed by alternating admin/user reply bubbles.
class TicketConversationShimmer extends StatelessWidget {
  const TicketConversationShimmer({super.key});

  Widget _bubble(BuildContext context, {required bool alignEnd}) {
    return Align(
      alignment: alignEnd ? Alignment.centerRight : Alignment.centerLeft,
      child: SizedBox(
        width: MediaQuery.sizeOf(context).width * 0.65,
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  ShimmerBox.circle(size: 24.r),
                  SizedBox(width: 8.w),
                  ShimmerBox(width: 80.w, height: 12.h, radius: 6),
                ],
              ),
              SizedBox(height: 12.h),
              const ShimmerLines(lines: 2),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShimmer(
      child: ListView(
        physics: const NeverScrollableScrollPhysics(),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
        children: [
          const TicketCardSkeleton(),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 24.h),
            child: Center(
              child: ShimmerBox(width: 120.w, height: 10.h, radius: 6),
            ),
          ),
          _bubble(context, alignEnd: false),
          SizedBox(height: 12.h),
          _bubble(context, alignEnd: true),
          SizedBox(height: 12.h),
          _bubble(context, alignEnd: false),
        ],
      ),
    );
  }
}
