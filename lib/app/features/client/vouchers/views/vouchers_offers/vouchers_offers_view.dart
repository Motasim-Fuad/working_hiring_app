import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/vouchers/controllers/vouchers_offers_controller.dart';
import 'package:working_hiring/app/features/client/vouchers/views/vouchers_offers/widgets/voucher_card.dart';
import 'package:working_hiring/app/features/client/vouchers/views/vouchers_offers/widgets/vouchers_offers_top_card.dart';
import 'package:working_hiring/app/features/client/vouchers/views/vouchers_offers/widgets/show_add_voucher_bottom_sheet.dart';

class VouchersOffersView extends GetView<VouchersOffersController> {
  const VouchersOffersView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Get.back(),
        ),
        title: Text(
          'Vouchers & offers'.tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          SizedBox(height: 16.h),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w),
            child: Row(
              children: [
                Expanded(
                  child: VouchersOffersTopCard(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Obx(
                          () => Text(
                            'Tk ${controller.totalSaved.value.toInt()}',
                            style: TextStyle(
                              fontSize: 20.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Saved this month'.tr,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: InkWell(
                    onTap: () => showAddVoucherBottomSheet(context),
                    child: VouchersOffersTopCard(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.confirmation_num_outlined,
                            color: Colors.black54,
                          ),
                          SizedBox(width: 8.w),
                          Text(
                            'Add a Voucher'.tr,
                            style: TextStyle(
                              fontSize: 14.sp,
                              fontWeight: FontWeight.bold,
                              color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: 16.h),

          Expanded(
            child: Obx(
              () => ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
                itemCount: controller.allVouchers.length,
                itemBuilder: (context, index) {
                  return VoucherCard(voucher: controller.allVouchers[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
