import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../data/repositories/auth_repository.dart';
import '../../../../service/api_service.dart';
import '../controllers/password_reset_controller.dart';

class ForgotPasswordView extends GetView<PasswordResetController> {
  ForgotPasswordView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<PasswordResetController>()) {
      if (!Get.isRegistered<AuthRepository>()) {
        if (!Get.isRegistered<ApiClient>()) {
          Get.put(ApiClient(), permanent: true);
        }
        Get.put(AuthRepository(Get.find<ApiClient>()), permanent: true);
      }
      Get.put(PasswordResetController(Get.find<AuthRepository>()));
    }

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
            key: controller.emailFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 10.h),
                Text(
                  "Forgot Password".tr,
                  style: TextStyle(
                    fontSize: 28.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Enter your email to receive a reset code".tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: AppColors.textSecondary,
                  ),
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
                  text: "Send Reset OTP".tr,
                  onPressed: controller.isRequestingOtp.value ? () {} : controller.requestResetOtp,
                  isLoading: controller.isRequestingOtp.value,
                )),
                SizedBox(height: 30.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
