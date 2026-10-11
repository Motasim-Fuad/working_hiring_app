import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_list.dart';
import 'package:working_hiring/app/core/widgets/shimmer/skeletons/ticket_card_skeleton.dart';

class TicketListShimmer extends StatelessWidget {
  const TicketListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerList(
      itemCount: 4,
      spacing: 12.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemBuilder: (_, _) => const TicketCardSkeleton(),
    );
  }
}
