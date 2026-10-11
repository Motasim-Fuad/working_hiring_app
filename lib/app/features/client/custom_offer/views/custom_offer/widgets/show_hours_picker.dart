import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/custom_offer/controllers/custom_offer_controller.dart';

void showHoursPicker(CustomOfferController controller) {
  Get.bottomSheet(
    Container(
      constraints: BoxConstraints(maxHeight: Get.height * 0.5),
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
              "How many hours?".tr,
              style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
            ),
          ),
          Flexible(
            child: Obx(
              () => ListView(
                shrinkWrap: true,
                children: controller.hoursOptions.map((h) {
                  final isSelected = controller.workingHour.value == h;
                  return ListTile(
                    selected: isSelected,
                    selectedColor: const Color(0xFF6CA34D),
                    title: Text('Hours Count'.trParams({'count': '$h'})),
                    subtitle: controller.hourlyRate > 0
                        ? Text(
                            "\$${(controller.hourlyRate * h).toStringAsFixed(0)}",
                          )
                        : null,
                    trailing: isSelected
                        ? Icon(Icons.check, color: Color(0xFF6CA34D))
                        : null,
                    onTap: () {
                      controller.selectHours(h);
                      Get.back();
                    },
                  );
                }).toList(),
              ),
            ),
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
