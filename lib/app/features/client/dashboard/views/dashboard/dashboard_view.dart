import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_images.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/chat/views/message_list/message_list_view.dart';
import 'package:working_hiring/app/features/client/profile/views/profile/profile_view.dart';
import 'package:working_hiring/app/features/client/dashboard/controllers/dashboard_controller.dart';
import 'package:working_hiring/app/features/client/home/views/home/home_view.dart';
import 'package:working_hiring/app/features/client/order/views/order/order_view.dart';
import 'package:working_hiring/app/features/client/dashboard/views/dashboard/widgets/dashboard_helpers.dart';

class DashboardView extends GetView<DashboardController> {
  const DashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(
        () => IndexedStack(
          index: controller.tabIndex.value,
          children: [
            HomeView(key: PageStorageKey('Home')),
            OrderView(key: PageStorageKey('Order')),
            MessageListView(key: PageStorageKey('Message')),
            ProfileView(key: PageStorageKey('Profile')),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        color: Colors.white,
        child: SafeArea(
          bottom: true,
          child: Obx(
            () => BottomNavigationBar(
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: AppColors.primary,
              unselectedItemColor: AppColors.textSecondary,
              showSelectedLabels: true,
              showUnselectedLabels: true,
              currentIndex: controller.tabIndex.value,
              onTap: controller.changeTabIndex,
              items: [
                buildNavItem(AppImages.home, AppStrings.home.tr),
                buildNavItem(AppImages.order, AppStrings.order.tr),
                buildNavItem(AppImages.chat, AppStrings.message.tr),
                buildNavItem(AppImages.profile, AppStrings.profile.tr),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
