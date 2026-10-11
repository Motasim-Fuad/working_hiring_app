import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/worker/home/controllers/worker_home_controller.dart';

class WorkerHomeDailyAvailableTime extends GetView<WorkerHomeController> {
  const WorkerHomeDailyAvailableTime({super.key});

  @override
  Widget build(BuildContext context) {
    final List<String> hoursList = [
      '06:00 AM',
      '07:00 AM',
      '08:00 AM',
      '09:00 AM',
      '10:00 AM',
      '11:00 AM',
      '12:00 PM',
      '01:00 PM',
      '02:00 PM',
      '03:00 PM',
      '04:00 PM',
      '05:00 PM',
      '06:00 PM',
      '07:00 PM',
      '08:00 PM',
      '09:00 PM',
      '10:00 PM',
    ];

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Set Daily Available Time".tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              "Applicable to each selected day of every week.".tr,
              style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 16.h),
            Text(
              "Select Days".tr,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.w500,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => Wrap(
                spacing: 6,
                runSpacing: 6,
                children: WorkerHomeController.weekDays.map((day) {
                  final isSelected = controller.selectedDaysOfWeek.contains(
                    day,
                  );
                  return GestureDetector(
                    onTap: () => controller.toggleDayOfWeek(day),
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 14.w,
                        vertical: 8.h,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Color(0xFF6CA34D)
                            : Colors.grey.shade200,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Text(
                        day,
                        style: TextStyle(
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.startTime.value,
                      decoration: InputDecoration(
                        labelText: 'Start Time'.tr,
                        labelStyle: TextStyle(fontSize: 12.sp),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        isDense: true,
                      ),
                      items: hoursList
                          .map(
                            (h) => DropdownMenuItem(
                              value: h,
                              child: Text(h, style: TextStyle(fontSize: 14.sp)),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) controller.startTime.value = val;
                      },
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0.w),
                  child: Text(
                    "-".tr,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
                Expanded(
                  child: Obx(
                    () => DropdownButtonFormField<String>(
                      initialValue: controller.endTime.value,
                      decoration: InputDecoration(
                        labelText: 'Ending Time'.tr,
                        labelStyle: TextStyle(fontSize: 12.sp),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 8.h,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade100,
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        isDense: true,
                      ),
                      items: hoursList
                          .map(
                            (h) => DropdownMenuItem(
                              value: h,
                              child: Text(h, style: TextStyle(fontSize: 14.sp)),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        if (val != null) controller.endTime.value = val;
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Obx(() {
              final synced = controller.isPatternSynced;
              final saving = controller.isSavingTime.value;
              return SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: (synced || saving)
                      ? null
                      : controller.setDailyAvailableTime,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6CA34D),
                    disabledBackgroundColor: Color(0xFFE8F5E9),
                    elevation: 0,
                    minimumSize: Size(double.infinity, 48.h),
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: saving
                      ? SizedBox(
                          height: 20.h,
                          width: 20.h,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : Text(
                          (synced
                                  ? "Already up to date ✓"
                                  : "Set Daily Available Time")
                              .tr,
                          style: TextStyle(
                            color: synced ? Color(0xFF2E7D32) : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 14.sp,
                          ),
                        ),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
