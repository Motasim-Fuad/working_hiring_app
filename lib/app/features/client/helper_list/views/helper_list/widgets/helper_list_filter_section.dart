import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/helper_list/controllers/helper_list_controller.dart';
import 'package:working_hiring/app/features/client/helper_list/views/helper_list/widgets/extended_filter_bottom_sheet.dart';

class HelperListFilterSection extends GetView<HelperListController> {
  const HelperListFilterSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(20.w, 16.h, 20.w, 10.h),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller.searchTextController,
              textInputAction: TextInputAction.search,
              onChanged: (value) {
                controller.onSearchChanged(value);
              },
              onSubmitted: (value) {
                controller.searchTextController.text = value.trim();
                controller.searchQuery.value = value.trim();
                controller.loadHelpers();
              },
              decoration: InputDecoration(
                hintText: "Search in this category...".tr,
                prefixIcon: Icon(Icons.search, color: Colors.grey),
                suffixIcon: Obx(
                  () => controller.searchQuery.value.isNotEmpty
                      ? IconButton(
                          icon: Icon(Icons.clear, color: Colors.grey),
                          onPressed: () {
                            controller.searchTextController.clear();
                            controller.searchQuery.value = '';
                            controller.loadHelpers();
                          },
                        )
                      : SizedBox.shrink(),
                ),
                filled: true,
                fillColor: Colors.grey.shade100,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 16.w,
                ),
              ),
            ),
          ),
          SizedBox(width: 12.w),
          OutlinedButton.icon(
            onPressed: () {
              controller.tempMaxDistance.value = controller.maxDistance.value;
              controller.tempMinRating.value = controller.minRating.value;
              controller.tempSelectedCategoryFilter.value =
                  controller.selectedCategoryFilter.value;
              controller.tempSelectedDate.value = controller.selectedDate.value;
              controller.tempSelectedTime.value = controller.selectedTime.value;
              controller.tempLocation.value = controller.location.value;
              controller.tempMinBudget.value = controller.minBudget.value;
              controller.tempMaxBudget.value = controller.maxBudget.value;
              controller.tempShowAvailableOnly.value =
                  controller.showAvailableOnly.value;

              Get.bottomSheet(
                ExtendedFilterBottomSheet(),
                backgroundColor: Colors.transparent,
                isScrollControlled: true,
              );
            },
            icon: Icon(Icons.tune, size: 18.sp),
            label: Text(
              'Filter'.tr,
              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500),
            ),
            style: OutlinedButton.styleFrom(
              backgroundColor: Color(0xFFE8F8F5),
              foregroundColor: Colors.black87,
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              side: BorderSide(color: Color(0xFFA3D5C0), width: 1.2),
              elevation: 0,
            ),
          ),
        ],
      ),
    );
  }
}
