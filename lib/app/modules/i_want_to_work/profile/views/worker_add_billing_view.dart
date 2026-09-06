import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../controllers/worker_profile_controller.dart';

class WorkerAddBillingView extends GetView<WorkerProfileController> {
  WorkerAddBillingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.billingAndPayments.tr,
        showLeading: true,
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: ResponsiveCenter(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.addBillingMethod.tr,
              style: TextStyle(
                fontSize: 20.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 24.h),

            // Cancel Button (Outlined, Full Width)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Get.back(),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Color(0xFF6A9B5D)),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  AppStrings.cancel.tr
                      .toLowerCase(), // Design shows lowercase "cancel"
                  style: TextStyle(
                    color: Color(0xFF6A9B5D),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 32.h),

            // Card Icons row if needed, or just Inputs
            // Design shows card logos above card number input right? No, standard input.
            CustomTextField(
              hintText: "8340 3948 9303 2087".tr, // AppStrings.cardNumber.tr,
              prefixIcon: Icon(
                Icons.credit_card,
                color: AppColors.textSecondary,
              ), // Placeholder icon
            ),
            SizedBox(height: 16.h),
            CustomTextField(hintText: AppStrings.cardHolderName.tr),
            SizedBox(height: 16.h),
            Row(
              children: [
                Expanded(child: CustomTextField(hintText: AppStrings.mm.tr)),
                SizedBox(width: 16.w),
                Expanded(child: CustomTextField(hintText: AppStrings.yy.tr)),
              ],
            ),
            SizedBox(height: 16.h),
            CustomTextField(hintText: AppStrings.cvc.tr),
            SizedBox(height: 16.h),
            CustomTextField(hintText: AppStrings.address.tr),
            SizedBox(height: 16.h),
            CustomTextField(hintText: AppStrings.city.tr), // generic city key
            SizedBox(height: 16.h),
            CustomTextField(hintText: AppStrings.postalCode.tr),

            SizedBox(height: 32.h),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Get.back();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF6A9B5D),
                  padding: EdgeInsets.symmetric(vertical: 16.h),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                ),
                child: Text(
                  AppStrings.save.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
          ),
        ),
      ),
    );
  }
}
