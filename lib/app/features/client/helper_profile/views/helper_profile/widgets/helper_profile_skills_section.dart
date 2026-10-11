import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/helper_profile/controllers/helper_profile_controller.dart';

class HelperProfileSkillsSection extends GetView<HelperDetailController> {
  const HelperProfileSkillsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final helper = controller.helper;
    if (helper == null ||
        helper.categories == null ||
        helper.categories!.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Skills".tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: helper.categories!.map((skill) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(
                  color: Color(0xFF6CA34D).withValues(alpha: 0.5),
                ),
              ),
              child: Text(
                skill,
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Color(0xFF6CA34D),
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
