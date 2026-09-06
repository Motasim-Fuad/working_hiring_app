import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../controllers/login_controller.dart';

class OtpVerifyView extends GetView<LoginController> {
  OtpVerifyView({super.key});

  @override
  Widget build(BuildContext context) {
    // Attempt to read email from arguments, fallback to controller text
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
        child: LayoutBuilder(
          builder: (context, viewport) {
            final horizontalPadding = AppResponsive.horizontalPadding(context);
            final contentWidth = (MediaQuery.sizeOf(context).width -
                    (horizontalPadding * 2))
                .clamp(0.0, AppResponsive.formMaxWidth)
                .toDouble();
            final otpDigitSize = ((contentWidth - 40) / 6)
                .clamp(38.0, 48.0)
                .toDouble();
            return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ResponsiveCenter(
              maxWidth: AppResponsive.formMaxWidth,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewport.maxHeight - 32),
                child: IntrinsicHeight(
                  child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                AppStrings.enterVerificationCode.tr,
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
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(
                  6,
                  (index) => _buildOtpDigit(context, index, otpDigitSize),
                ),
              ),

              SizedBox(height: 24.h),

              // Info Box
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: Color(0xFFF7F7F7),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lock_outline, size: 20.sp, color: Colors.black54),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        AppStrings.communitySafetyOtp.tr,
                        style: TextStyle(
                            fontSize: 13.sp, color: Colors.black87, height: 1.4),
                      ),
                    ),
                  ],
                ),
              ),

              SizedBox(height: 24.h),

              // Resend Code
              Center(
                child: Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      AppStrings.haventGotCode.tr,
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                    SizedBox(width: 4.w),
                    GestureDetector(
                      onTap: controller.isOtpRequestLoading.value ? null : controller.requestLoginOtp,
                      child: Obx(() => Text(
                        controller.isOtpRequestLoading.value
                            ? 'Sending...'.tr
                            : AppStrings.resendCode.tr,
                        style: TextStyle(
                          color: controller.isOtpRequestLoading.value ? Colors.grey : AppColors.primary,
                          fontWeight: FontWeight.w600,
                          decoration: controller.isOtpRequestLoading.value ? TextDecoration.none : TextDecoration.underline,
                        ),
                      )),
                    ),
                  ],
                ),
              ),

              Spacer(),

              // Verify Action Button
              Obx(() => CustomButton(
                text: AppStrings.continueText.tr,
                onPressed: controller.isOtpVerifyLoading.value ? () {} : controller.verifyLoginOtp,
                isLoading: controller.isOtpVerifyLoading.value,
              )),
              SizedBox(height: 30.h),
            ],
                  ),
                ),
              ),
            ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildOtpDigit(BuildContext context, int index, double width) {
    return Container(
      width: width,
      height: width,
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
