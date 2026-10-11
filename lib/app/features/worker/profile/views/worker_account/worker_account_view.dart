import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/widgets/custom_appBar/custom_app_bar.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/worker/profile/controllers/worker_profile_controller.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_change_name/worker_change_name_view.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_change_phone/worker_change_phone_view.dart';
import 'package:working_hiring/app/routes/app_pages.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_account/widgets/worker_account_photo_row.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_account/widgets/worker_account_editable_row.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_account/widgets/worker_account_read_only_row.dart';

class WorkerAccountView extends GetView<WorkerProfileController> {
  const WorkerAccountView({super.key});

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
              GestureDetector(
                onTap: () {
                  Get.toNamed(Routes.WORKER_CHANGE_PHOTO);
                },
                child: WorkerAccountPhotoRow(),
              ),
              SizedBox(height: 24.h),

              GestureDetector(
                onTap: () => Get.to(() => WorkerChangeNameView()),
                child: Obx(
                  () => WorkerAccountEditableRow(
                    label: AppStrings.name.tr,
                    value: controller.displayName.value,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              GestureDetector(
                onTap: () => Get.to(() => WorkerChangePhoneView()),
                child: Obx(
                  () => WorkerAccountEditableRow(
                    label: AppStrings.phoneNumber.tr,
                    value: controller.displayPhone.value,
                  ),
                ),
              ),
              SizedBox(height: 24.h),

              WorkerAccountReadOnlyRow(
                label: AppStrings.email.tr,
                value: controller.displayEmail.value,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
