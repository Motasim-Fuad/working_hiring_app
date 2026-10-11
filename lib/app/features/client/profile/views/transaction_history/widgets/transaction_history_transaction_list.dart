import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';

class TransactionHistoryTransactionList extends StatelessWidget {
  const TransactionHistoryTransactionList({super.key});

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
              color: Color(0xFFF9F9F9),
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
