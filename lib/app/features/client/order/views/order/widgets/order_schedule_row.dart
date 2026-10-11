import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:working_hiring/app/core/constants/app_images.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/client/order/views/order_detail/order_detail_view.dart';
import 'package:working_hiring/app/features/client/order/utils/order_formatters.dart';

class OrderScheduleRow extends StatelessWidget {
  final OrderModel order;

  const OrderScheduleRow({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              InkWell(
                onTap: () => Get.to(() => OrderDetailView(order: order)),
                child: Row(
                  children: [
                    SvgPicture.asset(
                      AppImages.calendar,
                      width: 14.sp,
                      height: 14.sp,
                      colorFilter: ColorFilter.mode(
                        Color(0xFF6CA34D),
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      formatOrderDate(order.workingDate),
                      style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                    ),
                    SizedBox(width: 12.w),
                    SvgPicture.asset(
                      AppImages.time,
                      width: 14.sp,
                      height: 14.sp,
                      colorFilter: ColorFilter.mode(
                        Color(0xFF6CA34D),
                        BlendMode.srcIn,
                      ),
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      order.workingStartTime ?? '',
                      style: TextStyle(fontSize: 13.sp, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 8.h),
              InkWell(
                child: Row(
                  children: [
                    Icon(
                      Icons.person_outline,
                      size: 20.sp,
                      color: Colors.grey.shade400,
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      order.providerName?.isNotEmpty == true
                          ? order.providerName!
                          : 'Pending Worker',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () => Get.to(() => OrderDetailView(order: order)),
          child: Text(
            formatOrderAmount(order.amount),
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18.sp,
              color: Colors.black,
            ),
          ),
        ),
      ],
    );
  }
}
