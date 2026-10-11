import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';

class WorkerReportSummaryVerticalDivider extends StatelessWidget {
  const WorkerReportSummaryVerticalDivider({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(height: 60.h, width: 1, color: AppColors.border);
  }
}
