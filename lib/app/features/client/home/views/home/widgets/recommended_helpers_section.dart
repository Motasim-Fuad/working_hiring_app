import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/home/controllers/home_controller.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/custom_offer_view.dart';
import 'package:working_hiring/app/features/client/home/views/home/widgets/shimmer/recommended_helpers_shimmer.dart';

class RecommendedHelpersSection extends GetView<HomeController> {
  const RecommendedHelpersSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 10.h),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Recommended Helpers".tr,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 15.h),
          Obx(() {
            if (controller.isLoadingHelpers.value) {
              return const RecommendedHelpersShimmer();
            }
            if (controller.recommendedHelpers.isEmpty) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 12.h),
                child: Text(
                  "No recommendations yet".tr,
                  style: TextStyle(color: Colors.grey),
                ),
              );
            }
            return ListView.separated(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: controller.recommendedHelpers.length,
              separatorBuilder: (context, index) => SizedBox(height: 10.h),
              itemBuilder: (context, index) {
                final helper = controller.recommendedHelpers[index];
                final double score =
                    ((helper.rating ?? 0) * 0.4) +
                    (((helper.totalTasks ?? 0) > 20 ? 4.0 : 2.5) * 0.3) +
                    (((helper.distance ?? 10) < 5 ? 4.0 : 2.5) * 0.3);

                return GestureDetector(
                  onTap: () {
                    Get.to(
                      () => CreateCustomOfferView(),
                      arguments: {
                        'workerID': helper.id.toString(),
                        'workerName': helper.companyName ?? 'Helper',
                        'workerAvatar': helper.avatarUrl,
                        'categoryID': '',
                      },
                    );
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 12.w,
                      vertical: 12.h,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: Colors.grey.shade200),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          backgroundColor: Color(
                            0xFF6CA34D,
                          ).withValues(alpha: 0.2),
                          child: Text(
                            (helper.companyName ?? '?')[0],
                            style: TextStyle(
                              color: Color(0xFF6CA34D),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 15.w),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                helper.companyName ?? 'Helper',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16.sp,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    size: 14.sp,
                                    color: Colors.amber,
                                  ),
                                  SizedBox(width: 4.w),
                                  Text(
                                    'Rating Smart Score'.trParams({
                                      'rating': (helper.rating ?? 0)
                                          .toStringAsFixed(1),
                                      'score': score.toStringAsFixed(2),
                                    }),
                                    style: TextStyle(
                                      fontSize: 12.sp,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right, color: Colors.grey),
                      ],
                    ),
                  ),
                );
              },
            );
          }),
        ],
      ),
    );
  }
}
