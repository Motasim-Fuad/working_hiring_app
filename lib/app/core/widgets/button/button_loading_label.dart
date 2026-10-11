import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/core/widgets/button/button_label.dart';

/// "Please wait..." style label used by buttons instead of a shimmer.
class ButtonLoadingLabel extends StatelessWidget {
  final String text;
  final Color color;

  const ButtonLoadingLabel({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = AppResponsive.icon(16);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: size,
          height: size,
          child: CircularProgressIndicator(strokeWidth: 2, color: color),
        ),
        SizedBox(width: 10.w),
        Flexible(
          child: ButtonLabel(text: text, color: color),
        ),
      ],
    );
  }
}
