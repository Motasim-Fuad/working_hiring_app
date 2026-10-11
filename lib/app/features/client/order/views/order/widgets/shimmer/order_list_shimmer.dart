import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_list.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/shimmer/order_card_skeleton.dart';

class OrderListShimmer extends StatelessWidget {
  const OrderListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerList(
      itemCount: 3,
      spacing: 32,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemBuilder: (_, _) => const OrderCardSkeleton(),
    );
  }
}
