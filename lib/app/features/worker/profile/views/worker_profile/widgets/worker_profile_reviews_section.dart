import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/features/worker/helper_profile/controllers/helper_profile_controller.dart';
import 'package:working_hiring/app/features/worker/profile/views/worker_profile/widgets/worker_profile_helpers.dart';

class WorkerProfileReviewsSection extends StatelessWidget {
  final HelperProfileController helperController;

  const WorkerProfileReviewsSection({
    super.key,
    required this.helperController,
  });

  @override
  Widget build(BuildContext context) {
    final profile = helperController.profileData.value;
    final reviews = profile?.reviewsAndRatings ?? [];

    double avgRating = 0.0;
    if (reviews.isNotEmpty) {
      final total = reviews.fold<int>(0, (sum, r) => sum + (r.rating ?? 0));
      avgRating = total / reviews.length;
    } else {
      avgRating = profile?.rating ?? 0.0;
    }

    final ratingCounts = List.filled(5, 0);
    for (final r in reviews) {
      final s = (r.rating ?? 1).clamp(1, 5);
      ratingCounts[5 - s]++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Reviews'.tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 16.h),

        if (reviews.isEmpty)
          Container(
            padding: EdgeInsets.symmetric(vertical: 32.h),
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.rate_review_outlined,
                  size: 40.sp,
                  color: Colors.grey,
                ),
                SizedBox(height: 8.h),
                Text(
                  'No reviews yet'.tr,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text(
                  'Complete jobs to receive your first review.'.tr,
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 12.sp,
                  ),
                ),
              ],
            ),
          )
        else ...[
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              borderRadius: BorderRadius.circular(16.r),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      avgRating.toStringAsFixed(1),
                      style: TextStyle(
                        fontSize: 40.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        if (i < avgRating.floor()) {
                          return Icon(
                            Icons.star,
                            color: Colors.amber,
                            size: 14.sp,
                          );
                        } else if (i.toDouble() < avgRating) {
                          return Icon(
                            Icons.star_half,
                            color: Colors.amber,
                            size: 14.sp,
                          );
                        }
                        return Icon(
                          Icons.star_border,
                          color: Colors.amber,
                          size: 14.sp,
                        );
                      }),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      'Review Count'.trParams({'count': '${reviews.length}'}),
                      style: TextStyle(color: Colors.grey, fontSize: 12.sp),
                    ),
                  ],
                ),
                SizedBox(width: 20.w),
                Expanded(
                  child: Column(
                    children: List.generate(5, (i) {
                      final starLabel = 5 - i;
                      final count = ratingCounts[i];
                      final fraction = reviews.isNotEmpty
                          ? count / reviews.length
                          : 0.0;
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 2.h),
                        child: Row(
                          children: [
                            Text(
                              '$starLabel',
                              style: TextStyle(
                                fontSize: 11.sp,
                                color: Colors.grey,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            Icon(Icons.star, color: Colors.amber, size: 11.sp),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: LinearProgressIndicator(
                                  value: fraction,
                                  minHeight: 6.h,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                    Color(0xFF6CA34D),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            SizedBox(
                              width: 20.w,
                              child: Text(
                                '$count',
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey,
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

          SizedBox(height: 16.h),

          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (_, _) =>
                Divider(color: Colors.grey.shade200, height: 24.h),
            itemBuilder: (context, index) {
              final review = reviews[index];
              final stars = (review.rating ?? 5).clamp(1, 5);
              final reviewerName =
                  '${review.customer?.firstName ?? ''} ${review.customer?.lastName ?? ''}'
                      .trim();
              final photoUrl = review.customer?.photo;
              final date = review.createdAt != null
                  ? formatDate(review.createdAt!)
                  : '';

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 18.r,
                        backgroundColor: Colors.grey.shade200,
                        backgroundImage: photoUrl != null
                            ? NetworkImage(photoUrl)
                            : null,
                        child: photoUrl == null
                            ? Text(
                                reviewerName.isNotEmpty
                                    ? reviewerName[0].toUpperCase()
                                    : 'A',
                                style: TextStyle(
                                  fontSize: 14.sp,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey.shade600,
                                ),
                              )
                            : null,
                      ),
                      SizedBox(width: 10.w),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              reviewerName.isEmpty ? 'Anonymous' : reviewerName,
                              style: TextStyle(
                                fontSize: 13.sp,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            if (date.isNotEmpty)
                              Text(
                                date,
                                style: TextStyle(
                                  fontSize: 11.sp,
                                  color: Colors.grey,
                                ),
                              ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8.h),
                  Row(
                    children: List.generate(
                      5,
                      (i) => Icon(
                        i < stars ? Icons.star : Icons.star_border,
                        color: Colors.amber,
                        size: 16.sp,
                      ),
                    ),
                  ),
                  SizedBox(height: 6.h),
                  Text(
                    review.review?.isNotEmpty == true
                        ? review.review!
                        : 'No comment provided.',
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Colors.black87,
                      height: 1.5,
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }
}
