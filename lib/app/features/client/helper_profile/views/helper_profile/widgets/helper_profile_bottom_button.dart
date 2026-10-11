import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/custom_offer_view.dart';
import 'package:working_hiring/app/features/client/helper_profile/controllers/helper_profile_controller.dart';

class HelperProfileBottomButton extends GetView<HelperDetailController> {
  const HelperProfileBottomButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: ElevatedButton(
          onPressed: () {
            final h = controller.helper;
            if (h == null) return;
            Get.to(
              () => CreateCustomOfferView(),
              arguments: {
                'workerID': h.id.toString(),
                'workerName': h.companyName ?? 'Helper',
                'workerAvatar': h.photo ?? '',
                'categoryID': h.categories?.isNotEmpty == true
                    ? h.categories!.first
                    : '',
                'minBookingHours': h.minBookingHours ?? 1,
                'hourlyRate': h.hourlyRate ?? 0,
              },
            );
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFF6CA34D),
            minimumSize: Size(double.infinity, 56.h),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            elevation: 0,
          ),
          child: Text(
            "Request This Helper".tr,
            style: TextStyle(
              fontSize: 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
}
