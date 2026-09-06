import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import '../constants/app_colors.dart';
import '../constants/app_images.dart';
import '../constants/app_strings.dart';
import '../../modules/main/controllers/main_controller.dart';
import '../../modules/i_need_help/home/controllers/home_controller.dart';
import 'language_selector.dart';
import 'responsive_layout.dart';

class HomeHeader extends GetView<MainController> {
  HomeHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return ResponsiveCenter(
      maxWidth: AppResponsive.wideContentMaxWidth,
      padding: EdgeInsets.zero,
      child: Column(children: [_buildLocationHeader(context), _buildRoleSwitcher(context)]),
    );
  }

  Widget _buildLocationHeader(BuildContext context) {
    final hasHomeController = Get.isRegistered<HomeController>();

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.horizontalPadding(context),
        vertical: 10,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: InkWell(
              // onTap: () {
              //   if (hasHomeController) {
              //     Get.find<HomeController>().openLocationList();
              //   }
              // },
              borderRadius: BorderRadius.circular(8.r),
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 4.0.h),
                child: Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: Color(0xFF7CB342),
                      size: 26.sp,
                    ),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            children: [
                              Flexible(
                                child: hasHomeController
                                    ? Obx(
                                      () => Text(
                                    Get.find<HomeController>().currentAddress.value,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                )
                                    : Text(
                                  'Your Location'.tr,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: 24.sp,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              if (hasHomeController)
                                Icon(Icons.keyboard_arrow_down, size: 20.sp),
                            ],
                          ),
                          // 🔽 SUB‑TEXT – now dynamic from HomeController
                          hasHomeController
                              ? Obx(
                                () => Text(
                              Get.find<HomeController>().currentFullAddress.value,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey,
                              ),
                            ),
                          )
                              : Text(
                            AppStrings.addressDetail.tr, // fallback static
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(width: 10),
          GestureDetector(
            onTap: () => Get.toNamed('/notification'),
            child: Stack(
              children: [
                SvgPicture.asset(
                  AppImages.bell,
                  width: 28.sp,
                  height: 28.sp,
                  colorFilter: ColorFilter.mode(Colors.grey, BlendMode.srcIn),
                ),
                Positioned(
                  right: 2.w,
                  top: 2.h,
                  child: Container(
                    width: 10.w,
                    height: 10.h,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoleSwitcher(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: AppResponsive.horizontalPadding(context),
        vertical: 10,
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final stack = constraints.maxWidth < 360;
          final toggle = _buildToggleContainer();
          final language = LanguageSelector(isHomeView: true);
          if (stack) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [toggle, SizedBox(height: 8), language],
            );
          }
          return Row(
            children: [
              Expanded(child: toggle),
              SizedBox(width: 10),
              SizedBox(width: 140, child: language),
            ],
          );
        },
      ),
    );
  }

  Widget _buildToggleContainer() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Color(0xFFF0F0F0),
        borderRadius: BorderRadius.circular(25.r),
      ),
      child: Obx(
            () => Row(
          children: [
            Expanded(
              child: _buildRoleButton(
                title: AppStrings.iNeedHelp.tr,
                isActive: controller.activePhase.value == 1,
                onTap: () {
                  if (controller.activePhase.value != 1) {
                    controller.changePhase(1);
                  }
                },
              ),
            ),
            Expanded(
              child: _buildRoleButton(
                title: AppStrings.iWantToWork.tr,
                isActive: controller.activePhase.value == 2,
                onTap: () {
                  if (controller.activePhase.value != 2) {
                    controller.changePhase(2);
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleButton({
    required String title,
    required bool isActive,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        decoration: BoxDecoration(
          color: isActive ? AppColors.textPrimary : Colors.transparent,
          borderRadius: BorderRadius.circular(25.r),
        ),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 4.0.w),
            child: Text(
              title,
              style: TextStyle(
                color: isActive ? Colors.white : Colors.grey.shade600,
                fontWeight: FontWeight.w600,
                fontSize: AppResponsive.font(12),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
