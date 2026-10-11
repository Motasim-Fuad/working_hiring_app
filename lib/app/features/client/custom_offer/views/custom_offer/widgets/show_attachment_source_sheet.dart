import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/custom_offer/controllers/custom_offer_controller.dart';

void showAttachmentSourceSheet(CustomOfferController controller) {
  Get.bottomSheet(
    Material(
      color: Colors.white,
      borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      clipBehavior: Clip.antiAlias,
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 8.h),
            ListTile(
              leading: Icon(
                Icons.camera_alt_outlined,
                color: Color(0xFF6CA34D),
              ),
              title: Text("Take a photo".tr),
              onTap: () {
                Get.back();
                controller.pickImageFromCamera();
              },
            ),
            ListTile(
              leading: Icon(Icons.image_outlined, color: Color(0xFF6CA34D)),
              title: Text("Choose from gallery".tr),
              onTap: () {
                Get.back();
                controller.pickImageFromGallery();
              },
            ),
            ListTile(
              leading: Icon(Icons.picture_as_pdf, color: Colors.red.shade400),
              title: Text("Attach a PDF".tr),
              onTap: () {
                Get.back();
                controller.pickPdf();
              },
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
    ),
  );
}
