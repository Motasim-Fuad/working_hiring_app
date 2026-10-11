import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_awaiting_client_banner.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_primary_button.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_outlined_button.dart';

/// Negotiation actions for a PENDING job.
///
/// A null [onCounter] means the provider already countered: they then wait
/// for the client, or get Accept/Decline once the client counters back.
class JobPendingActions extends StatelessWidget {
  final VoidCallback? onAccept;
  final VoidCallback? onCounter;
  final VoidCallback? onDecline;
  final bool clientCountered;

  const JobPendingActions({
    super.key,
    this.onAccept,
    this.onCounter,
    this.onDecline,
    this.clientCountered = false,
  });

  @override
  Widget build(BuildContext context) {
    if (onCounter == null && !clientCountered) {
      return const JobAwaitingClientBanner();
    }
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: JobPrimaryButton(label: 'Accept'.tr, onPressed: onAccept),
        ),
        SizedBox(height: 8),
        Row(
          children: [
            if (onDecline != null)
              Expanded(
                child: JobOutlinedButton(
                  label: 'Decline'.tr,
                  onPressed: onDecline,
                  fontSize: 15,
                ),
              ),
            if (onCounter != null) ...[
              SizedBox(width: 10),
              Expanded(
                child: JobOutlinedButton.green(
                  label: 'Counter'.tr,
                  onPressed: onCounter,
                ),
              ),
            ],
          ],
        ),
      ],
    );
  }
}
