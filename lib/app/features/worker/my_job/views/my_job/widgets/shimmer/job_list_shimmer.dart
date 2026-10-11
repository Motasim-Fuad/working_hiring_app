import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_list.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/shimmer/job_card_skeleton.dart';

class JobListShimmer extends StatelessWidget {
  const JobListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerList(
      itemCount: 3,
      spacing: 0,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      itemBuilder: (_, _) => const JobCardSkeleton(),
    );
  }
}
