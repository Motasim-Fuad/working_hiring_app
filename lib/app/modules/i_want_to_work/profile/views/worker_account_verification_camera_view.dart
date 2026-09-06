import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:camera/camera.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/worker_account_verification_controller.dart';
import '../../../../core/widgets/responsive_layout.dart';

class WorkerAccountVerificationCameraView
    extends GetView<WorkerAccountVerificationController> {
  WorkerAccountVerificationCameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFF1E1E1E), // Dark background from image
      body: LayoutBuilder(
        builder: (context, constraints) {
          final frameWidth = (constraints.maxWidth * 0.85).clamp(260.0, 720.0);
          final frameHeight = (frameWidth * 0.63).clamp(164.0, constraints.maxHeight * 0.62);
          return Stack(
            children: [
          // Close button
          Positioned(
            top: 50.h,
            right: 20.w,
            child: IconButton(
              icon: Icon(Icons.close, color: Colors.white, size: 28.sp),
              onPressed: () => Get.back(),
            ),
          ),

          // Main Content
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Camera Frame
                Container(
                  width: frameWidth,
                  height: frameHeight,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 2),
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Obx(() {
                      if (controller.isCameraInitialized.value &&
                          controller.cameraController != null) {
                        return CameraPreview(controller.cameraController!);
                      } else {
                        return Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        );
                      }
                    }),
                  ),
                ),
                SizedBox(height: 30.h),

                // Instruction Text
                Text(
                  AppStrings.placeIdInFrame.tr,
                  style: TextStyle(fontSize: 16.sp, color: Colors.white),
                ),
              ],
            ),
          ),

          // Shutter Button
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(bottom: 60.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Spacer to center the shutter button
                    SizedBox(width: 60.w),

                    // Shutter Button
                    GestureDetector(
                      onTap: () => controller.captureImage(),
                      child: Container(
                        width: 72.w,
                        height: 72.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 4),
                        ),
                        child: Center(
                          child: Container(
                            width: 56.w,
                            height: 56.h,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(width: 20.w),

                    // Gallery Button
                    GestureDetector(
                      onTap: () => controller.pickImageFromGallery(),
                      child: Container(
                        width: 40.w,
                        height: 40.h,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.photo_library, // Gallery icon
                          color: Colors.white,
                          size: 20.sp,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
            ],
          );
        },
      ),
    );
  }
}
