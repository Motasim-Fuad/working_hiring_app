import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/widgets/custom_appBar/custom_app_bar.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/worker/report/controllers/worker_report_controller.dart';
import 'package:working_hiring/app/features/worker/report/views/worker_report/widgets/worker_report_overview_tab.dart';
import 'package:working_hiring/app/features/worker/report/views/worker_report/widgets/worker_report_transaction_history_tab.dart';

class WorkerReportView extends GetView<WorkerReportController> {
  const WorkerReportView({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(WorkerReportController());
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          title: 'Earnings and Transactions'.tr,
          showLeading: true,
          bottom: TabBar(
            labelColor: Color(0xFF6A9B5D),
            unselectedLabelColor: Colors.grey,
            indicatorColor: Color(0xFF6A9B5D),
            indicatorWeight: 3,
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            tabs: [
              Tab(text: AppStrings.overview.tr),
              Tab(text: AppStrings.transactionHistory.tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            WorkerReportOverviewTab(),
            WorkerReportTransactionHistoryTab(),
          ],
        ),
      ),
    );
  }
}
