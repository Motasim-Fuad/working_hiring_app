import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';

class OrderStatusBadge extends StatelessWidget {
  final String status;

  const OrderStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bg;
    Color text;
    String label;

    switch (status) {
      case 'PENDING':
        bg = Color(0xFFE5F0FF);
        text = Color(0xFF007AFF);
        label = AppStrings.created.tr;
      case 'IN_PROGRESS':
        bg = Color(0xFFFFF4E5);
        text = Color(0xFFFF9500);
        label = AppStrings.progress.tr;
      case 'COMPLETED':
        bg = Color(0xFFE8FCEC);
        text = Color(0xFF28A745);
        label = AppStrings.completed.tr;
      case 'CONFIRM':
        bg = Color(0xFFE8FCEC);
        text = Color(0xFF28A745);
        label = "Confirmed";
      case 'CANCELLATION_REQUEST':
        bg = Color(0xFFFFF4E5);
        text = Color(0xFFFF9500);
        label = "Cancellation Pending";
      case 'ACCEPT':
        bg = Color(0xFFFFF4E5);
        text = Color(0xFFFF9500);
        label = "Accepted";
      case 'CANCELLED':
        bg = Color(0xFFFFE5E5);
        text = Color(0xFFFF3B30);
        label = "Cancelled";
      default:
        bg = Color(0xFFE5F0FF);
        text = Color(0xFF007AFF);
        label = status;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(100.r),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: text,
          fontWeight: FontWeight.w600,
          fontSize: 12.sp,
        ),
      ),
    );
  }
}
