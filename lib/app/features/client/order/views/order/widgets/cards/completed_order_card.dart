import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/client/order/views/order_detail/order_detail_view.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/order_card_header.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/order_schedule_row.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/order_feedback_button.dart';

class CompletedOrderCard extends StatelessWidget {
  final OrderModel order;

  const CompletedOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Get.to(() => OrderDetailView(order: order)),
            child: OrderCardHeader(order: order, showMenu: true),
          ),
          SizedBox(height: 12.h),
          OrderScheduleRow(order: order),
          SizedBox(height: 16.h),
          OrderFeedbackButton(order: order),
        ],
      ),
    );
  }
}
