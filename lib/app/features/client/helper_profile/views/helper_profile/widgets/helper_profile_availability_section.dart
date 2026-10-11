import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:working_hiring/app/features/client/helper_profile/controllers/helper_profile_controller.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/widgets/helper_profile_slot_chip.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/widgets/helper_profile_legend_item.dart';

class HelperProfileAvailabilitySection extends GetView<HelperDetailController> {
  const HelperProfileAvailabilitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Availability".tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 14.h),

        SizedBox(
          height: 64.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.availabilityDays.length,
            separatorBuilder: (_, _) => SizedBox(width: 10.w),
            itemBuilder: (_, i) {
              final day = controller.availabilityDays[i];
              return Obx(() {
                final selected = controller.isSameDay(
                  controller.selectedDay.value,
                  day,
                );
                final isToday = controller.isSameDay(DateTime.now(), day);
                return GestureDetector(
                  onTap: () => controller.loadAvailability(day),
                  child: Container(
                    width: 52.w,
                    decoration: BoxDecoration(
                      color: selected ? Color(0xFF6CA34D) : Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: selected
                            ? Color(0xFF6CA34D)
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isToday
                              ? "Today".tr
                              : DateFormat('EEE').format(day).tr,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: selected
                                ? Colors.white
                                : Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          DateFormat('d').format(day),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: selected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
        SizedBox(height: 16.h),

        Obx(() {
          if (controller.isLoadingSlots.value) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF6CA34D),
                  strokeWidth: 2,
                ),
              ),
            );
          }
          final slots = controller.daySlots;
          if (slots.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                "No slots for this day.".tr,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
              ),
            );
          }
          return Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: slots
                .map((slot) => HelperProfileSlotChip(slot: slot))
                .toList(),
          );
        }),
        SizedBox(height: 16.h),

        Row(
          children: [
            HelperProfileLegendItem(
              color: Color(0xFF6CA34D),
              label: "Available",
            ),
            SizedBox(width: 16.w),
            HelperProfileLegendItem(
              color: Colors.red.shade400,
              label: "Booked",
            ),
            SizedBox(width: 16.w),
            HelperProfileLegendItem(
              color: Colors.grey.shade400,
              label: "Unavailable",
            ),
          ],
        ),
      ],
    );
  }
}
