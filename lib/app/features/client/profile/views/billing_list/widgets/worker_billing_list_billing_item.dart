import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';

class WorkerBillingListBillingItem extends StatelessWidget {
  final String cardType;
  final String last4;
  final String currency;

  const WorkerBillingListBillingItem({
    super.key,
    required this.cardType,
    required this.last4,
    required this.currency,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 24.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40.w,
                height: 24.h,
                decoration: BoxDecoration(
                  color: Color(0xFF1A1F71),
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
                'Card Ending In'.trParams({'type': cardType, 'last4': last4}),
                style: TextStyle(color: AppColors.textPrimary, fontSize: 16.sp),
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
                onTap: () {},
                child: Text(
                  AppStrings.edit.tr,
                  style: TextStyle(
                    color: Color(0xFF6A9B5D),
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              SizedBox(width: 24.w),
              GestureDetector(
                onTap: () {},
                child: Text(
                  AppStrings.remove.tr,
                  style: TextStyle(
                    color: Color(0xFFFF5252),
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
