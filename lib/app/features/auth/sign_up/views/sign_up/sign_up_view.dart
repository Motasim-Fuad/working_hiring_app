import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter/gestures.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_images.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/core/widgets/custom_button.dart';
import 'package:working_hiring/app/core/widgets/custom_text_field.dart';
import 'package:working_hiring/app/core/widgets/social_button.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/auth/sign_up/controllers/signup_controller.dart';
import 'package:working_hiring/app/features/auth/sign_up/views/map_picker/map_picker_view.dart';
import 'package:working_hiring/app/routes/app_pages.dart';

class SignUpView extends GetView<SignupController> {
  const SignUpView({super.key});

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
        child: GestureDetector(
          onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
          behavior: HitTestBehavior.translucent,
          child: SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ResponsiveCenter(
              maxWidth: AppResponsive.formMaxWidth,
              child: Form(
                key: controller.signupFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Text(
                      AppStrings.createAccount.tr,
                      style: TextStyle(
                        fontSize: 28.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 10.h),
                    Wrap(
                      spacing: 3,
                      runSpacing: 4,
                      children: [
                        Text(
                          AppStrings.alreadyHaveAccount.tr,
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w400,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        GestureDetector(
                          onTap: () => Get.toNamed(Routes.SIGN_IN),
                          child: Text(
                            AppStrings.signIn.tr,
                            style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.w400,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 30.h),

                    LayoutBuilder(
                      builder: (context, constraints) {
                        final firstName = CustomTextField(
                          hintText: AppStrings.firstName.tr,
                          controller: controller.firstNameController,
                          validator: (value) =>
                              controller.validateRequired(value, "First Name"),
                        );
                        final lastName = CustomTextField(
                          hintText: AppStrings.lastName.tr,
                          controller: controller.lastNameController,
                          validator: (value) =>
                              controller.validateRequired(value, "Last Name"),
                        );
                        if (constraints.maxWidth < 420) {
                          return Column(
                            children: [
                              firstName,
                              SizedBox(height: 16),
                              lastName,
                            ],
                          );
                        }
                        return Row(
                          children: [
                            Expanded(child: firstName),
                            SizedBox(width: 16),
                            Expanded(child: lastName),
                          ],
                        );
                      },
                    ),
                    SizedBox(height: 16.h),

                    Obx(
                      () => CustomTextField(
                        hintText: AppStrings.email.tr,
                        keyboardType: TextInputType.emailAddress,
                        controller: controller.emailController,
                        validator: controller.validateEmail,
                        onChanged: controller.validateEmailRealTime,
                        suffixIcon: controller.isEmailValid.value
                            ? Icon(Icons.check_circle, color: Colors.green)
                            : null,
                      ),
                    ),
                    SizedBox(height: 16.h),

                    Obx(
                      () => Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          CustomTextField(
                            hintText: AppStrings.password.tr,
                            obscureText: controller.isPasswordHidden.value,
                            controller: controller.passwordController,
                            validator: controller.validatePassword,
                            onChanged: controller.updatePasswordStrength,
                            borderColor: controller.strengthColor.value,
                            suffixIcon: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (controller.passwordStrength.value ==
                                    'Strong')
                                  Icon(Icons.check_circle, color: Colors.green),
                                IconButton(
                                  icon: Icon(
                                    controller.isPasswordHidden.value
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                    color: AppColors.textSecondary,
                                  ),
                                  onPressed:
                                      controller.togglePasswordVisibility,
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
                      ),
                    ),
                    SizedBox(height: 16.h),

                    IntlPhoneField(
                      controller: controller.phoneController,
                      decoration: InputDecoration(
                        hintText: AppStrings.phoneHint.tr,
                        hintStyle: TextStyle(color: Colors.black38),
                        filled: true,
                        fillColor: Colors.white,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16.w,
                          vertical: 16.h,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.border),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: AppColors.primary),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12.r),
                          borderSide: BorderSide(color: Colors.red),
                        ),
                      ),
                      initialCountryCode: 'US',
                      onChanged: (phone) {},
                    ),
                    SizedBox(height: 16.h),

                    InkWell(
                      onTap: () async {
                        final LatLng? result = await Get.to(
                          () => MapPickerView(),
                        );
                        if (result != null) {
                          await controller.updateLocation(
                            result.latitude,
                            result.longitude,
                          );
                        }
                      },
                      child: Obx(() {
                        final cityText = controller.city.value;

                        return Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 16.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            border: Border.all(color: AppColors.border),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.search,
                                color: AppColors.textSecondary,
                              ),
                              SizedBox(width: 12.w),
                              Expanded(
                                child: Text(
                                  cityText.isNotEmpty ? cityText : "City",
                                  style: TextStyle(
                                    color: cityText.isNotEmpty
                                        ? AppColors.textPrimary
                                        : Colors.black38,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Icon(Icons.location_on, color: AppColors.primary),
                            ],
                          ),
                        );
                      }),
                    ),
                    SizedBox(height: 16.h),

                    CustomTextField(
                      hintText: 'Referral Code (Optional)'.tr,
                      controller: controller.referralCodeController,
                    ),
                    SizedBox(height: 24.h),

                    Center(
                      child: RichText(
                        textAlign: TextAlign.center,
                        text: TextSpan(
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13.sp,
                            height: 1.5,
                          ),
                          children: [
                            TextSpan(
                              text: 'By signing up, you agree to our '.tr,
                            ),
                            TextSpan(
                              text: 'Terms of Service'.tr,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                            TextSpan(text: ' and '.tr),
                            TextSpan(
                              text: 'Privacy Policy'.tr,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontWeight: FontWeight.w600,
                              ),
                              recognizer: TapGestureRecognizer()..onTap = () {},
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 30.h),

                    Obx(
                      () => CustomButton(
                        text: AppStrings.signUp.tr,
                        onPressed: controller.isLoading.value
                            ? () {}
                            : controller.signupUser,
                        isLoading: controller.isLoading.value,
                      ),
                    ),
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

                    SocialButton(
                      text: AppStrings.continueWithGoogle.tr,
                      iconPath: AppImages.google,
                      onPressed: () {},
                    ),
                    SizedBox(height: 16.h),
                    SocialButton(
                      text: AppStrings.continueWithApple.tr,
                      iconPath: AppImages.apple,
                      onPressed: () {},
                    ),

                    SizedBox(height: 40.h),
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
