import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/widgets/custom_appBar/custom_app_bar.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/worker/my_job/controllers/my_job_controller.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/widgets/my_job_job_list.dart';

class MyJobView extends GetView<MyJobController> {
  const MyJobView({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
          toolbarHeight: 0,
          showLeading: false,
          bottom: TabBar(
            labelColor: AppColors.primary,
            unselectedLabelColor: AppColors.textSecondary,
            indicatorColor: AppColors.primary,
            indicatorWeight: 3,
            dividerHeight: 0,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: AppStrings.allJob.tr),
              Tab(text: AppStrings.accepted.tr),
              Tab(text: AppStrings.completed.tr),
            ],
          ),
        ),
        body: ResponsiveCenter(
          maxWidth: AppResponsive.contentMaxWidth,
          padding: EdgeInsets.zero,
          child: TabBarView(
            children: [
              MyJobJobList(jobs: controller.pendingJobs),
              MyJobJobList(jobs: controller.acceptedJobs),
              MyJobJobList(jobs: controller.completedJobs),
            ],
          ),
        ),
      ),
    );
  }
}
