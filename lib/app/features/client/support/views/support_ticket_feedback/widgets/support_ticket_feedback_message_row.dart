import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/widgets/ticket_attachment_viewer.dart';

class SupportTicketFeedbackMessageRow extends StatelessWidget {
  final bool isAdmin;
  final String name;
  final String time;
  final String text;
  final String? attachment;

  const SupportTicketFeedbackMessageRow({
    super.key,
    required this.isAdmin,
    required this.name,
    required this.time,
    required this.text,
    this.attachment,
  });

  @override
  Widget build(BuildContext context) {
    final attachment = this.attachment;
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: Get.width * 0.75),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: isAdmin
            ? CrossAxisAlignment.start
            : CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 12.r,
                backgroundColor: Color(0xFFEAF4E5),
                child: Icon(
                  isAdmin ? Icons.support_agent : Icons.person_outline,
                  color: Color(0xFF6CA34D),
                  size: 15.sp,
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Text(
                  time,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12.sp),
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontSize: 14.sp,
              height: 1.4,
            ),
            textAlign: isAdmin ? TextAlign.left : TextAlign.right,
          ),
          if (attachment != null) ...[
            SizedBox(height: 12.h),
            InkWell(
              borderRadius: BorderRadius.circular(8.r),
              onTap: () => showTicketAttachment(context, attachment),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFE5E5E5)),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  children: [
                    Icon(
                      isTicketImageAttachment(attachment)
                          ? Icons.image_outlined
                          : Icons.insert_drive_file_outlined,
                      color: Colors.black54,
                      size: 20.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        attachment.split('/').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(
                      Icons.remove_red_eye_outlined,
                      color: Color(0xFF6CA34D),
                      size: 20.sp,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );

    final moreIcon = Icon(Icons.more_vert, color: Colors.black54, size: 20.sp);

    return Row(
      mainAxisAlignment: isAdmin
          ? MainAxisAlignment.start
          : MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (!isAdmin) moreIcon,
        if (!isAdmin) SizedBox(width: 8.w),
        Flexible(child: bubble),
        if (isAdmin) SizedBox(width: 8.w),
        if (isAdmin) moreIcon,
      ],
    );
  }
}
