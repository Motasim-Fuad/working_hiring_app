import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/repositories/chat_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/availability_repository.dart';
import '../controllers/message_controller.dart';
import 'chat_view.dart';
import '../../../core/widgets/responsive_layout.dart';

class MessageListView extends GetView<MessageController> {
  MessageListView({super.key});

  @override
  Widget build(BuildContext context) {
    if (!Get.isRegistered<MessageController>()) {
      if (!Get.isRegistered<AvailabilityRepository>()) {
        Get.put(AvailabilityRepository(Get.find()));
      }
      Get.put(MessageController(
        Get.find<ChatRepository>(),
        Get.find<OrderRepository>(),
        Get.find<AvailabilityRepository>(),
      ));
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          "Message".tr,
          style: TextStyle(
            color: Colors.black,
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ResponsiveCenter(
        maxWidth: AppResponsive.contentMaxWidth,
        padding: EdgeInsets.zero,
        child: RefreshIndicator(
        onRefresh: controller.loadRooms,
        child: Obx(() {
          // Always return a scrollable ListView so RefreshIndicator works.
          if (controller.isLoadingRooms.value && controller.chats.isEmpty) {
            return  ListView(
              children: [Center(child: CircularProgressIndicator())],
            );
          }
          if (controller.chats.isEmpty) {
            return  ListView(
              children: [Center(child: Text("No conversations yet.".tr))],
            );
          }
          return ListView.separated(
            padding: EdgeInsets.symmetric(horizontal: 0, vertical: 8.h),
            itemCount: controller.chats.length,
            separatorBuilder: (c, i) => Divider(
              height: 1,
              color: Color(0xFFF0F0F0),
            ),
            itemBuilder: (context, index) {
              final chat = controller.chats[index];
              return ListTile(
                contentPadding: EdgeInsets.symmetric(
                  vertical: 8.h,
                  horizontal: 16.w,
                ),
                onTap: () => Get.to(() => ChatView(chat: chat)),
                leading: Stack(
                  children: [
                    CircleAvatar(
                      radius: AppResponsive.icon(28),
                      backgroundColor: Colors.grey.shade200,
                      backgroundImage: chat.avatar.isNotEmpty
                          ? NetworkImage(chat.avatar)
                          : null,
                      child: chat.avatar.isEmpty
                          ? Icon(Icons.person, color: Colors.grey)
                          : null,
                    ),
                    if (chat.avatar.isNotEmpty)
                      Positioned(
                        right: 0,
                        bottom: 2.h,
                        child: Container(
                          width: AppResponsive.icon(16),
                          height: AppResponsive.icon(16),
                          decoration: BoxDecoration(
                            color: Color(0xFF007AFF),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          child: Icon(
                            Icons.check,
                            size: 10.sp,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Expanded(
                      child: Text(
                        chat.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontSize: AppResponsive.font(16),
                        ),
                      ),
                    ),
                    SizedBox(width: 12),
                    Flexible(
                      child: Text(
                        chat.timeAgo,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.end,
                        style: TextStyle(
                          color: Colors.black87,
                          fontSize: 13.sp,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Padding(
                  padding: EdgeInsets.only(top: 4.h),
                  child: Text(
                    chat.lastMessage,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.w600,
                      fontSize: 14.sp,
                    ),
                  ),
                ),
              );
            },
          );
        }),
      ),
      ),
    );
  }
}
