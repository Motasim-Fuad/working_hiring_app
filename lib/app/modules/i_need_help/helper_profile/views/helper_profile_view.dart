import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../data/models/availability_model.dart';
import '../../../../data/repositories/availability_repository.dart';
import '../../../../service/api_service.dart';
import '../../custom_offer/views/custom_offer_view.dart';
import '../controllers/helper_profile_controller.dart';

class HelperProfileView extends GetView<HelperDetailController> {
  HelperProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    // Make sure the availability repo exists (controller resolves it lazily).
    if (!Get.isRegistered<AvailabilityRepository>()) {
      Get.put(AvailabilityRepository(Get.find<ApiClient>()));
    }
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: "Helper Profile".tr,
      ),
      body: Obx(() {
        if (controller.isLoading.value && controller.helper == null) {
          return Center(child: CircularProgressIndicator(color: Color(0xFF6CA34D)));
        }
        if (controller.helper == null) {
          return Center(
            child: Text("Could not load helper.".tr, style: TextStyle(fontSize: 14.sp, color: Colors.grey)),
          );
        }
        return RefreshIndicator(
          color: Color(0xFF6CA34D),
          onRefresh: controller.refreshProfile,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 20.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(),
                SizedBox(height: 32.h),
                _buildBioSection(),
                SizedBox(height: 32.h),
                _buildPricingSection(),
                SizedBox(height: 32.h),
                _buildAvailabilitySection(),
                SizedBox(height: 32.h),
                _buildSkillsSection(),
                SizedBox(height: 32.h),
                _buildReviewsSection(),
                SizedBox(height: 40.h),
              ],
            ),
          ),
        );
      }),
      bottomNavigationBar: _buildBottomButton(),
    );
  }

  Widget _buildProfileHeader() {
    final helper = controller.helper;
    if (helper == null) return SizedBox.shrink();
    final photoUrl = helper.photo;
    return Center(
      child: Column(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 4.h),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFF6CA34D).withOpacity(0.3), width: 2),
            ),
            child: CircleAvatar(
              radius: 44.r,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: (photoUrl == null || photoUrl.isEmpty)
                  ? Icon(Icons.person, size: 44.sp, color: Colors.grey)
                  : null,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            helper.companyName ?? 'Helper',
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          if (helper.isVerified == true) ...[
            SizedBox(height: 6.h),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: Color(0xFF6CA34D).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12.r),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.verified, size: 16.sp, color: Color(0xFF6CA34D)),
                  SizedBox(width: 4.w),
                  Text(
                    'Verified'.tr,
                    style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6CA34D),
                    ),
                  ),
                ],
              ),
            ),
          ],
          SizedBox(height: 8.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.location_on, color: Colors.redAccent, size: 16.sp),
              SizedBox(width: 4.w),
              Flexible(
                child: Text(
                      'Location Distance Away'.trParams({
                        'location': helper.location ?? 'San Francisco',
                        'distance':
                            (helper.distance ?? 0).toStringAsFixed(1),
                      }),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                  ),
                ),
              ),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildBioSection() {
    final helper = controller.helper;
    if (helper == null) return SizedBox.shrink();
    final bio = helper.bio;
    if (bio == null || bio.trim().isEmpty) return SizedBox.shrink();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "About".tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Text(
          bio,
          style: TextStyle(
            fontSize: 14.sp,
            color: Colors.grey.shade700,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    final helper = controller.helper;
    final rate = helper?.hourlyRate;
    final minHours = helper?.minBookingHours;
    final rateText = (rate != null && rate > 0)
        ? 'Rate Per Hour'.trParams({
            'amount': '\$${rate.toStringAsFixed(0)}',
          })
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
              _buildPriceItem("Hourly Rate", rateText, Icons.payments_outlined),
              Container(width: 1.w, height: 40.h, color: Colors.grey.shade300),
              _buildPriceItem("Min. Booking", minText, Icons.timer_outlined),
            ],
          ),
        )
      ],
    );
  }

  Widget _buildPriceItem(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Color(0xFF6CA34D), size: 24.sp),
        SizedBox(height: 8.h),
        Text(title.tr, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade600)),
        SizedBox(height: 4.h),
        Text(value, style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold, color: Colors.black87)),
      ],
    );
  }

  // ── Availability: real slots from the API for the chosen day ──
  Widget _buildAvailabilitySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Availability".tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 14.h),

        // Day selector — chips for today + next 6 days (no dropdown).
        SizedBox(
          height: 64.h,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: controller.availabilityDays.length,
            separatorBuilder: (_, __) => SizedBox(width: 10.w),
            itemBuilder: (_, i) {
              final day = controller.availabilityDays[i];
              return Obx(() {
                final selected = controller.isSameDay(controller.selectedDay.value, day);
                final isToday = controller.isSameDay(DateTime.now(), day);
                return GestureDetector(
                  onTap: () => controller.loadAvailability(day),
                  child: Container(
                    width: 52.w,
                    decoration: BoxDecoration(
                      color: selected ? Color(0xFF6CA34D) : Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(
                        color: selected ? Color(0xFF6CA34D) : Colors.grey.shade300,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          isToday
                              ? "Today".tr
                              : DateFormat('EEE').format(day).tr,
                          style: TextStyle(
                            fontSize: 11.sp,
                            fontWeight: FontWeight.w600,
                            color: selected ? Colors.white : Colors.grey.shade600,
                          ),
                        ),
                        SizedBox(height: 2.h),
                        Text(
                          DateFormat('d').format(day),
                          style: TextStyle(
                            fontSize: 16.sp,
                            fontWeight: FontWeight.bold,
                            color: selected ? Colors.white : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              });
            },
          ),
        ),
        SizedBox(height: 16.h),

        // Slots for the selected day.
        Obx(() {
          if (controller.isLoadingSlots.value) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 12.h),
              child: Center(child: CircularProgressIndicator(color: Color(0xFF6CA34D), strokeWidth: 2)),
            );
          }
          final slots = controller.daySlots;
          if (slots.isEmpty) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 8.h),
              child: Text(
                "No slots for this day.".tr,
                style: TextStyle(fontSize: 13.sp, color: Colors.grey.shade600),
              ),
            );
          }
          return Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: slots.map(_buildSlotChip).toList(),
          );
        }),
        SizedBox(height: 16.h),

        // Legend.
        Row(
          children: [
            _buildLegendItem(Color(0xFF6CA34D), "Available"),
            SizedBox(width: 16.w),
            _buildLegendItem(Colors.red.shade400, "Booked"),
            SizedBox(width: 16.w),
            _buildLegendItem(Colors.grey.shade400, "Unavailable"),
          ],
        ),
      ],
    );
  }

  Widget _buildSlotChip(DateSlot slot) {
    final status = slot.status.toUpperCase();
    Color bg;
    Color fg;
    if (status == 'AVAILABLE') {
      bg = Color(0xFFE8F5E9);
      fg = Color(0xFF2E7D32);
    } else if (status == 'BOOKED') {
      bg = Colors.red.shade50;
      fg = Colors.red.shade400;
    } else {
      bg = Colors.grey.shade100;
      fg = Colors.grey.shade500;
    }
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10.r),
        border: Border.all(color: fg.withOpacity(0.3)),
      ),
      child: Text(
        slot.slot,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600, color: fg),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(
          width: 10.w,
          height: 10.h,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        SizedBox(width: 6.w),
        Text(label.tr, style: TextStyle(fontSize: 12.sp, color: Colors.grey.shade700, fontWeight: FontWeight.w500)),
      ],
    );
  }

  Widget _buildSkillsSection() {
    final helper = controller.helper;
    if (helper == null || helper.categories == null || helper.categories!.isEmpty) {
      return SizedBox.shrink();
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Skills".tr,
          style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
        ),
        SizedBox(height: 12.h),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: helper.categories!.map((skill) {
            return Container(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20.r),
                border: Border.all(color: Color(0xFF6CA34D).withOpacity(0.5)),
              ),
              child: Text(
                skill,
                style: TextStyle(fontSize: 13.sp, color: Color(0xFF6CA34D), fontWeight: FontWeight.w600),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildReviewsSection() {
    final reviews = controller.customerReviews;

    if (reviews.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Customer Reviews".tr, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
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
        Text("Customer Reviews".tr, style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
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
                    _buildStars(avg, 15.sp),
                    SizedBox(height: 6.h),
                    Text(
                      'Reviews Count'.trParams({
                        'count': '${reviews.length}',
                      }),
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
                      (_reviewRating(review) ?? 0).round() == star,
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
            child: _buildReviewCard(entry.value),
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(dynamic review) {
    final customer = review is Map && review['customer'] is Map
        ? review['customer'] as Map
        : const {};
    final firstName = customer['first_name']?.toString().trim() ?? '';
    final lastName = customer['last_name']?.toString().trim() ?? '';
    final fallbackName = customer['full_name']?.toString().trim() ??
        customer['username']?.toString().trim() ??
        '';
    final joinedName = "$firstName $lastName".trim();
    final reviewerName = joinedName.isNotEmpty
        ? joinedName
        : (fallbackName.isNotEmpty ? fallbackName : "Customer");
    final photo = customer['photo']?.toString();
    final text = _reviewText(review);
    final rating = _reviewRating(review) ?? 0;
    final date = _reviewDate(review);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.025),
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
                backgroundColor: Color(0xFF6CA34D).withOpacity(0.12),
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
                        _buildStars(rating, 14.sp),
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

  Widget _buildStars(double rating, double size) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final position = index + 1;
        final icon = rating >= position
            ? Icons.star_rounded
            : rating >= position - 0.5
            ? Icons.star_half_rounded
            : Icons.star_outline_rounded;
        return Icon(icon, color: Colors.amber.shade700, size: size);
      }),
    );
  }

  String _reviewDate(dynamic review) {
    if (review is! Map) return '';
    final raw = review['created_at'] ?? review['date'] ?? review['created'];
    if (raw == null) return '';
    final parsed = DateTime.tryParse(raw.toString());
    if (parsed == null) return '';
    return DateFormat('MMM d, yyyy').format(parsed.toLocal());
  }

  double? _reviewRating(dynamic r) {
    if (r is Map) {
      final v = r['rating'] ?? r['stars'] ?? r['score'];
      if (v is num) return v.toDouble();
      if (v is String) return double.tryParse(v);
    }
    return null;
  }

  String _reviewText(dynamic r) {
    if (r is Map) {
      final v = r['review'] ?? r['comment'] ?? r['text'] ?? r['message'] ?? '';
      return v.toString();
    }
    return '';
  }

  Widget _buildBottomButton() {
    return Container(
      padding: EdgeInsets.fromLTRB(24.w, 16.h, 24.w, 24.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
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
                'categoryID': h.categories?.isNotEmpty == true ? h.categories!.first : '',
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
