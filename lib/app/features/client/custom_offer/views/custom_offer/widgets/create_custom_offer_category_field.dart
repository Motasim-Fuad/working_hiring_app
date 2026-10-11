import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/client/custom_offer/controllers/custom_offer_controller.dart';

class CreateCustomOfferCategoryField extends StatelessWidget {
  final CustomOfferController fieldController;

  const CreateCustomOfferCategoryField({
    super.key,
    required this.fieldController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final selected = fieldController.selectedCategoryModel.value;
      final cats = fieldController.categories;

      return InkWell(
        borderRadius: BorderRadius.circular(12.r),
        onTap: cats.isEmpty
            ? null
            : () {
                Get.bottomSheet(
                  Column(
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
                        padding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        child: Text(
                          "Select Category".tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      Flexible(
                        child: ListView.builder(
                          shrinkWrap: true,
                          itemCount: cats.length,
                          itemBuilder: (_, i) {
                            final cat = cats[i];
                            final isSelected = cat.id == selected?.id;
                            return ListTile(
                              title: Text(cat.title ?? 'Category ${cat.id}'),
                              trailing: isSelected
                                  ? Icon(Icons.check, color: Color(0xFF6CA34D))
                                  : null,
                              onTap: () {
                                fieldController.selectedCategoryModel.value =
                                    cat;
                                Get.back();
                              },
                            );
                          },
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(20.r),
                    ),
                  ),
                );
              },
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(color: Color(0xFFE5E5E5)),
            borderRadius: BorderRadius.circular(12.r),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  selected?.title ??
                      (cats.isEmpty ? 'Loading...'.tr : 'Select category'.tr),
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: selected == null
                        ? Color(0xFF9E9E9E)
                        : AppColors.textPrimary,
                  ),
                ),
              ),
              Icon(Icons.keyboard_arrow_down, color: Color(0xFF9E9E9E)),
            ],
          ),
        ),
      );
    });
  }
}
