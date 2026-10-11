import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/client/order/controllers/order_controller.dart';

class TimeChangeBanner extends GetView<OrderController> {
  final OrderModel order;

  const TimeChangeBanner({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final req = controller.pendingTimeChangeFor(order.id);
      if (req == null) return SizedBox.shrink();

      return Container(
        margin: EdgeInsets.only(top: 12.h),
        padding: EdgeInsets.all(14.w),
        decoration: BoxDecoration(
          color: Colors.purple.shade50,
          borderRadius: BorderRadius.circular(12.r),
          border: Border.all(color: Colors.purple.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.schedule_outlined,
                  size: 18.sp,
                  color: Colors.purple.shade700,
                ),
                SizedBox(width: 8.w),
                Text(
                  'Provider proposed a new time'.tr,
                  style: TextStyle(
                    fontSize: 13.sp,
                    fontWeight: FontWeight.bold,
                    color: Colors.purple.shade900,
                  ),
                ),
              ],
            ),
            SizedBox(height: 8.h),
            if ((req.proposedDate ?? '').isNotEmpty)
              Text(
                '${'Date'.tr}: ${req.proposedDate}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.purple.shade800,
                ),
              ),
            if ((req.proposedTime ?? '').isNotEmpty)
              Text(
                '${'Time'.tr}: ${req.proposedTime}',
                style: TextStyle(
                  fontSize: 13.sp,
                  color: Colors.purple.shade800,
                ),
              ),
            if ((req.message ?? '').isNotEmpty) ...[
              SizedBox(height: 4.h),
              Text(
                '${'Reason'.tr}: ${req.message}',
                style: TextStyle(
                  fontSize: 12.sp,
                  color: Colors.purple.shade700,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
            SizedBox(height: 12.h),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () =>
                        controller.respondToTimeChange(order.id, 'ACCEPT'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6CA34D),
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      'Accept'.tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () =>
                        controller.respondToTimeChange(order.id, 'DECLINED'),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 10.h),
                      side: BorderSide(color: Colors.redAccent),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                    ),
                    child: Text(
                      'Decline'.tr,
                      style: TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    });
  }
}
