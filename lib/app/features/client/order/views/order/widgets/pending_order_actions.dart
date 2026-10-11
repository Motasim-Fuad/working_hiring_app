import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/client/order/controllers/order_controller.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/sheets/client_counter_sheet.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/dialogs/cancel_order_dialog.dart';

class PendingOrderActions extends GetView<OrderController> {
  final OrderModel order;

  const PendingOrderActions({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final bool providerCountered = controller.hasProviderCountered(order.id);
    final bool clientCountered = controller.hasClientCountered(order.id);

    if (!providerCountered) {
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => showCancelOrderDialog(context, order),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            side: BorderSide(color: Colors.redAccent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'Cancel'.tr,
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    } else if (providerCountered && !clientCountered) {
      return Column(
        children: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => controller.acceptOrder(order.id),
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                backgroundColor: Color(0xFF6CA34D),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.r),
                ),
                elevation: 0,
              ),
              child: Text(
                'Accept'.tr,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16.sp,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          SizedBox(height: 8.h),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => showCancelOrderDialog(context, order),
                  style: OutlinedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    side: BorderSide(color: Colors.redAccent),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Cancel'.tr,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 15.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              if (!clientCountered) ...[
                SizedBox(width: 10.w),
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => showClientCounterSheet(context, order),
                    style: OutlinedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      side: BorderSide(color: Color(0xFF6CA34D)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      'Counter'.tr,
                      style: TextStyle(
                        color: Color(0xFF6CA34D),
                        fontSize: 15.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    } else {
      // Client used their one counter. Their own proposal cannot be accepted
      // or countered again; only Decline remains until provider responds.
      return SizedBox(
        width: double.infinity,
        child: OutlinedButton(
          onPressed: () => showCancelOrderDialog(context, order),
          style: OutlinedButton.styleFrom(
            padding: EdgeInsets.symmetric(vertical: 12.h),
            side: BorderSide(color: Colors.redAccent),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12.r),
            ),
          ),
          child: Text(
            'Decline'.tr,
            style: TextStyle(
              color: Colors.redAccent,
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    }
  }
}
