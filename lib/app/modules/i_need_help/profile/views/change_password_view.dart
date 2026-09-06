import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/change_password_controller.dart';

class ChangePasswordView extends GetView<ChangePasswordController> {
  ChangePasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppStrings.changePassword.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20.h),
            Text(
              AppStrings
                  .changePassword
                  .tr, // Or "Change password" as header again if needed, match screenshot (Has title "Change password")
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),
            Obx(
              () => CustomTextField(
                hintText: AppStrings.currentPassword.tr,
                controller: controller.currentPasswordController,
                obscureText: controller.obscureCurrent.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureCurrent.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: controller.toggleCurrent,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => CustomTextField(
                hintText: AppStrings.newPassword.tr,
                controller: controller.newPasswordController,
                obscureText: controller.obscureNew.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureNew.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: controller.toggleNew,
                ),
              ),
            ),
            SizedBox(height: 16.h),
            Obx(
              () => CustomTextField(
                hintText: AppStrings.confirmPassword.tr,
                controller: controller.confirmPasswordController,
                obscureText: controller.obscureConfirm.value,
                suffixIcon: IconButton(
                  icon: Icon(
                    controller.obscureConfirm.value
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: AppColors.textSecondary,
                  ),
                  onPressed: controller.toggleConfirm,
                ),
              ),
            ),

            SizedBox(height: 30.h),
            CustomButton(
              // "Change password" button
              text: AppStrings.changePassword.tr,
              onPressed: controller.changePassword,
            ),

            SizedBox(height: 20.h),
            Center(
              child: Text(
                AppStrings.forgotPassword.tr,
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
