import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/worker/profile/controllers/worker_profile_controller.dart';
import 'package:working_hiring/app/features/worker/helper_profile/controllers/helper_profile_controller.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_profile/widgets/worker_profile_legend_item.dart';

class WorkerProfileAvailabilitySection
    extends GetView<WorkerProfileController> {
  final HelperProfileController helperController;

  const WorkerProfileAvailabilitySection({
    super.key,
    required this.helperController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final availabilityList = controller.weeklyAvailability;
      final isLoading = controller.isAvailabilityLoading.value;
      final profile = helperController.profileData.value;
      final anyAvailable = profile?.availabilityStatus ?? "";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    "Availability Status  : ".tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54,
                    ),
                  ),
                  Text(
                    (anyAvailable == true ? "Available" : "Unavailable").tr,
                    style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: anyAvailable == true
                          ? Colors.green
                          : Colors.redAccent,
                    ),
                  ),

                  SizedBox(width: 12.w),
                ],
              ),
            ),
          ),

          SizedBox(height: 16.h),

          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (availabilityList.isEmpty)
            Text(
              'No availability data'.tr,
              style: TextStyle(color: Colors.grey),
            )
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: availabilityList.map((day) {
                  final bool available = day.dayStatus == 'AVAILABLE';
                  final Color bgColor = available
                      ? Color(0xFFF0F9EA)
                      : Colors.grey.shade100;
                  final Color borderColor = available
                      ? Color(0xFF6CA34D).withValues(alpha: 0.3)
                      : Colors.grey.shade200;
                  final Color textColor = available
                      ? Color(0xFF6CA34D)
                      : Colors.grey.shade400;

                  return Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          day.day,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          day.dayStatus,
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: textColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          SizedBox(height: 16.h),
          Row(
            children: [
              WorkerProfileLegendItem(
                color: Color(0xFF6CA34D),
                label: 'Available',
              ),
              SizedBox(width: 16.w),
              WorkerProfileLegendItem(
                color: Colors.grey.shade400,
                label: 'Unavailable',
              ),
            ],
          ),
        ],
      );
    });
  }
}
