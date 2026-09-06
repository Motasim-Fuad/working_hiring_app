import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../controllers/otp_verification_controller.dart';

class OtpView extends GetView<OtpVerificationController> {
  OtpView({super.key});

  @override
  Widget build(BuildContext context) {
    final args = Get.arguments as Map<String, dynamic>?;
    final email = args?['email']?.toString() ?? '';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: SafeArea(
        top: false,
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
            return GestureDetector(
              behavior: HitTestBehavior.translucent,
              onTap: () => FocusManager.instance.primaryFocus?.unfocus(),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: ResponsiveCenter(
                  maxWidth: AppResponsive.formMaxWidth,
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight: (viewport.maxHeight - 32)
                          .clamp(0.0, double.infinity)
                          .toDouble(),
                    ),
                    child: IntrinsicHeight(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: AppResponsive.spacing(10)),
                          Text(
                            'Verify your account'.tr,
                            style: TextStyle(
                              fontSize: AppResponsive.font(28),
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          SizedBox(height: AppResponsive.spacing(8)),
                          Text(
                            'Code Sent To Address'.trParams({'email': email}),
                            style: TextStyle(
                              fontSize: AppResponsive.font(14),
                              color: AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(height: AppResponsive.spacing(40)),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: List.generate(
                              6,
                              (index) => _buildOtpDigit(
                                context,
                                index,
                                otpDigitSize,
                              ),
                            ),
                          ),

                          SizedBox(height: AppResponsive.spacing(24)),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFF7F7F7),
                              borderRadius: BorderRadius.circular(8.r),
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.lock_outline,
                                  size: AppResponsive.icon(20),
                                  color: Colors.black54,
                                ),
                                SizedBox(width: 10),
                                Expanded(
                                  child: Text(
                                    AppStrings.communitySafetyOtp.tr,
                                    style: TextStyle(
                                      fontSize: AppResponsive.font(13),
                                      color: Colors.black87,
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          SizedBox(height: AppResponsive.spacing(24)),
                          Center(
                            child: Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                Text(
                                  AppStrings.haventGotCode.tr,
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: controller.resendOtp,
                                  child: Text(
                                    AppStrings.resendCode.tr,
                                    style: TextStyle(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Spacer(),
                          SizedBox(height: AppResponsive.spacing(24)),
                          Obx(
                            () => CustomButton(
                              text: AppStrings.continueText.tr,
                              onPressed: controller.isLoading.value
                                  ? () {}
                                  : controller.verifyOtp,
                              isLoading: controller.isLoading.value,
                            ),
                          ),
                          SizedBox(height: AppResponsive.spacing(30)),
                        ],
                      ),
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

  Widget _buildOtpDigit(
    BuildContext context,
    int index,
    double size,
  ) {
    return SizedBox(
      width: size,
      height: size,
      child: TextField(
        controller: controller.otpControllers[index],
        textAlign: TextAlign.center,
        textAlignVertical: TextAlignVertical.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        onChanged: (value) {
          if (value.isNotEmpty && index < 5) {
            FocusScope.of(context).nextFocus();
          } else if (value.isEmpty && index > 0) {
            FocusScope.of(context).previousFocus();
          }
        },
        decoration: InputDecoration(
          counterText: '',
          contentPadding: EdgeInsets.zero,
          filled: true,
          fillColor: Colors.white,
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
        ),
        style: TextStyle(
          fontSize: AppResponsive.font(20),
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
