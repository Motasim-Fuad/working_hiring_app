part of 'quote_accepted_widget.dart';

class _QuoteAcceptedWidgetState extends State<QuoteAcceptedWidget> {
  static const _waitingAccent = Color(0xFFF59E0B);

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

  String _labeled(String label, String value) => '${label.tr} $value';

  @override
  Widget build(BuildContext context) {
    final total = _msg.proposedBudget ?? _msg.budget ?? 0.0;
    final isPaid = _msg.offerStatus == 'paid';

    return ChatCardShell(
      accent: isPaid ? AppColors.primary : _waitingAccent,
      icon: isPaid ? Icons.verified_rounded : Icons.receipt_long_rounded,
      label: (isPaid ? 'STATUS: PAID SECURELY' : 'STATUS: AWAITING PAYMENT').tr,
      trailing: isPaid
          ? ChatCardPill(
              text: 'Payment Completed'.tr,
              color: AppColors.primary,
              icon: Icons.check_circle_rounded,
            )
          : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChatCardTaskHeader(
            title: _msg.taskTitle ?? 'Task Details'.tr,
            subtitle: _msg.category ?? 'General',
            rating: _msg.clientRating,
          ),
          SizedBox(height: 16.h),
          ChatCardSectionLabel('JOB SUMMARY'.tr),
          ChatCardDetailsPanel(
            rows: [
              ChatCardDetailRow(
                icon: Icons.calendar_today_outlined,
                text: _labeled(
                  'Date:',
                  _msg.date?.toString().split(' ')[0] ?? 'Date Not Set'.tr,
                ),
              ),
              ChatCardDetailRow(
                icon: Icons.play_circle_outline,
                text: _labeled(
                  'Start Time:',
                  displayOrderTime(context, _msg.timeSlot),
                ),
              ),
              ChatCardDetailRow(
                icon: Icons.stop_circle_outlined,
                text: _labeled('End Time:', displayOrderEndTime(context, _msg)),
              ),
              ChatCardDetailRow(
                icon: Icons.timelapse_rounded,
                text: _labeled('Duration:', _msg.duration ?? '—'),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ChatCardDescription(
            text: _msg.description ?? 'No description provided.'.tr,
          ),
          if (_msg.orderAttachments.isNotEmpty) ...[
            SizedBox(height: 12.h),
            OrderAttachmentsStrip(urls: _msg.orderAttachments),
          ],
          SizedBox(height: 16.h),
          ChatCardPrice(
            text: 'Final Price'.trParams({
              'amount': '\$${total.toStringAsFixed(2)}',
            }),
          ),
          SizedBox(height: 16.h),
          ...(isPaid ? _paidFooter(context) : _unpaidFooter()),
        ],
      ),
    );
  }

  List<Widget> _unpaidFooter() {
    void cancel() => widget.controller.cancelRequest(_msg, widget.chat);
    return [
      ChatCardNotice(
        text:
            'Cancellation Policy: Full refund if cancelled 24h before job start; 50% refund after 24h.'
                .tr,
        color: const Color(0xFF8D6E63),
        icon: Icons.info_outline_rounded,
      ),
      SizedBox(height: 16.h),
      if (widget.isClient) ...[
        ChatCardButton(
          label: 'Pay and Confirm'.tr,
          icon: Icons.lock_rounded,
          color: AppColors.primary,
          onPressed: () => widget.controller.processPayment(_msg, widget.chat),
        ),
        SizedBox(height: 10.h),
        ChatCardButton.outlined(
          label: 'Cancel Booking'.tr,
          color: Colors.redAccent,
          onPressed: cancel,
        ),
      ] else ...[
        ChatCardNotice(
          text: 'Waiting for the client to pay.'.tr,
          color: _waitingAccent,
          icon: Icons.hourglass_top_rounded,
          centered: true,
        ),
        SizedBox(height: 10.h),
        ChatCardButton.outlined(
          label: 'Cancel Booking'.tr,
          color: Colors.redAccent,
          onPressed: cancel,
        ),
      ],
    ];
  }

  List<Widget> _paidFooter(BuildContext context) {
    final canSetHours =
        !widget.isClient && _msg.orderId != null && !_msg.hoursSet;
    return [
      ChatCardNotice(
        text: 'Payment Completed'.tr,
        color: AppColors.primary,
        icon: Icons.check_circle_rounded,
        centered: true,
      ),
      if (canSetHours) ...[
        SizedBox(height: 12.h),
        ChatCardButton(
          label: 'Set Hours'.tr,
          icon: Icons.more_time_rounded,
          color: const Color(0xFF3949AB),
          onPressed: () =>
              showSetHoursDialog(context, _msg.orderId!, widget.controller),
        ),
      ],
    ];
  }
}
