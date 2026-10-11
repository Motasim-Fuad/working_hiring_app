import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/worker/helper_profile/controllers/helper_profile_controller.dart';

class WorkerProfileSkillsSection extends StatelessWidget {
  final HelperProfileController helperController;

  const WorkerProfileSkillsSection({super.key, required this.helperController});

  @override
  Widget build(BuildContext context) {
    final categories =
        helperController.profileData.value?.serviceCategory ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Skills'.tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        categories.isEmpty
            ? Text(
                'No skills provided.'.tr,
                style: TextStyle(color: Colors.grey),
              )
            : Wrap(
                spacing: 8,
                runSpacing: 8,
                children: categories.map((cat) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 8.h,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20.r),
                      border: Border.all(color: Color(0xFF6CA34D)),
                    ),
                    child: Text(
                      cat.title ?? 'Service',
                      style: TextStyle(
                        color: Color(0xFF6CA34D),
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),
      ],
    );
  }
}
