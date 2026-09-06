import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/billing_payments_controller.dart';
import 'add_billing_view.dart';

class BillingListView extends GetView<BillingPaymentsController> {
  BillingListView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, size: 20.sp, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppStrings.billingAndPayments.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0.w, vertical: 24.0.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              AppStrings.manageBillingMethod.tr,
              style: TextStyle(
                fontSize: 20.sp,
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
            SizedBox(height: 30.h),
            Obx(
              () => ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: controller.paymentMethods.length,
                separatorBuilder: (_, _) => SizedBox(height: 16.h),
                itemBuilder: (context, index) {
                  final method = controller.paymentMethods[index];
                  // Using a simple Row layout instead of List Tile to match screens exactly
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Icon
                      Container(
                        width: 40.w,
                        height: 25.h,
                        decoration: BoxDecoration(
                          color: Color(0xFF1A1F71), // Visa color
                          borderRadius: BorderRadius.circular(4.r),
                        ),
                        alignment: Alignment.center,
                        // Use the SVG if available, or text
                        child: SvgPicture.asset(
                          AppImages.visa,
                          width: 32.w,
                          // colorFilter:ColorFilter.mode(Colors.white, BlendMode.srcIn) ,
                        ),
                        // Note: The dummy asset might be colored, so color: argument might need check
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Card Ending In'.trParams({
                                    'type': '${method.type}',
                                    'last4': '${method.last4}',
                                  }),
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                                Text(
                                  'CAD',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8.h),
                            Row(
                              children: [
                                GestureDetector(
                                  onTap: () {},
                                  child: Text(
                                    AppStrings.edit.tr,
                                    style: TextStyle(
                                      color: Color(0xFF6A9B5D), // Green
                                      fontSize: 14.sp,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                                SizedBox(width: 24.w), // Increased spacing
                                GestureDetector(
                                  onTap: () =>
                                      controller.removePaymentMethod(method.id),
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
                      ),
                    ],
                  );
                },
              ),
            ),
            SizedBox(height: 24.h),
            InkWell(
              onTap: () {
                Get.to(() => AddBillingView());
              },
              child: Row(
                children: [
                  Icon(Icons.add, color: Color(0xFF6A9B5D), size: 24.sp),
                  SizedBox(width: 8.w),
                  Text(
                    AppStrings.addBillingMethod.tr,
                    style: TextStyle(
                      color: Color(0xFF6A9B5D),
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
