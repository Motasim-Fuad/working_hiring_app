import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/worker/home/controllers/worker_home_controller.dart';
import 'package:working_hiring/app/features/worker/home/views/worker_home/widgets/worker_home_date_action_chip.dart';

class WorkerHomeSpecialDateToggle extends GetView<WorkerHomeController> {
  final DateTime date;

  const WorkerHomeSpecialDateToggle({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.event, size: 18.sp, color: AppColors.textSecondary),
              SizedBox(width: 8.w),
              Text(
                "Special Date".tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          SizedBox(height: 4.h),
          Text(
            "This applies to this date only. Tap Available to fill in your usual daily hours."
                .tr,
            style: TextStyle(
              fontSize: 11.sp,
              color: AppColors.textSecondary,
              height: 1.3,
            ),
          ),
          SizedBox(height: 8.h),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            children: [
              WorkerHomeDateActionChip(
                label: "Available",
                icon: Icons.check_circle_outline,
                color: Color(0xFF6CA34D),
                onTap: () => controller.setSpecialDate(
                  date,
                  isAvailable: true,
                  startTime: controller.startTime.value,
                  endTime: controller.endTime.value,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Text(
            "To clear availability for a date, tap the selected time slot.".tr,
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 12.sp,
              height: 1.3,
            ),
          ),
        ],
      ),
    );
  }
}
