import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_images.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/worker/dashboard/controllers/worker_dashboard_controller.dart';
import 'package:working_hiring/app/features/worker/home/views/worker_home/worker_home_view.dart';
import 'package:working_hiring/app/features/worker/my_job/views/my_job/my_job_view.dart';
import 'package:working_hiring/app/features/chat/views/message_list/message_list_view.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_profile/worker_profile_view.dart';
import 'package:working_hiring/app/features/worker/dashboard/views/worker_dashboard/widgets/worker_dashboard_helpers.dart';

class WorkerDashboardVerifiedDashboard
    extends GetView<WorkerDashboardController> {
  const WorkerDashboardVerifiedDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: [
            WorkerHomeView(key: PageStorageKey('WorkerHome')),
            MyJobView(key: PageStorageKey('WorkerMyJob')),
            MessageListView(key: PageStorageKey('WorkerMessage')),
            WorkerProfileView(key: PageStorageKey('WorkerProfile')),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          bottom: true,
          child: Obx(
            () => BottomNavigationBar(
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              currentIndex: controller.tabIndex.value,
              onTap: controller.changeTabIndex,
              items: [
                buildNavItem(AppImages.home, AppStrings.home.tr),
                buildNavItem(AppImages.order, AppStrings.myJob.tr),
                buildNavItem(AppImages.chat, AppStrings.message.tr),
                buildNavItem(AppImages.profile, AppStrings.profile.tr),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
