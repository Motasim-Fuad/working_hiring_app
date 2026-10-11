import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/models/order_model.dart';

class OrderCountdown extends StatelessWidget {
  final OrderModel order;

  const OrderCountdown({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    if (order.status != 'CONFIRM') return SizedBox.shrink();
    if (order.workingDate == null) return SizedBox.shrink();
    try {
      final target = DateTime.parse(order.workingDate!);
      final diff = target.difference(DateTime.now());
      if (diff.isNegative) return SizedBox.shrink();
      return Container(
        margin: EdgeInsets.only(top: 12.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Color(0xFFF0F7EB),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.timer_outlined, size: 16.sp, color: Color(0xFF6CA34D)),
            SizedBox(width: 8.w),
            Text(
              'Starts In'.trParams({
                'hours': '${diff.inHours}',
                'minutes': '${diff.inMinutes % 60}',
              }),
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6CA34D),
              ),
            ),
          ],
        ),
      );
    } catch (_) {
      return SizedBox.shrink();
    }
  }
}
