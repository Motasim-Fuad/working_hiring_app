import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/client/order/views/review/review_view.dart';
import 'package:working_hiring/app/features/worker/my_job/controllers/my_job_controller.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_primary_button.dart';

/// COMPLETED: give feedback, or show that it was already submitted.
class JobFeedbackButton extends StatelessWidget {
  final OrderModel job;

  const JobFeedbackButton({super.key, required this.job});

  Future<void> _openReview() async {
    await Get.to(() => ReviewView(orderId: job.id));
    if (Get.isRegistered<MyJobController>()) {
      Get.find<MyJobController>().loadJobs();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (job.isProviderReview) {
      return Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: Color(0xFFF0F0F0),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.check_circle, color: Color(0xFF6CA34D), size: 18),
            SizedBox(width: 8),
            Text(
              'Feedback submitted'.tr,
              style: TextStyle(
                color: Color(0xFF6CA34D),
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }
    return SizedBox(
      width: double.infinity,
      child: JobPrimaryButton(
        label: AppStrings.giveAFeedback.tr,
        onPressed: _openReview,
      ),
    );
  }
}
