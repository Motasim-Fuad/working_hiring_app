import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/worker/helper_profile/controllers/helper_profile_controller.dart';

class WorkerProfilePricingSection extends StatelessWidget {
  final HelperProfileController helperController;

  const WorkerProfilePricingSection({
    super.key,
    required this.helperController,
  });

  @override
  Widget build(BuildContext context) {
    final profile = helperController.profileData.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Pricing Details'.tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Column(
                      children: [
                        Icon(
                          Icons.account_balance_wallet_outlined,
                          color: Color(0xFF6CA34D),
                          size: 24.sp,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Hourly Rate'.tr,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          profile?.hourlyRate != null
                              ? 'Rate Per Hour'.trParams({
                                  'amount': '\$${profile!.hourlyRate!}',
                                })
                              : 'Rate Per Hour'.trParams({'amount': '\$0.00'}),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                  width: 1,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Column(
                      children: [
                        Icon(
                          Icons.access_time,
                          color: Color(0xFF6CA34D),
                          size: 24.sp,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Min. Booking'.tr,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          'Hours Count'.trParams({
                            'count': profile?.minBookingHours ?? "1",
                          }),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(
                  color: Colors.grey.shade300,
                  thickness: 1,
                  width: 1,
                ),
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Column(
                      children: [
                        Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF6CA34D),
                          size: 24.sp,
                        ),
                        SizedBox(height: 8.h),
                        Text(
                          'Complete Rate'.tr,
                          style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '${(profile?.completeRate ?? 0.0).toStringAsFixed(0)}%',
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
