import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/core/constants/app_strings.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_button.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_notice.dart';

part 'otp_entry_state.dart';

/// Provider-side completion code input. [onSubmit] resolves to whether the
/// backend accepted the code; on failure the typed code stays for correction.
class OtpEntry extends StatefulWidget {
  final Future<bool> Function(String otp) onSubmit;

  const OtpEntry({super.key, required this.onSubmit});

  @override
  State<OtpEntry> createState() => _OtpEntryState();
}
