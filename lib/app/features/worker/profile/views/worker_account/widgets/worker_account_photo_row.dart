import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/worker/profile/controllers/worker_profile_controller.dart';

class WorkerAccountPhotoRow extends GetView<WorkerProfileController> {
  const WorkerAccountPhotoRow({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.photo.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: AppColors.textPrimary,
          ),
        ),
        Obx(
          () => CircleAvatar(
            radius: 30.r,
            backgroundColor: Colors.grey.shade200,
            backgroundImage: controller.displayPhoto,
            child: controller.displayPhoto == null
                ? Icon(Icons.person, size: 25, color: Colors.grey)
                : null,
          ),
        ),
      ],
    );
  }
}
