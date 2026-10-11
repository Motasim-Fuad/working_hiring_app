import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_list.dart';
import 'package:working_hiring/app/features/client/saved_helpers/views/saved_helpers/widgets/shimmer/saved_helper_card_skeleton.dart';

class SavedHelpersShimmer extends StatelessWidget {
  const SavedHelpersShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerList(
      itemCount: 4,
      spacing: 16.h,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      itemBuilder: (_, _) => const SavedHelperCardSkeleton(),
    );
  }
}
