import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../routes/app_pages.dart';
class PaymentSuccessView extends StatelessWidget {
  final bool cameFromChat;
  PaymentSuccessView({super.key, this.cameFromChat = false});

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
      ).marginOnly(bottom: 60.h,left: 20.w,right: 20.w),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Big Green Check
            Container(
              width: 120.w,
              height: 120.h,
              decoration: BoxDecoration(
                color: Color(0xFF64D864), // Bright Green
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.check,
                color: Colors.white,
                size: 60.sp,
              ), // Simple icon
              // or SvgPicture.asset(AppImages.checkBig),
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
