import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/helper_list/controllers/helper_list_controller.dart';

class ExtendedFilterBottomSheet extends StatelessWidget {
  const ExtendedFilterBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HelperListController>();
    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.85,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Detailed Filters".tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () => Get.back(),
                  icon: Icon(Icons.close),
                ),
              ],
            ),
            SizedBox(height: 24.h),

            Text(
              "Category ".tr,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => SizedBox(
                height: 40.h,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: controller.availableCategories.length + 1,
                  separatorBuilder: (context, index) => SizedBox(width: 8.w),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      final isSelected =
                          controller.tempSelectedCategoryFilter.value ==
                          'All Categories';
                      return ChoiceChip(
                        label: Text('All Categories'.tr),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            controller.tempSelectedCategoryFilter.value =
                                'All Categories';
                            controller.applyFilters();
                          }
                        },
                        selectedColor: Color(0xFF6CA34D),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          side: BorderSide(
                            color: isSelected
                                ? Color(0xFF6CA34D)
                                : Colors.grey.shade300,
                          ),
                        ),
                        showCheckmark: false,
                      );
                    }
                    final category = controller.availableCategories[index - 1];
                    final catName = category.title ?? '';
                    return Obx(() {
                      final isSelected =
                          controller.tempSelectedCategoryFilter.value ==
                          catName;
                      return ChoiceChip(
                        label: Text(catName),
                        selected: isSelected,
                        onSelected: (selected) {
                          if (selected) {
                            controller.tempSelectedCategoryFilter.value =
                                catName;
                            controller.applyFilters();
                          } else {
                            controller.tempSelectedCategoryFilter.value = '';
                            controller.applyFilters();
                          }
                        },
                        selectedColor: Color(0xFF6CA34D),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.white : Colors.black87,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        backgroundColor: Colors.grey.shade100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                          side: BorderSide(
                            color: isSelected
                                ? Color(0xFF6CA34D)
                                : Colors.grey.shade300,
                          ),
                        ),
                        showCheckmark: false,
                      );
                    });
                  },
                ),
              ),
            ),

            SizedBox(height: 24.h),
            Text(
              "Date".tr,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => TextFormField(
                decoration: InputDecoration(
                  hintText: controller.tempSelectedDate.value != null
                      ? "${controller.tempSelectedDate.value!.year}-${controller.tempSelectedDate.value!.month.toString().padLeft(2, '0')}-${controller.tempSelectedDate.value!.day.toString().padLeft(2, '0')}"
                      : "Select Date".tr,
                  hintStyle: TextStyle(
                    color: controller.tempSelectedDate.value != null
                        ? Colors.black87
                        : Colors.grey,
                  ),
                  prefixIcon: Icon(
                    Icons.calendar_today,
                    size: 18.sp,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16.w,
                  ),
                ),
                readOnly: true,
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate:
                        controller.tempSelectedDate.value ?? DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Color(0xFF6CA34D),
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    controller.tempSelectedDate.value = picked;
                  }
                },
              ),
            ),
            SizedBox(height: 20.h),

            Text(
              "Time".tr,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => TextFormField(
                decoration: InputDecoration(
                  hintText: controller.tempSelectedTime.value != null
                      ? controller.tempSelectedTime.value!.format(context)
                      : "Select Time".tr,
                  hintStyle: TextStyle(
                    color: controller.tempSelectedTime.value != null
                        ? Colors.black87
                        : Colors.grey,
                  ),
                  prefixIcon: Icon(
                    Icons.access_time,
                    size: 18.sp,
                    color: Colors.grey,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16.w,
                  ),
                ),
                readOnly: true,
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime:
                        controller.tempSelectedTime.value ?? TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: ColorScheme.light(
                            primary: Color(0xFF6CA34D),
                            onPrimary: Colors.white,
                            onSurface: Colors.black,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (picked != null) {
                    controller.tempSelectedTime.value = picked;
                  }
                },
              ),
            ),
            SizedBox(height: 20.h),

            Text(
              "Location".tr,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8.h),
            Obx(
              () => TextFormField(
                key: Key(controller.tempLocation.value),
                initialValue: controller.tempLocation.value,
                onChanged: (val) => controller.tempLocation.value = val,
                decoration: InputDecoration(
                  prefixIcon: Icon(
                    Icons.location_on,
                    size: 18.sp,
                    color: Colors.redAccent,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 0,
                    horizontal: 16.w,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            Container(
              height: 120.h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12.r),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.map_outlined, size: 40.sp, color: Colors.grey),
                    SizedBox(height: 4.h),
                    Text(
                      "Interactive Map Area".tr,
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Budget".tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Obx(
                  () => Text(
                    "\$${controller.tempMinBudget.value.toInt()} - \$${controller.tempMaxBudget.value.toInt()}+",
                    style: TextStyle(
                      color: Color(0xFF6CA34D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Obx(
              () => RangeSlider(
                values: RangeValues(
                  controller.tempMinBudget.value,
                  controller.tempMaxBudget.value,
                ),
                min: 10,
                max: 200,
                activeColor: Color(0xFF6CA34D),
                inactiveColor: Colors.grey.shade200,
                onChanged: (values) {
                  controller.tempMinBudget.value = values.start;
                  controller.tempMaxBudget.value = values.end;
                },
              ),
            ),
            SizedBox(height: 20.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Minimum Rating".tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Obx(
                  () => Text(
                    "${controller.tempMinRating.value.toStringAsFixed(1)} ⭐️",
                    style: TextStyle(
                      color: Colors.amber,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            Obx(
              () => Slider(
                value: controller.tempMinRating.value,
                min: 1.0,
                max: 5.0,
                divisions: 8,
                activeColor: Colors.amber,
                inactiveColor: Colors.grey.shade200,
                onChanged: (value) => controller.tempMinRating.value = value,
              ),
            ),
            SizedBox(height: 20.h),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Show Available Only".tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Obx(
                  () => Switch(
                    value: controller.tempShowAvailableOnly.value,
                    onChanged: (val) {
                      controller.tempShowAvailableOnly.value = val;
                    },
                    activeThumbColor: Color(0xFF6CA34D),
                  ),
                ),
              ],
            ),
            SizedBox(height: 32.h),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  controller.applyFilters();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6CA34D),
                  foregroundColor: Colors.white,
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  "Apply Filters".tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 16.h),
          ],
        ),
      ),
    );
  }
}
