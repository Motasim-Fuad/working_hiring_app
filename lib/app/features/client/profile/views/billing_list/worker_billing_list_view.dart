import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/widgets/custom_appBar/custom_app_bar.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/worker/profile/controllers/worker_profile_controller.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_add_billing/worker_add_billing_view.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_add_bank_details/worker_add_bank_details_view.dart';
import 'package:working_hiring/app/features/client/profile/views/billing_list/widgets/worker_billing_list_billing_item.dart';

class WorkerBillingListView extends GetView<WorkerProfileController> {
  const WorkerBillingListView({super.key});

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
              style: TextStyle(fontSize: 14.sp, color: AppColors.textSecondary),
            ),
            SizedBox(height: 32.h),

            // List of cards - Mocked for now
            // Reuse logic or create widget if needed, but simple list here fine.
            WorkerBillingListBillingItem(
              cardType: "Visa",
              last4: "9380",
              currency: "CAD",
            ),

            SizedBox(height: 20.h),

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
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 12.h,
                      ),
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
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6A9B5D),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 24.w,
                      vertical: 14.h,
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    "Apply".tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
