import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_box.dart';

/// A single chat bubble placeholder, aligned like a sent or received message.
class ChatBubbleSkeleton extends StatelessWidget {
  final bool isMe;
  final double widthFactor;
  final double height;

  const ChatBubbleSkeleton({
    super.key,
    required this.isMe,
    required this.widthFactor,
    this.height = 40,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: ShimmerBox(height: height.h, radius: 14.r),
      ),
    );
  }
}
