import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:working_hiring/app/core/constants/app_colors.dart';
import 'package:working_hiring/app/data/models/order_event.dart';
import 'package:working_hiring/app/features/chat/controllers/message_controller.dart';
import 'package:working_hiring/app/features/chat/utils/order_time_format.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/accept_decline_row.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_button.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_code_box.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_description.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_detail_row.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_details_panel.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_notice.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_shell.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/cards/common/chat_card_task_header.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/dialogs/order_feedback_dialog.dart';
import 'package:working_hiring/app/features/chat/views/chat/widgets/otp_entry.dart';
import 'package:working_hiring/app/features/shell/controllers/main_controller.dart';

/// Compact card for order lifecycle events (work start/complete, cancel,
/// time change, hour change). Each card acts only on its own event's
/// orderId/changesRequestId, never on ids guessed from chat history.
class SystemEventCardWidget extends StatelessWidget {
  static const _timeAccent = Color(0xFF7E57C2);
  static const _hoursAccent = Color(0xFF3949AB);

  final MessageModel msg;
  final MessageController controller;
  final ChatModel chat;

  const SystemEventCardWidget({
    super.key,
    required this.msg,
    required this.controller,
    required this.chat,
  });

  bool get _isClient => Get.find<MainController>().activePhase.value == 1;

  (Color, IconData) get _style {
    switch (msg.eventType) {
      case OrderEventType.orderWorkStart:
        return (AppColors.primary, Icons.construction_rounded);
      case OrderEventType.orderCompleted:
        return (AppColors.primary, Icons.task_alt_rounded);
      case OrderEventType.orderCancel:
        return (Colors.redAccent, Icons.cancel_outlined);
      case OrderEventType.orderChangeRequest:
        return (_timeAccent, Icons.schedule_rounded);
      case OrderEventType.orderHourSet:
        return (_hoursAccent, Icons.access_time_rounded);
      default:
        return (Colors.blueGrey, Icons.notifications_none_rounded);
    }
  }

