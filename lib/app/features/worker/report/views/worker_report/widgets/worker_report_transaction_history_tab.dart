import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';

class WorkerReportTransactionHistoryTab extends StatelessWidget {
  const WorkerReportTransactionHistoryTab({super.key});

  @override
  Widget build(BuildContext context) {
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
                                AppStrings.refId.trParams({
                                  'id': item['refId'],
                                }),
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
