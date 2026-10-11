import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/widgets/home_header.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';

class WorkerDashboardAccessGate extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? buttonText;
  final Future<void> Function()? onPressed;
  final bool isLoading;

  const WorkerDashboardAccessGate({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.buttonText,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final buttonText = this.buttonText;
    final onPressed = this.onPressed;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: ResponsiveCenter(
                    maxWidth: AppResponsive.formMaxWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(28.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 72.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 28.h),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 28.h),
                        if (isLoading)
                          CircularProgressIndicator(color: AppColors.primary)
                        else if (buttonText != null && onPressed != null)
                          SizedBox(
                            width: double.infinity,
                            height: AppResponsive.height(52, min: 48, max: 58),
                            child: ElevatedButton(
                              onPressed: () => onPressed(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textPrimary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                buttonText,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
