// lib/modules/client/profile/support_ticket/views/support_ticket_feedback_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/modules/i_need_help/profile/controllers/SupportTicketDetailController.dart';
import 'package:working_hiring/app/service/api_service.dart';
import '../../../../data/models/ticket_model.dart';
import '../../../../data/repositories/ticket_repository.dart';
import '../../../../core/widgets/responsive_layout.dart';
import '../../../../core/widgets/ticket_attachment_viewer.dart';


class SupportTicketFeedbackView extends GetView<SupportTicketDetailController> {
  final int ticketId;
  final String profileType; // 'CUSTOMER' or 'PROVIDER'
  final String? orderTitle; // optional order title to display

  SupportTicketFeedbackView({
    super.key,
    required this.ticketId,
    required this.profileType,
    this.orderTitle,
  });

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TicketRepository>()) {
      Get.put(TicketRepository(Get.find<ApiClient>()));
    }
    Get.lazyPut(
          () => SupportTicketDetailController(
        Get.find<TicketRepository>(),
        ticketId,
        profileType,
      ),
    );
    final controller = Get.find<SupportTicketDetailController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black, size: 24.sp),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Support Ticket Feedback'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 20.sp,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          Obx(() {
            final ticket = controller.ticket.value;
            if (ticket != null && ticket.status != 'closed') {
              return TextButton(
                onPressed: controller.closeTicket,
                child: Text(
                  'Close'.tr,
                  style: TextStyle(color: Colors.red, fontSize: 16.sp),
                ),
              );
            }
            return SizedBox.shrink();
          }),
        ],
      ),
      body: ResponsiveCenter(
        maxWidth: AppResponsive.contentMaxWidth,
        padding: EdgeInsets.zero,
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          final ticket = controller.ticket.value;
          if (ticket == null) {
            return Center(child: Text('Ticket not found.'.tr));
          }
          return Column(
            children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 20.h),
                children: [
                  _buildTicketSummary(context, ticket),
                  Padding(
                    padding: EdgeInsets.symmetric(vertical: 24.h),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFE5E5E5), thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12.w),
                          child: Text(
                            'Support Responses'.tr,
                            style: TextStyle(
                              color: Color(0xFF9E9E9E),
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFE5E5E5), thickness: 1)),
                      ],
                    ),
                  ),
                  ...ticket.replies.map((reply) {
                    final isAdmin = reply.senderType == 'ADMIN';
                    return _buildMessageRow(
                      context: context,
                      isAdmin: isAdmin,
                      name: reply.replySenderName ??
                          (isAdmin ? 'Admin'.tr : 'User'.tr),
                      time: _formatTime(reply.createdAt),
                      text: reply.message,
                      attachment: reply.attachment,
                    );
                  }),
                  SizedBox(height: 24.h),
                ],
              ),
            ),
            if (ticket.status != 'closed') _buildBottomInputArea(controller),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildTicketSummary(BuildContext context, TicketModel ticket) {
    final isOpen = ticket.status == 'open';
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Color(0xFFF9FBF9),
        border: Border.all(color: Color(0xFFE5E5E5)),
        borderRadius: BorderRadius.circular(12.r),
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
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15.sp),
                    ),
                    Text(
                      _formatDate(ticket.createdAt),
                      style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 12.sp),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8.w),
              Flexible(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isOpen ? Color(0xFFFFF4E5) : Color(0xFFE8F5E9),
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    ticket.status,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: isOpen ? Color(0xFFFF9500) : Color(0xFF4CAF50),
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
                  'Subject Value'.trParams({
                    'subject': ticket.subject ?? '',
                  }),
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp, color: Colors.black87),
          ),
          SizedBox(height: 6.h),
          // Display order title if provided, else fallback to ID
          Text(
            orderTitle ?? 'Order #${ticket.order ?? ''}',
            style: TextStyle(color: Color(0xFF6CA34D), fontSize: 13.sp, fontWeight: FontWeight.w600),
          ),
          SizedBox(height: 12.h),
          Text(
            ticket.summary,
            style: TextStyle(fontSize: 14.sp, color: Colors.black87, height: 1.4),
          ),
          if (ticket.attachment != null) ...[
            SizedBox(height: 16.h),
            InkWell(
              borderRadius: BorderRadius.circular(8.r),
              onTap: () => showTicketAttachment(context, ticket.attachment!),
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFFE5E5E5)),
                  borderRadius: BorderRadius.circular(8.r),
                  color: Colors.white,
                ),
                child: Row(
                  children: [
                    Icon(Icons.image_outlined, color: Colors.blue, size: 24.sp),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        ticket.attachment!.split('/').last,
                        style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w500),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Icon(Icons.remove_red_eye_outlined, color: Color(0xFF6CA34D), size: 20.sp),
                  ],
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageRow({
    required BuildContext context,
    required bool isAdmin,
    required String name,
    required String time,
    required String text,
    String? attachment,
  }) {
    final bubble = Container(
      constraints: BoxConstraints(maxWidth: Get.width * 0.75),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(
        color: Color(0xFFF7F7F7),
        borderRadius: BorderRadius.circular(16.r),
      ),
      child: Column(
        crossAxisAlignment: isAdmin ? CrossAxisAlignment.start : CrossAxisAlignment.end,
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
                  style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
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
            style: TextStyle(color: Colors.black87, fontSize: 14.sp, height: 1.4),
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
      mainAxisAlignment: isAdmin ? MainAxisAlignment.start : MainAxisAlignment.end,
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

  Widget _buildBottomInputArea(SupportTicketDetailController controller) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h).copyWith(bottom: 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFF0F0F0))),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (controller.replyAttachmentPath.value.isNotEmpty)
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
                      controller.replyAttachmentName.value,
                      style: TextStyle(fontSize: 13.sp),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, size: 16.sp),
                    onPressed: controller.removeReplyAttachment,
                  ),
                ],
              ),
            ),
          Row(
            children: [
              IconButton(
                icon: Icon(Icons.add, color: Color(0xFF6CA34D), size: 28.sp),
                onPressed: controller.showReplyAttachmentOptions,
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
                    controller: controller.replyController,
                    decoration: InputDecoration(
                      hintText: 'Write message'.tr,
                      hintStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 14.sp),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.w),
              Obx(() {
                return IconButton(
                  icon: controller.isReplying.value
                      ? SizedBox(
                    width: 20.sp,
                    height: 20.sp,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                      : Icon(Icons.send_outlined, color: Color(0xFF535763), size: 24.sp),
                  onPressed: controller.isReplying.value ? null : controller.sendReply,
                );
              }),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return iso;
    }
  }

  String _formatTime(String iso) {
    try {
      final dt = DateTime.parse(iso);
      return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
    } catch (_) {
      return '';
    }
  }
}
