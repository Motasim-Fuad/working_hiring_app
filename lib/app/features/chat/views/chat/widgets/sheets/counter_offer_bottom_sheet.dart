import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/chat/controllers/message_controller.dart';

void showCounterOfferBottomSheet(
  BuildContext context,
  MessageModel msg,
  MessageController controller,
  ChatModel chat,
  String currentRole,
) {
  final priceController = TextEditingController();
  final messageController = TextEditingController();
  final budgetAmount = 0.0.obs;

  if (msg.proposedBudget != null) {
    priceController.text = msg.proposedBudget!.toStringAsFixed(0);
    budgetAmount.value = msg.proposedBudget!;
  } else if (msg.budget != null) {
    priceController.text = msg.budget!.toStringAsFixed(0);
    budgetAmount.value = msg.budget!;
  }

  priceController.addListener(() {
    budgetAmount.value = double.tryParse(priceController.text) ?? 0.0;
  });

  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) {
      return Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
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
                  "Enter Counteroffer".tr,
                  style: TextStyle(
                    fontSize: 18.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8.h),
                Text(
                  "Propose a new budget to the other party.".tr,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14.sp,
                  ),
                ),
                SizedBox(height: 24.h),
                TextField(
                  controller: priceController,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  textInputAction: TextInputAction.done,
                  onEditingComplete: () =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  onTapOutside: (_) =>
                      FocusManager.instance.primaryFocus?.unfocus(),
                  autofocus: true,
                  style: TextStyle(
                    fontSize: 24.sp,
                    fontWeight: FontWeight.bold,
                  ),
                  decoration: InputDecoration(
                    prefixText: r"$ ",
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 16.h),
                Obx(() {
                  final fee = budgetAmount.value * 0.20;
                  final net = budgetAmount.value - fee;
                  return Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            "Platform Fee (20%):".tr,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 13.sp,
                            ),
                          ),
                          Text(
                            "-\$${fee.toStringAsFixed(2)}",
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
                            "Net Amount:".tr,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            "\$${net.toStringAsFixed(2)}",
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
                SizedBox(height: 24.h),
                Text(
                  "Message / Description".tr,
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textSecondary,
                  ),
                ),
                SizedBox(height: 8.h),
                TextField(
                  controller: messageController,
                  maxLines: 4,
                  decoration: InputDecoration(
                    hintText: "Enter details about your proposal...".tr,
                    filled: true,
                    fillColor: Color(0xFFF5F5F5),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12.r),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
                SizedBox(height: 32.h),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () async {
                      final price =
                          double.tryParse(priceController.text) ?? 0.0;
                      final message = messageController.text.trim();
                      if (price > 0 && message.isNotEmpty) {
                        final success = await controller.sendCounterOffer(
                          chat,
                          msg,
                          price,
                          currentRole,
                          message,
                        );
                        if (success) {
                          if (ctx.mounted) Navigator.of(ctx).pop();
                        }
                      } else {
                        Get.snackbar(
                          "Error".tr,
                          "Please enter a valid price and a message.".tr,
                          backgroundColor: Colors.red.shade100,
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                    ),
                    child: Text(
                      "Send Counter".tr,
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16.sp,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}
