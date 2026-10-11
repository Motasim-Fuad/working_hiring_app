import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';

class WorkerSettingsMenuItem extends StatelessWidget {
  final dynamic icon;
  final String title;
  final VoidCallback? onTap;
  final String? trailingText;
  final bool isIconData;
  final IconData? iconData;
  final Widget? trailing;

  const WorkerSettingsMenuItem({
    super.key,
    required this.icon,
    required this.title,
    this.onTap,
    this.trailingText,
    this.isIconData = false,
    this.iconData,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final trailingText = this.trailingText;
    return ListTile(
      leading: Container(
        padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: isIconData
            ? Icon(iconData, color: Colors.black54)
            : SvgPicture.asset(icon, width: 24.w, height: 24.h),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 16.sp,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing:
          trailing ??
          (trailingText != null
              ? Text(
                  trailingText,
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                )
              : Icon(Icons.arrow_forward_ios, size: 16.sp, color: Colors.grey)),
      onTap: onTap,
    );
  }
}
