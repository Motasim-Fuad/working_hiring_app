import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import 'responsive_layout.dart';

class ServiceChip extends StatelessWidget {
  final String iconPath;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const ServiceChip({
    super.key,
    required this.iconPath,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(30.r),
      child: Container(
        constraints: const BoxConstraints(minHeight: 44, maxHeight: 56),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFF2F8F2)
              : Colors.white, // Light green bg if selected
          borderRadius: BorderRadius.circular(30.r),
          border: Border.all(
            color: isSelected ? AppColors.primary : AppColors.border,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (isSelected)
              Padding(
                padding: EdgeInsets.only(right: 8.0.w),
                child: Icon(
                  Icons.check,
                  color: AppColors.primary,
                  size: AppResponsive.icon(20),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.only(right: 8.0.w),
                child: SvgPicture.asset(
                  iconPath,
                  width: AppResponsive.icon(24),
                  height: AppResponsive.icon(24),
                ),
              ),
            Flexible(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: AppResponsive.font(14),
                  fontWeight: FontWeight.w500,
                  color: AppColors.textPrimary,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
