import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/home/controllers/home_controller.dart';

class MoreCategoriesSection extends GetView<HomeController> {
  const MoreCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "More Categories".tr,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15.h),
          Obx(() {
            if (controller.moreCategories.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  "No sub-categories available".tr,
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              );
            }
            return SizedBox(
              height: 100.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.moreCategories.length,
                separatorBuilder: (_, _) => SizedBox(width: 15.w),
                itemBuilder: (context, index) {
                  final cat = controller.moreCategories[index];
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 12.h,
                        ),
                        decoration: BoxDecoration(
                          color: Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Icon(Icons.category, color: Color(0xFF6CA34D)),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        cat.title ?? '',
                        style: TextStyle(fontSize: 12.sp),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}
