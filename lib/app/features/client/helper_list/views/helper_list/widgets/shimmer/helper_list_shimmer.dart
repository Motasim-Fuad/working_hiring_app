import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_list.dart';
import 'package:working_hiring/app/features/client/helper_list/views/helper_list/widgets/shimmer/helper_card_skeleton.dart';

class HelperListShimmer extends StatelessWidget {
  const HelperListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerList(
      itemCount: 3,
      spacing: 16.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      itemBuilder: (_, _) => const HelperCardSkeleton(),
    );
  }
}
