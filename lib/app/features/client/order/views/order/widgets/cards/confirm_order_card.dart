import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/client/order/views/order_detail/order_detail_view.dart';
import 'package:working_hiring/app/features/client/payment/views/payment/payment_view.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/order_countdown.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/dialogs/cancel_order_dialog.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/cancellation_request_panel.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/order_card_header.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/time_change_banner.dart';
import 'package:working_hiring/app/features/client/order/views/order/widgets/order_schedule_row.dart';

class ConfirmOrderCard extends StatelessWidget {
  final OrderModel order;

  const ConfirmOrderCard({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    final status = order.effectiveStatus;
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: () => Get.to(() => OrderDetailView(order: order)),
            child: OrderCardHeader(order: order),
          ),
          SizedBox(height: 12.h),
          OrderScheduleRow(order: order),
          OrderCountdown(order: order),
          SizedBox(height: 16.h),

          if (status == 'ACCEPT') ...[
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Get.to(() => PaymentView(), arguments: order),
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                  backgroundColor: Color(0xFF6CA34D),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12.r),
                  ),
                  elevation: 0,
                ),
                child: Text(
                  AppStrings.pay.tr,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 8.h),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => showCancelOrderDialog(context, order),
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.redAccent),
                  padding: EdgeInsets.symmetric(vertical: 12.h),
                ),
                child: Text(
                  'Cancel'.tr,
                  style: TextStyle(color: Colors.redAccent),
                ),
              ),
            ),
          ] else if (status == 'CONFIRM' ||
              status == 'CANCELLATION_REQUEST') ...[
            TimeChangeBanner(order: order),
            CancellationRequestPanel(order: order),
            SizedBox(height: 16.h),
            if (order.pendingCancellationRequest == null)
              SizedBox(
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
                    "Cancel".tr,
                    style: TextStyle(
                      color: Colors.redAccent,
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
          ] else if (status == 'IN_PROGRESS') ...[
            CancellationRequestPanel(order: order),
            if (order.pendingCancellationRequest == null) ...[
              SizedBox(height: 16.h),
              SizedBox(
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
              ),
            ],
          ] else
            SizedBox.shrink(),
        ],
      ),
    );
  }
}
