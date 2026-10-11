part of 'payment_completed_card_widget.dart';

class _PaymentCompletedCardWidgetState
    extends State<PaymentCompletedCardWidget> {
  static const _progressAccent = Color(0xFFEF6C00);
  static const _hoursAccent = Color(0xFF3949AB);

  @override
  void initState() {
    super.initState();
    final msg = widget.msg;
    if (msg?.orderId != null && msg!.orderAttachments.isEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        widget.controller.loadOrderAttachments(msg);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final msg = widget.msg;
    final total = msg?.proposedBudget ?? msg?.budget ?? 0.0;
    final isClientMode = Get.find<MainController>().activePhase.value == 1;
    final isCompleted =
        msg?.offerStatus == 'completed' ||
        (msg?.workCompleted ?? false) ||
        (msg?.feedbackGiven ?? false) ||
        msg?.eventType == OrderEventType.orderCompleted;
    final inProgress = !isCompleted && msg?.offerStatus == 'inProgress';

    final statusLabel = isCompleted
        ? 'STATUS: WORK COMPLETED'
        : inProgress
        ? 'STATUS: WORK IN PROGRESS'
        : 'STATUS: PAID SECURELY';
    final accent = inProgress ? _progressAccent : AppColors.primary;
    final lifecycle = _lifecycleSection(isClientMode);
    final canSetHours =
        !isClientMode &&
        msg?.orderId != null &&
        msg?.offerStatus == 'paid' &&
        !(msg?.hoursSet ?? false);
    final canCancel = msg?.orderId != null && !isCompleted;

    return ChatCardShell(
      accent: accent,
      icon: isCompleted
          ? Icons.task_alt_rounded
          : inProgress
          ? Icons.construction_rounded
          : Icons.verified_rounded,
      label: statusLabel.tr,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ChatCardTaskHeader(title: msg?.taskTitle ?? 'Task Details'.tr),
          SizedBox(height: 14.h),
          ChatCardDetailsPanel(
            rows: [
              ChatCardDetailRow(
                icon: Icons.calendar_today_outlined,
                text: 'Date Value'.trParams({
                  'date': msg?.date?.toString().split(' ')[0] ?? '—',
                }),
              ),
              ChatCardDetailRow(
                icon: Icons.play_circle_outline,
                text: 'Start Time Value'.trParams({
                  'time': displayOrderTime(context, msg?.timeSlot),
                }),
              ),
              ChatCardDetailRow(
                icon: Icons.stop_circle_outlined,
                text: 'End Time Value'.trParams({
                  'time': msg == null ? '—' : displayOrderEndTime(context, msg),
                }),
              ),
              ChatCardDetailRow(
                icon: Icons.timelapse_rounded,
                text: 'Duration Value'.trParams({
                  'duration': msg?.duration ?? '—',
                }),
              ),
            ],
          ),
          SizedBox(height: 14.h),
          ChatCardDescription(
            text: msg?.description ?? 'No description provided.'.tr,
          ),
          if (msg?.orderAttachments.isNotEmpty == true) ...[
            SizedBox(height: 12.h),
            OrderAttachmentsStrip(urls: msg!.orderAttachments),
          ],
          SizedBox(height: 16.h),
          ChatCardPrice(
            text: 'Final Price'.trParams({
              'amount': '\$${total.toStringAsFixed(2)}',
            }),
          ),
          if (lifecycle != null) ...[SizedBox(height: 16.h), lifecycle],
          if (canSetHours) ...[
            SizedBox(height: 12.h),
            ChatCardButton(
              label: 'Set Hours'.tr,
              icon: Icons.more_time_rounded,
              color: _hoursAccent,
              onPressed: () => showSetLogHoursBottomSheet(
                context,
                msg!.orderId!,
                widget.controller,
              ),
            ),
          ],
          if (canCancel) ...[
            SizedBox(height: 12.h),
            ChatCardButton.outlined(
              label: 'Request Cancellation'.tr,
              color: Colors.redAccent,
              onPressed: () =>
                  widget.controller.cancelRequest(msg!, widget.chat),
            ),
          ],
        ],
      ),
    );
  }

  Widget? _lifecycleSection(bool isClientMode) {
    final msg = widget.msg;
    if (msg == null) return null;

    switch (msg.eventType) {
      case OrderEventType.orderWorkStart:
        if (!isClientMode) {
          final orderId = msg.orderId;
          return OtpEntry(
            onSubmit: (otp) async {
              if (orderId == null) return false;
              return widget.controller.completeWorkWithOtp(orderId, otp);
            },
          );
        }
        final code = msg.confirmationOtp;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ChatCardNotice(
              title: 'Work started'.tr,
              text: 'Share this confirmation code with the provider.'.tr,
              color: AppColors.primary,
              icon: Icons.key_rounded,
            ),
            SizedBox(height: 10.h),
            ChatCardCodeBox(
              code: code?.isNotEmpty == true ? code! : 'Loading code…'.tr,
            ),
          ],
        );
      case OrderEventType.orderHourSet:
        return ChatCardNotice(
          text: msg.proposedHour == null
              ? 'Estimated hours updated'.tr
              : 'Estimated hours updated to'.trParams({
                  'hours': '${msg.proposedHour}',
                }),
          color: _hoursAccent,
          icon: Icons.access_time_rounded,
        );
      case OrderEventType.orderCompleted:
        final orderId = msg.orderId;
        if (orderId == null) return null;
        if (msg.feedbackGiven) {
          return ChatCardNotice(
            text: 'Thanks for your feedback!'.tr,
            color: AppColors.primary,
            icon: Icons.favorite_rounded,
            centered: true,
          );
        }
        return ChatCardButton(
          label: 'Rate & Review'.tr,
          icon: Icons.star_rounded,
          color: AppColors.primary,
          onPressed: () => showOrderFeedbackDialog(widget.controller, orderId),
        );
      default:
        return null;
    }
  }
}
