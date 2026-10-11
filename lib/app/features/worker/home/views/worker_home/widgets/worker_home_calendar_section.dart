import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/worker/home/controllers/worker_home_controller.dart';
import 'package:working_hiring/app/features/worker/home/views/worker_home/widgets/worker_home_time_slot_panel.dart';

class WorkerHomeCalendarSection extends GetView<WorkerHomeController> {
  const WorkerHomeCalendarSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final year = controller.selectedYear.value;
      final month = controller.selectedMonth.value;

      final firstDayOfMonth = DateTime(year, month, 1);
      final lastDayOfMonth = DateTime(year, month + 1, 0);

      int firstWeekDay = firstDayOfMonth.weekday;
      final daysInMonth = lastDayOfMonth.day;
      final totalSlots = daysInMonth + (firstWeekDay - 1);

      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Manage Availability".tr,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              "Tap a date to open it. Use it to override a single day.".tr,
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 24.h),

            Container(
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
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Month Year'.trParams({
                          'month': DateFormat(
                            'MMMM',
                          ).format(firstDayOfMonth).tr,
                          'year': '$year',
                        }),
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Expanded(
                        child: Wrap(
                          alignment: WrapAlignment.end,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          spacing: 4,
                          children: [
                            Icon(
                              Icons.circle,
                              size: 10.sp,
                              color: Color(0xFF6CA34D),
                            ),
                            Text(
                              "Available".tr,
                              style: TextStyle(fontSize: 12.sp),
                            ),
                            SizedBox(width: 8.w),
                            Icon(
                              Icons.circle,
                              size: 10.sp,
                              color: Color(0xFFEF5350),
                            ),
                            Text(
                              "Not Available / Booked".tr,
                              style: TextStyle(fontSize: 12.sp),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 20.h),
                  Row(
                    children:
                        [
                          'Mon Short'.tr,
                          'Tue Short'.tr,
                          'Wed Short'.tr,
                          'Thu Short'.tr,
                          'Fri Short'.tr,
                          'Sat Short'.tr,
                          'Sun Short'.tr,
                        ].map((day) {
                          return Expanded(
                            child: Center(
                              child: Text(
                                day,
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                  ),
                  SizedBox(height: 16.h),

                  GridView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: totalSlots,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 7,
                      mainAxisSpacing: 10,
                      crossAxisSpacing: 10,
                      childAspectRatio: 1,
                    ),
                    itemBuilder: (context, index) {
                      if (index < firstWeekDay - 1) {
                        return SizedBox();
                      }

                      final dayNumber = index - (firstWeekDay - 1) + 1;
                      final currentDate = DateTime(year, month, dayNumber);

                      return Obx(() {
                        final dayColor = controller.colorForDate(currentDate);
                        final isSelected =
                            controller.selectedDate.value == currentDate;

                        Color bgColor = Color(0xFFF5F5F5);
                        Color borderColor = Colors.transparent;
                        Color textColor = Colors.black87;

                        if (dayColor == DayColor.available) {
                          bgColor = Color(0xFFE8F5E9);
                          borderColor = Color(
                            0xFF6CA34D,
                          ).withValues(alpha: 0.5);
                          textColor = Color(0xFF2E7D32);
                        } else if (dayColor == DayColor.booked) {
                          bgColor = Color(0xFFFFEBEE);
                          borderColor = Color(
                            0xFFEF5350,
                          ).withValues(alpha: 0.5);
                          textColor = Color(0xFFEF5350);
                        }

                        if (isSelected) {
                          borderColor = dayColor == DayColor.available
                              ? Color(0xFF2E7D32)
                              : (dayColor == DayColor.booked
                                    ? Color(0xFFC62828)
                                    : Colors.black87);
                        }

                        final isHighlighted =
                            dayColor != DayColor.none || isSelected;

                        return GestureDetector(
                          onTap: () => controller.selectDate(currentDate),
                          child: AnimatedContainer(
                            duration: Duration(milliseconds: 200),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(10.r),
                              border: Border.all(
                                color: borderColor,
                                width: isSelected ? 2.5 : 1.5,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                dayNumber.toString(),
                                style: TextStyle(
                                  color: textColor,
                                  fontWeight: isHighlighted
                                      ? FontWeight.bold
                                      : FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                    },
                  ),
                ],
              ),
            ),
            SizedBox(height: 12.h),

            Obx(() {
              return AnimatedSize(
                duration: Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                child: controller.selectedDate.value == null
                    ? SizedBox(width: double.infinity)
                    : WorkerHomeTimeSlotPanel(),
              );
            }),

            SizedBox(height: 24.h),

            Obx(() {
              final daysCount = controller.totalAvailableDays;
              final slotsCount = controller.totalAvailableSlots;
              return Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Color(0xFF6CA34D), Color(0xFF4B7B32)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16.r),
                  boxShadow: [
                    BoxShadow(
                      color: Color(0xFF4B7B32).withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 16.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.event_available,
                        color: Color(0xFF4B7B32),
                        size: 32.sp,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Availability Summary".tr,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.8),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Available Days Count'.trParams({
                              'count': '$daysCount',
                            }),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 6.h),
                          Text(
                            'Open Slots This Month'.trParams({
                              'count': '$slotsCount',
                            }),
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.9),
                              fontSize: 14.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      );
    });
  }
}
