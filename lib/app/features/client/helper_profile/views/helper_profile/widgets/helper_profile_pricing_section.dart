import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/helper_profile/controllers/helper_profile_controller.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/widgets/helper_profile_price_item.dart';

class HelperProfilePricingSection extends GetView<HelperDetailController> {
  const HelperProfilePricingSection({super.key});

  @override
  Widget build(BuildContext context) {
    final helper = controller.helper;
    final rate = helper?.hourlyRate;
    final minHours = helper?.minBookingHours;
    final rateText = (rate != null && rate > 0)
        ? 'Rate Per Hour'.trParams({'amount': '\$${rate.toStringAsFixed(0)}'})
        : "—";
    final minText = (minHours != null && minHours > 0)
        ? 'Hours Count'.trParams({
            'count': minHours.toStringAsFixed(
              minHours.truncateToDouble() == minHours ? 0 : 1,
            ),
          })
        : "—";
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Pricing Details".tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
          decoration: BoxDecoration(
            color: Color(0xFFF9F9F9),
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              HelperProfilePriceItem(
                title: "Hourly Rate",
                value: rateText,
                icon: Icons.payments_outlined,
              ),
              Container(width: 1.w, height: 40.h, color: Colors.grey.shade300),
              HelperProfilePriceItem(
                title: "Min. Booking",
                value: minText,
                icon: Icons.timer_outlined,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
