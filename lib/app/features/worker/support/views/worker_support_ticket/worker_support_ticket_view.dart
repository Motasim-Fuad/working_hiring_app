import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/data/repositories/ticket_repository.dart';
import 'package:working_hiring/app/features/worker/support/controllers/worker_support_ticket_controller.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/worker/support/views/worker_support_ticket/widgets/worker_support_ticket_label.dart';
import 'package:working_hiring/app/features/worker/support/views/worker_support_ticket/widgets/worker_support_ticket_text_field.dart';
import 'package:working_hiring/app/features/worker/support/views/worker_support_ticket/widgets/worker_support_ticket_message_field.dart';
import 'package:working_hiring/app/features/worker/support/views/worker_support_ticket/widgets/worker_support_ticket_order_selector.dart';
import 'package:working_hiring/app/features/worker/support/views/worker_support_ticket/widgets/worker_support_ticket_attachment_tile.dart';

class WorkerSupportTicketView extends StatelessWidget {
  const WorkerSupportTicketView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TicketRepository>()) {
      Get.put(TicketRepository(Get.find<ApiClient>()));
    }
    final controller = Get.put(
      WorkerSupportTicketController(Get.find<TicketRepository>()),
    );

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: Colors.black,
            size: 24.sp,
          ),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppStrings.supportTicket.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ResponsiveCenter(
        maxWidth: AppResponsive.contentMaxWidth,
        padding: EdgeInsets.zero,
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: CircularProgressIndicator());
          }
          return SingleChildScrollView(
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            child: ResponsiveCenter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WorkerSupportTicketLabel(text: AppStrings.subject.tr),
                  SizedBox(height: 8.h),
                  WorkerSupportTicketTextField(
                    fieldController: controller.subjectController,
                    hint: AppStrings.subject.tr,
                  ),
                  SizedBox(height: 24.h),

                  WorkerSupportTicketLabel(
                    text: AppStrings.orderLabel.tr,
                    withInfo: true,
                  ),
                  SizedBox(height: 8.h),
                  WorkerSupportTicketOrderSelector(fieldController: controller),
                  SizedBox(height: 24.h),

                  WorkerSupportTicketLabel(
                    text: AppStrings.attachment.tr,
                    withInfo: true,
                  ),
                  SizedBox(height: 8.h),
                  WorkerSupportTicketAttachmentTile(
                    fieldController: controller,
                  ),
                  SizedBox(height: 24.h),

                  WorkerSupportTicketLabel(text: AppStrings.yourMessage.tr),
                  SizedBox(height: 8.h),
                  WorkerSupportTicketMessageField(
                    fieldController: controller.summaryController,
                  ),
                  SizedBox(height: 32.h),

                  SizedBox(
                    width: double.infinity,
                    height: AppResponsive.height(50, min: 48, max: 56),
                    child: ElevatedButton(
                      onPressed: controller.submitTicket,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.r),
                        ),
                        elevation: 0,
                      ),
                      child: Text(
                        AppStrings.submitTicket.tr,
                        style: TextStyle(
                          fontSize: 16.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20.h),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}
