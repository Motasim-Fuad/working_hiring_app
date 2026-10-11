import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/custom_offer/controllers/custom_offer_controller.dart';

void showSlotPicker(CustomOfferController controller) {
  Get.bottomSheet(
    Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(height: 12.h),
          Container(
            width: 40.w,
            height: 4.h,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2.r),
            ),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Text(
              "Available time slots".tr,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Flexible(
            child: Obx(() {
              if (controller.isLoadingSlots.value) {
                return Padding(
                  padding: EdgeInsets.all(24.h),
                  child: Center(
                    child: CircularProgressIndicator(color: Color(0xFF6CA34D)),
                  ),
                );
              }
              final slots = controller.availableSlots;
              if (slots.isEmpty) {
                return ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: 96.h,
                    maxHeight: Get.height * 0.35,
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.all(24.h),
                      child: Text(
                        "No available slots for this date.".tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ),
                  ),
                );
              }
              return ListView.builder(
                shrinkWrap: true,
                itemCount: slots.length,
                itemBuilder: (_, i) {
                  final s = slots[i];
                  final isSelected =
                      controller.selectedSlot.value?.slot == s.slot;
                  return ListTile(
                    selected: isSelected,
                    selectedColor: const Color(0xFF6CA34D),
                    title: Text(s.slot),
                    trailing: isSelected
                        ? Icon(Icons.check, color: Color(0xFF6CA34D))
                        : null,
                    onTap: () {
                      controller.selectSlot(s);
                      Get.back();
                    },
                  );
                },
              );
            }),
          ),
          SizedBox(height: 16.h),
        ],
      ),
    ),
    backgroundColor: Colors.white,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
    ),
    clipBehavior: Clip.antiAlias,
  );
}
