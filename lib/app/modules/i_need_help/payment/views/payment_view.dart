import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../../core/constants/app_images.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../core/widgets/contextual_warning_banner.dart';
import '../../../../data/models/order_model.dart';
import '../../../../data/repositories/order_repository.dart';
import '../../../../service/api_service.dart';
import '../../../i_need_help/order/controllers/order_controller.dart';
import 'payment_success_view.dart';

class PaymentView extends StatelessWidget {
  PaymentView({super.key});

  @override
  Widget build(BuildContext context) {
    final dynamic args = Get.arguments;

    // ── Parse arguments ───────────────────────────────────────────────────
    String amount = r'$0';
    int? orderId;
    bool cameFromChat = false;

    if (args != null) {
      if (args is OrderModel) {
        orderId = args.id;
        amount = '\$${(args.amount ?? 0).toStringAsFixed(0)}';
      } else if (args is Map && args.containsKey('message')) {
        // Called from chat view — it handles payment itself
        cameFromChat = true;
        final msg = args['message'];
        final total = (msg?.proposedBudget ?? msg?.budget ?? 0.0) as double;
        amount = '\$${total.toStringAsFixed(2)}';
        orderId = msg?.orderId as int?;
      }
    }

    final isLoading = false.obs;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(icons: Icons.close, title: AppStrings.pay.tr),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
          width: double.infinity,
          child: Obx(() => ElevatedButton(
            onPressed: isLoading.value
                ? null
                : () async {
              if (orderId == null) {
                Get.snackbar('Error'.tr, 'Order information missing.'.tr);
                return;
              }

              isLoading.value = true;
              try {
                // ✅ Actually call the payAndConfirm API
                final repo = Get.find<OrderRepository>();
                await repo.payAndConfirm(orderId!);

                // ✅ Refresh order list so status updates immediately
                if (Get.isRegistered<OrderController>()) {
                  Get.find<OrderController>().loadOrders();
                }

                isLoading.value = false;

                if (cameFromChat) {
                  final result = await Get.to(
                        () => PaymentSuccessView(
                        cameFromChat: true),
                  );
                  if (result == true) {
                    Get.back(result: true);
                  }
                } else {
                  // Go to success screen, then pop back to orders
                  await Get.to(() => PaymentSuccessView());
                  // Pop PaymentView itself so user lands on Order list
                  Get.back(result: true);
                }
              } on ApiException catch (e) {
                isLoading.value = false;
                Get.snackbar('Payment Error', e.message,
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red.shade900);
              } catch (_) {
                isLoading.value = false;
                Get.snackbar('Error'.tr, 'Payment failed. Please try again.'.tr,
                    backgroundColor: Colors.red.shade100,
                    colorText: Colors.red.shade900);
              }
            },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 16.h),
              backgroundColor: Color(0xFF6CA34D),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.r),
              ),
              elevation: 0,
            ),
            child: isLoading.value
                ? SizedBox(
              height: 20.h,
              width: 20.h,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : Text(
              '${AppStrings.pay.tr} $amount',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
              ),
            ),
          )),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            ContextualWarningBanner(message: AppStrings.paymentBanner.tr),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    AppStrings.enterAmount.tr,
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: Colors.black,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  SizedBox(height: 8.h),
                  Text(
                    amount,
                    style: TextStyle(
                      fontSize: 56.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 60.h),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      AppStrings.paymentMethod.tr,
                      style: TextStyle(
                        fontSize: 18.sp,
                        color: Colors.black,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 16.w,
                      vertical: 16.h,
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Color(0xFFE5E5E5)),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        SvgPicture.asset(AppImages.visa, height: 20.h),
                        SizedBox(width: 12.w),
                        Expanded(
                          child: Text(
                            'Visa ending in 9380'.tr,
                            style: TextStyle(
                              fontSize: 16.sp,
                              color: Colors.black87,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        Text(
                          AppStrings.change.tr,
                          style: TextStyle(
                            color: Color(0xFF6CA34D),
                            fontSize: 16.sp,
                            fontWeight: FontWeight.w600,
                            decoration: TextDecoration.underline,
                            decorationColor: Color(0xFF6CA34D),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}