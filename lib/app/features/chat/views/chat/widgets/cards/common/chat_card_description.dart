import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_section_label.dart';

part 'chat_card_description_state.dart';

/// Job description clamped to two lines, with a See more/less toggle shown
/// only when the text actually overflows.
class ChatCardDescription extends StatefulWidget {
  final String text;

  const ChatCardDescription({super.key, required this.text});

  @override
  State<ChatCardDescription> createState() => _ChatCardDescriptionState();
}
