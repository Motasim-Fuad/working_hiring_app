import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/home_header.dart';
import '../../../main/controllers/main_controller.dart';
import '../../../../routes/app_pages.dart';
import '../controllers/home_controller.dart';
import '../inner_widget/home_baner/home_banner.dart';
// ⬇️ নতুন ইমপোর্ট – CreateCustomOfferView
import '../../custom_offer/views/custom_offer_view.dart';
import '../../../../core/widgets/responsive_layout.dart';

class HomeView extends GetView<HomeController> {
  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            HomeHeader(),
            Expanded(
              child: RefreshIndicator(
                color: Color(0xFF6CA34D),
                onRefresh: () => controller.loadInitialData(),
                child: SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: ResponsiveCenter(
                    maxWidth: AppResponsive.wideContentMaxWidth,
                    padding: EdgeInsets.zero,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        HomeBanner(),
                        HomeSearchBar(),
                        HomeMyActivitySection(),
                        _buildServiceGrid(context),
                        RecommendedHelpersSection(),
                        RecentActivitySection(),
                        SizedBox(height: 120.h),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceGrid(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallPhone = screenWidth < 360;
    final serviceColumns = screenWidth >= 900
        ? 4
        : screenWidth >= 600
            ? 3
            : 2;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppStrings.serviceCategory.tr,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15.h),
          Obx(() => GridView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: controller.servicesCategories.length,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: serviceColumns,
              mainAxisSpacing: isSmallPhone ? 10 : 15,
              crossAxisSpacing: isSmallPhone ? 10 : 15,
              childAspectRatio: isSmallPhone ? 1.05 : 1.15,
            ),
            itemBuilder: (context, index) {
              final service = controller.servicesCategories[index];
              final isSelected =
                  controller.selectedCategory.value == (service.title ?? '');
              return InkWell(
                onTap: () {
                  controller.selectCategory(service.title ?? '');
                  Get.toNamed(Routes.HELPER_LIST,
                      arguments: service.title ?? '');
                },
                borderRadius: BorderRadius.circular(12.r),
                child: Container(
                  decoration: BoxDecoration(
                    color: Color(0xFFF9F9F9),
                    borderRadius: BorderRadius.circular(12.r),
                    border: Border.all(
                      color: isSelected
                          ? Color(0xFF6CA34D)
                          : Colors.grey.shade200,
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              AppImages.categoryIcon(service.icon),
                              width: 40.w,
                              height: 40.h,
                            ),
                            SizedBox(height: 10.h),
                            Text(
                              service.title ?? '',
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w500,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(128),
                            borderRadius: BorderRadius.circular(12.r),
                          ),
                          child: Center(
                            child: Icon(
                              Icons.check_circle,
                              color: Color(0xFF6CA34D),
                              size: 32.sp,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          )),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ✅ HomeMyActivitySection – অপরিবর্তিত
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HomeMyActivitySection extends GetView<HomeController> {
  HomeMyActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isSmallPhone = screenWidth < 360;
    final columnCount = screenWidth >= 900
        ? 4
        : screenWidth >= 600
            ? 3
            : 2;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "My Activity".tr,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15.h),
          Obx(() {
            final activity = controller.activityData.value;
            final items = [
              _activityItem("Active Jobs".tr,
                  (activity?.activeOrders ?? 0).toString(), Icons.work_outline,
                  Colors.blue),
              _activityItem("Completed".tr,
                  (activity?.completedOrders ?? 0).toString(),
                  Icons.check_circle_outline, Colors.green),
              _activityItem("Total Spent".tr,
                  r'$' + (activity?.totalSpent ?? 0).toStringAsFixed(0),
                  Icons.account_balance_wallet_outlined, Colors.purple),
              _activityItem("My Rating".tr,
                  (activity?.avgRating ?? 0.0).toStringAsFixed(1),
                  Icons.star_outline, Colors.orange),
            ];
            return GridView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: items.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columnCount,
                mainAxisSpacing: isSmallPhone ? 10 : 15,
                crossAxisSpacing: isSmallPhone ? 10 : 15,
                childAspectRatio: isSmallPhone ? 1.75 : 2.05,
              ),
              itemBuilder: (context, index) => items[index],
            );
          }),
        ],
      ),
    );
  }

  Widget _activityItem(String title, String value, IconData icon, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: Colors.grey.shade100),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20.sp, color: color),
          ),
          SizedBox(width: 12.w),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade600,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 2.h),
                Text(value,
                    style: TextStyle(
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ✅ HomeSearchBar –
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class HomeSearchBar extends StatefulWidget {
  HomeSearchBar({super.key});

  @override
  State<HomeSearchBar> createState() => _HomeSearchBarState();
}

class _HomeSearchBarState extends State<HomeSearchBar> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onSubmit(String query) {
    if (query.trim().isEmpty) return;
    Get.toNamed(Routes.HELPER_LIST, arguments: {'query': query.trim()});
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: TextField(
        controller: _controller,
        onSubmitted: _onSubmit,
        decoration: InputDecoration(
          hintText: "Search for services, helpers...".tr,
          prefixIcon: Icon(Icons.search, color: Colors.grey),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
            icon: Icon(Icons.clear, color: Colors.grey),
            onPressed: () {
              _controller.clear();
            },
          )
              : null,
          filled: true,
          fillColor: Colors.grey.shade100,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12.r),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ✅ MoreCategoriesSection – কমেন্ট করা আছে, আপাতত রেখেছি
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class MoreCategoriesSection extends GetView<HomeController> {
  MoreCategoriesSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "More Categories".tr,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15.h),
          Obx(() {
            if (controller.moreCategories.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text("No sub-categories available".tr,
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
              );
            }
            return SizedBox(
              height: 100.h,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: controller.moreCategories.length,
                separatorBuilder: (_, __) => SizedBox(width: 15.w),
                itemBuilder: (context, index) {
                  final cat = controller.moreCategories[index];
                  return Column(
                    children: [
                      Container(
                        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                        decoration: BoxDecoration(
                          color: Color(0xFFF9F9F9),
                          borderRadius: BorderRadius.circular(12.r),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: Icon(Icons.category, color: Color(0xFF6CA34D)),
                      ),
                      SizedBox(height: 5.h),
                      Text(
                        cat.title ?? '',
                        style: TextStyle(fontSize: 12.sp),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  );
                },
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ✅ RecommendedHelpersSection – **ক্লিকেবল করা হয়েছে**
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class RecommendedHelpersSection extends GetView<HomeController> {
  RecommendedHelpersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recommended Helpers".tr,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15.h),
          Obx(() {
            if (controller.isLoadingHelpers.value) {
              return Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                  child: CircularProgressIndicator(),
                ),
              );
            }
            if (controller.recommendedHelpers.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text("No recommendations yet".tr,
                    style: TextStyle(color: Colors.grey)),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.recommendedHelpers.length,
              separatorBuilder: (context, index) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final helper = controller.recommendedHelpers[index];
                final double score = ((helper.rating ?? 0) * 0.4) +
                    (((helper.totalTasks ?? 0) > 20 ? 4.0 : 2.5) * 0.3) +
                    (((helper.distance ?? 10) < 5 ? 4.0 : 2.5) * 0.3);

                // 👇 ক্লিক করলে CreateCustomOfferView-এ যাবে
                return GestureDetector(
                  onTap: () {
                    Get.to(
                          () => CreateCustomOfferView(),
                      arguments: {
                        'workerID': helper.id.toString(),
                        'workerName': helper.companyName ?? helper.name ?? 'Helper',
                        'workerAvatar': helper.avatarUrl ?? '',
                        'categoryID': '',
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.02),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        )
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(0xFF6CA34D).withOpacity(0.2),
                          child: Text(
                            (helper.companyName ?? '?')[0],
                            style: TextStyle(
                                color: Color(0xFF6CA34D), fontWeight: FontWeight.bold),
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(helper.companyName ?? 'Helper',
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold, fontSize: 16.sp)),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(Icons.star, size: 14.sp, color: Colors.amber),
                                  SizedBox(width: 4.w),
                                  Text(
                          'Rating Smart Score'.trParams({
                            'rating':
                                (helper.rating ?? 0).toStringAsFixed(1),
                            'score': score.toStringAsFixed(2),
                          }),
                                    style: TextStyle(
                                        fontSize: 12.sp, color: Colors.grey.shade600),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}

// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
// ✅ RecentActivitySection – অপরিবর্তিত
// ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
class RecentActivitySection extends GetView<HomeController> {
  RecentActivitySection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recent Activity".tr,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15.h),
          Obx(() {
            final activities = controller.activityData.value?.recentActivities ?? [];
            if (activities.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text("No recent activity".tr,
                    style: TextStyle(color: Colors.grey, fontSize: 14.sp)),
              );
            }
            return ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Container(
                    padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(Icons.history, color: Colors.blue, size: 20.sp),
                  ),
                  title: Text(activity.title ?? '',
                      style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.w500)),
                  subtitle: Text(activity.timestamp ?? '',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
