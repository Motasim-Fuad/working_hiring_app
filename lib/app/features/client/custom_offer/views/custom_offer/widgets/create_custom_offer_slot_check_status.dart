import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/custom_offer/controllers/custom_offer_controller.dart';

class CreateCustomOfferSlotCheckStatus extends StatelessWidget {
  final CustomOfferController fieldController;

  const CreateCustomOfferSlotCheckStatus({
    super.key,
    required this.fieldController,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (fieldController.isCheckingSlot.value) {
        return Padding(
          padding: EdgeInsets.only(top: 8.h),
          child: Row(
            children: [
              SizedBox(
                width: 14.sp,
                height: 14.sp,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              SizedBox(width: 8.w),
              Text(
                "Checking availability…".tr,
                style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        );
      }
      final check = fieldController.slotCheck.value;
      if (check == null) return SizedBox.shrink();

      if (check.isAvailable) {
        return Container(
          margin: EdgeInsets.only(top: 8.h),
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
          decoration: BoxDecoration(
            color: Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(10.r),
          ),
          child: Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF2E7D32), size: 18.sp),
              SizedBox(width: 8.w),
              Expanded(
                child: Text(
                  check.slot != null && check.slot!.isNotEmpty
                      ? "Available Slot".trParams({'slot': check.slot!})
                      : (check.message.isNotEmpty
                            ? check.message
                            : "Slot available".tr),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Color(0xFF2E7D32),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      }

      return Container(
        margin: EdgeInsets.only(top: 8.h),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 10.h),
        decoration: BoxDecoration(
          color: Colors.red.shade50,
          borderRadius: BorderRadius.circular(10.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.error_outline,
                  color: Colors.red.shade600,
                  size: 18.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: Text(
                    check.message.isNotEmpty
                        ? check.message
                        : "Not available for these hours".tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.red.shade700,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            if (check.alternatives.isNotEmpty) ...[
              SizedBox(height: 8.h),
              Text(
                "Available start times:".tr,
                style: TextStyle(fontSize: 11.sp, color: Colors.grey.shade700),
              ),
              SizedBox(height: 6.h),
              Wrap(
                spacing: 8.w,
                runSpacing: 8.h,
                children: check.alternatives
                    .map(
                      (s) => GestureDetector(
                        onTap: () => fieldController.selectSlot(s),
                        child: Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 10.w,
                            vertical: 6.h,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8.r),
                            border: Border.all(color: Color(0xFF6CA34D)),
                          ),
                          child: Text(
                            s.slot,
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Color(0xFF6CA34D),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ],
          ],
        ),
      );
    });
  }
}
