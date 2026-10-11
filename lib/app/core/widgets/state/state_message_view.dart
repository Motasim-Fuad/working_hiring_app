import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/animations/fade_slide_in.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/widgets/custom_button.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';

/// Centered icon + title + optional message + optional action button.
/// Base for [EmptyStateView] and [ErrorStateView].
class StateMessageView extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? message;
  final String? actionText;
  final VoidCallback? onAction;

  const StateMessageView({
    super.key,
    required this.icon,
    required this.title,
    this.iconColor = AppColors.primary,
    this.message,
    this.actionText,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: EdgeInsets.symmetric(horizontal: 32.w, vertical: 24.h),
        child: FadeSlideIn(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: EdgeInsets.all(18.r),
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 36.r, color: iconColor),
              ),
              SizedBox(height: 16.h),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: AppResponsive.font(16),
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              if (message != null) ...[
                SizedBox(height: 6.h),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: AppResponsive.font(13),
                    color: AppColors.textSecondary,
                    height: 1.4,
                  ),
                ),
              ],
              if (actionText != null && onAction != null) ...[
                SizedBox(height: 20.h),
                CustomButton(
                  text: actionText!,
                  onPressed: onAction!,
                  isFullWidth: false,
                  width: 160.w,
                  height: 44,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
