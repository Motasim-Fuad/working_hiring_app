import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/data/repositories/ticket_repository.dart';
import 'package:working_hiring/app/features/worker/support/controllers/worker_support_ticket_controller.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/worker/support/views/worker_support_ticket_history/widgets/worker_support_ticket_history_ticket_card.dart';
import 'package:working_hiring/app/core/widgets/shimmer/skeletons/ticket_list_shimmer.dart';

class WorkerSupportTicketHistoryView
    extends GetView<WorkerSupportTicketController> {
  const WorkerSupportTicketHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TicketRepository>()) {
      Get.put(TicketRepository(Get.find<ApiClient>()));
    }
    if (!Get.isRegistered<WorkerSupportTicketController>()) {
      Get.put(WorkerSupportTicketController(Get.find<TicketRepository>()));
    }
    final controller = Get.find<WorkerSupportTicketController>();

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
          'Ticket History'.tr,
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
            return const TicketListShimmer();
          }
          if (controller.ticketHistory.isEmpty) {
            return Center(child: Text('No tickets found.'.tr));
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            itemCount: controller.ticketHistory.length,
            separatorBuilder: (_, _) => SizedBox(height: 12.h),
            itemBuilder: (context, index) {
              final ticket = controller.ticketHistory[index];
              return WorkerSupportTicketHistoryTicketCard(
                ticket: ticket,
                fieldController: controller,
              );
            },
          );
        }),
      ),
    );
  }
}
