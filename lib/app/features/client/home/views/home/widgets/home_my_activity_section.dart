import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/home/controllers/home_controller.dart';

class HomeMyActivitySection extends GetView<HomeController> {
  const HomeMyActivitySection({super.key});

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
              _activityItem(
                "Active Jobs".tr,
                (activity?.activeOrders ?? 0).toString(),
                Icons.work_outline,
                Colors.blue,
              ),
              _activityItem(
                "Completed".tr,
                (activity?.completedOrders ?? 0).toString(),
                Icons.check_circle_outline,
                Colors.green,
              ),
              _activityItem(
                "Total Spent".tr,
                r'$' + (activity?.totalSpent ?? 0).toStringAsFixed(0),
                Icons.account_balance_wallet_outlined,
                Colors.purple,
              ),
              _activityItem(
                "My Rating".tr,
                (activity?.avgRating ?? 0.0).toStringAsFixed(1),
                Icons.star_outline,
                Colors.orange,
              ),
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
            color: Colors.black.withValues(alpha: 0.03),
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
              color: color.withValues(alpha: 0.1),
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
                Text(
                  title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12.sp,
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 2.h),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
