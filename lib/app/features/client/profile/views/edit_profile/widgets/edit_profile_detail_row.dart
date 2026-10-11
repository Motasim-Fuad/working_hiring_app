import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/client/profile/controllers/profile_controller.dart';

class EditProfileDetailRow extends GetView<ProfileController> {
  final String label;
  final RxString? obsValue;
  final bool isPhoto;

  const EditProfileDetailRow({
    super.key,
    required this.label,
    this.obsValue,
    this.isPhoto = false,
  });

  @override
  Widget build(BuildContext context) {
    final obsValue = this.obsValue;
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: AppColors.textPrimary,
          ),
        ),
        if (isPhoto)
          Obx(
            () => CircleAvatar(
              radius: 30.r,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: controller.displayPhoto,
              child: controller.displayPhoto == null
                  ? Icon(Icons.person, size: 25, color: Colors.grey)
                  : null,
            ),
          )
        else if (obsValue != null)
          Obx(
            () => Text(
              obsValue.value.isEmpty ? '—' : obsValue.value,
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
            ),
          ),
      ],
    );
  }
}
