import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_status_badge.dart';

/// Title, status badge, category, customer, address, schedule and amount.
class JobCardDetails extends StatelessWidget {
  final OrderModel job;
  final String status;

  const JobCardDetails({super.key, required this.job, required this.status});

  String get _customerLabel {
    final name = job.customerName;
    if (name != null && name.trim().isNotEmpty) return name;
    return 'Customer'.tr;
  }

  @override
  Widget build(BuildContext context) {
    const primaryText = TextStyle(fontSize: 13, color: AppColors.textPrimary);
    const scheduleIconColor = Color(0xFF6CA34D);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                job.title ?? '',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            JobStatusBadge(status: status),
          ],
        ),
        SizedBox(height: 12),
        Row(
          children: [
            Icon(
              Icons.people_outline,
              size: 18,
              color: AppColors.textSecondary,
            ),
            SizedBox(width: 8),
            Text(
              job.categoryName ?? '',
              style: TextStyle(fontSize: 14, color: AppColors.textPrimary),
            ),
          ],
        ),
        SizedBox(height: 10),
        Row(
          children: [
            Text(
              AppStrings.postedBy.tr,
              style: TextStyle(fontSize: 14, color: AppColors.textSecondary),
            ),
            SizedBox(width: 4),
            Text(
              _customerLabel,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            SizedBox(width: 4),
            Icon(Icons.verified, color: Colors.blue, size: 16),
          ],
        ),
        SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 18,
                        color: Colors.pinkAccent,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          job.address ?? '',
                          style: primaryText,
                          softWrap: true,
                          maxLines: null,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Row(
                    children: [
                      Icon(
                        Icons.calendar_today_outlined,
                        size: 16,
                        color: scheduleIconColor,
                      ),
                      SizedBox(width: 8),
                      Text(job.workingDate ?? '', style: primaryText),
                      SizedBox(width: 12),
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: scheduleIconColor,
                      ),
                      SizedBox(width: 6),
                      Text(job.workingStartTime ?? '', style: primaryText),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(width: 12),
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: Text(
                '\$${(job.amount ?? 0).toStringAsFixed(0)}',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
