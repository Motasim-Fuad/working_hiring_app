import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/client/order/views/order_detail/widgets/order_detail_timeline_item.dart';

class OrderDetailStatusTimeline extends StatelessWidget {
  final OrderModel order;

  const OrderDetailStatusTimeline({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Timeline'.tr,
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w600),
        ),
        SizedBox(height: 8.h),
        if (order.acceptedAt != null)
          OrderDetailTimelineItem(label: 'Accepted', date: order.acceptedAt!),
        if (order.startedAt != null)
          OrderDetailTimelineItem(label: 'Started', date: order.startedAt!),
        if (order.completedAt != null)
          OrderDetailTimelineItem(label: 'Completed', date: order.completedAt!),
      ],
    );
  }
}
