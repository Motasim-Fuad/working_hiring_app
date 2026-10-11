import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_list.dart';
import 'package:working_hiring/app/features/chat/views/message_list/widgets/chat_list_tile_skeleton.dart';

class ChatListShimmer extends StatelessWidget {
  const ChatListShimmer({super.key});

  static const List<double> _nameWidths = [0.5, 0.35, 0.6, 0.42, 0.55, 0.38];

  @override
  Widget build(BuildContext context) {
    return ShimmerList(
      itemCount: _nameWidths.length,
      spacing: 1,
      padding: EdgeInsets.symmetric(vertical: 8.h),
      itemBuilder: (_, index) =>
          ChatListTileSkeleton(nameWidthFactor: _nameWidths[index]),
    );
  }
}
