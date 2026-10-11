import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/client/profile/views/transaction_history/widgets/transaction_history_transaction_list.dart';

class TransactionHistoryView extends StatelessWidget {
  const TransactionHistoryView({super.key});

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
            AppStrings.reposts.tr,
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
            labelStyle: TextStyle(fontWeight: FontWeight.bold, fontSize: 16.sp),
            tabs: [
              Tab(text: AppStrings.overview.tr),
              Tab(text: AppStrings.transactionHistory.tr),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Center(child: Text(AppStrings.overview.tr)),
            TransactionHistoryTransactionList(),
          ],
        ),
      ),
    );
  }
}
