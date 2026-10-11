import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/shell/views/main/main_view.dart';
import 'package:working_hiring/app/features/shell/bindings/main_binding.dart';
import 'package:working_hiring/app/features/client/order/views/feedback_success/widgets/crescent_clipper.dart';

class FeedbackSuccessView extends StatelessWidget {
  const FeedbackSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD1E8C5),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 140.w,
                          height: 140.h,
                          decoration: BoxDecoration(
                            color: Color(0xFF32C759),
                            shape: BoxShape.circle,
                          ),
                        ),
                        Positioned(
                          top: 0,
                          right: 0,
                          child: ClipPath(
                            clipper: CrescentClipper(),
                            child: Container(
                              width: 140.w,
                              height: 140.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(50),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 80.sp,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 48.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      AppStrings.thankYouFeedback.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A),
                        height: 1.3,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      AppStrings.reviewSubmittedSuccess.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Color(0xFF333333),
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Get.offAll(() => MainView(), binding: MainBinding());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A1A1A),
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppStrings.backToHome.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
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
