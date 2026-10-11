import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_outlined_button.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_primary_button.dart';

/// CONFIRM: client paid; provider can cancel or start work.
class JobConfirmActions extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onStartWork;

  const JobConfirmActions({super.key, this.onCancel, this.onStartWork});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (onCancel != null)
          Expanded(
            child: JobOutlinedButton(label: 'Cancel'.tr, onPressed: onCancel),
          ),
        if (onStartWork != null) ...[
          SizedBox(width: 12),
          Expanded(
            child: JobPrimaryButton(
              label: 'Start Work'.tr,
              onPressed: onStartWork,
            ),
          ),
        ],
      ],
    );
  }
}
