import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:working_hiring/app/core/widgets/custom_appBar/custom_app_bar.dart';
import 'package:working_hiring/app/data/repositories/availability_repository.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/features/client/helper_profile/controllers/helper_profile_controller.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/widgets/helper_profile_profile_header.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/widgets/helper_profile_bio_section.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/widgets/helper_profile_pricing_section.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/widgets/helper_profile_availability_section.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/widgets/helper_profile_skills_section.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/widgets/helper_profile_reviews_section.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/widgets/helper_profile_bottom_button.dart';
import 'package:working_hiring/app/core/widgets/shimmer/skeletons/profile_page_skeleton.dart';

class HelperProfileView extends GetView<HelperDetailController> {
  const HelperProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<AvailabilityRepository>()) {
      Get.put(AvailabilityRepository(Get.find<ApiClient>()));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Helper Profile".tr),
      body: Obx(() {
        if (controller.isLoading.value && controller.helper == null) {
          return ProfilePageSkeleton(
            avatarSize: 100.r,
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
          );
        }
        if (controller.helper == null) {
          return Center(
            child: Text(
              "Could not load helper.".tr,
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          );
        }
        return RefreshIndicator(
          color: Color(0xFF6CA34D),
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HelperProfileProfileHeader(),
                SizedBox(height: 32.h),
                HelperProfileBioSection(),
                SizedBox(height: 32.h),
                HelperProfilePricingSection(),
                SizedBox(height: 32.h),
                HelperProfileAvailabilitySection(),
                SizedBox(height: 32.h),
                HelperProfileSkillsSection(),
                SizedBox(height: 32.h),
                HelperProfileReviewsSection(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: HelperProfileBottomButton(),
    );
  }
}
