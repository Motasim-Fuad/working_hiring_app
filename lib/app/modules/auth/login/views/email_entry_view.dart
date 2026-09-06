import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/social_button.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/login_controller.dart';

class EmailEntryView extends GetView<LoginController> {
  EmailEntryView({super.key});

  @override
  Widget build(BuildContext context) {
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
            key: controller.emailEntryFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                Text(
                  AppStrings.signIn.tr,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Row(
                  children: [
                    Text(
                      'or, '.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Get.toNamed(Routes.SIGN_UP),
                      child: Text(
                        AppStrings.createAccount.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 40.h),

                // Email Field
                Obx(() => CustomTextField(
                  hintText: "Email".tr,
                  keyboardType: TextInputType.emailAddress,
                  controller: controller.emailController,
                  prefixIcon: Icon(Icons.email_outlined, color: AppColors.primary),
                  onChanged: controller.validateEmailRealTime,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Email is required".tr;
                    }
                    if (!GetUtils.isEmail(value)) {
                      return "Enter a valid email".tr;
                    }
                    return null;
                  },
                  suffixIcon: controller.isEmailValid.value 
                    ? Icon(Icons.check_circle, color: Colors.green)
                    : null,
                )),
                SizedBox(height: 40.h),

                Obx(() => CustomButton(
                  text: AppStrings.continueText.tr,
                  onPressed: controller.isOtpRequestLoading.value ? () {} : controller.requestLoginOtp,
                  isLoading: controller.isOtpRequestLoading.value,
                )),

                SizedBox(height: 24.h),

                Row(
                  children: [
                    Expanded(child: Divider()),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.w),
                      child: Text(
                        AppStrings.or.tr,
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ),
                    Expanded(child: Divider()),
                  ],
                ),

                SizedBox(height: 24.h),

                Obx(() => SocialButton(
                  text: AppStrings.continueWithGoogle.tr,
                  iconPath: AppImages.google,
                  onPressed: controller.isGoogleLoginLoading.value ? () {} : controller.loginWithGoogle,
                  isLoading: controller.isGoogleLoginLoading.value,
                )),
                SizedBox(height: 16.h),
                SocialButton(
                  text: AppStrings.continueWithApple.tr,
                  iconPath: AppImages.apple,
                  onPressed: controller.onAppleSignIn,
                ),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
