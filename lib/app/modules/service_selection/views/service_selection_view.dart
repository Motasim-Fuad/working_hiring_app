import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../core/widgets/custom_button.dart';
import '../../../core/widgets/service_chip.dart';
import '../../../core/widgets/responsive_layout.dart';
import '../controllers/service_selection_controller.dart';

class ServiceSelectionView extends GetView<ServiceSelectionController> {
  ServiceSelectionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(),
      body: SafeArea(
        child: ResponsiveCenter(
          maxWidth: AppResponsive.formMaxWidth,
          padding: EdgeInsets.symmetric(
            horizontal: AppResponsive.horizontalPadding(context),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 10.h),
              Text(
                AppStrings.chooseServiceCategory.tr,
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(height: 30.h),

              Expanded(
                child: SingleChildScrollView(
                  child: Obx(
                    () => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: controller.services.map((service) {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: ServiceChip(
                            iconPath: service.icon ?? '',
                            label: service.title ?? '',
                            isSelected: controller.selectedServiceIds.contains(service.id),
                            onTap: () => controller.toggleService(service.id),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),

              SizedBox(height: 20.h),

              Obx(
                () => CustomButton(
                  text: AppStrings.done.tr,
                  onPressed: controller.onDone,
                  backgroundColor: controller.selectedServiceIds.isNotEmpty
                      ? AppColors
                            .primary // Active color (green)
                      : Colors.grey, // Inactive color (grey)
                ),
              ),

              SizedBox(height: 16.h),

              Center(
                child: TextButton(
                  onPressed: controller.onSkip,
                  child: Text(
                    AppStrings.skip.tr,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 30.h),
            ],
          ),
        ),
      ),
    );
  }
}
