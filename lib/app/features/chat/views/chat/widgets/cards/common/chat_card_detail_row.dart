import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';

class ChatCardDetailRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool emphasize;
  final bool strike;

  const ChatCardDetailRow({
    super.key,
    required this.icon,
    required this.text,
    this.emphasize = false,
    this.strike = false,
  });

  @override
  Widget build(BuildContext context) {
    final color = emphasize ? AppColors.textPrimary : const Color(0xFF4A4A4A);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16.sp, color: AppColors.textSecondary),
        SizedBox(width: 10.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: 13.sp,
              height: 1.35,
              color: strike ? AppColors.textSecondary : color,
              fontWeight: emphasize ? FontWeight.w700 : FontWeight.w500,
              decoration: strike ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ],
    );
  }
}
