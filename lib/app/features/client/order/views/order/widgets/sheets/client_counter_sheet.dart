import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/client/order/controllers/order_controller.dart';

void showClientCounterSheet(BuildContext context, OrderModel order) {
  final controller = Get.find<OrderController>();
  final priceCtrl = TextEditingController(
    text: (order.amount ?? 0).toStringAsFixed(0),
  );
  final msgCtrl = TextEditingController();
  final budgetObs = (order.amount ?? 0.0).obs;

  priceCtrl.addListener(() {
    budgetObs.value = double.tryParse(priceCtrl.text) ?? 0.0;
  });

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 24.w,
          right: 24.w,
          top: 24.h,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Counter Offer'.tr,
                style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 6.h),
              Text(
                'Propose a new budget to the provider.'.tr,
                style: TextStyle(color: Color(0xFF999999), fontSize: 14.sp),
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                autofocus: true,
                style: TextStyle(fontSize: 24.sp, fontWeight: FontWeight.bold),
                decoration: InputDecoration(
                  prefixText: r'$ ',
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              Text(
                'Message'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF999999),
                ),
              ),
              SizedBox(height: 8.h),
              TextField(
                controller: msgCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Explain your counter offer...'.tr,
                  filled: true,
                  fillColor: Color(0xFFF5F5F5),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              SizedBox(height: 28.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final price = double.tryParse(priceCtrl.text) ?? 0.0;
                    final msg = msgCtrl.text.trim();
                    if (price <= 0) {
                      Get.snackbar(
                        'Error'.tr,
                        'Enter a valid price.'.tr,
                        backgroundColor: Colors.red.shade100,
                      );
                      return;
                    }
                    if (msg.isEmpty) {
                      Get.snackbar(
                        'Error'.tr,
                        'Please enter a message.'.tr,
                        backgroundColor: Colors.red.shade100,
                      );
                      return;
                    }
                    Navigator.pop(ctx);
                    controller.sendCounterOffer(order.id, price, msg);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF6CA34D),
                    padding: EdgeInsets.symmetric(vertical: 14.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.r),
                    ),
                  ),
                  child: Text(
                    'Send Counter'.tr,
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 24.h),
            ],
          ),
        ),
      );
    },
  );
}
