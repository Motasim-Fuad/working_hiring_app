import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../main/views/main_view.dart';
import '../../../main/bindings/main_binding.dart';

class FeedbackSuccessView extends StatelessWidget {
  FeedbackSuccessView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFD1E8C5), // Light pastel green background
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Center Graphic
                  Center(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Outer vibrant green circle
                        Container(
                          width: 140.w,
                          height: 140.h,
                          decoration: BoxDecoration(
                            color: Color(0xFF32C759), // Vibrant green
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Top-right lighter crescent highlight
                        Positioned(
                          top: 0,
                          right: 0,
                          child: ClipPath(
                            clipper: _CrescentClipper(),
                            child: Container(
                              width: 140.w,
                              height: 140.h,
                              decoration: BoxDecoration(
                                color: Colors.white.withAlpha(50), // Lighter highlight
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ),
                        // Inner bold white checkmark
                        Icon(
                          Icons.check_rounded,
                          color: Colors.white,
                          size: 80.sp,
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 48.h),

                  // Title
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      AppStrings.thankYouFeedback.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1A1A1A), // Very dark grey/black
                        height: 1.3,
                      ),
                    ),
                  ),

                  SizedBox(height: 16.h),

                  // Subtitle
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 40.w),
                    child: Text(
                      AppStrings.reviewSubmittedSuccess.tr,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 15.sp,
                        color: Color(0xFF333333), // Standard dark grey
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Bottom Action Button
            Padding(
              padding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 16.h), // SafeArea bottom padding handled by Scaffold SafeArea
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Safe explicit routing that avoids triggering the root route and its SplashController
                    Get.offAll(() => MainView(), binding: MainBinding());
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF1A1A1A), // Very dark grey/black
                    padding: EdgeInsets.symmetric(vertical: 18.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(50.r), // Fully rounded / Stadium Border
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    AppStrings.backToHome.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600, // Medium-bold
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

// Custom clipper for the highlight crescent on the top right
class _CrescentClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(size.width / 2, 0);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.2, size.width * 0.2, size.height / 2);
    path.quadraticBezierTo(size.width * 0.2, size.height * 0.8, size.width / 2, size.height);
    path.arcToPoint(
      Offset(size.width / 2, 0),
      radius: Radius.circular(size.width / 2),
      clockwise: false,
    );
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
