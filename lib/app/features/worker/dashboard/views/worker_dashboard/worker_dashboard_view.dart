import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/worker/dashboard/controllers/worker_dashboard_controller.dart';
import 'package:working_hiring/app/features/worker/dashboard/views/worker_dashboard/widgets/worker_dashboard_verified_dashboard.dart';
import 'package:working_hiring/app/features/worker/dashboard/views/worker_dashboard/widgets/worker_dashboard_access_gate.dart';

class WorkerDashboardView extends GetView<WorkerDashboardController> {
  const WorkerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.accessState.value) {
        case ProviderAccessState.loading:
          return WorkerDashboardAccessGate(
            icon: Icons.hourglass_top_rounded,
            title: 'Checking provider profile'.tr,
            description: 'Please wait a moment...'.tr,
            isLoading: true,
          );
        case ProviderAccessState.noProfile:
          return WorkerDashboardAccessGate(
            icon: Icons.person_add_alt_1_rounded,
            title: 'Create your provider profile'.tr,
            description:
                'Create your profile before offering services and starting work.'
                    .tr,
            buttonText: 'Create Profile'.tr,
            onPressed: controller.openCreateProfile,
          );
        case ProviderAccessState.unverified:
          return WorkerDashboardAccessGate(
            icon: Icons.verified_user_outlined,
            title: 'Verify your provider profile'.tr,
            description:
                "Your provider profile is ready. Complete verification to start receiving work."
                    .tr,
            buttonText: 'Verify now'.tr,
            onPressed: controller.openVerification,
          );
        case ProviderAccessState.error:
          return WorkerDashboardAccessGate(
            icon: Icons.cloud_off_rounded,
            title: 'Could not check provider profile'.tr,
            description: 'Please check your connection and try again.'.tr,
            buttonText: 'Try Again'.tr,
            onPressed: controller.refreshAccess,
          );
        case ProviderAccessState.verified:
          return WorkerDashboardVerifiedDashboard();
      }
    });
  }
}
