import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/worker/profile/controllers/worker_profile_controller.dart';

void showPhotoOptions(BuildContext context) {
  final controller = Get.find<WorkerProfileController>();
  Get.bottomSheet(
    Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: AppResponsive.formMaxWidth),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  title: Center(
                    child: Text(
                      AppStrings.takePhoto.tr,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () => controller.pickImage(true),
                ),
                Divider(height: 1.h),
                ListTile(
                  title: Center(
                    child: Text(
                      AppStrings.chooseFromLibrary.tr,
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  onTap: () => controller.pickImage(false),
                ),
                Divider(height: 1.h),
                ListTile(
                  title: Center(
                    child: Text(
                      "Cancel".tr,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                  onTap: () => Get.back(),
                ),
              ],
            ),
          ),
        ),
      ),
    ),
  );
}
