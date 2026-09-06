import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../i_want_to_work/profile/controllers/worker_profile_controller.dart';
import '../../../i_want_to_work/profile/views/worker_add_billing_view.dart';
import '../../../i_want_to_work/profile/views/worker_add_bank_details_view.dart';

class WorkerBillingListView extends GetView<WorkerProfileController> {
  WorkerBillingListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.billingAndPayments.tr,
        showLeading: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.manageBillingMethod.tr,
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Text(
              AppStrings.manageBillingDesc.tr,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 32.h),

            // List of cards - Mocked for now
            // Reuse logic or create widget if needed, but simple list here fine.
            _buildBillingItem(
              cardType: "Visa",
              last4: "9380",
              currency: "CAD", // AppStrings.cad.tr
            ),

            SizedBox(height: 20.h),

            // Add Billing Method Button
            TextButton.icon(
              onPressed: () => Get.to(() => WorkerAddBillingView()),
              icon: Icon(Icons.add, color: Color(0xFF6A9B5D)),
              label: Text(
                AppStrings.addBillingMethod.tr,
                style: TextStyle(
                  color: Color(0xFF6A9B5D),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
            ),
            SizedBox(height: 16.h),
            TextButton.icon(
              onPressed: () => Get.to(() => WorkerAddBankDetailsView()),
              icon: Icon(Icons.account_balance, color: Color(0xFF6A9B5D)),
              label: Text(
                "Add Bank Account".tr,
                style: TextStyle(
                  color: Color(0xFF6A9B5D),
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w500,
                ),
              ),
              style: TextButton.styleFrom(
                padding: EdgeInsets.zero,
                alignment: Alignment.centerLeft,
              ),
            ),
            SizedBox(height: 32.h),
            Divider(),
            SizedBox(height: 16.h),
            Text(
              "Voucher Code".tr,
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(height: 8.h),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    decoration: InputDecoration(
                      hintText: "Enter voucher code".tr,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8.r),
                        borderSide: BorderSide(color: AppColors.border),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                ElevatedButton(
                  onPressed: () {
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6A9B5D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 14.h),
                    elevation: 0,
                  ),
                  child: Text(
                    "Apply".tr,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBillingItem({
    required String cardType,
    required String last4,
    required String currency,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Card Icon Placeholder -
              // ideally SvgPicture.asset('assets/icons/visa.svg')
              Container(
                width: 40.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: Color(0xFF1A1F71), // Visa Blue or image
                  borderRadius: BorderRadius.circular(4.r),
                ),
                alignment: Alignment.center,
                child: Text(
                  "VISA".tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Text(
                                  'Card Ending In'.trParams({
                                    'type': '$cardType',
                                    'last4': '$last4',
                                  }),
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16.sp,
                ),
              ),
              Spacer(),
              Text(
                currency,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ],
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              GestureDetector(
                onTap: () {
                  // Edit logic
                },
                child: Text(
                  AppStrings.edit.tr,
                  style: TextStyle(
                    color: Color(0xFF6A9B5D), // Green
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 24.w),
              GestureDetector(
                onTap: () {
                  // Remove logic
                },
                child: Text(
                  AppStrings.remove.tr,
                  style: TextStyle(
                    color: Color(0xFFFF5252), // Red
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
