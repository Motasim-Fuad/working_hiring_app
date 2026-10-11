import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card/job_outlined_button.dart';

/// ACCEPT: provider accepted, client has not paid yet.
class JobAcceptActions extends StatelessWidget {
  final VoidCallback? onCancel;

  const JobAcceptActions({super.key, this.onCancel});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: Colors.amber.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.hourglass_top, color: Colors.amber.shade800, size: 18),
              SizedBox(width: 8),
              Text(
                'Waiting for client payment'.tr,
                style: TextStyle(
                  color: Colors.amber.shade900,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
        if (onCancel != null) ...[
          SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: JobOutlinedButton(label: 'Cancel'.tr, onPressed: onCancel),
          ),
        ],
      ],
    );
  }
}
