import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/worker/account_verification/views/worker_account_verification/widgets/worker_account_verification_selection_card.dart';

class WorkerAccountVerificationDocumentSelection extends StatelessWidget {
  const WorkerAccountVerificationDocumentSelection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.documentVerification.tr,
          style: TextStyle(
            fontSize: 22.sp,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        SizedBox(height: 24.h),
        Text(
          AppStrings.documentType.tr,
          style: TextStyle(
            fontSize: 14.sp,
            fontWeight: FontWeight.w500,
            color: AppColors.textSecondary,
          ),
        ),
        SizedBox(height: 12.h),

        WorkerAccountVerificationSelectionCard(
          title: AppStrings.idCard.tr,
          iconData: Icons.badge_outlined,
          isSelected: true,
          onTap: () {},
        ),
        SizedBox(height: 16.h),

        WorkerAccountVerificationSelectionCard(
          title: AppStrings.passport.tr,
          iconData: Icons.book_outlined,
          isSelected: false,
          onTap: () {},
        ),
      ],
    );
  }
}
