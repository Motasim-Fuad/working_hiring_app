import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/worker/home/controllers/worker_home_controller.dart';
import 'package:working_hiring/app/features/worker/home/views/worker_home/widgets/worker_home_special_date_toggle.dart';

class WorkerHomeTimeSlotPanel extends GetView<WorkerHomeController> {
  const WorkerHomeTimeSlotPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final date = controller.selectedDate.value!;
    final dateStr = DateFormat('MMM d, yyyy').format(date);
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Slots For Date'.trParams({'date': dateStr}),
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: () => controller.selectedDate.value = null,
                child: Icon(Icons.close, size: 20.sp, color: Colors.grey),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          WorkerHomeSpecialDateToggle(date: date),
          SizedBox(height: 16.h),
          Obx(
            () => Wrap(
              spacing: 12,
              runSpacing: 12,
              children: controller.allTimeSlots.map((slot) {
                final slotState = controller.effectiveSlotState(date, slot);
                final bool isAvailable = slotState == SlotState.available;
                final bool isBooked = slotState == SlotState.booked;
                final bool matchesFilter =
                    controller.selectedHour.value == slot;

                Color bgColor = Color(0xFFF5F5F5);
                Color textColor = AppColors.textPrimary;
                Color borderColor = Colors.transparent;
                const TextDecoration textDecoration = TextDecoration.none;

                if (isAvailable) {
                  bgColor = Color(0xFF6CA34D);
                  textColor = Colors.white;
                  borderColor = Color(0xFF6CA34D);
                } else if (isBooked) {
                  bgColor = Color(0xFFEF5350);
                  textColor = Colors.white;
                  borderColor = Color(0xFFEF5350);
                }

                if (matchesFilter) {
                  borderColor = isAvailable ? Colors.white : Colors.blueAccent;
                }

                return GestureDetector(
                  onTap: isBooked
                      ? null
                      : () => controller.toggleTimeSlot(slot),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 200),
                    padding: EdgeInsets.symmetric(
                      horizontal: 14.w,
                      vertical: 10.h,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: matchesFilter ? Colors.blueAccent : borderColor,
                        width: matchesFilter ? 2.0 : 1.0,
                      ),
                      boxShadow: matchesFilter
                          ? [
                              BoxShadow(
                                color: Colors.blueAccent.withValues(alpha: 0.3),
                                blurRadius: 8,
                                spreadRadius: 2,
                              ),
                            ]
                          : [],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isAvailable) ...[
                          Icon(Icons.check, color: Colors.white, size: 16.sp),
                          SizedBox(width: 6.w),
                        ],
                        if (isBooked) ...[
                          Icon(Icons.block, color: Colors.white54, size: 16.sp),
                          SizedBox(width: 6.w),
                        ],
                        Text(
                          slot,
                          style: TextStyle(
                            color: textColor,
                            fontWeight: (isAvailable || matchesFilter)
                                ? FontWeight.bold
                                : FontWeight.w500,
                            fontSize: 13.sp,
                            decoration: textDecoration,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
