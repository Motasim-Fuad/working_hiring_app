import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:working_hiring/app/core/widgets/shimmer/app_shimmer.dart';
import 'package:working_hiring/app/core/widgets/shimmer/shimmer_box.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/data/models/order_event.dart';
import 'package:working_hiring/app/features/chat/controllers/message_controller.dart';
import 'package:working_hiring/app/features/chat/utils/message_timeline.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/shimmer/chat_history_shimmer.dart';
import 'package:working_hiring/app/features/shell/controllers/main_controller.dart';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:working_hiring/app/core/widgets/responsive_layout.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/negotiation_card_widget.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/quote_accepted_widget.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/payment_completed_card_widget.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/system_event_card_widget.dart';

part 'chat_view_state.dart';

class ChatView extends StatefulWidget {
  final ChatModel chat;
  const ChatView({super.key, required this.chat});

  @override
  State<ChatView> createState() => _ChatViewState();
}
