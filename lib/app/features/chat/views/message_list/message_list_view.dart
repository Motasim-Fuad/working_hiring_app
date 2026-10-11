import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import 'package:working_hiring/app/core/animations/fade_slide_in.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/core/widgets/state/empty_state_view.dart';
import 'package:working_hiring/app/data/repositories/availability_repository.dart';
import 'package:working_hiring/app/data/repositories/chat_repository.dart';
import 'package:working_hiring/app/data/repositories/order_repository.dart';
import 'package:working_hiring/app/features/chat/controllers/message_controller.dart';
import 'package:working_hiring/app/features/chat/views/message_list/widgets/chat_list_tile.dart';
import 'package:working_hiring/app/features/chat/views/message_list/widgets/chat_list_shimmer.dart';
import 'package:working_hiring/app/features/chat/views/chat/chat_view.dart';

class MessageListView extends GetView<MessageController> {
  const MessageListView({super.key});

  void _ensureController() {
    if (Get.isRegistered<MessageController>()) return;
    if (!Get.isRegistered<AvailabilityRepository>()) {
      Get.put(AvailabilityRepository(Get.find()));
    }
    Get.put(
      MessageController(
        Get.find<ChatRepository>(),
        Get.find<OrderRepository>(),
        Get.find<AvailabilityRepository>(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _ensureController();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
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
            if (controller.isLoadingRooms.value && controller.chats.isEmpty) {
              return const ChatListShimmer();
            }
            if (controller.chats.isEmpty) {
              return LayoutBuilder(
                builder: (context, constraints) => ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    SizedBox(
                      height: constraints.maxHeight,
                      child: EmptyStateView(
                        icon: Icons.chat_bubble_outline_rounded,
                        title: "No conversations yet.".tr,
                      ),
                    ),
                  ],
                ),
              );
            }
            return ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: EdgeInsets.symmetric(vertical: 8.h),
              itemCount: controller.chats.length,
              separatorBuilder: (_, _) =>
                  const Divider(height: 1, color: Color(0xFFF0F0F0)),
              itemBuilder: (context, index) {
                final chat = controller.chats[index];
                return FadeSlideIn(
                  index: index,
                  child: ChatListTile(
                    chat: chat,
                    onTap: () => Get.to(() => ChatView(chat: chat)),
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
