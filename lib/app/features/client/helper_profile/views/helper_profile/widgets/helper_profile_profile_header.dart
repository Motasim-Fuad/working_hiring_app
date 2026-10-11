import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/helper_profile/controllers/helper_profile_controller.dart';

class HelperProfileProfileHeader extends GetView<HelperDetailController> {
  const HelperProfileProfileHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final helper = controller.helper;
    if (helper == null) return SizedBox.shrink();
    final photoUrl = helper.photo;
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Color(0xFF6CA34D).withValues(alpha: 0.3),
                width: 2,
              ),
            ),
            child: CircleAvatar(
              radius: 44.r,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: (photoUrl == null || photoUrl.isEmpty)
                  ? Icon(Icons.person, size: 44.sp, color: Colors.grey)
                  : null,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            helper.companyName ?? 'Helper',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (helper.isVerified == true) ...[
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Color(0xFF6CA34D).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, size: 16.sp, color: Color(0xFF6CA34D)),
                  SizedBox(width: 4.w),
                  Text(
                    'Verified'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6CA34D),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: Colors.redAccent, size: 16.sp),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                  'Location Distance Away'.trParams({
                    'location': helper.location ?? 'San Francisco',
                    'distance': (helper.distance ?? 0).toStringAsFixed(1),
                  }),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
