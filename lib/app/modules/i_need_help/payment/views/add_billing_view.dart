import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';

class AddBillingView extends StatelessWidget {
  AddBillingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: AppStrings.billingAndPayments.tr),

      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0.w),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20.h),
              Text(
                AppStrings.addBillingMethod.tr,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 20.h),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(
                      color: Color(0xFF6A9B5D),
                    ), // Green border
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    AppStrings.cancel.tr,
                    style: TextStyle(
                      color: Color(0xFF6A9B5D), // Green text
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SvgPicture.asset(
                    'assets/icons/icon_mastercard.svg',
                    height: 20.h,
                  ),
                  SizedBox(width: 8.w),
                  SvgPicture.asset('assets/icons/icon_visa.svg', height: 20.h),
                  SizedBox(width: 8.w),
                  SvgPicture.asset('assets/icons/icon_amex.svg', height: 20.h),
                ],
              ),
              SizedBox(height: 10.h),

              CustomTextField(
                hintText: '8340 3948 9303 2087'.tr,
                prefixIcon: Icon(
                  Icons.credit_card,
                  color: Colors.black54,
                ),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),

              CustomTextField(hintText: AppStrings.cardHolderName.tr),
              SizedBox(height: 16.h),

              Row(
                children: [
                  Expanded(
                    child: CustomTextField(
                      hintText: AppStrings.mm.tr,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  SizedBox(width: 16.w),
                  Expanded(
                    child: CustomTextField(
                      hintText: AppStrings.yy.tr,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 16.h),

              CustomTextField(
                hintText: AppStrings.cvc.tr,
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),
              CustomTextField(hintText: AppStrings.address.tr),
              SizedBox(height: 16.h),
              CustomTextField(hintText: AppStrings.city.tr),
              SizedBox(height: 16.h),
              CustomTextField(
                hintText: AppStrings.postalCode.tr, // Ensure postalCode exists
                keyboardType: TextInputType.number,
              ),

              SizedBox(height: 40.h),

              CustomButton(
                text: AppStrings.save.tr,
                backgroundColor: Color(0xFF6A9B5D), // Green
                onPressed: () {
                  Get.back();
                },
              ),
              SizedBox(height: 40.h),
            ],
          ),
        ),
      ),
    );
  }
}
