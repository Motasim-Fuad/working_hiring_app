import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/data/models/order_event.dart';
import 'package:working_hiring/app/features/chat/controllers/message_controller.dart';
import 'package:working_hiring/app/features/chat/utils/order_time_format.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_button.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_code_box.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_description.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_detail_row.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_details_panel.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_notice.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_price.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_shell.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_task_header.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/dialogs/order_feedback_dialog.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/order_attachments_strip.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/otp_entry.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/sheets/set_log_hours_bottom_sheet.dart';
import 'package:working_hiring/app/features/shell/controllers/main_controller.dart';

part 'payment_completed_card_widget_state.dart';

class PaymentCompletedCardWidget extends StatefulWidget {
  final MessageModel? msg;
  final MessageController controller;
  final ChatModel chat;

  const PaymentCompletedCardWidget({
    super.key,
    this.msg,
    required this.controller,
    required this.chat,
  });

  @override
  State<PaymentCompletedCardWidget> createState() =>
      _PaymentCompletedCardWidgetState();
}
