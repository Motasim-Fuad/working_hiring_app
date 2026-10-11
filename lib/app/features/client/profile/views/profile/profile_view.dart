import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:working_hiring/app/core/constants/app_images.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/core/widgets/custom_appBar/custom_app_bar.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/routes/app_pages.dart';
import 'package:working_hiring/app/features/client/saved_helpers/views/saved_helpers/saved_helpers_view.dart';
import 'package:working_hiring/app/features/client/profile/controllers/profile_controller.dart';
import 'package:working_hiring/app/features/client/profile/views/edit_profile/edit_profile_view.dart';
import 'package:working_hiring/app/features/client/profile/views/client_reviews/client_reviews_view.dart';
import 'package:working_hiring/app/features/client/support/views/support_ticket/support_ticket_view.dart';
import 'package:working_hiring/app/features/client/support/views/support_ticket_history/support_ticket_history_view.dart';
import 'package:working_hiring/app/features/client/profile/views/billing_list/worker_billing_list_view.dart';
import 'package:working_hiring/app/features/client/profile/views/profile/widgets/profile_menu_item.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: AppStrings.profile.tr, showLeading: false),
      body: RefreshIndicator(
        onRefresh: () => controller.loadProfile(),
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
          child: ResponsiveCenter(
            maxWidth: AppResponsive.contentMaxWidth,
            child: Column(
              children: [
                SizedBox(height: 20.h),
                Center(
                  child: Column(
                    children: [
                      Obx(
                        () => CircleAvatar(
                          radius: AppResponsive.icon(60),
                          backgroundColor: Colors.grey.shade200,
                          backgroundImage: controller.displayPhoto,
                          child: controller.displayPhoto == null
                              ? Icon(
                                  Icons.person,
                                  size: AppResponsive.icon(50),
                                  color: Colors.grey,
                                )
                              : null,
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Obx(
                        () => Text(
                          controller.displayName.value.isNotEmpty
                              ? controller.displayName.value
                              : '—',
                          style: TextStyle(
                            fontSize: 22.sp,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                      Obx(
                        () => Text(
                          controller.userEmail.value.isNotEmpty
                              ? controller.userEmail.value
                              : '—',
                          style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 40.h),

                ProfileMenuItem(
                  icon: AppImages.user,
                  title: AppStrings.account.tr,
                  onTap: () => Get.to(() => EditProfileView()),
                ),

                Divider(height: 1.h, color: Color(0xFFF0F0F0)),

                ProfileMenuItem(
                  icon: AppImages.lock,
                  title: AppStrings.changePassword.tr,
                  onTap: () => Get.toNamed(Routes.CHANGE_PASSWORD),
                ),
                Divider(height: 1.h, color: Color(0xFFF0F0F0)),

                ProfileMenuItem(
                  icon: AppImages.wallet,
                  title: AppStrings.payment.tr,
                  onTap: () => Get.to(() => WorkerBillingListView()),
                ),
                Divider(height: 1.h, color: Color(0xFFF0F0F0)),

                ProfileMenuItem(
                  icon: Icons.local_offer_outlined,
                  title: 'Vouchers & offers'.tr,
                  onTap: () => Get.toNamed(Routes.VOUCHERS_OFFERS),
                ),
                Divider(height: 1.h, color: Color(0xFFF0F0F0)),

                ProfileMenuItem(
                  icon: Icons.bookmark_border,
                  title: 'Saved Helper'.tr,
                  onTap: () => Get.to(() => SavedHelpersView()),
                ),
                Divider(height: 1.h, color: Color(0xFFF0F0F0)),

                ProfileMenuItem(
                  icon: Icons.star_border,
                  title: 'My Reviews'.tr,
                  onTap: () => Get.to(() => ClientReviewsView()),
                ),
                Divider(height: 1.h, color: Color(0xFFF0F0F0)),

                ProfileMenuItem(
                  icon: Icons.support_agent,
                  title: AppStrings.supportTicket.tr,
                  onTap: () => Get.to(() => SupportTicketView()),
                ),
                Divider(height: 1.h, color: Color(0xFFF0F0F0)),

                ProfileMenuItem(
                  icon: Icons.history,
                  title: AppStrings.ticketHistory.tr,
                  onTap: () => Get.to(() => SupportTicketHistoryView()),
                ),
                Divider(height: 1.h, color: Color(0xFFF0F0F0)),

                ProfileMenuItem(
                  icon: Icons.person_add_outlined,
                  title: "Invite a friend".tr,
                  onTap: () {
                    if (controller.referralCode.value.isEmpty &&
                        !controller.isLoadingReferral.value) {
                      controller.loadReferralData();
                    }
                    Get.dialog(
                      AlertDialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16.r),
                        ),
                        title: Text(
                          "Invite a friend".tr,
                          textAlign: TextAlign.center,
                        ),
                        content: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Share this code with your friends:".tr,
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 16.h),
                            Obx(() {
                              if (controller.isLoadingReferral.value) {
                                return CircularProgressIndicator();
                              }
                              return Container(
                                padding: EdgeInsets.symmetric(
                                  horizontal: 16.w,
                                  vertical: 16.h,
                                ),
                                decoration: BoxDecoration(
                                  color: Color(0xFFF5F5F5),
                                  borderRadius: BorderRadius.circular(8.r),
                                  border: Border.all(color: Color(0xFFE5E5E5)),
                                ),
                                child: Text(
                                  controller.referralCode.value.isNotEmpty
                                      ? controller.referralCode.value
                                      : '—',
                                  style: TextStyle(
                                    fontSize: 18.sp,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: 2,
                                  ),
                                ),
                              );
                            }),
                          ],
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Get.back(),
                            child: Text(
                              "Close".tr,
                              style: TextStyle(color: Color(0xFF6A9B5D)),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),

                Divider(height: 1.h, color: Color(0xFFF0F0F0)),

                ProfileMenuItem(
                  icon: AppImages.info,
                  title: AppStrings.about.tr,
                  onTap: () => Get.toNamed(Routes.ABOUT),
                ),
                Divider(height: 1.h, color: Color(0xFFF0F0F0)),

                ProfileMenuItem(
                  icon: Icons.logout,
                  title: AppStrings.signOut.tr,
                  onTap: () {
                    Get.dialog(
                      Dialog(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        elevation: 0,
                        backgroundColor: Colors.transparent,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(maxWidth: 520),
                          child: Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 24,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20.r),
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFE5E5),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Icon(
                                    Icons.logout,
                                    color: Color(0xFFFF3B30),
                                    size: AppResponsive.icon(32),
                                  ),
                                ),
                                SizedBox(height: 20.h),
                                Text(
                                  AppStrings.signOut.tr,
                                  style: TextStyle(
                                    fontSize: 22.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 12.h),
                                Text(
                                  AppStrings.signOutConfirm.tr,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    color: Colors.black54,
                                    height: 1.5,
                                  ),
                                ),
                                SizedBox(height: 24.h),
                                Row(
                                  children: [
                                    Expanded(
                                      child: OutlinedButton(
                                        onPressed: () => Get.back(),
                                        style: OutlinedButton.styleFrom(
                                          minimumSize: Size.fromHeight(48),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                          side: BorderSide(
                                            color: Color(0xFFE5E5E5),
                                          ),
                                        ),
                                        child: Text(
                                          "Cancel".tr,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 12.w),
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          Get.back();
                                          controller.signOut();
                                        },
                                        style: ElevatedButton.styleFrom(
                                          minimumSize: Size.fromHeight(48),
                                          backgroundColor: Color(0xFFFF3B30),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12.r,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          "Sign Out".tr,
                                          style: TextStyle(
                                            fontSize: 16.sp,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                Divider(height: 1.h, color: Color(0xFFF0F0F0)),

                SizedBox(height: 40.h),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
