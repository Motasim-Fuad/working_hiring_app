import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../controllers/worker_profile_controller.dart';

class WorkerChangePhotoView extends GetView<WorkerProfileController> {
  WorkerChangePhotoView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: AppStrings.photo.tr, showLeading: true),
      body: LayoutBuilder(
        builder: (context, viewport) => SingleChildScrollView(
          child: ResponsiveCenter(
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: viewport.maxHeight - 48),
              child: IntrinsicHeight(
                child: Column(
          children: [
            SizedBox(height: 20.h),
            Text(
              AppStrings.changePhoto.tr,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 40.h),
            Center(
              child: GestureDetector(
                onTap: () => _showPhotoOptions(context),
                child: Obx(
                  () => CircleAvatar(
                    radius: 80.r,
                    backgroundColor: Colors.grey.shade200,
                    backgroundImage: controller.displayPhoto,
                    child: controller.displayPhoto == null
                        ? Icon(
                      Icons.person,
                      size: 70,
                      color: Colors.grey,
                    )
                        : null,
                  )
                ),
              ),
            ),
            Spacer(),
            Obx(
              () => CustomButton(
                text: controller.isUploadingPhoto.value
                    ? '...'
                    : AppStrings.save.tr,
                onPressed: controller.isUploadingPhoto.value
                    ? () {}
                    : controller.updatePhoto,
              ),
            ),
            SizedBox(height: 20.h),
          ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showPhotoOptions(BuildContext context) {
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
                onTap: () => controller.pickImage(true), // Camera
              ),
              Divider(height: 1.h),
              ListTile(
                title: Center(
                  child: Text(
                    AppStrings.chooseFromLibrary.tr,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
                onTap: () => controller.pickImage(false), // Gallery
              ),
              Divider(height: 1.h), // Add separator
              ListTile(
                title: Center(
                  child: Text(
                    "Cancel".tr, // Should use AppStrings.cancel.tr
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
}
