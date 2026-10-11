import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/data/models/order_model.dart';
import 'package:working_hiring/app/features/worker/my_job/controllers/my_job_controller.dart';

void showCancelJobDialog(BuildContext context, OrderModel job) {
  final controller = Get.find<MyJobController>();
  final reasonCtrl = TextEditingController();
  final isAgreed = false.obs;
  final isPaid = (job.paymentStatus ?? '').toUpperCase() == 'PAID';

  Get.dialog(
    Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20.r)),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 24.h),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                (isPaid ? 'Request Cancellation' : 'Cancel Job').tr,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: Colors.redAccent,
                ),
              ),
              SizedBox(height: 10.h),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.warning_amber_rounded,
                    color: Colors.redAccent,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(
                    child: Text(
                      isPaid
                          ? 'The customer must approve this cancellation request.'
                          : 'This cancellation will result in 1 strike.',
                      style: TextStyle(
                        fontSize: 14.sp,
                        color: Colors.redAccent,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 13.h),
              Text(
                isPaid
                    ? 'The order will remain active until the customer accepts your request.'
                    : 'Are you sure you want to cancel this job? Frequent cancellations may affect your profile rating.',
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
              SizedBox(height: 20.h),
              TextField(
                controller: reasonCtrl,
                maxLines: 4,
                decoration: InputDecoration(
                  hintText: 'Please write your reason here...'.tr,
                  hintStyle: TextStyle(color: Colors.grey, fontSize: 14.sp),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12.r),
                    borderSide: BorderSide(color: Colors.redAccent, width: 1.5),
                  ),
                ),
              ),
              SizedBox(height: 16.h),
              if (!isPaid)
                Obx(
                  () => Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 24.h,
                        width: 24.w,
                        child: Checkbox(
                          value: isAgreed.value,
                          activeColor: Colors.redAccent,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.r),
                          ),
                          onChanged: (v) => isAgreed.value = v ?? false,
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Expanded(
                        child: Text(
                          'I acknowledge that canceling this job will result in 1 strike.'
                              .tr,
                          style: TextStyle(
                            fontSize: 14.sp,
                            color: AppColors.textSecondary,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SizedBox(height: 24.h),
              Row(
                children: [
                  Expanded(
                    child: TextButton(
                      onPressed: () => Get.back(),
                      child: Text(
                        'Cancel'.tr,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (reasonCtrl.text.trim().isEmpty) {
                          Get.snackbar(
                            'Error'.tr,
                            'Please provide a reason'.tr,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        if (!isPaid && !isAgreed.value) {
                          Get.snackbar(
                            'Error'.tr,
                            'Please check the acknowledgment box'.tr,
                            backgroundColor: Colors.redAccent,
                            colorText: Colors.white,
                            snackPosition: SnackPosition.BOTTOM,
                          );
                          return;
                        }
                        controller.cancelJob(job.id, reasonCtrl.text);
                        Get.back();
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12.r),
                        ),
                        elevation: 0,
                        padding: EdgeInsets.symmetric(vertical: 12.h),
                      ),
                      child: Text(
                        'OK'.tr,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
