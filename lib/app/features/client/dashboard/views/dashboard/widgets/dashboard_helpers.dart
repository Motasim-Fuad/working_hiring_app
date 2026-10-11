import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';

BottomNavigationBarItem buildNavItem(String iconPath, String label) {
  return BottomNavigationBarItem(
    icon: Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: SvgPicture.asset(
        iconPath,
        width: 24.sp,
        height: 24.sp,
        colorFilter: ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
      ),
    ),
    activeIcon: Padding(
      padding: EdgeInsets.only(bottom: 4.h),
      child: SvgPicture.asset(
        iconPath,
        width: 24.sp,
        height: 24.sp,
        colorFilter: ColorFilter.mode(AppColors.primary, BlendMode.srcIn),
      ),
    ),
    label: label,
  );
}
