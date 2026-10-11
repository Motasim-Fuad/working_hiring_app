import 'package:flutter/material.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_list.dart';
import 'package:working_hiring/app/features/notification/views/notification/widgets/shimmer/notification_tile_skeleton.dart';

class NotificationListShimmer extends StatelessWidget {
  const NotificationListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return ShimmerList(
      itemCount: 7,
      spacing: 1,
      itemBuilder: (_, _) => const NotificationTileSkeleton(),
    );
  }
}
