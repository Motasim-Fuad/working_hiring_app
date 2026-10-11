import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/widgets/helper_profile_stars.dart';
import 'package:working_hiring/app/features/client/helper_profile/views/helper_profile/widgets/helper_profile_helpers.dart';

class HelperProfileReviewCard extends StatelessWidget {
  final dynamic review;

  const HelperProfileReviewCard({super.key, required this.review});

  @override
  Widget build(BuildContext context) {
    final customer = review is Map && review['customer'] is Map
        ? review['customer'] as Map
        : const {};
    final firstName = customer['first_name']?.toString().trim() ?? '';
    final lastName = customer['last_name']?.toString().trim() ?? '';
    final fallbackName =
        customer['full_name']?.toString().trim() ??
        customer['username']?.toString().trim() ??
        '';
    final joinedName = "$firstName $lastName".trim();
    final reviewerName = joinedName.isNotEmpty
        ? joinedName
        : (fallbackName.isNotEmpty ? fallbackName : "Customer");
    final photo = customer['photo']?.toString();
    final text = reviewText(review);
    final rating = reviewRating(review) ?? 0;
    final date = reviewDate(review);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 20.r,
                backgroundColor: Color(0xFF6CA34D).withValues(alpha: 0.12),
                backgroundImage: photo != null && photo.isNotEmpty
                    ? NetworkImage(photo)
                    : null,
                child: photo == null || photo.isEmpty
                    ? Text(
                        reviewerName.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontSize: 15.sp,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFF6CA34D),
                        ),
                      )
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      reviewerName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(height: 4.h),
                    Row(
                      children: [
                        HelperProfileStars(rating: rating, size: 14.sp),
                        if (date.isNotEmpty) ...[
                          SizedBox(width: 8.w),
                          Flexible(
                            child: Text(
                              date,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey.shade500,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          Text(
            text.isNotEmpty ? text : "No written feedback.".tr,
            style: TextStyle(
              fontSize: 13.sp,
              color: Colors.grey.shade800,
              height: 1.5,
            ),
          ),
          SizedBox(height: 12.h),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.verified_outlined,
                size: 14.sp,
                color: Color(0xFF6CA34D),
              ),
              SizedBox(width: 5.w),
              Text(
                "Verified booking".tr,
                style: TextStyle(
                  fontSize: 11.sp,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6CA34D),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
