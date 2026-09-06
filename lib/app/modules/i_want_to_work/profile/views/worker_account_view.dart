import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/worker_profile_controller.dart';
import 'worker_change_name_view.dart';
import 'worker_change_phone_view.dart';
import '../../../../routes/app_pages.dart';
import '../../../../core/widgets/responsive_layout.dart';

class WorkerAccountView extends GetView<WorkerProfileController> {
  WorkerAccountView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: AppStrings.account.tr, showLeading: true),
      body: ResponsiveCenter(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Column(
            children: [
              // ─── Photo (editable) ──────────────────────────
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.WORKER_CHANGE_PHOTO);
                },
                child: _buildPhotoRow(),
              ),
              SizedBox(height: 24.h),

              // ─── Name (editable) ───────────────────────────
              GestureDetector(
                onTap: () => Get.to(() => WorkerChangeNameView()),
                child:
                Obx(()=>
                   _buildEditableRow(
                    AppStrings.name.tr,
                    value: controller.displayName.value,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // ─── Phone (editable) ──────────────────────────
              GestureDetector(
                onTap: () => Get.to(() => WorkerChangePhoneView()),
                child:
                Obx(()=>
                   _buildEditableRow(
                    AppStrings.phoneNumber.tr,
                    value: controller.displayPhone.value,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              // ─── Email (read-only) ─────────────────────────
              _buildReadOnlyRow(
                AppStrings.email.tr,
                value: controller.displayEmail.value,
              ),
              // City is removed as requested.
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          AppStrings.photo.tr,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: AppColors.textPrimary,
          ),
        ),
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
        ),
      ],
    );
  }

  Widget _buildEditableRow(String label, {required String value}) {
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
        Expanded(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  value.isEmpty ? '—' : value,
                  textAlign: TextAlign.end,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
              ),
              SizedBox(width: 8.w),
              Icon(
                Icons.arrow_forward_ios,
                size: 14.sp,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyRow(String label, {required String value}) {
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
        Flexible(
          child: Text(
            value.isEmpty ? '—' : value,
            textAlign: TextAlign.end,
            overflow: TextOverflow.ellipsis,
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
