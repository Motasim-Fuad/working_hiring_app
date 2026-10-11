import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/worker/account_verification/controllers/worker_account_verification_controller.dart';
import 'package:working_hiring/app/features/worker/account_verification/views/worker_account_verification/widgets/worker_account_verification_label.dart';
import 'package:working_hiring/app/features/worker/account_verification/views/worker_account_verification/widgets/worker_account_verification_text_field.dart';

class WorkerAccountVerificationDetailsForm
    extends GetView<WorkerAccountVerificationController> {
  const WorkerAccountVerificationDetailsForm({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.documentVerification.tr,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          AppStrings.provideIdInfo.tr,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 32.h),

        WorkerAccountVerificationLabel(text: AppStrings.fullName.tr),
        SizedBox(height: 8.h),
        WorkerAccountVerificationTextField(
          fieldController: controller.nameController,
          hintText: "Alex Smith",
        ),

        SizedBox(height: 20.h),

        WorkerAccountVerificationLabel(text: AppStrings.dateOfBirth.tr),
        SizedBox(height: 8.h),
        WorkerAccountVerificationTextField(
          fieldController: controller.dobController,
          hintText: "mm/dd/yy".tr,
          readOnly: true,
          onTap: () => controller.pickDateOfBirth(Get.context!),
        ),

        SizedBox(height: 20.h),

        WorkerAccountVerificationLabel(text: AppStrings.idNumber.tr),
        SizedBox(height: 8.h),
        WorkerAccountVerificationTextField(
          fieldController: controller.idNumberController,
          hintText: "45246282554252".tr,
        ),
      ],
    );
  }
}
