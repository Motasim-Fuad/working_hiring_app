import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../constants/app_strings.dart';
import '../responsive_layout.dart';
class TaskSuccessCoustomView extends StatelessWidget {
  final String imagePath;
  final String title;
  final String subTitle1;
  final String subTitleNum1;
  final String subTitle2;
  final String subTitleNum2;
  final String buttonTitle;
  final bool isOrder;
  final VoidCallback onTap;
  TaskSuccessCoustomView({
    super.key,
    required this.imagePath,
    required this.title,
    required this.subTitle1,
    required this.subTitleNum1,
    required this.subTitle2,
    required this.subTitleNum2,
    required this.buttonTitle,
    required this.onTap,  this.isOrder=true,
  });
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(
        0xFFCBEFB6,
      ), // Light green background from design
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, viewport) => SingleChildScrollView(
            child: ResponsiveCenter(
              maxWidth: AppResponsive.formMaxWidth,
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: viewport.maxHeight - 32),
                child: IntrinsicHeight(
                  child: Column(
            children: [
              SizedBox(height: viewport.maxHeight < 650 ? 20 : 60),

              // "Let's Go" Text added to match design requirements and avoid image bleed
              Text(
                AppStrings.letsGo.tr,
                style: TextStyle(
                  fontSize: 32.sp,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1B1C1E),
                ),
              ),
              SizedBox(height: 10.h),

              // "Let's Go" Image
              Image.asset(
                imagePath,
                height: viewport.maxHeight < 650 ? 120 : 200,
                fit: BoxFit.contain,
              ), // Assuming 'successful.png' contains the text "Let's Go" logic or similar. If not, text widget.
              // Design shows big "Let's Go" which looks like graphic text.

              Spacer(),
              Text(
                title.tr,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 18.sp, color: Color(0xFF1B1C1E)),
              ),

              SizedBox(height: viewport.maxHeight < 650 ? 16 : 32),

              _buildStepRow(subTitleNum1, subTitle1.tr),
              SizedBox(height: 16.h),
              _buildStepRow(subTitleNum2, subTitle2.tr),

              SizedBox(height: viewport.maxHeight < 650 ? 20 : 40),
              SizedBox(
                width: double.infinity,
                height: 56.h,
                child: ElevatedButton(
                  onPressed: onTap,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1B1C1E), // Black button
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: FittedBox(
                    fit: BoxFit.scaleDown,
                    child: Text(
                      buttonTitle.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 40.h),

              // Bottom Indicator bar simulation
              Container(
                width: 140.w,
                height: 5.h,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(10.r),
                ),
              ),
              SizedBox(height: 10.h),
            ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStepRow(String number, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 24.w,
          height: 24.h,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Color(0xFF1B1C1E),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12.sp,
            ),
          ),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontSize: AppResponsive.font(16),
              fontWeight: FontWeight.w600,
              color: Color(0xFF1B1C1E),
            ),
          ),
        ),
      ],
    );
  }
}
