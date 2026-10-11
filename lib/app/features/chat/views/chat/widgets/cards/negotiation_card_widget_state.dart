part of 'negotiation_card_widget.dart';

class _NegotiationCardWidgetState extends State<NegotiationCardWidget> {
  static const _timeChangeAccent = Color(0xFF7E57C2);
  static const _counterAccent = Color(0xFFEF6C00);

  MessageModel get _msg => widget.msg;

  @override
  void initState() {
    super.initState();
    if (_msg.orderId != null && _msg.orderAttachments.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.loadOrderAttachments(_msg);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isClientMode = Get.find<MainController>().activePhase.value == 1;
    final currentRole = isClientMode ? 'client' : 'provider';

    final isSender = _msg.senderRole == currentRole;
    final hasCounterMsg = (_msg.counterMessage ?? '').isNotEmpty;
    final isTimeChange = _msg.isRescheduleRequest;
    final price = _msg.proposedBudget ?? _msg.budget ?? 0.0;
    final isPending =
        _msg.offerStatus == 'pending' || _msg.offerStatus == 'sent';
    final isCancelled = _msg.offerStatus == 'cancelled';
    final isDeclined = _msg.offerStatus == 'declined';

    final counterCount = _msg.counterCount;
    final lastWasClient = _msg.senderRole == 'client';
    final providerTurn = !isClientMode && lastWasClient;
    final clientTurn = isClientMode && !lastWasClient;
    final myTurn = providerTurn || clientTurn;
    final canCounter =
        (providerTurn && counterCount == 0) ||
        (clientTurn && counterCount == 1);

    var label = isSender ? 'SENT REQUEST SUMMARY' : 'NEW JOB REQUEST';
    var accent = AppColors.primary;
    var icon = Icons.request_quote_outlined;
    if (isTimeChange) {
      label = isSender ? 'YOUR TIME CHANGE REQUEST' : 'TIME CHANGE REQUEST';
      accent = _timeChangeAccent;
      icon = Icons.update_rounded;
    } else if (hasCounterMsg || counterCount > 0) {
      label = counterCount >= 2
          ? 'COUNTER OFFER (FINAL)'
          : (isSender ? 'YOUR COUNTER OFFER' : 'COUNTER OFFER RECEIVED');
      accent = _counterAccent;
      icon = Icons.handshake_outlined;
    }

    return ChatCardShell(
      alignment: isSender ? Alignment.centerRight : Alignment.centerLeft,
      accent: accent,
      icon: icon,
      label: label.tr,
      trailing: isPending && !myTurn
          ? ChatCardPill(
              text: 'WAITING'.tr,
              color: accent,
              icon: Icons.hourglass_top_rounded,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChatCardTaskHeader(
            title: _msg.taskTitle ?? 'Task Details'.tr,
            rating: _msg.clientRating,
          ),
          SizedBox(height: 14.h),
          ChatCardDetailsPanel(
            rows: [
              ..._scheduleRows(context, isTimeChange),
              ChatCardDetailRow(
                icon: Icons.location_on_outlined,
                text: _msg.address ?? 'Location'.tr,
              ),
              ChatCardDetailRow(
                icon: Icons.schedule_outlined,
                text: 'Booking Duration'.trParams({
                  'duration': _msg.duration ?? '—',
                }),
              ),
              ChatCardDetailRow(
                icon: Icons.payments_outlined,
                text: 'Budget Value'.trParams({
                  'amount': '\$${price.toStringAsFixed(0)}',
                }),
                emphasize: true,
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ChatCardDescription(
            text: _msg.description ?? 'Please review details.'.tr,
          ),
          if (_msg.orderAttachments.isNotEmpty) ...[
            SizedBox(height: 12.h),
            OrderAttachmentsStrip(urls: _msg.orderAttachments),
          ],
          if (hasCounterMsg) ...[
            SizedBox(height: 14.h),
            ChatCardNotice(
              title: (isTimeChange ? 'Reason for Time Change:' : 'Message:').tr,
              text: '"${_msg.counterMessage}"',
              color: accent,
              icon: Icons.format_quote_rounded,
              italic: true,
            ),
          ],
          ..._footer(
            context,
            isCancelled: isCancelled,
            isDeclined: isDeclined,
            isPending: isPending,
            myTurn: myTurn,
            canCounter: canCounter,
            isClientMode: isClientMode,
            currentRole: currentRole,
          ),
        ],
      ),
    );
  }

  List<Widget> _scheduleRows(BuildContext context, bool isTimeChange) {
    if (isTimeChange) {
      return [
        ChatCardDetailRow(
          icon: Icons.history_rounded,
          text: 'Old Time'.trParams({'time': _msg.timeSlot ?? '—'}),
          strike: true,
        ),
        ChatCardDetailRow(
          icon: Icons.update_rounded,
          text: 'New Time'.trParams({'time': _msg.proposedTimeSlot ?? '—'}),
          emphasize: true,
        ),
      ];
    }
    return [
      ChatCardDetailRow(
        icon: Icons.calendar_today_outlined,
        text: _msg.date?.toString().split(' ')[0] ?? 'Date'.tr,
      ),
      ChatCardDetailRow(
        icon: Icons.play_circle_outline,
        text: 'Start Time Value'.trParams({
          'time': displayOrderTime(context, _msg.timeSlot),
        }),
      ),
      ChatCardDetailRow(
        icon: Icons.stop_circle_outlined,
        text: 'End Time Value'.trParams({
          'time': displayOrderEndTime(context, _msg),
        }),
      ),
    ];
  }

  List<Widget> _footer(
    BuildContext context, {
    required bool isCancelled,
    required bool isDeclined,
    required bool isPending,
    required bool myTurn,
    required bool canCounter,
    required bool isClientMode,
    required String currentRole,
  }) {
    if (isCancelled) {
      return [
        SizedBox(height: 16.h),
        ChatCardNotice(
          text: 'REQUEST CANCELLED'.tr,
          color: Colors.blueGrey,
          icon: Icons.block_rounded,
          centered: true,
        ),
      ];
    }
    if (isDeclined) {
      return [
        SizedBox(height: 16.h),
        ChatCardNotice(
          text: 'OFFER DECLINED'.tr,
          color: Colors.redAccent,
          icon: Icons.cancel_outlined,
          centered: true,
        ),
      ];
    }
    if (isPending && myTurn) {
      return [
        SizedBox(height: 16.h),
        Row(
          children: [
            Expanded(
              child: ChatCardButton(
                label: 'Accept'.tr,
                icon: Icons.check_rounded,
                color: AppColors.primary,
                onPressed: () =>
                    widget.controller.onAcceptQuote(_msg, widget.chat),
              ),
            ),
            if (canCounter) ...[
              SizedBox(width: 10.w),
              Expanded(
                child: ChatCardButton.outlined(
                  label: 'Counter'.tr,
                  icon: Icons.swap_horiz_rounded,
                  color: _counterAccent,
                  onPressed: () => showCounterOfferBottomSheet(
                    context,
                    _msg,
                    widget.controller,
                    widget.chat,
                    currentRole,
                  ),
                ),
              ),
            ],
          ],
        ),
        SizedBox(height: 10.h),
        ChatCardButton.outlined(
          label: 'Decline'.tr,
          color: Colors.redAccent,
          onPressed: () => widget.controller.onDeclineQuote(_msg, widget.chat),
        ),
      ];
    }
    if (isPending && isClientMode && _msg.counterCount == 0) {
      return [
        SizedBox(height: 16.h),
        ChatCardButton.outlined(
          label: 'Cancel Request'.tr,
          color: Colors.redAccent,
          onPressed: () => widget.controller.cancelRequest(_msg, widget.chat),
        ),
      ];
    }
    return const [];
  }
}
