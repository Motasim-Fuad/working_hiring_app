import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';

class CreateCustomOfferDropdownLikeField extends StatelessWidget {
  final String hint;
  final Widget trailingIcon;
  final Widget? leadingIcon;
  final VoidCallback? onTap;
  final String? value;

  const CreateCustomOfferDropdownLikeField({
    super.key,
    required this.hint,
    required this.trailingIcon,
    this.leadingIcon,
    this.onTap,
    this.value,
  });

  @override
  Widget build(BuildContext context) {
    final leadingIcon = this.leadingIcon;
    final value = this.value;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Row(
          children: [
            if (leadingIcon != null) ...[leadingIcon, SizedBox(width: 8.w)],
            Expanded(
              child: Text(
                value ?? hint,
                style: TextStyle(
                  fontSize: 16.sp,
                  color: value == null
                      ? Color(0xFF9E9E9E)
                      : AppColors.textPrimary,
                ),
              ),
            ),
            trailingIcon,
          ],
        ),
      ),
    );
  }
}
