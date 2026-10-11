import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_hiring/app/features/client/custom_offer/controllers/custom_offer_controller.dart';

class CreateCustomOfferAttachmentTile extends StatelessWidget {
  final CustomOfferController fieldController;
  final File file;

  const CreateCustomOfferAttachmentTile({
    super.key,
    required this.fieldController,
    required this.file,
  });

  @override
  Widget build(BuildContext context) {
    final isPdf = fieldController.isPdf(file);
    return Padding(
      padding: EdgeInsets.only(right: 12.w),
      child: Stack(
        children: [
          Container(
            width: 80.w,
            height: 80.h,
            clipBehavior: Clip.antiAlias,
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: isPdf
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.picture_as_pdf,
                        color: Colors.red.shade400,
                        size: 30.sp,
                      ),
                      SizedBox(height: 4.h),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 4.w),
                        child: Text(
                          fieldController.fileName(file),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 9.sp,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                    ],
                  )
                : Image.file(
                    file,
                    fit: BoxFit.cover,
                    width: 80.w,
                    height: 80.h,
                  ),
          ),
          Positioned(
            top: 2,
            right: 2,
            child: GestureDetector(
              onTap: () => fieldController.removeAttachment(file),
              child: Container(
                padding: EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.close, color: Colors.white, size: 14.sp),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