  @override
  Widget build(BuildContext context) {
    final (accent, icon) = _style;
    final details = _detailRows(context);

    return ChatCardShell(
      accent: accent,
      icon: icon,
      label: 'Order update'.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChatCardTaskHeader(title: msg.taskTitle ?? 'Order update'.tr),
          if (details.isNotEmpty) ...[
            SizedBox(height: 14.h),
            ChatCardDetailsPanel(rows: details),
          ],
          if ((msg.description ?? '').isNotEmpty) ...[
            SizedBox(height: 14.h),
            ChatCardDescription(text: msg.description!),
          ],
          Padding(
            padding: EdgeInsets.symmetric(vertical: 14.h),
            child: Divider(height: 1, color: AppColors.border),
          ),
          _bodyForEvent(),
        ],
      ),
    );
  }

  List<Widget> _detailRows(BuildContext context) {
    final hasStart = (msg.timeSlot ?? '').isNotEmpty;
    final hasEnd = (msg.endTime ?? '').isNotEmpty;
    final budget = msg.proposedBudget ?? msg.budget;
    return [
      if (msg.date != null)
        ChatCardDetailRow(
          icon: Icons.calendar_today_outlined,
          text: 'Date Value'.trParams({
            'date': msg.date.toString().split(' ')[0],
          }),
        ),
      if (hasStart)
        ChatCardDetailRow(
          icon: Icons.play_circle_outline,
          text: 'Start Time Value'.trParams({
            'time': displayOrderTime(context, msg.timeSlot),
          }),
        ),
      if (hasStart || hasEnd)
        ChatCardDetailRow(
          icon: Icons.stop_circle_outlined,
          text: 'End Time Value'.trParams({
            'time': displayOrderEndTime(context, msg),
          }),
        ),
      if ((msg.address ?? '').isNotEmpty)
        ChatCardDetailRow(
          icon: Icons.location_on_outlined,
          text: 'Location Value'.trParams({'location': msg.address!}),
        ),
      if (budget != null)
        ChatCardDetailRow(
          icon: Icons.payments_outlined,
          text: 'Budget Value'.trParams({
            'amount': '\$${budget.toStringAsFixed(0)}',
          }),
          emphasize: true,
        ),
    ];
  }

  Widget _bodyForEvent() {
    switch (msg.eventType) {
      case OrderEventType.orderWorkStart:
        return _workStartBody();
      case OrderEventType.orderCompleted:
        return _completedBody();
      case OrderEventType.orderCancel:
        return _cancelBody();
      case OrderEventType.orderChangeRequest:
        return _timeChangeBody();
      case OrderEventType.orderHourSet:
        return _hourSetBody();
      default:
        return _title(msg.text);
    }
  }

  Widget _title(String text, {IconData? icon, Color? color}) => Row(
    children: [
      if (icon != null) ...[
        Icon(icon, size: 18.sp, color: color ?? AppColors.primary),
        SizedBox(width: 8.w),
      ],
      Expanded(
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 15.sp,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    ],
  );

  Widget _sub(String text) => Padding(
    padding: EdgeInsets.only(top: 4.h),
    child: Text(
      text,
      style: TextStyle(
        fontSize: 13.sp,
        height: 1.4,
        color: AppColors.textSecondary,
      ),
    ),
  );

  Widget _workStartBody() {
    if (msg.workCompleted) {
      return ChatCardNotice(
        title: 'Work completed'.tr,
        text: 'This job has been marked complete.'.tr,
        color: AppColors.primary,
        icon: Icons.check_circle_rounded,
      );
    }
    if (!_isClient) {
      final orderId = msg.orderId;
      return OtpEntry(
        onSubmit: (otp) async {
          if (orderId == null) return false;
          return controller.completeWorkWithOtp(orderId, otp);
        },
      );
    }
    final otp = msg.confirmationOtp;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ChatCardNotice(
          title: 'Work started'.tr,
          text: 'Share this 6-digit code with the helper to confirm completion.'
              .tr,
          color: AppColors.primary,
          icon: Icons.key_rounded,
        ),
        SizedBox(height: 10.h),
        if (otp != null && otp.isNotEmpty)
          ChatCardCodeBox(code: otp)
        else
          _sub('Loading code…'.tr),
      ],
    );
  }

  Widget _completedBody() {
    final orderId = msg.orderId;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title('Work completed'.tr, icon: Icons.task_alt_rounded),
        if (_isClient && orderId != null) ...[
          SizedBox(height: 10.h),
          if (msg.feedbackGiven)
            ChatCardNotice(
              text: 'Thanks for your feedback!'.tr,
              color: AppColors.primary,
              icon: Icons.favorite_rounded,
            )
          else ...[
            _sub('How was your experience?'.tr),
            SizedBox(height: 12.h),
            ChatCardButton(
              label: 'Rate & Review'.tr,
              icon: Icons.star_rounded,
              color: AppColors.primary,
              onPressed: () => showOrderFeedbackDialog(controller, orderId),
            ),
          ],
        ],
      ],
    );
  }

  Widget _cancelBody() {
    final status = msg.offerStatus;
    final isPending = status == 'cancellationRequested' || status == 'pending';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(
          (status == 'cancelled' ? 'Order cancelled' : 'Cancellation requested')
              .tr,
          icon: Icons.cancel_outlined,
          color: Colors.redAccent,
        ),
        if ((msg.proposedMessage ?? '').isNotEmpty)
          _sub('Reason Value'.trParams({'reason': msg.proposedMessage!})),
        if (isPending && !msg.isMe) ...[
          SizedBox(height: 14.h),
          AcceptDeclineRow(
            onAccept: () =>
                controller.respondToCancellation(msg, chat, 'ACCEPT'),
            onDecline: () =>
                controller.respondToCancellation(msg, chat, 'DECLINED'),
          ),
        ],
      ],
    );
  }

  Widget _timeChangeBody() {
    final date = msg.proposedDateStr;
    final time = msg.proposedTime;
    final accepted = msg.offerStatus == 'accepted';
    final responded = accepted || msg.offerStatus == 'declined';
    final hasRequestId = msg.changesRequestId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(
          'New time proposed'.tr,
          icon: Icons.schedule_rounded,
          color: _timeAccent,
        ),
        if (date != null && date.isNotEmpty)
          _sub('Date Value'.trParams({'date': date})),
        if (time != null && time.isNotEmpty)
          _sub('Time Value'.trParams({'time': time})),
        if ((msg.proposedMessage ?? '').isNotEmpty)
          _sub('Reason Value'.trParams({'reason': msg.proposedMessage!})),
        SizedBox(height: 12.h),
        if (responded)
          ChatCardNotice(
            text:
                (accepted ? 'Time change accepted' : 'Time change declined').tr,
            color: accepted ? AppColors.primary : Colors.redAccent,
            icon: accepted ? Icons.check_circle_rounded : Icons.cancel_rounded,
          )
        else if (_isClient && !msg.isMe && hasRequestId)
          AcceptDeclineRow(
            onAccept: () => controller.respondToTimeChange(msg, chat, 'ACCEPT'),
            onDecline: () =>
                controller.respondToTimeChange(msg, chat, 'DECLINED'),
          )
        else if (_isClient && !msg.isMe)
          _sub(
            'Cannot respond — request ID missing. Please pull to refresh.'.tr,
          )
        else
          ChatCardNotice(
            text:
                (_isClient
                        ? 'Waiting for your response — see above, or check your Orders tab.'
                        : 'Waiting for the client to respond.')
                    .tr,
            color: _timeAccent,
            icon: Icons.hourglass_top_rounded,
          ),
      ],
    );
  }

  Widget _hourSetBody() {
    final isPending = msg.offerStatus == 'pending';
    final hour = msg.proposedHour;
    final hasRequestId = msg.changesRequestId != null;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _title(
          'Updated estimated hours'.tr,
          icon: Icons.access_time_rounded,
          color: _hoursAccent,
        ),
        if (hour != null)
          _sub('New Estimate Hours'.trParams({'count': '$hour'})),
        if ((msg.proposedMessage ?? '').isNotEmpty) _sub(msg.proposedMessage!),
        if (isPending && _isClient && hasRequestId) ...[
          SizedBox(height: 14.h),
          AcceptDeclineRow(
            onAccept: () => controller.confirmHourChange(msg, chat, 'ACCEPT'),
            onDecline: () =>
                controller.confirmHourChange(msg, chat, 'DECLINED'),
          ),
        ] else if (isPending && _isClient)
          _sub('Cannot respond — request ID missing. Please refresh.'.tr)
        else if (isPending) ...[
          SizedBox(height: 12.h),
          ChatCardNotice(
            text: 'Waiting for client to confirm hours…'.tr,
            color: _hoursAccent,
            icon: Icons.hourglass_top_rounded,
          ),
        ],
      ],
    );
  }
}
