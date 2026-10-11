import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/helper_profile/controllers/helper_profile_controller.dart';

class HelperProfileBioSection extends GetView<HelperDetailController> {
  const HelperProfileBioSection({super.key});

  @override
  Widget build(BuildContext context) {
    final helper = controller.helper;
    if (helper == null) return SizedBox.shrink();
    final bio = helper.bio;
    if (bio == null || bio.trim().isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About".tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Text(
          bio,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }
}
