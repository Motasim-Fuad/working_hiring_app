import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/client/support/controllers/support_ticket_controller.dart';
import 'package:working_hiring/app/features/client/support/views/support_ticket/widgets/show_order_selection_sheet.dart';

class SupportTicketOrderSelector extends StatelessWidget {
  final SupportTicketController fieldController;

  const SupportTicketOrderSelector({super.key, required this.fieldController});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => showOrderSelectionSheet(context, fieldController),
      borderRadius: BorderRadius.circular(8.r),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 14.h),
        decoration: BoxDecoration(
          border: Border.all(color: Color(0xFFE5E5E5)),
          borderRadius: BorderRadius.circular(8.r),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Obx(() {
              final order = fieldController.selectedOrder.value;
              return Text(
                order != null
                    ? (order.title ?? 'Order #${order.id}')
                    : AppStrings.selectYourOrder.tr,
                style: TextStyle(
                  color: order != null ? Colors.black : Color(0xFF9E9E9E),
                  fontSize: 14.sp,
                ),
              );
            }),
            Icon(
              Icons.keyboard_arrow_down,
              color: Color(0xFF9E9E9E),
              size: 20.sp,
            ),
          ],
        ),
      ),
    );
  }
}
