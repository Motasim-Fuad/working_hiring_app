import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/support/controllers/support_ticket_detail_controller.dart';

class SupportTicketFeedbackBottomInputArea extends StatelessWidget {
  final SupportTicketDetailController fieldController;

  const SupportTicketFeedbackBottomInputArea({
    super.key,
    required this.fieldController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: 16.w,
        vertical: 12.h,
      ).copyWith(bottom: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (fieldController.replyAttachmentPath.value.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              margin: EdgeInsets.only(bottom: 8.h),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8.r),
              ),
              child: Row(
                children: [
                  Icon(Icons.attach_file, size: 16.sp),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      fieldController.replyAttachmentName.value,
                      style: TextStyle(fontSize: 13.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 16.sp),
                    onPressed: fieldController.removeReplyAttachment,
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.add, color: Color(0xFF6CA34D), size: 28.sp),
                onPressed: fieldController.showReplyAttachmentOptions,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Container(
                  height: 48.h,
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE5E5E5)),
                    borderRadius: BorderRadius.circular(8.r),
                  ),
                  child: TextField(
                    controller: fieldController.replyController,
                    decoration: InputDecoration(
                      hintText: 'Write message'.tr,
                      hintStyle: TextStyle(
                        color: Color(0xFF9E9E9E),
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 14.h,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Obx(() {
                return IconButton(
                  icon: fieldController.isReplying.value
                      ? SizedBox(
                          width: 20.sp,
                          height: 20.sp,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          Icons.send_outlined,
                          color: Color(0xFF535763),
                          size: 24.sp,
                        ),
                  onPressed: fieldController.isReplying.value
                      ? null
                      : fieldController.sendReply,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}
