// lib/modules/i_want_to_work/profile/views/worker_profile_view.dart
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:working_hiring/app/modules/i_want_to_work/profile/helper_profile_model.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../../../../routes/app_pages.dart';
import '../../../../core/constants/app_strings.dart';
import '../controllers/worker_profile_controller.dart';
import '../helper_profile_controller.dart';
import '../edit_helper_profile_view.dart';
import '../create_helper_profile_view.dart';
import '../../../../core/widgets/responsive_layout.dart';

class WorkerProfileView extends GetView<WorkerProfileController> {
  WorkerProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final helperController = Get.find<HelperProfileController>();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(
        title: AppStrings.profile.tr,
        showLeading: false,
        actions: [
          IconButton(
            icon: Icon(Icons.edit, color: Colors.black87),
            onPressed: () => Get.to(() => EditHelperProfileView()),
          ),
          IconButton(
            icon: Icon(Icons.menu, color: Colors.black87),
            onPressed: () => Get.toNamed(Routes.WORKER_SETTINGS),
          ),
        ],
      ),
      body: Obx(() {
        if (helperController.isLoading.value) {
          return Center(
            child: CircularProgressIndicator(color: Color(0xFF4CAF50)),
          );
        }

        if (helperController.profileData.value == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.account_circle_outlined,
                    size: 80.sp, color: Colors.grey),
                SizedBox(height: 16.h),
                Text('No Profile Set Up'.tr,
                    style: TextStyle(
                        fontSize: 20.sp, fontWeight: FontWeight.bold)),
                SizedBox(height: 8.h),
                Text(
                  'Create your helper profile to start offering services.'.tr,
                  style: TextStyle(color: Colors.grey),
                ),
                SizedBox(height: 24.h),
                ElevatedButton(
                  onPressed: () => Get.to(() => CreateHelperProfileView()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF4CAF50),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r)),
                    padding: EdgeInsets.symmetric(
                        horizontal: 32.w, vertical: 12.h),
                  ),
                  child: Text('Create Profile'.tr,
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          color: Color(0xFF6CA34D),
          onRefresh: () async {
            await helperController.fetchProfile();
            await controller.loadProfile();
            await controller.fetchWeeklyAvailability();
          },
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: ResponsiveCenter(
              maxWidth: AppResponsive.contentMaxWidth,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildProfileHeader(helperController),
                SizedBox(height: 32.h),
                _buildAboutSection(helperController),
                SizedBox(height: 32.h),
                _buildPricingSection(helperController),
                SizedBox(height: 32.h),
                _buildAccountStatusSection(helperController),
                SizedBox(height: 32.h),
                _buildAvailabilitySection(helperController),
                SizedBox(height: 32.h),
                _buildSkillsSection(helperController),
                SizedBox(height: 32.h),
                _buildReviewsSection(helperController),
                SizedBox(height: 100.h),
              ],
              ),
            ),
          ),
        );
      }),
    );
  }

  // ─── Profile Header ───────────────────────────────────────────────────────
  Widget _buildProfileHeader(HelperProfileController helperController) {
    final profile = helperController.profileData.value;
    final logoUrl = profile?.logo;
    final companyName = profile?.companyName ?? 'No Name Set';
    final location = _buildLocationString(profile);
    final totalJobs = profile?.totalJobs ?? 0;
    final rating = profile?.rating ?? 0.0;

    return Center(
      child: Column(
        children: [
          // Company Logo (or fallback to user photo / placeholder)
          Container(
            padding: EdgeInsets.all(4.w),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Color(0xFF6CA34D), width: 1),
            ),
            child: CircleAvatar(
              radius: 50.r,
              backgroundColor: Colors.grey.shade200,
              backgroundImage: _getAvatarImage(logoUrl),
              child: logoUrl == null || logoUrl.isEmpty
                  ? Icon(Icons.business, size: 40.sp, color: Colors.grey.shade600)
                  : null,
            ),
          ),
          SizedBox(height: 16.h),
          Text(
            companyName,
            style: TextStyle(
                fontSize: 24.sp,
                fontWeight: FontWeight.bold,
                color: Colors.black),
          ),
          SizedBox(height: 8.h),
          // Location
          if (location.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.location_on, color: Colors.redAccent, size: 16.sp),
                  SizedBox(width: 4.w),
                  Flexible(
                    child: Text(
                      location,
                      style: TextStyle(fontSize: 13.sp, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          SizedBox(height: 8.h),
          // Stats: Total Jobs & Rating
          // Row(
          //   mainAxisAlignment: MainAxisAlignment.center,
          //   children: [
          //     _buildStatChip(
          //       Icons.work_outline,
          //       '$totalJobs Jobs',
          //     ),
          //     SizedBox(width: 12.w),
          //     _buildStatChip(
          //       Icons.star,
          //       rating.toStringAsFixed(1),
          //       iconColor: Colors.amber,
          //     ),
          //   ],
          // ),
        ],
      ),
    );
  }

  /// Build location string from officeLocation.
  String _buildLocationString(HelperProfileModel? profile) {
    if (profile == null) return '';
    final loc = profile.officeLocation;
    if (loc == null) return '';
    final parts = [
      loc.addressLine,
      loc.city,
    ].where((s) => s != null && s.isNotEmpty).toList();
    return parts.isNotEmpty ? parts.join(', ') : '';
  }

  /// Returns ImageProvider for avatar: logo → user photo → placeholder.
  ImageProvider? _getAvatarImage(String? logoUrl) {
    if (logoUrl != null && logoUrl.isNotEmpty) {
      return NetworkImage(logoUrl);
    }
    // Fallback to user's personal photo (from WorkerProfileController)
    final workerCtrl = Get.find<WorkerProfileController>();
    return workerCtrl.displayPhoto;
  }

  Widget _buildStatChip(IconData icon, String label,
      {Color iconColor = Colors.green}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(20.r),
      ),
      child: Row(
        children: [
          Icon(icon, size: 14.sp, color: iconColor),
          SizedBox(width: 4.w),
          Text(label,
              style:
              TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  // ─── About ────────────────────────────────────────────────────────────────
  Widget _buildAboutSection(HelperProfileController helperController) {
    final details =
        helperController.profileData.value?.details ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('About'.tr,
            style:
            TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        Text(
          details.isEmpty ? 'No description provided.' : details,
          style: TextStyle(
              fontSize: 14, color: Colors.black87, height: 1.5),
        ),
      ],
    );
  }

  // ─── Pricing ──────────────────────────────────────────────────────────────
  Widget _buildPricingSection(HelperProfileController helperController) {
    final profile = helperController.profileData.value;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Pricing Details'.tr,
            style:
            TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: IntrinsicHeight(
            child: Row(
              children: [
                // Hourly Rate
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Column(
                      children: [
                        Icon(Icons.account_balance_wallet_outlined,
                            color: Color(0xFF6CA34D), size: 24.sp),
                        SizedBox(height: 8.h),
                        Text('Hourly Rate'.tr,
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey)),
                        SizedBox(height: 4.h),
                        Text(
                          profile?.hourlyRate != null
                              ? 'Rate Per Hour'.trParams({
                                  'amount': '\$${profile!.hourlyRate!}',
                                })
                              : 'Rate Per Hour'.trParams({
                                  'amount': '\$0.00',
                                }),
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(
                    color: Colors.grey.shade300, thickness: 1, width: 1),
                // Min Booking
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Column(
                      children: [
                        Icon(Icons.access_time,
                            color: Color(0xFF6CA34D), size: 24.sp),
                        SizedBox(height: 8.h),
                        Text('Min. Booking'.tr,
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey)),
                        SizedBox(height: 4.h),
                        Text(
                          'Hours Count'.trParams({
                            'count': '${profile?.minBookingHours ?? "1"}',
                          }),
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
                VerticalDivider(
                    color: Colors.grey.shade300, thickness: 1, width: 1),
                // Completion Rate
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.symmetric(vertical: 20.h),
                    child: Column(
                      children: [
                        Icon(Icons.check_circle_outline,
                            color: Color(0xFF6CA34D), size: 24.sp),
                        SizedBox(height: 8.h),
                        Text('Complete Rate'.tr,
                            style: TextStyle(
                                fontSize: 12.sp, color: Colors.grey)),
                        SizedBox(height: 4.h),
                        Text(
                          '${(profile?.completeRate ?? 0.0).toStringAsFixed(0)}%',
                          style: TextStyle(
                              fontSize: 16.sp,
                              fontWeight: FontWeight.bold),
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

  // ─── Account Status ───────────────────────────────────────────────────────
  Widget _buildAccountStatusSection(HelperProfileController helperController) {
    final profile = helperController.profileData.value;
    final strikeCount = profile?.strikeCount ?? 0;
    final accountStatus = profile?.accountStatus ?? 'GOOD';
    final isVerified = profile?.isVerified ?? false;

    Color badgeColor;
    Color badgeBg;
    switch (accountStatus.toUpperCase()) {
      case 'GOOD':
        badgeColor = Colors.green;
        badgeBg = Colors.green.shade50;
        break;
      case 'WARNING':
        badgeColor = Colors.orange;
        badgeBg = Colors.orange.shade50;
        break;
      case 'SUSPENDED':
        badgeColor = Colors.red;
        badgeBg = Colors.red.shade50;
        break;
      default:
        badgeColor = Colors.grey;
        badgeBg = Colors.grey.shade50;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Account Status'.tr,
            style:
            TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),

        // Verification banner (if not verified)
        if (!isVerified)
          Container(
            padding:
            EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
            margin: EdgeInsets.only(bottom: 12.h),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(12.r),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              children: [
                Icon(Icons.verified_user_outlined,
                    color: Colors.orange, size: 24.sp),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Identity Verification Required'.tr,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 14.sp)),
                      SizedBox(height: 4.h),
                      Text(
                        'Verify your account to start receiving jobs.'.tr,
                        style:
                        TextStyle(fontSize: 12.sp, color: Colors.grey),
                      ),
                    ],
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Get.toNamed(
                      Routes.WORKER_ACCOUNT_VERIFICATION),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.r)),
                  ),
                  child: Text('Verify'.tr,
                      style: TextStyle(
                          color: Colors.white, fontSize: 12.sp)),
                ),
              ],
            ),
          ),

        // Strike & status card
        Container(
          padding:
          EdgeInsets.symmetric(horizontal: 20.w, vertical: 20.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16.r),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Strike Count'.tr,
                          style: TextStyle(
                              fontSize: 14.sp, color: Colors.grey)),
                      SizedBox(height: 4.h),
                      Text(
                        '$strikeCount',
                        style: TextStyle(
                            fontSize: 24.sp,
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: 16.w, vertical: 8.h),
                    decoration: BoxDecoration(
                      color: badgeBg,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Text(
                      accountStatus,
                      style: TextStyle(
                          color: badgeColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 14.sp),
                    ),
                  ),
                ],
              ),
              if (strikeCount > 0) ...[
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: Colors.orange, size: 18.sp),
                    SizedBox(width: 8.w),
                    Expanded(
                      child: Text(
              'Strike Count Warning'.trParams({
                'count': '$strikeCount',
              }),
                        style: TextStyle(
                            fontSize: 13.sp,
                            color: Colors.orange.shade900,
                            fontWeight: FontWeight.w500),
                      ),
                    ),
                  ],
                ),
              ] else ...[
                SizedBox(height: 16.h),
                Row(
                  children: [
                    Icon(Icons.check_circle_outline,
                        color: Colors.green, size: 18.sp),
                    SizedBox(width: 8.w),
                    Text(
                      'No strikes — keep up the great work!'.tr,
                      style: TextStyle(
                          fontSize: 13.sp,
                          color: Colors.green.shade700,
                          fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  // ─── Availability ─────────────────────────────────────────────────────────
  Widget _buildAvailabilitySection(HelperProfileController helperController) {
    // Use an Obx to watch availability data changes
    return Obx(() {
      final availabilityList = controller.weeklyAvailability;
      final isLoading = controller.isAvailabilityLoading.value;
      final profile = helperController.profileData.value;
      // Determine overall availability (any day AVAILABLE)
      final anyAvailable = profile?.availabilityStatus?? "";

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

             Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey,width: 1),
                borderRadius: BorderRadius.circular(10)
              ),
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Text("Availability Status  : ".tr,style: TextStyle(
                      fontSize: 18.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black54
                    ),),
                      Text(
                        (anyAvailable == true ? "Available" : "Unavailable").tr,
                        style: TextStyle(
                          fontSize: 18.sp,
                          fontWeight: FontWeight.bold,
                          color: anyAvailable == true
                              ? Colors.green
                              : Colors.redAccent,
                        ),
                      ),

                    SizedBox(width: 12.w),
                  ],
                ),
              ),
            ),

          SizedBox(height: 16.h),

          if (isLoading)
            Center(child: CircularProgressIndicator())
          else if (availabilityList.isEmpty)
            Text('No availability data'.tr, style: TextStyle(color: Colors.grey))
          else
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: availabilityList.map((day) {
                  final bool available = day.dayStatus == 'AVAILABLE';
                  final Color bgColor = available ? Color(0xFFF0F9EA) : Colors.grey.shade100;
                  final Color borderColor = available ? Color(0xFF6CA34D).withOpacity(0.3) : Colors.grey.shade200;
                  final Color textColor = available ? Color(0xFF6CA34D) : Colors.grey.shade400;

                  return Container(
                    margin: EdgeInsets.only(right: 8.w),
                    padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      color: bgColor,
                      borderRadius: BorderRadius.circular(12.r),
                      border: Border.all(color: borderColor),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          day.day,
                          style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold, color: textColor),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          day.dayStatus,
                          style: TextStyle(fontSize: 10.sp, color: textColor, fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
          SizedBox(height: 16.h),
          Row(
            children: [
              _buildLegendItem(Color(0xFF6CA34D), 'Available'),
              SizedBox(width: 16.w),
              _buildLegendItem(Colors.grey.shade400, 'Unavailable'),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      children: [
        Container(width: 8.w, height: 8.h, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        SizedBox(width: 6.w),
        Text(label, style: TextStyle(fontSize: 12.sp, color: Colors.grey)),
      ],
    );
  }

  // ─── Skills ───────────────────────────────────────────────────────────────
  Widget _buildSkillsSection(HelperProfileController helperController) {
    final categories =
        helperController.profileData.value?.serviceCategory ?? [];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Skills'.tr,
            style:
            TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
        SizedBox(height: 12.h),
        categories.isEmpty
            ? Text('No skills provided.'.tr,
            style: TextStyle(color: Colors.grey))
            : Wrap(
          spacing: 8,
          runSpacing: 8,
          children: categories.map((cat) {
            return Container(
              padding: EdgeInsets.symmetric(
                  horizontal: 16.w, vertical: 8.h),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20.r),
                border:
                Border.all(color: Color(0xFF6CA34D)),
              ),
              child: Text(
                cat.title ?? 'Service',
                style: TextStyle(
                    color: Color(0xFF6CA34D),
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w500),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ─── Reviews ──────────────────────────────────────────────────────────────
  Widget _buildReviewsSection(HelperProfileController helperController) {
    final profile = helperController.profileData.value;
    final reviews = profile?.reviewsAndRatings ?? [];

    // Calculate average rating from reviews
    double avgRating = 0.0;
    if (reviews.isNotEmpty) {
      final total = reviews.fold<int>(0, (sum, r) => sum + (r.rating ?? 0));
      avgRating = total / reviews.length;
    } else {
      avgRating = profile?.rating ?? 0.0;
    }

    // Rating bar counts (5★ → 1★)
    final ratingCounts = List.filled(5, 0);
    for (final r in reviews) {
      final s = (r.rating ?? 1).clamp(1, 5);
      ratingCounts[5 - s]++;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Reviews'.tr,
            style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold)),
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
                Icon(Icons.rate_review_outlined,
                    size: 40.sp, color: Colors.grey),
                SizedBox(height: 8.h),
                Text('No reviews yet'.tr,
                    style: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.sp,
                        fontWeight: FontWeight.w500)),
                SizedBox(height: 4.h),
                Text('Complete jobs to receive your first review.'.tr,
                    style:
                    TextStyle(color: Colors.grey.shade400, fontSize: 12.sp)),
              ],
            ),
          )
        else ...[
          // Summary card
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
                          fontSize: 40.sp, fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: List.generate(5, (i) {
                        if (i < avgRating.floor()) {
                          return Icon(Icons.star,
                              color: Colors.amber, size: 14.sp);
                        } else if (i.toDouble() < avgRating) {
                          return Icon(Icons.star_half,
                              color: Colors.amber, size: 14.sp);
                        }
                        return Icon(Icons.star_border,
                            color: Colors.amber, size: 14.sp);
                      }),
                    ),
                    SizedBox(height: 4.h),
                    Text('Review Count'.trParams({
                      'count': '${reviews.length}',
                    }),
                        style:
                        TextStyle(color: Colors.grey, fontSize: 12.sp)),
                  ],
                ),
                SizedBox(width: 20.w),
                // Rating bars
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
                            Text('$starLabel',
                                style: TextStyle(
                                    fontSize: 11.sp, color: Colors.grey)),
                            SizedBox(width: 4.w),
                            Icon(Icons.star,
                                color: Colors.amber, size: 11.sp),
                            SizedBox(width: 6.w),
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(4.r),
                                child: LinearProgressIndicator(
                                  value: fraction,
                                  minHeight: 6.h,
                                  backgroundColor: Colors.grey.shade200,
                                  valueColor:
                                  AlwaysStoppedAnimation<Color>(
                                      Color(0xFF6CA34D)),
                                ),
                              ),
                            ),
                            SizedBox(width: 6.w),
                            SizedBox(
                              width: 20.w,
                              child: Text('$count',
                                  style: TextStyle(
                                      fontSize: 11.sp, color: Colors.grey)),
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

          // Review list
          ListView.separated(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: reviews.length,
            separatorBuilder: (_, __) => Divider(
              color: Colors.grey.shade200,
              height: 24.h,
            ),
            itemBuilder: (context, index) {
              final review = reviews[index];
              final stars = (review.rating ?? 5).clamp(1, 5);
              final reviewerName =
              '${review.customer?.firstName ?? ''} ${review.customer?.lastName ?? ''}'
                  .trim();
              final photoUrl = review.customer?.photo;
              final date = review.createdAt != null
                  ? _formatDate(review.createdAt!)
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
                              color: Colors.grey.shade600),
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
                                  fontWeight: FontWeight.bold),
                            ),
                            if (date.isNotEmpty)
                              Text(date,
                                  style: TextStyle(
                                      fontSize: 11.sp,
                                      color: Colors.grey)),
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
                        height: 1.5),
                  ),
                ],
              );
            },
          ),
        ],
      ],
    );
  }

  String _formatDate(String isoDate) {
    try {
      final dt = DateTime.parse(isoDate);
      const months = [
        'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
        'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
      ];
      return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
    } catch (_) {
      return '';
    }
  }
}
