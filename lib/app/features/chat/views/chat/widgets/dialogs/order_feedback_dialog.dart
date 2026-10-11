import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/chat/controllers/message_controller.dart';

void showOrderFeedbackDialog(MessageController controller, int orderId) {
  final rating = 5.obs;
  final reviewController = TextEditingController();
  Get.dialog(
    AlertDialog(
      backgroundColor: Colors.white,
      insetPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
      titlePadding: EdgeInsets.fromLTRB(24.w, 24.h, 24.w, 8.h),
      contentPadding: EdgeInsets.fromLTRB(24.w, 8.h, 24.w, 16.h),
      actionsPadding: EdgeInsets.fromLTRB(16.w, 0, 16.w, 16.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      title: Text(
        'Rate & Review'.tr,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.w700),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                final value = index + 1;
                return IconButton(
                  onPressed: () => rating.value = value,
                  icon: Icon(
                    value <= rating.value
                        ? Icons.star_rounded
                        : Icons.star_outline_rounded,
                    size: 32.sp,
                    color: const Color(0xFFFFB400),
                  ),
                );
              }),
            ),
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: reviewController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: 'Share your experience…'.tr,
              filled: true,
              fillColor: const Color(0xFFF6F7F9),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12.r),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text('Cancel'.tr)),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          onPressed: () async {
            final success = await controller.submitFeedback(
              orderId,
              rating.value,
              reviewController.text.trim(),
            );
            if (success) {
              final overlayContext = Get.overlayContext;
              if (overlayContext != null && overlayContext.mounted) {
                Navigator.of(overlayContext, rootNavigator: true).pop();
              }
            }
          },
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.w),
            child: Text('Submit'.tr),
          ),
        ),
      ],
    ),
  );
}
