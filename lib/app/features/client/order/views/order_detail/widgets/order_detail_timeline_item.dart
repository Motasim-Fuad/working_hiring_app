import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/order/views/order_detail/widgets/order_detail_helpers.dart';

class OrderDetailTimelineItem extends StatelessWidget {
  final String label;
  final String date;

  const OrderDetailTimelineItem({
    super.key,
    required this.label,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final dt = parseDateTime(date);
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        children: [
          Icon(Icons.circle, size: 10.w, color: Color(0xFF6CA34D)),
          SizedBox(width: 8.w),
          Text(
            'Label Date Value'.trParams({
              'label': label.tr,
              'date': formatDate(dt),
            }),
            style: TextStyle(fontSize: 13.sp, color: Colors.grey[700]),
          ),
        ],
      ),
    );
  }
}
