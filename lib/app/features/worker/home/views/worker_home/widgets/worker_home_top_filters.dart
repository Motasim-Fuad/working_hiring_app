import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/worker/home/controllers/worker_home_controller.dart';

class WorkerHomeTopFilters extends GetView<WorkerHomeController> {
  const WorkerHomeTopFilters({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w),
      child: Obx(() {
        final year = controller.selectedYear.value;
        final month = controller.selectedMonth.value;
        final hour = controller.selectedHour.value;
        return Row(
          children: [
            Expanded(
              flex: 2,
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: year,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 8.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  isDense: true,
                ),
                dropdownColor: Colors.white,
                style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
                items: [2024, 2025, 2026, 2027]
                    .map(
                      (y) => DropdownMenuItem(
                        value: y,
                        child: Text(
                          y.toString(),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    )
                    .toList(),
                onChanged: (val) => controller.selectedYear.value = val!,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                initialValue: month,
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 8.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  isDense: true,
                ),
                dropdownColor: Colors.white,
                style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
                items: List.generate(12, (index) {
                  final m = index + 1;
                  return DropdownMenuItem(
                    value: m,
                    child: Text(
                      DateFormat('MMMM').format(DateTime(2020, m)).tr,
                      overflow: TextOverflow.ellipsis,
                    ),
                  );
                }),
                onChanged: (val) => controller.selectedMonth.value = val!,
              ),
            ),
            SizedBox(width: 8.w),
            Expanded(
              flex: 3,
              child: DropdownButtonFormField<String>(
                isExpanded: true,
                initialValue: hour.isEmpty ? null : hour,
                hint: Text(
                  'Hour'.tr,
                  style: TextStyle(fontSize: 14.sp),
                  overflow: TextOverflow.ellipsis,
                ),
                decoration: InputDecoration(
                  contentPadding: EdgeInsets.symmetric(
                    horizontal: 4.w,
                    vertical: 8.h,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  isDense: true,
                ),
                dropdownColor: Colors.white,
                style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary),
                items: [
                  DropdownMenuItem(value: '', child: Text('All'.tr)),
                  ...controller.allTimeSlots.map(
                    (h) => DropdownMenuItem(
                      value: h,
                      child: Text(
                        h.split(' - ')[0],
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
                ],
                onChanged: (val) => controller.selectedHour.value = val ?? '',
              ),
            ),
          ],
        );
      }),
    );
  }
}
