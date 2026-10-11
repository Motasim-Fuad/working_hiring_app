import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/models/ticket_model.dart';
import 'package:working_hiring/app/features/worker/support/controllers/worker_support_ticket_controller.dart';
import 'package:working_hiring/app/features/client/support/views/support_ticket_feedback/support_ticket_feedback_view.dart';
import 'package:working_hiring/app/core/widgets/ticket_attachment_viewer.dart';
import 'package:working_hiring/app/features/worker/support/views/worker_support_ticket_history/widgets/worker_support_ticket_history_helpers.dart';

class WorkerSupportTicketHistoryTicketCard extends StatelessWidget {
  final TicketModel ticket;
  final WorkerSupportTicketController fieldController;

  const WorkerSupportTicketHistoryTicketCard({
    super.key,
    required this.ticket,
    required this.fieldController,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = ticket.status == 'open';
    final statusColor = isOpen ? Color(0xFFFF9500) : Color(0xFF4CAF50);
    final statusBg = isOpen ? Color(0xFFFFF4E5) : Color(0xFFE8F5E9);

    return GestureDetector(
      onTap: () => Get.to(
        () => SupportTicketFeedbackView(
          ticketId: ticket.id,
          profileType: 'PROVIDER',
          orderTitle: fieldController.getOrderTitle(ticket.order),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border.all(color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(12.r),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.02),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 18.r,
                  backgroundColor: Color(0xFFEAF4E5),
                  child: Icon(
                    Icons.person_outline,
                    color: Color(0xFF6CA34D),
                    size: 21.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ticket.userName ?? 'User',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15.sp,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        formatDate(ticket.createdAt),
                        style: TextStyle(
                          color: Color(0xFF9E9E9E),
                          fontSize: 12.sp,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: 8.w),
                Flexible(
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: statusBg,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      ticket.status,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            Text(
              'Subject Value'.trParams({'subject': ticket.subject}),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16.sp,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 6.h),
            Text(
              fieldController.getOrderTitle(ticket.order),
              style: TextStyle(
                color: Color(0xFF6CA34D),
                fontSize: 13.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              ticket.summary,
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (ticket.attachment != null) ...[
              SizedBox(height: 16.h),
              InkWell(
                borderRadius: BorderRadius.circular(8.r),
                onTap: () => showTicketAttachment(context, ticket.attachment!),
                child: Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 12.w,
                    vertical: 10.h,
                  ),
                  decoration: BoxDecoration(
                    border: Border.all(color: Color(0xFFE5E5E5)),
                    borderRadius: BorderRadius.circular(8.r),
                    color: Color(0xFFF9FBF9),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.image_outlined,
                        color: Colors.blue,
                        size: 24.sp,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Text(
                          ticket.attachment!.split('/').last,
                          style: TextStyle(
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w500,
                          ),
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
      ),
    );
  }
}
