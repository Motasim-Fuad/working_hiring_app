import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/data/repositories/helper_repository.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/client/helper_list/controllers/helper_list_controller.dart';
import 'package:working_hiring/app/features/client/custom_offer/views/custom_offer/custom_offer_view.dart';

class HelperListHelperCard extends GetView<HelperListController> {
  final HelperListModel helper;
  final Future<void> Function(HelperListModel) onChat;

  const HelperListHelperCard({
    super.key,
    required this.helper,
    required this.onChat,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => controller.navigateToProfile(helper),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16.r),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 10,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    controller.categoryName.value,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Obx(() {
                  final isSaved = controller.savedHelperMap.containsKey(
                    helper.id,
                  );
                  return IconButton(
                    icon: Icon(
                      isSaved ? Icons.bookmark : Icons.bookmark_border,
                      color: isSaved ? Color(0xFF6CA34D) : Colors.grey,
                      size: 24.sp,
                    ),
                    onPressed: () => controller.toggleSaveHelper(helper),
                    padding: EdgeInsets.zero,
                    constraints: BoxConstraints(),
                  );
                }),
              ],
            ),
            SizedBox(height: 16.h),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 26.r,
                  backgroundColor: Colors.grey.shade200,
                  backgroundImage: helper.avatarUrl.isNotEmpty
                      ? NetworkImage(helper.avatarUrl)
                      : null,
                  child: helper.avatarUrl.isEmpty
                      ? Icon(Icons.person, color: Colors.grey, size: 26.sp)
                      : null,
                ),
                SizedBox(width: 16.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        helper.name,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(Icons.star, color: Colors.amber, size: 16.sp),
                          SizedBox(width: 4.w),
                          Text(
                            helper.rating!.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            'Tasks Count Parenthesized'.trParams({
                              'count': '${helper.totalTasks}',
                            }),
                            style: TextStyle(
                              fontSize: 12.sp,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: Colors.redAccent,
                            size: 14.sp,
                          ),
                          SizedBox(width: 4.w),
                          Expanded(
                            child: Text(
                              helper.distance != null
                                  ? 'Location With Distance'.trParams({
                                      'location': helper.location ?? 'N/A'.tr,
                                      'distance': '${helper.distance}',
                                    })
                                  : helper.location ?? 'N/A'.tr,
                              style: TextStyle(
                                fontSize: 12.sp,
                                color: Colors.grey.shade600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (helper.distance != null)
                  Text(
                    'Distance Kilometers'.trParams({
                      'distance': '${helper.distance!.toInt()}',
                    }),
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Colors.grey.shade400,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
            SizedBox(height: 12.h),

            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16.sp,
                      color: Colors.grey,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      helper.totalTasks != null
                          ? 'Tasks Count'.trParams({
                              'count': '${helper.totalTasks}',
                            })
                          : "No tasks yet".tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: Colors.grey.shade700,
                      ),
                    ),
                    SizedBox(width: 16.w),
                    Icon(Icons.verified, size: 16.sp, color: Colors.green),
                    SizedBox(width: 6.w),
                    Text(
                      (helper.isVerified == true ? "Verified" : "Unverified")
                          .tr,
                      style: TextStyle(
                        fontSize: 12.sp,
                        color: helper.isVerified == true
                            ? Colors.green
                            : Colors.grey.shade700,
                      ),
                    ),
                    Spacer(),
                    Text(
                      helper.hourlyRate != null
                          ? 'Rate Per Hour'.trParams({
                              'amount': '\$${helper.hourlyRate!.toInt()}',
                            })
                          : "N/A".tr,
                      style: TextStyle(
                        fontSize: 14.sp,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF6CA34D),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 12.h),

                Text(
                  helper.bio ??
                      'Service Provider In'.trParams({
                        'category': controller.categoryName.value,
                      }),
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: Colors.grey.shade600,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 4.h),
                GestureDetector(
                  onTap: () {},
                  child: Text(
                    "See more".tr,
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: Color(0xFF6CA34D),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 12.h),

            Obx(() {
              if (controller.requestedDate.value != null) {
                return Padding(
                  padding: EdgeInsets.only(bottom: 12.h),
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color: Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(8.r),
                      border: Border.all(color: Color(0xFFCBEFB6)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Color(0xFF2E7D32),
                          size: 12.sp,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "Available on your date".tr,
                          style: TextStyle(
                            color: Color(0xFF2E7D32),
                            fontSize: 10.sp,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return SizedBox.shrink();
            }),

            SizedBox(height: 4.h),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => onChat(helper),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade300),
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      minimumSize: Size(double.infinity, 48.h),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Text(
                      'Send Message'.tr,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 14.sp,
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Get.to(
                        () => CreateCustomOfferView(),
                        arguments: {
                          'workerID': helper.id.toString(),
                          'workerName': helper.name,
                          'workerAvatar': helper.avatarUrl,
                          'categoryID': controller.categoryName.value,
                        },
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      elevation: 0,
                      backgroundColor: Color(0xFF6CA34D),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12.r),
                      ),
                      minimumSize: Size(double.infinity, 48.h),
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                    ),
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Send Request'.tr,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14.sp,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
