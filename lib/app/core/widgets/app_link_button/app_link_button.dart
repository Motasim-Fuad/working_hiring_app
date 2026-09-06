import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../../constants/app_colors.dart';
import '../responsive_layout.dart';

class AppLinkButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;
  final bool underline;

  const AppLinkButton({
    super.key,
    required this.text,
    required this.onTap,
    this.color = AppColors.primary,
    this.underline = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque, // Makes the entire area clickable
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 2.w),
        child: Text(
          text,
          style: TextStyle(
            fontSize: AppResponsive.font(14),
            color: color,
            fontWeight: FontWeight.w600,
            decoration: underline ? TextDecoration.underline : TextDecoration.none,
          ),
        ),
      ),
    );
  }
}
