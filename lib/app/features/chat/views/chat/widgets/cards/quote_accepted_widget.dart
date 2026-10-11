import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/chat/controllers/message_controller.dart';
import 'package:working_hiring/app/features/chat/utils/order_time_format.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_button.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_description.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_detail_row.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_details_panel.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_notice.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_pill.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_price.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_section_label.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_shell.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_task_header.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/dialogs/set_hours_dialog.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/order_attachments_strip.dart';

part 'quote_accepted_widget_state.dart';

class QuoteAcceptedWidget extends StatefulWidget {
  final MessageModel msg;
  final MessageController controller;
  final ChatModel chat;
  final bool isClient;

  const QuoteAcceptedWidget({
    super.key,
    required this.msg,
    required this.controller,
    required this.chat,
    this.isClient = true,
  });

  @override
  State<QuoteAcceptedWidget> createState() => _QuoteAcceptedWidgetState();
}
