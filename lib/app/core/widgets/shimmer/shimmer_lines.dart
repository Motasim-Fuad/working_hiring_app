import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/shimmer/shimmer_box.dart';

/// Paragraph placeholder: full-width lines with a shorter last line.
class ShimmerLines extends StatelessWidget {
  final int lines;
  final double lineHeight;
  final double spacing;
  final double lastLineFactor;

  const ShimmerLines({
    super.key,
    this.lines = 2,
    this.lineHeight = 12,
    this.spacing = 8,
    this.lastLineFactor = 0.6,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < lines; i++) ...[
          if (i > 0) SizedBox(height: spacing.h),
          FractionallySizedBox(
            widthFactor: i == lines - 1 ? lastLineFactor : 1,
            child: ShimmerBox(height: lineHeight.h, radius: 6),
          ),
        ],
      ],
    );
  }
}
