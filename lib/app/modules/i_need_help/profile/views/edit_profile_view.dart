// lib/modules/i_need_help/profile/views/edit_profile_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/profile_controller.dart';
import 'change_photo_view.dart';
import 'change_name_view.dart';
import 'change_phone_view.dart';

class EditProfileView extends GetView<ProfileController> {
  EditProfileView({super.key});

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
      body: SingleChildScrollView(  // ← Overflow সমাধান
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            children: [
              // Photo row
              GestureDetector(
                onTap: () => Get.to(() => ChangePhotoView()),
                child: _buildDetailRow(AppStrings.photo.tr, isPhoto: true),
              ),
              SizedBox(height: 24.h),

              // Name (editable)
              GestureDetector(
                onTap: () => Get.to(() => ChangeNameView()),
                child: _buildDetailRow(
                  AppStrings.name.tr,
                  obsValue: controller.displayName, // ← Observable পাঠানো হচ্ছে
                ),
              ),
              SizedBox(height: 24.h),

              // Phone (editable)
              GestureDetector(
                onTap: () => Get.to(() => ChangePhoneView()),
                child: _buildDetailRow(
                  AppStrings.phoneNumber.tr,
                  obsValue: controller.displayPhone, // ← Observable
                ),
              ),
              // Email and City omitted
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, {RxString? obsValue, bool isPhoto = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: AppColors.textPrimary,
          ),
        ),
        if (isPhoto)
          Obx(
                () => CircleAvatar(
                  radius: 30.r,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: controller.displayPhoto,
                  child: controller.displayPhoto == null
                      ? Icon(
                    Icons.person,
                    size: 25,
                    color: Colors.grey,
                  )
                      : null,
                )
          )
        else if (obsValue != null)
          Obx(
                () => Text(
              obsValue.value.isEmpty ? '—' : obsValue.value,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14.sp,
              ),
            ),
          ),
      ],
    );
  }
}