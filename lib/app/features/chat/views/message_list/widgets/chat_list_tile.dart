import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/chat/models/chat_model.dart';

class ChatListTile extends StatelessWidget {
  final ChatModel chat;
  final VoidCallback onTap;

  const ChatListTile({super.key, required this.chat, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.symmetric(vertical: 8.h, horizontal: 16.w),
      onTap: onTap,
      leading: Stack(
        children: [
          CircleAvatar(
            radius: AppResponsive.icon(28),
            backgroundColor: Colors.grey.shade200,
            backgroundImage: chat.avatar.isNotEmpty
                ? NetworkImage(chat.avatar)
                : null,
            child: chat.avatar.isEmpty
                ? const Icon(Icons.person, color: Colors.grey)
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
                  color: const Color(0xFF007AFF),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(Icons.check, size: 10.sp, color: Colors.white),
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
          const SizedBox(width: 12),
          Flexible(
            child: Text(
              chat.timeAgo,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.end,
              style: TextStyle(color: Colors.black87, fontSize: 13.sp),
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
  }
}
