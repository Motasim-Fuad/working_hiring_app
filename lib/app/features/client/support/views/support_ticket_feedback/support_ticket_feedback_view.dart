import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/support/controllers/support_ticket_detail_controller.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/data/repositories/ticket_repository.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/client/support/views/support_ticket_feedback/widgets/support_ticket_feedback_ticket_summary.dart';
import 'package:working_hiring/app/features/client/support/views/support_ticket_feedback/widgets/support_ticket_feedback_message_row.dart';
import 'package:working_hiring/app/features/client/support/views/support_ticket_feedback/widgets/support_ticket_feedback_bottom_input_area.dart';
import 'package:working_hiring/app/features/client/support/views/support_ticket_feedback/widgets/support_ticket_feedback_helpers.dart';
import 'package:working_hiring/app/features/client/support/views/support_ticket_feedback/widgets/shimmer/ticket_conversation_shimmer.dart';

class SupportTicketFeedbackView extends GetView<SupportTicketDetailController> {
  final int ticketId;
  final String profileType;
  final String? orderTitle;

  const SupportTicketFeedbackView({
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
            return const TicketConversationShimmer();
          }
          final ticket = controller.ticket.value;
          if (ticket == null) {
            return Center(child: Text('Ticket not found.'.tr));
          }
          return Column(
            children: [
              Expanded(
                child: ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 16.w,
                    vertical: 20.h,
                  ),
                  children: [
                    SupportTicketFeedbackTicketSummary(
                      ticket: ticket,
                      orderTitle: orderTitle,
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(vertical: 24.h),
                      child: Row(
                        children: [
                          Expanded(
                            child: Divider(
                              color: Color(0xFFE5E5E5),
                              thickness: 1,
                            ),
                          ),
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
                          Expanded(
                            child: Divider(
                              color: Color(0xFFE5E5E5),
                              thickness: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    ...ticket.replies.map((reply) {
                      final isAdmin = reply.senderType == 'ADMIN';
                      return SupportTicketFeedbackMessageRow(
                        isAdmin: isAdmin,
                        name:
                            reply.replySenderName ??
                            (isAdmin ? 'Admin'.tr : 'User'.tr),
                        time: formatTime(reply.createdAt),
                        text: reply.message,
                        attachment: reply.attachment,
                      );
                    }),
                    SizedBox(height: 24.h),
                  ],
                ),
              ),
              if (ticket.status != 'closed')
                SupportTicketFeedbackBottomInputArea(
                  fieldController: controller,
                ),
            ],
          );
        }),
      ),
    );
  }
}
