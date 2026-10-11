import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_hiring/app/data/models/availability_model.dart';

class HelperProfileSlotChip extends StatelessWidget {
  final DateSlot slot;

  const HelperProfileSlotChip({super.key, required this.slot});

  @override
  Widget build(BuildContext context) {
    final status = slot.status.toUpperCase();
    Color bg;
    Color fg;
    if (status == 'AVAILABLE') {
      bg = Color(0xFFE8F5E9);
      fg = Color(0xFF2E7D32);
    } else if (status == 'BOOKED') {
      bg = Colors.red.shade50;
      fg = Colors.red.shade400;
    } else {
      bg = Colors.grey.shade100;
      fg = Colors.grey.shade500;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: fg.withValues(alpha: 0.3)),
      ),
      child: Text(
        slot.slot,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}
