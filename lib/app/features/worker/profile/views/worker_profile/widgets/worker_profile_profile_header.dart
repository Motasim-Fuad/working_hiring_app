import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_hiring/app/features/worker/helper_profile/controllers/helper_profile_controller.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_profile/widgets/worker_profile_helpers.dart';

class WorkerProfileProfileHeader extends StatelessWidget {
  final HelperProfileController helperController;

  const WorkerProfileProfileHeader({super.key, required this.helperController});

  @override
  Widget build(BuildContext context) {
    final profile = helperController.profileData.value;
    final logoUrl = profile?.logo;
    final companyName = profile?.companyName ?? 'No Name Set';
    final location = buildLocationString(profile);

    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFF6CA34D), width: 1),
            ),
            child: CircleAvatar(
              radius: 50.r,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: getAvatarImage(logoUrl),
              child: logoUrl == null || logoUrl.isEmpty
                  ? Icon(
                      Icons.business,
                      size: 40.sp,
                      color: Colors.grey.shade600,
                    )
                  : null,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            companyName,
            style: TextStyle(
              fontSize: 24.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          SizedBox(height: 8.h),
          if (location.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.redAccent, size: 16.sp),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      location,
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 8.h),
        ],
      ),
    );
  }
}
