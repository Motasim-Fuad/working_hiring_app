import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_images.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/routes/app_pages.dart';
import 'package:working_hiring/app/features/client/home/controllers/home_controller.dart';

class HomeServiceGrid extends GetView<HomeController> {
  const HomeServiceGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallPhone = screenWidth < 360;
    final serviceColumns = screenWidth >= 900
        ? 4
        : screenWidth >= 600
        ? 3
        : 2;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.serviceCategory.tr,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15.h),
          Obx(
            () => GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.servicesCategories.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: serviceColumns,
                mainAxisSpacing: isSmallPhone ? 10 : 15,
                crossAxisSpacing: isSmallPhone ? 10 : 15,
                childAspectRatio: isSmallPhone ? 1.05 : 1.15,
              ),
              itemBuilder: (context, index) {
                final service = controller.servicesCategories[index];
                final isSelected =
                    controller.selectedCategory.value == (service.title ?? '');
                return InkWell(
                  onTap: () {
                    controller.selectCategory(service.title ?? '');
                    Get.toNamed(
                      Routes.HELPER_LIST,
                      arguments: service.title ?? '',
                    );
                  },
                  borderRadius: BorderRadius.circular(12.r),
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: isSelected
                            ? Color(0xFF6CA34D)
                            : Colors.grey.shade200,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Stack(
                      children: [
                        Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                AppImages.categoryIcon(service.icon),
                                width: 40.w,
                                height: 40.h,
                              ),
                              SizedBox(height: 10.h),
                              Text(
                                service.title ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.w500,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Container(
                            decoration: BoxDecoration(
                              color: Colors.white.withAlpha(128),
                              borderRadius: BorderRadius.circular(12.r),
                            ),
                            child: Center(
                              child: Icon(
                                Icons.check_circle,
                                color: Color(0xFF6CA34D),
                                size: 32.sp,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
