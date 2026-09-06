import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/profile_controller.dart';
import 'edit_profile_view.dart';
import 'support_ticket_view.dart';
import 'support_ticket_history_view.dart';
import 'worker_billing_list_view.dart';

class SettingsView extends GetView<ProfileController> {
  SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: "Settings".tr),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20.h),
            // Menu Items
            _buildMenuItem(
              icon: AppImages.user,
              title: AppStrings.account.tr,
             // subtitle: "justinleo@gmail.com",
              onTap: () => Get.to(() => EditProfileView()),
            ),
            Divider(height: 1.h, color: Color(0xFFF0F0F0)),
            _buildMenuItem(
              icon: AppImages.lock,
              title: AppStrings.changePassword.tr,
              onTap: () => Get.toNamed(Routes.CHANGE_PASSWORD),
            ),
            Divider(height: 1.h, color: Color(0xFFF0F0F0)),
            _buildMenuItem(
              icon: AppImages.wallet,
              title: AppStrings.payment.tr,
              onTap: () => Get.to(() => WorkerBillingListView()),
            ),
            Divider(height: 1.h, color: Color(0xFFF0F0F0)),
            _buildMenuItem(
              icon: Icons.local_offer_outlined,
              title: 'Vouchers & offers'.tr,
              onTap: () => Get.toNamed(Routes.VOUCHERS_OFFERS),
            ),
            Divider(height: 1.h, color: Color(0xFFF0F0F0)),
            _buildMenuItem(
              icon: Icons.support_agent,
              title: AppStrings.supportTicket.tr,
              onTap: () => Get.to(() => SupportTicketView()),
            ),
            Divider(height: 1.h, color: Color(0xFFF0F0F0)),
            _buildMenuItem(
              icon: Icons.history,
              title: AppStrings.ticketHistory.tr,
              onTap: () => Get.to(() => SupportTicketHistoryView()),
            ),

            Divider(height: 1.h, color: Color(0xFFF0F0F0)),
            _buildMenuItem(
              icon: AppImages.info,
              title: AppStrings.about.tr,
              onTap: () => Get.toNamed(Routes.ABOUT),
            ),
            Divider(height: 1.h, color: Color(0xFFF0F0F0)),
            _buildMenuItem(
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
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20.r),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
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
                                    padding: EdgeInsets.symmetric(
                                      vertical: 14.h,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12.r),
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
            Divider(height: 1.h, color: Color(0xFFF0F0F0)),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required dynamic icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 8.h),
      onTap: onTap,
      leading: icon is IconData
          ? Icon(icon, color: Colors.black87, size: 24.sp)
          : SvgPicture.asset(
              icon,
              width: 24.w,
              colorFilter: ColorFilter.mode(
                Colors.black87,
                BlendMode.srcIn,
              ),
            ),
      title: Text(
        title,
        style: TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w500,
          fontSize: 16.sp,
        ),
      ),
      trailing: subtitle != null
          ? Text(
              subtitle,
              style: TextStyle(color: Colors.black87, fontSize: 15.sp),
            )
          : Icon(
              Icons.arrow_forward_ios,
              size: 16.sp,
              color: Color(0xFFBDBDBD),
            ),
    );
  }
}
