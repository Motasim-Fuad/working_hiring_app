import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:working_hiring/app/core/animations/app_durations.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/core/widgets/button/button_label.dart';
import 'package:working_hiring/app/core/widgets/button/button_loading_label.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/core/widgets/button/button_type.dart';
export 'package:working_hiring/app/core/widgets/button/button_type.dart';

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

  /// Shown instead of [text] while [isLoading] is true.
  final String? loadingText;

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
    this.loadingText,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: isFullWidth ? double.infinity : width,
      height: AppResponsive.height(height, min: 48, max: 64),
      child: _buildButtonChild(),
    );
  }

  VoidCallback? get _onPressed => isLoading ? null : onPressed;

  Widget _buildButtonChild() {
    final shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12.r),
    );

    switch (type) {
      case ButtonType.outline:
        return OutlinedButton(
          onPressed: _onPressed,
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: backgroundColor ?? AppColors.primary),
            shape: shape,
          ),
          child: _buildButtonContent(AppColors.primary),
        );

      case ButtonType.text:
        return TextButton(
          onPressed: _onPressed,
          child: _buildButtonContent(textColor ?? AppColors.primary),
        );

      case ButtonType.primary:
        final bg = backgroundColor ?? AppColors.primary;
        return ElevatedButton(
          onPressed: _onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: bg,
            disabledBackgroundColor: isLoading
                ? bg.withValues(alpha: 0.8)
                : null,
            elevation: 0,
            shape: shape,
          ),
          child: _buildButtonContent(textColor ?? Colors.white),
        );
    }
  }

  Widget _buildButtonContent(Color color) {
    return AnimatedSwitcher(
      duration: AppDurations.fast,
      child: isLoading
          ? ButtonLoadingLabel(
              key: const ValueKey('loading'),
              text: loadingText ?? AppStrings.pleaseWait.tr,
              color: color,
            )
          : Row(
              key: const ValueKey('idle'),
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
                  child: ButtonLabel(text: text, color: color),
                ),
              ],
            ),
    );
  }
}
