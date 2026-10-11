import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_images.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/core/widgets/custom_text_field.dart';

class AddBillingMethodView extends StatelessWidget {
  const AddBillingMethodView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppStrings.addBillingMethod.tr,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.addBillingMethod.tr,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 24.h),

              // Cancel button? Design shows a wide 'cancel' button outline at top?
              // "cancel" in green outline box. Strange UI pattern but I will follow design.
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => Get.back(),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(color: Color(0xFF6A9B5D)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    AppStrings.cancel.tr,
                    style: TextStyle(
                      color: Color(0xFF6A9B5D),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              SizedBox(height: 24.h),

              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [SvgPicture.asset(AppImages.visa, width: 32.w)],
              ),
              SizedBox(height: 8.h),

              CustomTextField(
                hintText: "8340 3948 9303 2087".tr,
                prefixIcon: Icon(Icons.payment, color: AppColors.textSecondary),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 16.h),
              CustomTextField(hintText: AppStrings.cardHolderName.tr),
              SizedBox(height: 16.h),
              Row(
                children: [
                  Expanded(child: CustomTextField(hintText: "MM")),
                  SizedBox(width: 16.w),
                  Expanded(child: CustomTextField(hintText: "YY")),
                ],
              ),
              SizedBox(height: 16.h),
              CustomTextField(hintText: AppStrings.cvc.tr),
              SizedBox(height: 16.h),
              CustomTextField(hintText: AppStrings.address.tr),
              SizedBox(height: 16.h),
              CustomTextField(hintText: AppStrings.city.tr),
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
              SizedBox(height: 20.h),
            ],
          ),
        ),
      ),
    );
  }
}
