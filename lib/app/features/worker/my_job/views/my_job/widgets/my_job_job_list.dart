import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/worker/my_job/controllers/my_job_controller.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_card.dart';
import 'package:working_hiring/app/features/worker/my_job/views/job_otp_verification/job_otp_verification_view.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_cancellation_request_panel.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/show_counter_offer_sheet.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/show_decline_dialog.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/show_cancel_job_dialog.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/shimmer/job_list_shimmer.dart';

class MyJobJobList extends GetView<MyJobController> {
  final RxList<OrderModel> jobs;

  const MyJobJobList({super.key, required this.jobs});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final loading = controller.isLoading.value;
      if (loading && jobs.isEmpty) {
        return const JobListShimmer();
      }
      if (jobs.isEmpty) {
        return RefreshIndicator(
          onRefresh: () => controller.loadJobs(),
          color: Color(0xFF6CA34D),
          child: ListView(
            children: [
              SizedBox(
                height: AppResponsive.height(400, min: 240, max: 480),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.volunteer_activism_outlined,
                        size: AppResponsive.icon(64),
                        color: Color(0xFF6CA34D).withValues(alpha: 0.5),
                      ),
                      SizedBox(height: 16.h),
                      Text(
                        AppStrings.beFirstToHelp.tr,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      Text(
                        AppStrings.noRequestsRightNow.tr,
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return RefreshIndicator(
        onRefresh: () => controller.loadJobs(),
        color: Color(0xFF6CA34D),
        child: ListView.builder(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          itemCount: jobs.length,
          itemBuilder: (context, index) {
            final job = jobs[index];
            final status = job.effectiveStatus;

            final bool clientCountered = controller.hasClientCountered(job.id);

            return Column(
              children: [
                MyJobCard(
                  job: job,
                  status: status,
                  clientCountered: clientCountered,
                  onTap: () {},

                  onAccept: status == 'PENDING'
                      ? () => controller.acceptJob(job.id)
                      : null,

                  onCounter:
                      (status == 'PENDING' && !controller.hasCountered(job.id))
                      ? () => showCounterOfferSheet(context, job)
                      : null,

                  onDecline: status == 'PENDING'
                      ? () => showDeclineDialog(context, job)
                      : null,

                  onStartWork:
                      status == 'CONFIRM' &&
                          job.pendingCancellationRequest == null
                      ? () => controller.startWork(job.id)
                      : null,

                  onCompleteWork: status == 'IN_PROGRESS'
                      ? () => Get.to(() => JobOtpVerificationView(job: job))
                      : null,

                  onCancel:
                      (status == 'ACCEPT' ||
                              status == 'CONFIRM' ||
                              status == 'CANCELLATION_REQUEST' ||
                              status == 'IN_PROGRESS') &&
                          job.pendingCancellationRequest == null
                      ? () => showCancelJobDialog(context, job)
                      : null,
                ),
                if (job.pendingCancellationRequest != null)
                  MyJobCancellationRequestPanel(job: job),
              ],
            );
          },
        ),
      );
    });
  }
}
