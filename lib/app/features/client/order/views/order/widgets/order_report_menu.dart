import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/sheets/report_issue_sheet.dart';

class OrderReportMenu extends StatelessWidget {
  final OrderModel order;

  const OrderReportMenu({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_vert, color: Colors.grey, size: 20.sp),
      onSelected: (value) {
        if (value == 'report') showReportIssueSheet(context, order);
      },
      itemBuilder: (context) => [
        PopupMenuItem(value: 'report', child: Text("Report Issue".tr)),
      ],
    );
  }
}
