import 'package:flutter/material.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_accept_actions.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_card_details.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_confirm_actions.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_feedback_button.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_in_progress_actions.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_pending_actions.dart';

class MyJobCard extends StatelessWidget {
  final OrderModel job;
  final VoidCallback onTap;
  final VoidCallback? onAccept;
  final VoidCallback? onCounter;
  final VoidCallback? onDecline;
  final VoidCallback? onStartWork;
  final VoidCallback? onCompleteWork;
  final VoidCallback? onCancel;
  final VoidCallback? onProposeTime;
  final bool proposeTimeAlreadySent;
  final String status;
  final bool clientCountered;

  const MyJobCard({
    super.key,
    required this.job,
    required this.onTap,
    this.onAccept,
    this.onCounter,
    this.onDecline,
    this.onStartWork,
    this.onCompleteWork,
    this.onCancel,
    this.onProposeTime,
    this.proposeTimeAlreadySent = false,
    required this.status,
    this.clientCountered = false,
  });

  Widget? _actions() {
    switch (status) {
      case 'PENDING':
        return JobPendingActions(
          onAccept: onAccept,
          onCounter: onCounter,
          onDecline: onDecline,
          clientCountered: clientCountered,
        );
      case 'ACCEPT':
        return JobAcceptActions(onCancel: onCancel);
      case 'CONFIRM':
        return JobConfirmActions(onCancel: onCancel, onStartWork: onStartWork);
      case 'IN_PROGRESS':
        if (onCompleteWork == null) return null;
        return JobInProgressActions(
          onCancel: onCancel,
          onCompleteWork: onCompleteWork,
        );
      case 'COMPLETED':
        return JobFeedbackButton(job: job);
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final actions = _actions();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 20),
        color: Colors.white,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            JobCardDetails(job: job, status: status),
            if (actions != null) ...[SizedBox(height: 16), actions],
          ],
        ),
      ),
    );
  }
}
