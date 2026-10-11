import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/widgets/custom_appBar/custom_app_bar.dart';
import 'package:working_hiring/app/routes/app_pages.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/worker/profile/controllers/worker_profile_controller.dart';
import 'package:working_hiring/app/features/worker/helper_profile/controllers/helper_profile_controller.dart';
import 'package:working_hiring/app/features/worker/helper_profile/views/edit_helper_profile/edit_helper_profile_view.dart';
import 'package:working_hiring/app/features/worker/helper_profile/views/create_helper_profile/create_helper_profile_view.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_profile/widgets/worker_profile_profile_header.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_profile/widgets/worker_profile_about_section.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_profile/widgets/worker_profile_pricing_section.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_profile/widgets/worker_profile_account_status_section.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_profile/widgets/worker_profile_availability_section.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_profile/widgets/worker_profile_skills_section.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_profile/widgets/worker_profile_reviews_section.dart';
import 'package:working_hiring/app/core/widgets/shimmer/skeletons/profile_page_skeleton.dart';

class WorkerProfileView extends GetView<WorkerProfileController> {
  const WorkerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final helperController = Get.find<HelperProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.profile.tr,
        showLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black87),
            onPressed: () => Get.to(() => EditHelperProfileView()),
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Get.toNamed(Routes.WORKER_SETTINGS),
          ),
        ],
      ),
      body: Obx(() {
        if (helperController.isLoading.value) {
          return ProfilePageSkeleton(
            avatarSize: 110.r,
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          );
        }

        if (helperController.profileData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.account_circle_outlined,
                  size: 80.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 16.h),
                Text(
                  'No Profile Set Up'.tr,
                  style: TextStyle(
                    fontSize: 20.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  'Create your helper profile to start offering services.'.tr,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => Get.to(() => CreateHelperProfileView()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                    padding: EdgeInsets.symmetric(
                      horizontal: 32.w,
                      vertical: 12.h,
                    ),
                  ),
                  child: Text(
                    'Create Profile'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: Color(0xFF6CA34D),
          onRefresh: () async {
            await helperController.fetchProfile();
            await controller.loadProfile();
            await controller.fetchWeeklyAvailability();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: ResponsiveCenter(
              maxWidth: AppResponsive.contentMaxWidth,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  WorkerProfileProfileHeader(
                    helperController: helperController,
                  ),
                  SizedBox(height: 32.h),
                  WorkerProfileAboutSection(helperController: helperController),
                  SizedBox(height: 32.h),
                  WorkerProfilePricingSection(
                    helperController: helperController,
                  ),
                  SizedBox(height: 32.h),
                  WorkerProfileAccountStatusSection(
                    helperController: helperController,
                  ),
                  SizedBox(height: 32.h),
                  WorkerProfileAvailabilitySection(
                    helperController: helperController,
                  ),
                  SizedBox(height: 32.h),
                  WorkerProfileSkillsSection(
                    helperController: helperController,
                  ),
                  SizedBox(height: 32.h),
                  WorkerProfileReviewsSection(
                    helperController: helperController,
                  ),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
