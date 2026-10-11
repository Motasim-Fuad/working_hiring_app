import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/data/repositories/ticket_repository.dart';
import 'package:working_hiring/app/features/client/support/controllers/support_ticket_controller.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/client/support/views/support_ticket_history/widgets/support_ticket_history_ticket_card.dart';
import 'package:working_hiring/app/core/widgets/shimmer/skeletons/ticket_list_shimmer.dart';

class SupportTicketHistoryView extends GetView<SupportTicketController> {
  const SupportTicketHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<TicketRepository>()) {
      Get.put(TicketRepository(Get.find<ApiClient>()));
    }
    if (!Get.isRegistered<SupportTicketController>()) {
      Get.put(SupportTicketController(Get.find<TicketRepository>()));
    }
    final controller = Get.find<SupportTicketController>();

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
              return SupportTicketHistoryTicketCard(
                ticket: ticket,
                controller: controller,
              );
            },
          );
        }),
      ),
    );
  }
}
