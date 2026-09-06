import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/worker_account_verification_controller.dart';
import '../../../../core/widgets/responsive_layout.dart';

class WorkerAccountVerificationResultView
    extends GetView<WorkerAccountVerificationController> {
  WorkerAccountVerificationResultView({super.key});

  @override
  Widget build(BuildContext context) {
    // Determine state from arguments or controller
    // For simplicity, let's assume controller holds the state of "last attempt"
    // Or we pass it as argument. Let's use controller observable.

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.accountVerification.tr,
        showLeading: false,
      ),
      body: Obx(() {
        final isSuccess = controller.isVerificationSuccess.value;

        return Column(
          children: [
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: ResponsiveCenter(
                    child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Icon
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                        decoration: BoxDecoration(
                          color: isSuccess
                              ? Color(0xFF69F0AE).withValues(alpha: 0.2)
                              : Color(0xFFFFEBEE), // Light Green / Red
                          shape: BoxShape.circle,
                        ),
                        // Actual design uses specific shapes/colors
                        // Success: Green scalloped shape with check
                        // Failure: Red circle with X
                        child: isSuccess
                            ? Icon(
                                Icons.check,
                                color: Color(0xFF00C853),
                                size: 60.sp,
                              ) // Placeholder for scalloped shape
                            : Icon(
                                Icons.close,
                                color: Color(0xFFD32F2F),
                                size: 60.sp,
                              ),
                      ),

                      SizedBox(height: 24.h),

                      // Title
                      Text(
                        isSuccess
                            ? AppStrings.verificationSuccessful.tr
                            : AppStrings.verificationFailed.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                    ),
                  ),
                ),
              ),
            ),

            // Button - Pinned to bottom with SafeArea
            SafeArea(
              child: ResponsiveCenter(
                child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0.h),
                child: SizedBox(
                  width: double.infinity,
                  height: AppResponsive.height(70, min: 60, max: 76),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      if (isSuccess) {
                        controller.finishVerification();
                      } else {
                        controller.retryVerification();
                      }
                    },
                    child: Text(
                      isSuccess ? AppStrings.close.tr : AppStrings.tryAgain.tr,
                      style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
              ),
            ),
          ],
        );
      }),
    );
  }
}
