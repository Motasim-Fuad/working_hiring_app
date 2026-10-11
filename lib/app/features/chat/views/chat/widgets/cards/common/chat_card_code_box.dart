import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';

/// Shows the work-completion code; 6-digit codes get large spaced digits.
class ChatCardCodeBox extends StatelessWidget {
  final String code;

  const ChatCardCodeBox({super.key, required this.code});

  @override
  Widget build(BuildContext context) {
    final isOtp = RegExp(r'^\d{6}$').hasMatch(code);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
      decoration: BoxDecoration(
        color: AppColors.primary.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: AppColors.primary.withValues(alpha: 0.4)),
      ),
      child: Text(
        code,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: isOtp ? 26.sp : 13.sp,
          fontWeight: FontWeight.w800,
          letterSpacing: isOtp ? 8 : 0,
          color: AppColors.primary,
        ),
      ),
    );
  }
}
