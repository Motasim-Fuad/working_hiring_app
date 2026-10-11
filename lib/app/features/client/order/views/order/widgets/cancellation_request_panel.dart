import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/client/order/controllers/order_controller.dart';

class CancellationRequestPanel extends GetView<OrderController> {
  final OrderModel order;

  const CancellationRequestPanel({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final request = order.pendingCancellationRequest;
    if (request == null) return SizedBox.shrink();
    final requestedByProvider =
        (request.sender ?? '').toUpperCase() == 'PROVIDER';
    return Container(
      width: double.infinity,
      margin: EdgeInsets.only(top: 16.h),
      padding: EdgeInsets.all(14.w),
      decoration: BoxDecoration(
        color: Colors.orange.shade50,
        border: Border.all(color: Colors.orange.shade200),
        borderRadius: BorderRadius.circular(12.r),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cancellation requested'.tr,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14.sp),
          ),
          if ((request.message ?? '').isNotEmpty) ...[
            SizedBox(height: 6.h),
            Text(
              '${'Reason'.tr}: ${request.message}',
              style: TextStyle(fontSize: 13.sp),
            ),
          ],
          SizedBox(height: 12.h),
          if (requestedByProvider)
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => controller.cancelAcceptOrder(
                      order.id,
                      request.id,
                      'ACCEPT',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Color(0xFF6CA34D),
                    ),
                    child: Text(
                      'Accept'.tr,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => controller.cancelAcceptOrder(
                      order.id,
                      request.id,
                      'DECLINED',
                    ),
                    child: Text('Decline'.tr),
                  ),
                ),
              ],
            )
          else
            Text('Waiting for provider approval.'.tr),
        ],
      ),
    );
  }
}
