import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/widgets/custom_appBar/custom_app_bar.dart';
import 'package:working_hiring/app/routes/app_pages.dart';
import 'package:working_hiring/app/core/constants/app_images.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/payout/views/payout/payout_view.dart';
import 'package:working_hiring/app/features/worker/profile/controllers/worker_profile_controller.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_account/worker_account_view.dart';
import 'package:working_hiring/app/features/worker/report/views/worker_report/worker_report_view.dart';
import 'package:working_hiring/app/features/worker/support/views/worker_support_ticket/worker_support_ticket_view.dart';
import 'package:working_hiring/app/features/worker/support/views/worker_support_ticket_history/worker_support_ticket_history_view.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_settings/widgets/worker_settings_menu_item.dart';

class WorkerSettingsView extends GetView<WorkerProfileController> {
  const WorkerSettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Settings".tr),
      body: ResponsiveCenter(
        maxWidth: AppResponsive.contentMaxWidth,
        padding: EdgeInsets.zero,
        child: ListView(
          children: [
            SizedBox(height: 10),
            WorkerSettingsMenuItem(
              icon: AppImages.user,
              title: AppStrings.account.tr,
              onTap: () => Get.to(() => WorkerAccountView()),
            ),
            Divider(
              height: .5,
              indent: 16,
              endIndent: 16,
              color: AppColors.secondary,
            ),

            WorkerSettingsMenuItem(
              icon: Icons.verified_user_outlined,
              isIconData: true,
              iconData: Icons.verified_user_outlined,
              title: AppStrings.accountVerification.tr,
              trailing: Obx(
                () => controller.isVerified.value
                    ? Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 12.w,
                          vertical: 4.h,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          border: Border.all(color: AppColors.primary),
                          borderRadius: BorderRadius.circular(20.r),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check,
                              size: 16.sp,
                              color: AppColors.primary,
                            ),
                            SizedBox(width: 4.w),
                            Text(
                              AppStrings.verified.tr,
                              style: TextStyle(
                                color: AppColors.primary,
                                fontSize: 12.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      )
                    : Icon(
                        Icons.arrow_forward_ios,
                        size: 16.sp,
                        color: Colors.grey,
                      ),
              ),
              onTap: () => Get.toNamed(Routes.WORKER_ACCOUNT_VERIFICATION),
            ),
            Divider(
              height: .5,
              indent: 16,
              endIndent: 16,
              color: AppColors.secondary,
            ),

            Divider(
              height: .5,
              indent: 16,
              endIndent: 16,
              color: AppColors.secondary,
            ),

            WorkerSettingsMenuItem(
              icon: Icons.monetization_on_outlined,
              title: "Payout Methods".tr,
              iconData: Icons.monetization_on_outlined,
              isIconData: true,
              onTap: () => Get.to(() => PayoutView()),
            ),
            Divider(
              height: .5,
              indent: 16,
              endIndent: 16,
              color: AppColors.secondary,
            ),

            WorkerSettingsMenuItem(
              icon: Icons.bar_chart_outlined,
              isIconData: true,
              iconData: Icons.bar_chart_outlined,
              title: "Earnings and Transactions".tr,
              onTap: () => Get.to(() => WorkerReportView()),
            ),
            Divider(
              height: .5,
              indent: 16,
              endIndent: 16,
              color: AppColors.secondary,
            ),

            WorkerSettingsMenuItem(
              icon: Icons.support_agent,
              isIconData: true,
              iconData: Icons.support_agent,
              title: AppStrings.supportTicket.tr,
              onTap: () => Get.to(() => WorkerSupportTicketView()),
            ),
            Divider(
              height: .5,
              indent: 16,
              endIndent: 16,
              color: AppColors.secondary,
            ),

            WorkerSettingsMenuItem(
              icon: Icons.history,
              isIconData: true,
              iconData: Icons.history,
              title: AppStrings.ticketHistory.tr,
              onTap: () => Get.to(() => WorkerSupportTicketHistoryView()),
            ),

            Divider(
              height: .5,
              indent: 16,
              endIndent: 16,
              color: AppColors.secondary,
            ),

            WorkerSettingsMenuItem(
              icon: Icons.info_outline,
              title: AppStrings.about.tr,
              iconData: Icons.info_outline,
              isIconData: true,
              onTap: () => Get.toNamed(Routes.ABOUT),
            ),
            Divider(
              height: .5,
              indent: 16,
              endIndent: 16,
              color: AppColors.secondary,
            ),

            WorkerSettingsMenuItem(
              icon: Icons.exit_to_app_outlined,
              title: AppStrings.signOut.tr,
              isIconData: true,
              iconData: Icons.exit_to_app_outlined,
              onTap: () {
                Get.dialog(
                  Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    elevation: 0,
                    backgroundColor: Colors.transparent,
                    child: Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 24.w,
                        vertical: 24.h,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 16.w,
                              vertical: 16.h,
                            ),
                            decoration: BoxDecoration(
                              color: Color(0xFFFFE5E5),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.logout,
                              color: Color(0xFFFF3B30),
                              size: 32.sp,
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
                              fontSize: 16,
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
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
                                    ),
                                    side: BorderSide(color: Color(0xFFE5E5E5)),
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
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                    ),
                                    backgroundColor: Color(0xFFFF3B30),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
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
                );
              },
            ),
            Divider(
              height: .5,
              indent: 16,
              endIndent: 16,
              color: AppColors.secondary,
            ),
          ],
        ),
      ),
    );
  }
}
