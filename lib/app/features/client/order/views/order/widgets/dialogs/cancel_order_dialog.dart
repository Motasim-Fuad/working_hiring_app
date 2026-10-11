import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/client/order/controllers/order_controller.dart';

void showCancelOrderDialog(BuildContext context, OrderModel order) {
  final controller = Get.find<OrderController>();
  final TextEditingController reasonController = TextEditingController();
  final isPaid = (order.paymentStatus ?? '').toUpperCase() == 'PAID';
  showDialog(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text((isPaid ? "Request Cancellation" : "Cancel Order").tr),
      content: TextField(
        controller: reasonController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: "Reason for cancellation".tr,
          border: OutlineInputBorder(),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: Text("Back".tr)),
        ElevatedButton(
          onPressed: () {
            controller.cancelOrder(order.id, reasonController.text);
            Get.back();
          },
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
          child: Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              (isPaid ? "Send Request" : "Confirm Cancel").tr,
              style: TextStyle(color: Colors.white),
            ),
          ),
        ),
      ],
    ),
  );
}
