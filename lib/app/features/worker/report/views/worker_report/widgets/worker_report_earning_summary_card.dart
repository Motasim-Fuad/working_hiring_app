import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/worker/report/controllers/worker_report_controller.dart';
import 'package:working_hiring/app/features/worker/report/views/worker_report/widgets/worker_report_summary_vertical_divider.dart';
import 'package:working_hiring/app/features/worker/report/views/worker_report/widgets/worker_report_summary_item.dart';

class WorkerReportEarningSummaryCard extends GetView<WorkerReportController> {
  const WorkerReportEarningSummaryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WorkerReportSummaryItem(
                icon: Icons.account_balance_wallet,
                title: "Total Payouts".tr,
                amountObx: controller.totalPayoutsAmount,
              ),
              WorkerReportSummaryVerticalDivider(),
              WorkerReportSummaryItem(
                icon: Icons.pending_actions,
                title: "Upcoming Payouts".tr,
                amountObx: controller.upcomingAmount,
              ),
            ],
          ),

          Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0.h),
            child: Divider(height: 1, color: AppColors.border),
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              WorkerReportSummaryItem(
                icon: Icons.check_circle_outline,
                title: "Paid Payouts".tr,
                amountObx: controller.paidAmount,
              ),
              WorkerReportSummaryVerticalDivider(),
              WorkerReportSummaryItem(
                icon: Icons.account_balance_wallet_outlined,
                title: "Available Payouts".tr,
                amountObx: controller.availableAmount,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
