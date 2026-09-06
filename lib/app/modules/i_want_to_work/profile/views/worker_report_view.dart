import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/worker_report_controller.dart';
import '../../../../core/widgets/responsive_layout.dart';

class WorkerReportView extends GetView<WorkerReportController> {
  WorkerReportView({super.key});

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
            labelStyle: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 16.sp,
            ),
            tabs: [
              Tab(text: AppStrings.overview.tr),
              Tab(text: AppStrings.transactionHistory.tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [_buildOverviewTab(), _buildTransactionHistoryTab()],
        ),
      ),
    );
  }

  Widget _buildOverviewTab() {
    return ResponsiveCenter(
      maxWidth: AppResponsive.contentMaxWidth,
      padding: EdgeInsets.zero,
      child: SingleChildScrollView(
        child: ResponsiveCenter(
          maxWidth: AppResponsive.contentMaxWidth,
          child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildEarningSummaryCard(),
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
                child: Text("No reports available yet.".tr, style: TextStyle(color: Colors.grey)),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.latestReports.length,
              separatorBuilder: (context, index) => Divider(height: 1, color: AppColors.border),
              itemBuilder: (context, index) {
                final report = controller.latestReports[index];
                final isAvailable = report.status.toLowerCase() == 'available';
                return ListTile(
                  contentPadding: EdgeInsets.symmetric(vertical: 8.h),
                  title: Text(
                    report.title,
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 16.sp),
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
                          color: isAvailable ? AppColors.primary : Colors.grey.shade600,
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

  Widget _buildEarningSummaryCard() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
        border: Border.all(color: AppColors.border.withOpacity(0.5)),
      ),
      child: Column(
        children: [
          // Top Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                icon: Icons.account_balance_wallet,
                title: "Total Payouts".tr,
                amountObx: controller.totalPayoutsAmount,
              ),
              _buildSummaryVerticalDivider(),
              _buildSummaryItem(
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
          
          // Bottom Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildSummaryItem(
                icon: Icons.check_circle_outline,
                title: "Paid Payouts".tr,
                amountObx: controller.paidAmount,
              ),
              _buildSummaryVerticalDivider(),
              _buildSummaryItem(
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

  Widget _buildSummaryVerticalDivider() {
    return Container(
      height: 60.h,
      width: 1,
      color: AppColors.border,
    );
  }

  Widget _buildSummaryItem({
    required IconData icon,
    required String title,
    required RxString amountObx,
  }) {
    return Expanded(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: AppColors.primary, size: 24.sp),
          ),
          SizedBox(height: 12.h),
          Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 12.sp,
              color: Colors.grey,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(height: 8.h),
          Obx(() => Text(
                amountObx.value,
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildTransactionHistoryTab() {
    final List<Map<String, dynamic>> transactions = [
      {
        'date': 'Jan 10, 2026',
        'items': [
          {
            'refId': '778855203',
            'type': AppStrings.serviceFee.tr,
            'amount': '-\$10.24',
          },
          {
            'refId': '778855203',
            'type': AppStrings.deposit.tr,
            'amount': '\$80',
          },
        ],
      },
      {
        'date': 'Jan 12, 2026',
        'items': [
          {
            'refId': '778855203',
            'type': AppStrings.serviceFee.tr,
            'amount': '-\$28.01',
          },
          {
            'refId': '778855203',
            'type': AppStrings.deposit.tr,
            'amount': '\$180',
          },
        ],
      },
      {
        'date': 'Jan 18, 2026',
        'items': [
          {
            'refId': '778855203',
            'type': AppStrings.serviceFee.tr,
            'amount': '-\$9.80',
          },
          {
            'refId': '778855203',
            'type': AppStrings.deposit.tr,
            'amount': '\$85',
          },
        ],
      },
    ];

    return ResponsiveCenter(
      maxWidth: AppResponsive.contentMaxWidth,
      padding: EdgeInsets.zero,
      child: ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final group = transactions[index];
        final items = group['items'] as List<Map<String, dynamic>>;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 8.w),
              width: double.infinity,
              color: Color(0xFFF9F9F9),
              child: Text(
                group['date'].toString(),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ),
            Divider(height: 1, color: AppColors.background),
            ...items.map((item) {
              return Column(
                children: [
                  Container(
                    padding: EdgeInsets.symmetric(vertical: 16.h),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              AppStrings.refId.trParams({'id': item['refId']}),
                              style: TextStyle(
                                color: Color(0xFF6A9B5D),
                                fontSize: 16.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 4.h),
                            Text(
                              item['type'],
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 14.sp,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          item['amount'],
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 0.5, color: AppColors.textSecondary),
                ],
              );
            }),
            SizedBox(height: 16.h),
          ],
        );
      },
      ),
    );
  }
}
