import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/widgets/custom_appBar/custom_app_bar.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/core/widgets/custom_button.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/worker/profile/controllers/worker_profile_controller.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_change_photo/widgets/show_photo_options.dart';

class WorkerChangePhotoView extends GetView<WorkerProfileController> {
  const WorkerChangePhotoView({super.key});

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
                        onTap: () => showPhotoOptions(context),
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
                          ),
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
}
