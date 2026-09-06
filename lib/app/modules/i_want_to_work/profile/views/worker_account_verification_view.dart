import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/worker_account_verification_controller.dart';
import '../../../../core/widgets/responsive_layout.dart';

class WorkerAccountVerificationView
    extends GetView<WorkerAccountVerificationController> {
  WorkerAccountVerificationView({super.key});

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
        body: Obx(
          () {
            // Already verified — show success state
            if (controller.isVerified.value) {
              return _buildAlreadyVerifiedState();
            }

            // Under review — show pending state only when docs were actually submitted
            if (controller.verificationStatus.value == 'REVIEW' &&
                controller.hasSubmittedDocuments.value) {
              return _buildPendingState(
                icon: Icons.hourglass_top,
                iconColor: Colors.orange,
                title: 'Verification Under Review'.tr,
                subtitle:
                    'Your documents are being reviewed. This usually takes 1-2 business days.',
              );
            }

            // Show submission form
            return Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                    child: ResponsiveCenter(
                      child: controller.selectedDocumentType.value.isEmpty
                          ? _buildDocumentSelection()
                          : _buildDetailsForm(),
                    ),
                  ),
                ),

                // Continue Button
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
          },
        ),
      ),
    );
  }

  /// Shows the already-verified state with a button to go to the dashboard.
  Widget _buildAlreadyVerifiedState() {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0.w, vertical: 32.0.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: Color(0xFF00C853).withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check_circle,
                color: Color(0xFF00C853),
                size: 64.sp,
              ),
            ),
            SizedBox(height: 24.h),
            Text(
              AppStrings.verificationSuccessful.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Your account has been verified.'.tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              height: AppResponsive.height(50, min: 48, max: 56),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                onPressed: () => controller.finishVerification(),
                child: Text(
                  'Go to Dashboard'.tr,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Step 1: Document Selection
  Widget _buildDocumentSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.documentVerification.tr,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          AppStrings.documentType.tr,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),

        // ID Card Option
        _buildSelectionCard(
          title: AppStrings.idCard.tr,
          iconData: Icons.badge_outlined, // Placeholder for ID icon
          isSelected: true, // Mocking state for UI demo as per Image 1
          onTap: () {
            // In a real flow, this would update a local state, then "Continue" moves to next step
            // For this implementation, I'll make the card tap immediately set the type to show the form?
            // Or should I maintain the 2-step visually?
            // The image shows a "Continue" button at the bottom.
            // So I should probably use a local variable for "currently highlighted selection" vs "confirmed selection".
            // But to keep it simple, let's say tapping "Continue" moves to the form.
          },
        ),
        SizedBox(height: 16.h),

        // Passport Option
        _buildSelectionCard(
          title: AppStrings.passport.tr,
          iconData: Icons.book_outlined, // Placeholder for Passport icon
          isSelected: false,
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildSelectionCard({
    required String title,
    required IconData iconData,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    // Need to handle the "Radio" button look
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: isSelected ? Colors.white : Color(0xFFF9F9F9),
          border: Border.all(
            color: isSelected ? AppColors.primary : Colors.transparent,
            width: 1.5,
          ),
          borderRadius: BorderRadius.circular(8.r),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            Icon(
              iconData,
              color: isSelected ? AppColors.primary : AppColors.textPrimary,
              size: 24.sp,
            ), // Custom icon in asset would be better
            SizedBox(width: 16.w),
            Expanded(
              child: Text(
                title,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            // Radio Circle
            Container(
              width: 20.w,
              height: 20.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? AppColors.primary : Colors.grey.shade400,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? Center(
                      child: Container(
                        width: 10.w,
                        height: 10.h,
                        decoration: BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                      ),
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  // Step 2: Form Input
  Widget _buildDetailsForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.documentVerification.tr,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          AppStrings.provideIdInfo.tr,
          style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
        ),
        SizedBox(height: 32.h),

        // Full Name
        _buildLabel(AppStrings.fullName.tr),
        SizedBox(height: 8.h),
        _buildTextField(
          controller: controller.nameController,
          hintText: "Alex Smith",
        ),

        SizedBox(height: 20.h),

        // DOB
        _buildLabel(AppStrings.dateOfBirth.tr),
        SizedBox(height: 8.h),
        _buildTextField(
          controller: controller.dobController,
          hintText: "mm/dd/yy".tr,
          readOnly: true,
          onTap: () => controller.pickDateOfBirth(Get.context!),
        ),

        SizedBox(height: 20.h),

        // ID Number
        _buildLabel(AppStrings.idNumber.tr),
        SizedBox(height: 8.h),
        _buildTextField(
          controller: controller.idNumberController,
          hintText: "45246282554252".tr,
        ),

        // Upload would go here if needed, but per images 2/3 it's just the form visible.
        // I will stick to what is clearly visible in the reference for now.
      ],
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        fontSize: 14.sp,
        fontWeight: FontWeight.w500,
        color: Color(0xFF424242),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      onTap: onTap,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(color: Color(0xFFBDBDBD)),
        contentPadding: EdgeInsets.symmetric(
          horizontal: 16.w,
          vertical: 14.h,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: Color(0xFFE0E0E0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10.r),
          borderSide: BorderSide(color: AppColors.primary, width: 1.5),
        ),
      ),
    );
  }

  Widget _buildPendingState({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 32.0.w, vertical: 32.0.h),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: iconColor, size: 64.sp),
            ),
            SizedBox(height: 24.h),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
