import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/contextual_warning_banner.dart';
import '../controllers/worker_account_verification_controller.dart';
import '../../../../core/widgets/responsive_layout.dart';

class WorkerAccountVerificationInstructionView
    extends GetView<WorkerAccountVerificationController> {
  WorkerAccountVerificationInstructionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.accountVerification.tr,
        showLeading: true,
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: Colors.black, size: 24),
            onPressed: () => Get.back(),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            ContextualWarningBanner(
              message:
                  "Your privacy is secured. We don't share your private information with others.",
              backgroundColor: Color(0xFFE3F2FD), // Light blue
              textColor: Color(0xFF1976D2), // Dark blue
              icon: Icons.security,
              iconColor: Color(0xFF1976D2),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: ResponsiveCenter(
                  child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10.h),
                    Text(
                      AppStrings.documentVerification.tr,
                      style: TextStyle(
                        fontSize: 24.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    Text(
                      AppStrings.takePicturesOfId.tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    SizedBox(height: 40.h),

                    // ID Card Illustration
                    Center(child: _buildIdCardIllustration()),
                    SizedBox(
                      height: 20.h,
                    ), // Add some bottom spacing for scrollable content
                  ],
                  ),
                ),
              ),
            ),

            // Continue Button - Pinned to bottom
            ResponsiveCenter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 24.0.h),
                child: SizedBox(
                width: double.infinity,
                height: AppResponsive.height(70, min: 60, max: 76),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () => controller.goToCamera(),
                  child: Text(
                    AppStrings.continueText.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
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

  Widget _buildIdCardIllustration() {
    return Container(
      width: 300.w.clamp(250.0, 360.0),
      height: 190.h.clamp(158.0, 228.0),
      decoration: BoxDecoration(
        color: Color(0xFF78A8B6), // Teal-ish background
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Stack(
        children: [
          // Header Text
          Positioned(
            top: 20,
            left: 0,
            right: 0,
            child: Text(
              "ID CARD".tr,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.5,
              ),
            ),
          ),

          // Content Area
          Positioned(
            top: 60,
            left: 12,
            right: 12,
            bottom: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Color(0xFFA6CED7), // Lighter teal
                borderRadius: BorderRadius.circular(8),
              ),
              child: Stack(
                children: [
                  // Photo Placeholder
                  Positioned(
                    top: 15,
                    left: 15,
                    bottom: 15,
                    width: 70,
                    child: Container(
                      color: Color(0xFFF2E7C9), // Beige skin tone bg
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // Rough shape of a person
                          Positioned(
                            bottom: 0,
                            child: Container(
                              width: 70,
                              height: 30,
                              color: Color(0xFF1A3348), // Dark blue suit
                            ),
                          ),
                          // Head/Neck would be complex to draw with containers,
                          // keeping it simple abstract or simple shapes
                          Positioned(
                            top: 15,
                            child: Container(
                              width: 35,
                              height: 45,
                              decoration: BoxDecoration(
                                color: Color(0xFFF3C774), // Face color
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          // Hair
                          Positioned(
                            top: 10,
                            child: Container(
                              width: 40,
                              height: 25,
                              decoration: BoxDecoration(
                                color: Color(0xFF333333), // Hair color
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(20),
                                  topRight: Radius.circular(20),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Text Lines
                  Positioned(
                    top: 20,
                    left: 100,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          height: 6,
                          color: Color(0xFF6B97A3),
                          width: 140,
                        ), // Title line
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              height: 6,
                              color: Color(0xFF6B97A3),
                              width: 60,
                            ),
                            SizedBox(width: 10),
                            Container(
                              height: 6,
                              color: Color(0xFF6B97A3),
                              width: 40,
                            ),
                          ],
                        ),
                        SizedBox(height: 12),
                        Container(
                          height: 6,
                          color: Color(0xFF6B97A3),
                          width: 100,
                        ),
                        SizedBox(height: 12),
                        Container(
                          height: 6,
                          color: Color(0xFF6B97A3),
                          width: 120,
                        ),
                        SizedBox(height: 12),
                        Row(
                          children: [
                            Container(
                              height: 6,
                              color: Color(0xFF6B97A3),
                              width: 50,
                            ),
                            SizedBox(width: 10),
                            Container(
                              height: 6,
                              color: Color(0xFF6B97A3),
                              width: 30,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Barcode
                  Positioned(
                    top: 15,
                    bottom: 15,
                    right: 15,
                    width: 20,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(
                        15,
                        (index) => Container(
                          height: 2,
                          color: Color(0xFF455A64),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
