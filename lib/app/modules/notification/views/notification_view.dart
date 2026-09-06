import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/custom_appBar/custom_app_bar.dart';
import '../controllers/notification_controller.dart';

class NotificationView extends GetView<NotificationController> {
  NotificationView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: CustomAppBar(title: AppStrings.notification.tr),
      body: Obx(() {
        if (controller.isLoading.value) {
          return Center(child: CircularProgressIndicator());
        }
        if (controller.notifications.isEmpty) {
          return RefreshIndicator(
            onRefresh: () => controller.loadNotifications(showError: true),
            color: Color(0xFF6CA34D),
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                SizedBox(height: 180.h),
                Icon(Icons.notifications_none, size: 64.sp, color: Colors.grey.shade400),
                SizedBox(height: 16.h),
                Center(
                  child: Text("No notifications yet".tr, style: TextStyle(fontSize: 16.sp, color: Colors.grey)),
                ),
              ],
            ),
          );
        }
        return RefreshIndicator(
          onRefresh: () => controller.loadNotifications(showError: true),
          color: Color(0xFF6CA34D),
          child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: controller.notifications.length,
          separatorBuilder: (c, i) => Divider(height: 1, color: AppColors.border),
          itemBuilder: (context, index) {
            final notif = controller.notifications[index];
            final isSystem = (notif.type ?? '').startsWith('system');
            final isRead = notif.isRead ?? false;

            return InkWell(
              onTap: () {
                if (!isRead) controller.markRead(notif.id);
              },
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
                color: Colors.white,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (isSystem)
                      CircleAvatar(
                        backgroundColor: Color(0xFF333333),
                        radius: 24.r,
                        child: Icon(
                          notif.type == 'system_strike' ? Icons.warning_amber_rounded : Icons.notifications,
                          color: Colors.white,
                          size: 24.sp,
                        ),
                      )
                    else
                      CircleAvatar(
                        radius: 24.r,
                        backgroundImage: AssetImage(AppImages.alexSmith),
                      ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (notif.title != null && notif.title!.isNotEmpty)
                            Text(
                              notif.title!,
                              style: TextStyle(fontSize: 14.sp, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                            ),
                          if (notif.message != null)
                            Text(
                              notif.message!,
                              style: TextStyle(fontSize: 14.sp, color: AppColors.textPrimary, height: 1.4),
                            ),
                        ],
                      ),
                    ),
                    SizedBox(width: 8.w),
                    Text(
                      _formatTime(notif.createdAt),
                      style: TextStyle(fontSize: 12.sp, color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
        );
      }),
    );
  }

  String _formatTime(String? raw) {
    if (raw == null || raw.isEmpty) return '';
    final dt = DateTime.tryParse(raw);
    if (dt == null) return raw;
    return DateFormat('MMM d, HH:mm').format(dt.toLocal());
  }
}
