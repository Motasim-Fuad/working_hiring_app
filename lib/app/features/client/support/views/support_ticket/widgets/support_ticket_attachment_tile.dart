import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/client/support/controllers/support_ticket_controller.dart';

class SupportTicketAttachmentTile extends StatelessWidget {
  final SupportTicketController fieldController;

  const SupportTicketAttachmentTile({super.key, required this.fieldController});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: fieldController.showAttachmentOptions,
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          children: [
            Obx(() {
              final isAttached =
                  fieldController.attachedFileName.value.isNotEmpty;
              return Expanded(
                child: Text(
                  isAttached
                      ? fieldController.attachedFileName.value
                      : AppStrings.addAttachment.tr,
                  style: TextStyle(
                    color: isAttached ? Colors.black : Color(0xFF9E9E9E),
                    fontSize: 14.sp,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }),
            SizedBox(width: 8.w),
            Obx(() {
              final isAttached =
                  fieldController.attachedFileName.value.isNotEmpty;
              return Icon(
                isAttached ? Icons.check_circle : Icons.attach_file,
                color: isAttached ? Color(0xFF32C759) : Color(0xFF9E9E9E),
                size: 20.sp,
              );
            }),
          ],
        ),
      ),
    );
  }
}
