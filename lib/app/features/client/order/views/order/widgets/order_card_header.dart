import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:working_hiring/app/core/constants/app_images.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/order_report_menu.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/order_status_badge.dart';

class OrderCardHeader extends StatelessWidget {
  final OrderModel order;
  final bool showMenu;

  const OrderCardHeader({
    super.key,
    required this.order,
    this.showMenu = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Text(
                order.title ?? '',
                style: TextStyle(
                  fontSize: 16.sp,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(width: 8.w),
            OrderStatusBadge(status: order.status ?? ''),
            if (showMenu) OrderReportMenu(order: order),
          ],
        ),
        SizedBox(height: 12.h),
        Row(
          children: [
            SvgPicture.asset(
              AppImages.homeAssistance,
              width: 18.sp,
              height: 18.sp,
            ),
            SizedBox(width: 6.w),
            Text(
              order.categoryName ?? '',
              style: TextStyle(
                fontSize: 14.sp,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            Text(
              "Posted by You".tr,
              style: TextStyle(fontSize: 14.sp, color: Colors.black87),
            ),
            SizedBox(width: 4.w),
            Icon(Icons.verified, color: Color(0xFF007AFF), size: 16.sp),
          ],
        ),
        SizedBox(height: 8.h),
        Row(
          children: [
            SvgPicture.asset(
              AppImages.location,
              width: 14.sp,
              height: 14.sp,
              colorFilter: ColorFilter.mode(Color(0xFFFF3B30), BlendMode.srcIn),
            ),
            SizedBox(width: 6.w),
            Expanded(
              child: Text(
                order.address == 'San Francisco CA'
                    ? AppStrings.sanFranciscoCA.tr
                    : (order.address ?? ''),
                style: TextStyle(fontSize: 14.sp, color: Colors.black87),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
