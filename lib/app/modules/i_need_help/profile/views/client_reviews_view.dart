import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../controllers/profile_controller.dart';

class ClientReviewsView extends StatelessWidget {
  ClientReviewsView({super.key});

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
                // Empty state – still a scrollable ListView so RefreshIndicator works
                return ListView(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
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
              // Reviews list
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

                  return _buildReviewCard(
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

  Widget _buildReviewCard({
    required String providerName,
    required double rating,
    required String reviewText,
    DateTime? date,
  }) {
    return Container(
      margin: EdgeInsets.only(bottom: 20.h),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16.r),
        border: Border.all(color: Color(0xFFF0F0F0)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 26.r,
                  backgroundColor: Colors.grey.shade200,
                  child: Icon(Icons.person, color: Colors.grey),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    providerName,
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Divider(height: 1.h, color: Color(0xFFF0F0F0)),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: List.generate(5, (i) {
                        return Icon(
                          i < rating.floor()
                              ? Icons.star
                              : (i < rating ? Icons.star_half : Icons.star_border),
                          color: Color(0xFF6CA34D),
                          size: 18.sp,
                        );
                      }),
                    ),
                    if (date != null)
                      Text(
                        DateFormat('MMM d, yyyy').format(date),
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: Colors.grey.shade500,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                  ],
                ),
                if (reviewText.isNotEmpty) ...[
                  SizedBox(height: 12.h),
                  Text(
                    '"$reviewText"',
                    style: TextStyle(
                      fontSize: 14.sp,
                      color: Colors.grey.shade800,
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
