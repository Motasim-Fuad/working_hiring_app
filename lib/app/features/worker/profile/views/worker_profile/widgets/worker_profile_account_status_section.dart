import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/routes/app_pages.dart';
import 'package:working_hiring/app/features/worker/helper_profile/controllers/helper_profile_controller.dart';

class WorkerProfileAccountStatusSection extends StatelessWidget {
  final HelperProfileController helperController;

  const WorkerProfileAccountStatusSection({
    super.key,
    required this.helperController,
  });

  @override
  Widget build(BuildContext context) {
    final profile = helperController.profileData.value;
    final strikeCount = profile?.strikeCount ?? 0;
    final accountStatus = profile?.accountStatus ?? 'GOOD';
    final isVerified = profile?.isVerified ?? false;

    Color badgeColor;
    Color badgeBg;
    switch (accountStatus.toUpperCase()) {
      case 'GOOD':
        badgeColor = Colors.green;
        badgeBg = Colors.green.shade50;
        break;
      case 'WARNING':
        badgeColor = Colors.orange;
        badgeBg = Colors.orange.shade50;
        break;
      case 'SUSPENDED':
        badgeColor = Colors.red;
        badgeBg = Colors.red.shade50;
        break;
      default:
        badgeColor = Colors.grey;
        badgeBg = Colors.grey.shade50;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Account Status'.tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),

        if (!isVerified)
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.verified_user_outlined,
                  color: Colors.orange,
                  size: 24.sp,
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Identity Verification Required'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp,
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        'Verify your account to start receiving jobs.'.tr,
                        style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () =>
                      Get.toNamed(Routes.WORKER_ACCOUNT_VERIFICATION),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                  ),
                  child: Text(
                    'Verify'.tr,
                    style: TextStyle(color: Colors.white, fontSize: 12.sp),
                  ),
                ),
              ],
            ),
          ),

        Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Strike Count'.tr,
                        style: TextStyle(fontSize: 14.sp, color: Colors.grey),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '$strikeCount',
                        style: TextStyle(
                          fontSize: 24.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      accountStatus,
                      style: TextStyle(
                        color: badgeColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ],
              ),
              if (strikeCount > 0) ...[
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.orange, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
                        'Strike Count Warning'.trParams({
                          'count': '$strikeCount',
                        }),
                        style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.orange.shade900,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.green,
                      size: 18.sp,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      'No strikes — keep up the great work!'.tr,
                      style: TextStyle(
                        fontSize: 13.sp,
                        color: Colors.green.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
