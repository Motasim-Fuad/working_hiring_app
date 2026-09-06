import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/worker_dashboard_controller.dart';
import '../../home/views/worker_home_view.dart';
import '../../my_job/views/my_job_view.dart';
import '../../../message/views/message_list_view.dart';
import '../../profile/views/worker_profile_view.dart';
import '../../../../core/widgets/home_header.dart';
import '../../../../core/widgets/responsive_layout.dart';

class WorkerDashboardView extends GetView<WorkerDashboardController> {
  WorkerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      switch (controller.accessState.value) {
        case ProviderAccessState.loading:
          return _buildAccessGate(
            context,
            icon: Icons.hourglass_top_rounded,
            title: 'Checking provider profile'.tr,
            description: 'Please wait a moment...'.tr,
            isLoading: true,
          );
        case ProviderAccessState.noProfile:
          return _buildAccessGate(
            context,
            icon: Icons.person_add_alt_1_rounded,
            title: 'Create your provider profile'.tr,
            description:
                'Create your profile before offering services and starting work.'
                    .tr,
            buttonText: 'Create Profile'.tr,
            onPressed: controller.openCreateProfile,
          );
        case ProviderAccessState.unverified:
          return _buildAccessGate(
            context,
            icon: Icons.verified_user_outlined,
            title: 'Verify your provider profile'.tr,
            description:
                "Your provider profile is ready. Complete verification to start receiving work."
                    .tr,
            buttonText: 'Verify now'.tr,
            onPressed: controller.openVerification,
          );
        case ProviderAccessState.error:
          return _buildAccessGate(
            context,
            icon: Icons.cloud_off_rounded,
            title: 'Could not check provider profile'.tr,
            description:
                'Please check your connection and try again.'.tr,
            buttonText: 'Try Again'.tr,
            onPressed: controller.refreshAccess,
          );
        case ProviderAccessState.verified:
          return _buildVerifiedDashboard();
      }
    });
  }

  Widget _buildVerifiedDashboard() {
    return Scaffold(
      body: Obx(
            () => IndexedStack(
          index: controller.tabIndex.value,
          children:  [
            // Added PageStorageKeys to maintain scroll states when switching tabs
            WorkerHomeView(key: PageStorageKey('WorkerHome')),
            MyJobView(key: PageStorageKey('WorkerMyJob')),
            MessageListView(key: PageStorageKey('WorkerMessage')),
            WorkerProfileView(key: PageStorageKey('WorkerProfile')),
          ],
        ),
      ),
      // Wrapped in Container and SafeArea to fix bottom spacing
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          bottom: true,
          child: Obx(
                () => BottomNavigationBar(
              elevation: 0, // Removed default shadow
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              currentIndex: controller.tabIndex.value,
              onTap: controller.changeTabIndex,
              items: [
                _buildNavItem(AppImages.home, AppStrings.home.tr),
                _buildNavItem(
                  AppImages.order,
                  AppStrings.myJob.tr,
                ), // Icon reuse: order icon for My Job
                _buildNavItem(AppImages.chat, AppStrings.message.tr),
                _buildNavItem(AppImages.profile, AppStrings.profile.tr),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAccessGate(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String description,
    String? buttonText,
    Future<void> Function()? onPressed,
    bool isLoading = false,
  }) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(),
            Expanded(
              child: Center(
                child: SingleChildScrollView(
                  child: ResponsiveCenter(
                    maxWidth: AppResponsive.formMaxWidth,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.all(28.w),
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.10),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            icon,
                            size: 72.sp,
                            color: AppColors.primary,
                          ),
                        ),
                        SizedBox(height: 28.h),
                        Text(
                          title,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        SizedBox(height: 10.h),
                        Text(
                          description,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14.sp,
                            height: 1.45,
                            color: AppColors.textSecondary,
                          ),
                        ),
                        SizedBox(height: 28.h),
                        if (isLoading)
                          CircularProgressIndicator(color: AppColors.primary)
                        else if (buttonText != null && onPressed != null)
                          SizedBox(
                            width: double.infinity,
                            height: AppResponsive.height(
                              52,
                              min: 48,
                              max: 58,
                            ),
                            child: ElevatedButton(
                              onPressed: () => onPressed(),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.textPrimary,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                              ),
                              child: Text(
                                buttonText,
                                style: TextStyle(
                                  fontSize: 15.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildNavItem(String iconPath, String label) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: EdgeInsets.only(bottom: 4.h),
        child: SvgPicture.asset(
          iconPath,
          width: 24.w,
          height: 24.h,
          colorFilter: ColorFilter.mode(
            AppColors.textSecondary,
            BlendMode.srcIn,
          ),
        ),
      ),
      activeIcon: Padding(
        padding: EdgeInsets.only(bottom: 4.h),
        child: SvgPicture.asset(
          iconPath,
          width: 24.w,
          height: 24.h,
          colorFilter: ColorFilter.mode(
            AppColors.primary,
            BlendMode.srcIn,
          ),
        ),
      ),
      label: label,
    );
  }
}
