import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../controllers/password_reset_controller.dart';

class ResetPasswordConfirmView extends GetView<PasswordResetController> {
  ResetPasswordConfirmView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final String email = args?['email'] ?? controller.emailController.text;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.symmetric(horizontal: 24.w),
          child: Form(
            key: controller.resetFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                Text(
                  'Reset Password'.tr,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Code Sent To Address'.trParams({'email': email}),
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 40.h),

                // OTP Fields
                Padding(
                  padding: EdgeInsets.symmetric(vertical: 20.0.h),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(6, (index) => _buildOtpDigit(context, index)),
                  ),
                ),

                SizedBox(height: 20.h),

                // New Password Field
                Obx(() => Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    CustomTextField(
                      hintText: "New Password".tr,
                      controller: controller.passwordController,
                      obscureText: !controller.isPasswordVisible.value,
                      prefixIcon: Icon(Icons.lock_outline, color: AppColors.primary),
                      validator: (value) => (value == null || value.isEmpty)
                          ? "Password is required".tr
                          : null,
                      onChanged: controller.updatePasswordStrength,
                      borderColor: controller.strengthColor.value,
                      suffixIcon: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (controller.passwordStrength.value == 'Strong')
                            Icon(Icons.check_circle, color: Colors.green),
                          IconButton(
                            icon: Icon(
                              controller.isPasswordVisible.value ? Icons.visibility_off : Icons.visibility,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: controller.togglePasswordVisibility,
                          ),
                        ],
                      ),
                    ),
                    if (controller.passwordStrength.value.isNotEmpty)
                      Padding(
                        padding: EdgeInsets.only(top: 4.h, right: 8.w),
                        child: Text(
                          controller.passwordStrength.value,
                          style: TextStyle(
                            color: controller.strengthColor.value,
                            fontSize: 12.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                  ],
                )),

                SizedBox(height: 20.h),

                // Reset Action Button
                Obx(() => CustomButton(
                  text: "Reset Password".tr,
                  onPressed: controller.isResettingPassword.value ? () {} : controller.resetPasswordConfirm,
                  isLoading: controller.isResettingPassword.value,
                )),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOtpDigit(BuildContext context, int index) {
    return Container(
      width: 48.w,
      height: 48.h,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: AppColors.border),
      ),
      child: TextField(
        controller: controller.otpControllers[index],
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
        decoration: InputDecoration(counterText: "", border: InputBorder.none),
        style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.w600),
      ),
    );
  }
}
