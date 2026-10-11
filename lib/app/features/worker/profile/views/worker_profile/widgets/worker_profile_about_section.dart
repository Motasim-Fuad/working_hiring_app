import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/worker/helper_profile/controllers/helper_profile_controller.dart';

class WorkerProfileAboutSection extends StatelessWidget {
  final HelperProfileController helperController;

  const WorkerProfileAboutSection({super.key, required this.helperController});

  @override
  Widget build(BuildContext context) {
    final details = helperController.profileData.value?.details ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'About'.tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Text(
          details.isEmpty ? 'No description provided.' : details,
          style: TextStyle(fontSize: 14, color: Colors.black87, height: 1.5),
        ),
      ],
    );
  }
}
