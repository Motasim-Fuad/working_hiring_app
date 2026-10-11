import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/worker/report/controllers/worker_report_controller.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/worker/report/views/worker_report/widgets/worker_report_earning_summary_card.dart';

class WorkerReportOverviewTab extends GetView<WorkerReportController> {
  const WorkerReportOverviewTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      maxWidth: AppResponsive.contentMaxWidth,
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        child: ResponsiveCenter(
          maxWidth: AppResponsive.contentMaxWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              WorkerReportEarningSummaryCard(),
              SizedBox(height: 32.h),
              Text(
                "Latest Reports".tr,
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 16.h),
              Obx(() {
                if (controller.latestReports.isEmpty) {
                  return Center(
                    child: Text(
                      "No reports available yet.".tr,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.separated(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: controller.latestReports.length,
                  separatorBuilder: (context, index) =>
                      Divider(height: 1, color: AppColors.border),
                  itemBuilder: (context, index) {
                    final report = controller.latestReports[index];
                    final isAvailable =
                        report.status.toLowerCase() == 'available';
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                      title: Text(
                        report.title,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 16.sp,
                        ),
                      ),
                      subtitle: Padding(
                        padding: EdgeInsets.only(top: 4.0.h),
                        child: Text(
                          report.date,
                          style: TextStyle(color: Colors.grey, fontSize: 13.sp),
                        ),
                      ),
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            report.amount,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16.sp,
                              color: Colors.black87,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          Text(
                            report.status,
                            style: TextStyle(
                              fontSize: 12.sp,
                              fontWeight: FontWeight.w600,
                              color: isAvailable
                                  ? AppColors.primary
                                  : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
