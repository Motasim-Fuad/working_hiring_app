import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../constants/app_colors.dart';
import 'responsive_layout.dart';

enum ButtonType { primary, outline, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final bool isFullWidth;
  final double? width;
  final double height;
  final Color? backgroundColor;
  final Color? textColor;
  final String? icon;
  final bool isLoading;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isFullWidth = true,
    this.width,
    this.height = 56,
    this.backgroundColor,
    this.textColor,
    this.icon,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonWidth = isFullWidth ? double.infinity : width;

    return SizedBox(
      width: buttonWidth,
      height: AppResponsive.height(height, min: 48, max: 64),
      child: _buildButtonChild(),
    );
  }

  Widget _buildButtonChild() {
    switch (type) {
      case ButtonType.outline:
        return OutlinedButton(
          onPressed: onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: backgroundColor ?? AppColors.primary),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: _buildButtonContent(AppColors.primary),
        );

      case ButtonType.text:
        return TextButton(
          onPressed: onPressed,
          child: _buildButtonContent(textColor ?? AppColors.primary),
        );

      default:
        return ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: backgroundColor ?? AppColors.primary,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: _buildButtonContent(textColor ?? Colors.white),
        );
    }
  }

  Widget _buildButtonContent(Color color) {
    if (isLoading) {
      return Center(
        child: SizedBox(
          width: AppResponsive.icon(24),
          height: AppResponsive.icon(24),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: color,
          ),
        ),
      );
    }
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (icon != null) ...[
          SvgPicture.asset(
            icon!,
            colorFilter: ColorFilter.mode(color, BlendMode.srcIn),
            width: AppResponsive.icon(24),
            height: AppResponsive.icon(24),
          ),
          SizedBox(width: 8.w),
        ],
        Flexible(
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontSize: AppResponsive.font(16),
                fontWeight: FontWeight.w600,
                height: 1.0, // Fix vertical alignment/clipping
              ),
            ),
          ),
        ),
      ],
    );
  }
}
