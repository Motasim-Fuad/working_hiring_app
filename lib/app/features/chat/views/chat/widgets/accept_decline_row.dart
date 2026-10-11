import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_button.dart';

class AcceptDeclineRow extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onDecline;

  const AcceptDeclineRow({
    super.key,
    required this.onAccept,
    required this.onDecline,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ChatCardButton(
            label: 'Accept'.tr,
            icon: Icons.check_rounded,
            color: AppColors.primary,
            onPressed: onAccept,
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: ChatCardButton.outlined(
            label: 'Decline'.tr,
            icon: Icons.close_rounded,
            color: Colors.redAccent,
            onPressed: onDecline,
          ),
        ),
      ],
    );
  }
}
