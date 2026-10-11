import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_outlined_button.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_primary_button.dart';

/// IN_PROGRESS: cancellation stays available until completion; completing
/// still requires the customer's OTP.
class JobInProgressActions extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onCompleteWork;

  const JobInProgressActions({super.key, this.onCancel, this.onCompleteWork});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (onCancel != null) ...[
          SizedBox(
            width: double.infinity,
            child: JobOutlinedButton(label: 'Cancel'.tr, onPressed: onCancel),
          ),
          SizedBox(height: 8),
        ],
        SizedBox(
          width: double.infinity,
          child: JobPrimaryButton(
            label: 'Complete Work'.tr,
            onPressed: onCompleteWork,
          ),
        ),
      ],
    );
  }
}
