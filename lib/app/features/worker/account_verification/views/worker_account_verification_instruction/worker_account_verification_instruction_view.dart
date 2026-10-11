import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/widgets/custom_appBar/custom_app_bar.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/core/widgets/contextual_warning_banner.dart';
import 'package:working_hiring/app/features/worker/account_verification/controllers/worker_account_verification_controller.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/worker/account_verification/views/worker_account_verification_instruction/widgets/worker_account_verification_instruction_id_card_illustration.dart';

class WorkerAccountVerificationInstructionView
    extends GetView<WorkerAccountVerificationController> {
  const WorkerAccountVerificationInstructionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.accountVerification.tr,
        showLeading: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black, size: 24),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            ContextualWarningBanner(
              message:
                  "Your privacy is secured. We don't share your private information with others.",
              backgroundColor: Color(0xFFE3F2FD),
              textColor: Color(0xFF1976D2),
              icon: Icons.security,
              iconColor: Color(0xFF1976D2),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ResponsiveCenter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 10.h),
                      Text(
                        AppStrings.documentVerification.tr,
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppStrings.takePicturesOfId.tr,
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      SizedBox(height: 40.h),

                      Center(
                        child:
                            WorkerAccountVerificationInstructionIdCardIllustration(),
                      ),
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ),
            ),

            ResponsiveCenter(
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
                    onPressed: () => controller.goToCamera(),
                    child: Text(
                      AppStrings.continueText.tr,
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
          ],
        ),
      ),
    );
  }
}
