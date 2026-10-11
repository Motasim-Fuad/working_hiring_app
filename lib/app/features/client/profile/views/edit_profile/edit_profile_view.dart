import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/client/profile/controllers/profile_controller.dart';
import 'package:working_hiring/app/features/client/profile/views/change_photo/change_photo_view.dart';
import 'package:working_hiring/app/features/client/profile/views/change_name/change_name_view.dart';
import 'package:working_hiring/app/features/client/profile/views/change_phone/change_phone_view.dart';
import 'package:working_hiring/app/features/client/profile/views/edit_profile/widgets/edit_profile_detail_row.dart';

class EditProfileView extends GetView<ProfileController> {
  const EditProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Get.back(),
        ),
        title: Text(
          AppStrings.profile.tr,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            children: [
              GestureDetector(
                onTap: () => Get.to(() => ChangePhotoView()),
                child: EditProfileDetailRow(
                  label: AppStrings.photo.tr,
                  isPhoto: true,
                ),
              ),
              SizedBox(height: 24.h),

              GestureDetector(
                onTap: () => Get.to(() => ChangeNameView()),
                child: EditProfileDetailRow(
                  label: AppStrings.name.tr,
                  obsValue: controller.displayName,
                ),
              ),
              SizedBox(height: 24.h),

              GestureDetector(
                onTap: () => Get.to(() => ChangePhoneView()),
                child: EditProfileDetailRow(
                  label: AppStrings.phoneNumber.tr,
                  obsValue: controller.displayPhone,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
