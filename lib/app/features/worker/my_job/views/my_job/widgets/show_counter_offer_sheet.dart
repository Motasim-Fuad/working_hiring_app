import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/worker/my_job/controllers/my_job_controller.dart';

void showCounterOfferSheet(BuildContext context, OrderModel job) {
  final controller = Get.find<MyJobController>();
  final priceCtrl = TextEditingController(
    text: (job.amount ?? 0).toStringAsFixed(0),
  );
  final msgCtrl = TextEditingController();
  final budgetObs = (job.amount ?? 0.0).obs;

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
                'Propose a different budget to the client.'.tr,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14.sp,
                ),
              ),
              SizedBox(height: 24.h),
              TextField(
                controller: priceCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                textInputAction: TextInputAction.done,
                onEditingComplete: () =>
                    FocusManager.instance.primaryFocus?.unfocus(),
                onTapOutside: (_) =>
                    FocusManager.instance.primaryFocus?.unfocus(),
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
              SizedBox(height: 12.h),
              Obx(() {
                final fee = budgetObs.value * 0.20;
                final net = budgetObs.value - fee;
                return Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Platform Fee (20%):'.tr,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13.sp,
                          ),
                        ),
                        Text(
                          '-\$${fee.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 13.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8.h),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Net Amount:'.tr,
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 14.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '\$${net.toStringAsFixed(2)}',
                          style: TextStyle(
                            color: AppColors.primary,
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                );
              }),
              SizedBox(height: 20.h),
              Text(
                'Message'.tr,
                style: TextStyle(
                  fontSize: 14.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
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
                    Get.back();
                    controller.sendCounterOffer(job.id, price, msg);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
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
