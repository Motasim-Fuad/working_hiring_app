import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';


class TransactionHistoryView extends StatelessWidget {
  TransactionHistoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
            onPressed: () => Get.back(),
          ),
          centerTitle: true,
          title: Text(
            AppStrings
                .reposts
                .tr, // Using 'Reposts' as per user design image logic or request
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: TabBar(
            labelColor: Color(0xFF6A9B5D),
            unselectedLabelColor: AppColors.textSecondary,
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
          children: [
            Center(
              child: Text(AppStrings.overview.tr),
            ), // Placeholder for Overview
            _buildTransactionList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTransactionList() {
    // Mock Data based on image
    final List<Map<String, dynamic>> transactions = [
      {
        'date': 'Jan 10, 2026',
        'items': [
          {
            'refId': '778855203',
            'type': AppStrings.serviceFee.tr,
            'amount': '-\$10.24',
            'isNegative': true,
          },
          {
            'refId': '778855203',
            'type': AppStrings.deposit.tr,
            'amount': '\$80',
            'isNegative': false,
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
            'isNegative': true,
          },
          {
            'refId': '778855203',
            'type': AppStrings.deposit.tr,
            'amount': '\$180',
            'isNegative': false,
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
            'isNegative': true,
          },
          {
            'refId': '778855203',
            'type': AppStrings.deposit.tr,
            'amount': '\$85',
            'isNegative': false,
          },
        ],
      },
    ];

    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
              color: Color(
                0xFFF9F9F9,
              ), // Light hint for date header? Or just whitespace
              // Design shows just text "Jan 10, 2026" with underline separator
              child: Text(
                group['date'].toString(),
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
            ),
            Divider(height: 1.h),
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
                                color: Color(0xFF6A9B5D), // Green Ref ID
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
                            color: item['isNegative'] == true
                                ? AppColors.textPrimary
                                : AppColors.textPrimary,
                            // Design shows black for both, maybe negative sign is enough.
                            // Actually negative might be red in some apps, but here looks black/grey.
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Divider(height: 1.h),
                ],
              );
            }),
            SizedBox(height: 16.h),
          ],
        );
      },
    );
  }
}
