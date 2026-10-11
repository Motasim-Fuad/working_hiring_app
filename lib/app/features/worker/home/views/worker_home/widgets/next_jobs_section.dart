import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/worker/home/controllers/worker_home_controller.dart';

class NextJobsSection extends StatelessWidget {
  const NextJobsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<WorkerHomeController>();
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Next job".tr,
            style: TextStyle(fontSize: 15.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 8.h),
          Obx(() {
            if (controller.nextJobs.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  "No upcoming jobs".tr,
                  style: TextStyle(color: Colors.grey, fontSize: 14.sp),
                ),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.nextJobs.length,
              itemBuilder: (context, index) {
                final job = controller.nextJobs[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.schedule,
                      color: Colors.blue,
                      size: 20.sp,
                    ),
                  ),
                  title: Text(
                    job.title ?? 'Upcoming job',
                    style: TextStyle(
                      fontSize: 14.sp,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    job.workingDate != null
                        ? '${job.workingDate} ${job.workingStartTime ?? ''}'
                        : 'Date TBD',
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade600,
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
