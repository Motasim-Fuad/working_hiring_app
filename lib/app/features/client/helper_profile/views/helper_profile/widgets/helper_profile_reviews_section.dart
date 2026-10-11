import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/helper_profile/controllers/helper_profile_controller.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/widgets/helper_profile_review_card.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/widgets/helper_profile_stars.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/widgets/helper_profile_helpers.dart';

class HelperProfileReviewsSection extends GetView<HelperDetailController> {
  const HelperProfileReviewsSection({super.key});

  @override
  Widget build(BuildContext context) {
    final reviews = controller.customerReviews;

    if (reviews.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Customer Reviews".tr,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.h),
          Row(
            children: [
              Icon(Icons.star_border, color: Colors.amber, size: 18.sp),
              SizedBox(width: 6.w),
              Text(
                "No customer reviews yet".tr,
                style: TextStyle(fontSize: 14.sp, color: Colors.grey.shade600),
              ),
            ],
          ),
        ],
      );
    }

    final avg = controller.rating;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Customer Reviews".tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),
        Container(
          padding: EdgeInsets.all(18.w),
          decoration: BoxDecoration(
            color: Color(0xFFFAFAFA),
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              SizedBox(
                width: 86.w,
                child: Column(
                  children: [
                    Text(
                      avg.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 36.sp,
                        fontWeight: FontWeight.w800,
                        color: Colors.black87,
                        height: 1,
                      ),
                    ),
                    SizedBox(height: 8.h),
                    HelperProfileStars(rating: avg, size: 15.sp),
                    SizedBox(height: 6.h),
                    Text(
                      'Reviews Count'.trParams({'count': '${reviews.length}'}),
                      style: TextStyle(
                        fontSize: 11.sp,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 16.w),
              Container(width: 1, height: 96.h, color: Colors.grey.shade300),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  children: List.generate(5, (index) {
                    final star = 5 - index;
                    final count = reviews
                        .where(
                          (review) =>
                              (reviewRating(review) ?? 0).round() == star,
                        )
                        .length;
                    return Padding(
                      padding: EdgeInsets.symmetric(vertical: 2.h),
                      child: Row(
                        children: [
                          Text(
                            "$star",
                            style: TextStyle(
                              fontSize: 11.sp,
                              color: Colors.grey.shade700,
                            ),
                          ),
                          SizedBox(width: 3.w),
                          Icon(
                            Icons.star_rounded,
                            size: 12.sp,
                            color: Colors.amber.shade700,
                          ),
                          SizedBox(width: 7.w),
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20.r),
                              child: LinearProgressIndicator(
                                minHeight: 6.h,
                                value: count / reviews.length,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.amber.shade600,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(width: 7.w),
                          SizedBox(
                            width: 18.w,
                            child: Text(
                              "$count",
                              textAlign: TextAlign.right,
                              style: TextStyle(
                                fontSize: 10.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ),
              ),
            ],
          ),
        ),
        SizedBox(height: 18.h),
        ...reviews.asMap().entries.map(
          (entry) => Padding(
            padding: EdgeInsets.only(
              bottom: entry.key == reviews.length - 1 ? 0 : 12.h,
            ),
            child: HelperProfileReviewCard(review: entry.value),
          ),
        ),
      ],
    );
  }
}
