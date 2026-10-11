import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/widgets/custom_appBar/custom_app_bar.dart';
import 'package:working_hiring/app/features/client/profile/controllers/profile_controller.dart';
import 'package:working_hiring/app/features/client/profile/views/client_reviews/widgets/client_reviews_review_card.dart';

class ClientReviewsView extends StatelessWidget {
  const ClientReviewsView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<ProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: 'My Reviews'.tr),
      body: RefreshIndicator(
        onRefresh: controller.loadMyReviews,
        child: LayoutBuilder(
          builder: (context, constraints) {
            return Obx(() {
              final reviews = controller.myReviews;
              if (reviews.isEmpty) {
                return ListView(
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 20.h,
                  ),
                  children: [
                    SizedBox(
                      height: constraints.maxHeight,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.star_border,
                              size: 60.sp,
                              color: Colors.grey.shade400,
                            ),
                            SizedBox(height: 16.h),
                            Text(
                              "You haven't submitted any reviews yet.".tr,
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Colors.grey.shade600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              }
              return ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
                itemCount: reviews.length,
                itemBuilder: (context, index) {
                  final r = reviews[index];
                  final provider = r['provider'] as Map<String, dynamic>? ?? {};
                  final providerName =
                      provider['company_name'] as String? ?? 'Helper';
                  final rating = (r['rating'] as num?)?.toDouble() ?? 0.0;
                  final reviewText = r['review'] as String? ?? '';
                  final createdAt = r['created_at'] as String?;
                  DateTime? date;
                  if (createdAt != null) {
                    try {
                      date = DateTime.parse(createdAt);
                    } catch (_) {}
                  }

                  return ClientReviewsReviewCard(
                    providerName: providerName,
                    rating: rating,
                    reviewText: reviewText,
                    date: date,
                  );
                },
              );
            });
          },
        ),
      ),
    );
  }
}
