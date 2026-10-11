import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/core/widgets/custom_button.dart';
import 'package:working_hiring/app/routes/app_pages.dart';

class PaymentSuccessView extends StatelessWidget {
  final bool cameFromChat;
  const PaymentSuccessView({super.key, this.cameFromChat = false});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: CustomButton(
        text: cameFromChat ? "Done" : AppStrings.goOrder.tr,
        onPressed: () {
          if (cameFromChat) {
            Get.back(result: true);
          } else {
            Get.toNamed(Routes.DASHBOARD);
          }
        },
        backgroundColor: AppColors.textPrimary,
      ).marginOnly(bottom: 60.h, left: 20.w, right: 20.w),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: Color(0xFF64D864),
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.check, color: Colors.white, size: 60.sp),
            ),
            SizedBox(height: 40.h),
            Text(
              AppStrings.paymentSuccessful.tr,
              style: TextStyle(
                fontSize: 22.sp,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
