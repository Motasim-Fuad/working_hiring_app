import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/widgets/custom_appBar/custom_app_bar.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/worker/account_verification/controllers/worker_account_verification_controller.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/worker/account_verification/views/worker_account_verification/widgets/worker_account_verification_already_verified_state.dart';
import 'package:working_hiring/app/features/worker/account_verification/views/worker_account_verification/widgets/worker_account_verification_document_selection.dart';
import 'package:working_hiring/app/features/worker/account_verification/views/worker_account_verification/widgets/worker_account_verification_details_form.dart';
import 'package:working_hiring/app/features/worker/account_verification/views/worker_account_verification/widgets/worker_account_verification_pending_state.dart';

class WorkerAccountVerificationView
    extends GetView<WorkerAccountVerificationController> {
  const WorkerAccountVerificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: true,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: AppStrings.accountVerification.tr,

          showLeading: true,
          onPressed: controller.leaveVerification,
        ),
        body: Obx(() {
          if (controller.isVerified.value) {
            return WorkerAccountVerificationAlreadyVerifiedState();
          }

          if (controller.verificationStatus.value == 'REVIEW' &&
              controller.hasSubmittedDocuments.value) {
            return WorkerAccountVerificationPendingState(
              icon: Icons.hourglass_top,
              iconColor: Colors.orange,
              title: 'Verification Under Review'.tr,
              subtitle:
                  'Your documents are being reviewed. This usually takes 1-2 business days.',
            );
          }

          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  child: ResponsiveCenter(
                    child: controller.selectedDocumentType.value.isEmpty
                        ? WorkerAccountVerificationDocumentSelection()
                        : WorkerAccountVerificationDetailsForm(),
                  ),
                ),
              ),

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
                          if (controller.selectedDocumentType.value.isEmpty) {
                            controller.setDocumentType(AppStrings.idCard.tr);
                          } else {
                            controller.submit();
                          }
                        },
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
              ),
            ],
          );
        }),
      ),
    );
  }
}
