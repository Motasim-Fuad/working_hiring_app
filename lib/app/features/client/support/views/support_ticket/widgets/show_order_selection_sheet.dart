import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/support/controllers/support_ticket_controller.dart';

void showOrderSelectionSheet(
  BuildContext context,
  SupportTicketController controller,
) {
  Get.bottomSheet(
    Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(16.r)),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        child: Obx(() {
          if (controller.orders.isEmpty) {
            return Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: Text('No orders found.'.tr)),
            );
          }
          return ListView(
            shrinkWrap: true,
            children: controller.orders.map((order) {
              return ListTile(
                title: Text(order.title ?? 'Order #${order.id}'),
                onTap: () => controller.selectOrder(order),
              );
            }).toList(),
          );
        }),
      ),
    ),
    isScrollControlled: true,
  );
}
