import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_list.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/shimmer/chat_bubble_skeleton.dart';

/// Placeholder conversation shown while a room's history is first loading.
/// Includes one taller block for the order card that most rooms start with.
class ChatHistoryShimmer extends StatelessWidget {
  const ChatHistoryShimmer({super.key});

  static const List<(bool isMe, double width, double height)> _bubbles = [
    (false, 0.78, 150),
    (false, 0.55, 40),
    (true, 0.45, 40),
    (true, 0.62, 56),
    (false, 0.4, 40),
    (true, 0.5, 40),
  ];

  @override
  Widget build(BuildContext context) {
    return ShimmerList(
      itemCount: _bubbles.length,
      padding: EdgeInsets.fromLTRB(16.w, 16.h, 16.w, 0),
      itemBuilder: (_, index) {
        final (isMe, width, height) = _bubbles[index];
        return ChatBubbleSkeleton(
          isMe: isMe,
          widthFactor: width,
          height: height,
        );
      },
    );
  }
}
