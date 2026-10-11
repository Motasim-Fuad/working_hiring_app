part of 'chat_view.dart';

class _ChatViewState extends State<ChatView> {
  MessageController get _ctrl => Get.find<MessageController>();
  ChatModel get _chat => widget.chat;

  final TextEditingController _inputCtrl = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late final Worker _messageListWorker;

  final ImagePicker _picker = ImagePicker();
  final Rx<File?> _staged = Rx<File?>(null);
  final RxBool _stagedIsPdf = false.obs;
  final RxBool _sending = false.obs;

  void _scrollToBottomIfNeeded() {
    if (_scrollController.hasClients && _chat.messages.isNotEmpty) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  void initState() {
    super.initState();
    // Live WS messages and order-card replacements rebuild the list after the
    // current frame. Scroll only then, so a new normal message is visibly
    // below the latest card just like it is after reopening the room.
    _messageListWorker = ever(_chat.messages, (_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _scrollToBottomIfNeeded();
      });
    });
    if (_chat.roomUuid != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _ctrl.loadMessages(_chat);
        _ctrl.connectToChatRoom(_chat.roomUuid!);
        _scrollToBottomIfNeeded();
      });

      Future.delayed(Duration(milliseconds: 1200), () {
        if (mounted) {
          _ctrl.loadMessages(_chat);
          _scrollToBottomIfNeeded();
        }
      });
    }
  }

  @override
  void dispose() {
    _messageListWorker.dispose();
    _inputCtrl.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _inputCtrl.text.trim();
    final file = _staged.value;

    if (file != null) {
      if (_sending.value) return;
      _sending.value = true;
      final ok = await _ctrl.sendAttachment(
        _chat,
        file,
        _stagedIsPdf.value ? 'file' : 'image',
        caption: text.isNotEmpty ? text : null,
      );
      _sending.value = false;
      if (ok) {
        _staged.value = null;
        _inputCtrl.clear();
        _scrollToBottomIfNeeded();
      }
      return;
    }

    if (text.isEmpty) return;
    _ctrl.sendMessage(_chat, text);
    _inputCtrl.clear();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _scrollToBottomIfNeeded();
    });
  }

  void _showAttachSheet() {
    if (_ctrl.isDeclined.value) return;
    Get.bottomSheet(
      SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(height: 12.h),
            Container(
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2.r),
              ),
            ),
            SizedBox(height: 8.h),
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: Icon(
                  Icons.camera_alt_outlined,
                  color: Color(0xFF6CA34D),
                ),
                title: Text("Take a photo".tr),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.camera);
                },
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: Icon(Icons.image_outlined, color: Color(0xFF6CA34D)),
                title: Text("Choose from gallery".tr),
                onTap: () {
                  Get.back();
                  _pickImage(ImageSource.gallery);
                },
              ),
            ),
            Material(
              color: Colors.transparent,
              child: ListTile(
                leading: Icon(Icons.picture_as_pdf, color: Colors.red.shade400),
                title: Text("Attach a PDF".tr),
                onTap: () {
                  Get.back();
                  _pickPdf();
                },
              ),
            ),
            SizedBox(height: 12.h),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final x = await _picker.pickImage(source: source, imageQuality: 70);
      if (x != null) {
        _staged.value = File(x.path);
        _stagedIsPdf.value = false;
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Could not pick image.'.tr);
    }
  }

  Future<void> _pickPdf() async {
    try {
      final r = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
      );
      final path = r?.files.single.path;
      if (path != null) {
        _staged.value = File(path);
        _stagedIsPdf.value = true;
      }
    } catch (e) {
      Get.snackbar('Error'.tr, 'Could not pick file.'.tr);
    }
  }

  void _handleAttachmentTap(String url, String fileName, String? mime) {
    final isPdf =
        (mime?.contains('pdf') ?? false) ||
        fileName.toLowerCase().endsWith('.pdf');
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(20.w),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.visibility, color: AppColors.primary),
              title: Text('${'Open'.tr} ${isPdf ? 'PDF' : 'File'.tr}'),
              onTap: () {
                Get.back();
                _downloadAndOpenFile(
                  url,
                  fileName,
                  mime,
                  openAfterDownload: true,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.download, color: AppColors.primary),
              title: Text('Download'.tr),
              onTap: () {
                Get.back();
                _downloadAndOpenFile(
                  url,
                  fileName,
                  mime,
                  openAfterDownload: false,
                );
              },
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20.r)),
      ),
    );
  }

  Future<void> _downloadAndOpenFile(
    String url,
    String fileName,
    String? mime, {
    required bool openAfterDownload,
  }) async {
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode != 200) {
        Get.snackbar("Error".tr, "Could not download file.".tr);
        return;
      }

      Directory dir;
      if (openAfterDownload) {
        dir = await getTemporaryDirectory();
      } else {
        if (Platform.isAndroid) {
          final extDir = await getExternalStorageDirectory();
          if (extDir != null) {
            dir = Directory('${extDir.path}/Download');
            if (!await dir.exists()) {
              await dir.create(recursive: true);
            }
          } else {
            dir = await getApplicationDocumentsDirectory();
          }
        } else {
          dir = await getApplicationDocumentsDirectory();
        }
      }

      final filePath = '${dir.path}/$fileName';
      final file = File(filePath);
      await file.writeAsBytes(response.bodyBytes);

      if (openAfterDownload) {
        final result = await OpenFilex.open(filePath, type: mime);
        if (result.type != ResultType.done) {
          Get.snackbar("Error".tr, result.message);
        }
      } else {
        final openResult = await OpenFilex.open(filePath, type: mime);
        if (openResult.type != ResultType.done) {}
      }
    } catch (e) {
      Get.snackbar(
        "Error".tr,
        "Failed to download file".trParams({'error': e.toString()}),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ResponsiveCenter(
        maxWidth: 900,
        padding: EdgeInsets.zero,
        child: Column(
          children: [
            _buildTopProfileSection(),
            Expanded(
              child: Obx(() {
                final messageList = _collapseByOrder(_chat.messages.toList());
                if (messageList.isEmpty && _ctrl.isHistoryLoading(_chat)) {
                  return const ChatHistoryShimmer();
                }
                if (messageList.isEmpty) {
                  return Center(
                    child: Text(
                      "No messages yet. Say hello!".tr,
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }
                return ListView.builder(
                  controller: _scrollController,
                  padding: EdgeInsets.only(
                    left: 16.w,
                    right: 16.w,
                    top: 16.h,
                    bottom: 0,
                  ),
                  itemCount: messageList.length,
                  itemBuilder: (context, index) =>
                      _buildMessageBubble(context, messageList[index]),
                );
              }),
            ),
            _buildInputArea(),
          ],
        ),
      ),
    );
  }

  List<MessageModel> _collapseByOrder(List<MessageModel> raw) {
    // The controller sorts its canonical list, but API replacement and a WS
    // frame can notify separate reactive mutations in the same render cycle.
    // Sort this local snapshot again by the exact same backend-id chronology
    // before collapsing. This is non-mutating for the controller list.
    raw.sort(compareMessageTimeline);

    // Controller already keeps one canonical order card. This is a defensive
    // collapse for API/WS races: choose the chronologically latest order item
    // and place it at that item's position, never at the first event position.
    final Map<int, MessageModel> latest = {};
    final Map<int, int> latestIndex = {};
    final Map<int, int> maxCounter = {};
    for (var index = 0; index < raw.length; index++) {
      final m = raw[index];
      if (m.orderId == null) continue;
      final oid = m.orderId!;
      final prevCnt = maxCounter[oid] ?? 0;
      maxCounter[oid] = m.counterCount > prevCnt ? m.counterCount : prevCnt;
      latest[oid] = m;
      latestIndex[oid] = index;
    }

    final List<MessageModel> out = [];
    for (var index = 0; index < raw.length; index++) {
      final m = raw[index];
      final oid = m.orderId;
      if (oid != null) {
        if (latestIndex[oid] != index) continue;
        final rep = latest[oid]!;
        rep.counterCount = maxCounter[oid] ?? rep.counterCount;
        out.add(rep);
      } else {
        out.add(m);
      }
    }
    return out;
  }

  Widget _buildTopProfileSection() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 50),
          Row(
            children: [
              IconButton(onPressed: Get.back, icon: Icon(Icons.arrow_back_ios)),
              CircleAvatar(
                radius: 20.r,
                backgroundColor: Colors.grey.shade200,
                backgroundImage: _chat.avatar.isNotEmpty
                    ? NetworkImage(_chat.avatar)
                    : null,
                child: _chat.avatar.isEmpty
                    ? Icon(Icons.person, color: Colors.grey)
                    : null,
              ),
              SizedBox(width: 12.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _chat.name,
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16.sp,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Obx(() {
            final isClientMode =
                Get.find<MainController>().activePhase.value == 1;
            if (!isClientMode) return SizedBox.shrink();

            final hasPendingRequest = _chat.messages.any(
              (m) =>
                  (m.type == MessageType.offer ||
                      m.type == MessageType.quote) &&
                  m.senderRole == 'client' &&
                  (m.offerStatus == 'pending' || m.offerStatus == 'sent'),
            );

            if (!hasPendingRequest) return SizedBox.shrink();

            return Column(
              children: [
                SizedBox(height: 16.h),
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 4.h),
                  alignment: Alignment.center,
                  child: Text(
                    "STATUS: WAITING FOR RESPONSE".tr,
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.sp,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.1,
                    ),
                  ),
                ),
              ],
            );
          }),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(BuildContext context, MessageModel msg) {
    if (msg.quoteExpiryTime != null &&
        DateTime.now().isAfter(msg.quoteExpiryTime!) &&
        msg.offerStatus == 'pending') {
      msg.offerStatus = 'expired';
    }

    final cancellationResponse = (msg.changesRequestStatus ?? '').toUpperCase();
    final cancellationWasDeclined =
        cancellationResponse == 'DECLINED' || cancellationResponse == 'DECLINE';
    if (msg.eventType == OrderEventType.orderCancel &&
        cancellationWasDeclined) {
      final restoredStatus = (msg.jobState ?? '').toUpperCase();
      msg.offerStatus = restoredStatus == 'IN_PROGRESS'
          ? 'inProgress'
          : restoredStatus == 'COMPLETED'
          ? 'completed'
          : 'paid';
    }

    final cancellationIsPending =
        cancellationResponse.isEmpty ||
        cancellationResponse == 'PENDING' ||
        cancellationResponse == 'NO_RESPONSE';
    if (msg.eventType == OrderEventType.orderCancel &&
        msg.offerStatus == 'cancellationRequested' &&
        cancellationIsPending) {
      return SystemEventCardWidget(msg: msg, controller: _ctrl, chat: _chat);
    }

    // Status wins over wire event type. Work-start, set-hours, completion and
    // review events update the same full order card instead of rendering a
    // separate compact SystemEventCardWidget.
    if (msg.offerStatus == 'paid' ||
        msg.offerStatus == 'inProgress' ||
        msg.offerStatus == 'completed') {
      return PaymentCompletedCardWidget(
        msg: msg,
        controller: _ctrl,
        chat: _chat,
      );
    }
    if (msg.offerStatus == 'accepted') {
      final isClientMode = Get.find<MainController>().activePhase.value == 1;
      return QuoteAcceptedWidget(
        msg: msg,
        controller: _ctrl,
        chat: _chat,
        isClient: isClientMode,
      );
    }
    if (msg.type == MessageType.offer || msg.type == MessageType.quote) {
      return NegotiationCardWidget(msg: msg, controller: _ctrl, chat: _chat);
    }

    if (msg.type == MessageType.systemEvent) {
      return SystemEventCardWidget(msg: msg, controller: _ctrl, chat: _chat);
    }

    if (msg.type == MessageType.image ||
        msg.type == MessageType.file ||
        msg.type == MessageType.video ||
        msg.type == MessageType.audio) {
      return _buildAttachmentBubble(msg);
    }

    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: msg.isMe ? Color(0xFFF2FBF0) : Color(0xFFF5F5F5),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16.r),
            topRight: Radius.circular(16.r),
            bottomLeft: msg.isMe ? Radius.circular(16.r) : Radius.zero,
            bottomRight: msg.isMe ? Radius.zero : Radius.circular(16.r),
          ),
        ),
        child: Text(
          msg.text,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 15.sp,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildAttachmentBubble(MessageModel msg) {
    final url = msg.attachmentUrl;
    final hasUrl = url != null && url.isNotEmpty;
    final isImage = msg.type == MessageType.image;

    final attachmentWidth = (MediaQuery.sizeOf(context).width * 0.58)
        .clamp(180.0, 280.0)
        .toDouble();
    Widget media;
    if (isImage && hasUrl) {
      media = ClipRRect(
        borderRadius: BorderRadius.circular(12.r),
        child: GestureDetector(
          onTap: () => _openImageFullScreen(url),
          child: CachedNetworkImage(
            imageUrl: url,
            width: attachmentWidth,
            height: attachmentWidth * 0.75,
            fit: BoxFit.cover,
            memCacheWidth:
                (attachmentWidth * MediaQuery.devicePixelRatioOf(context))
                    .round(),
            fadeInDuration: const Duration(milliseconds: 200),
            placeholder: (_, _) => AppShimmer(
              child: ShimmerBox(
                width: attachmentWidth,
                height: attachmentWidth * 0.75,
                radius: 12.r,
              ),
            ),
            errorWidget: (_, _, _) => Container(
              width: attachmentWidth,
              height: attachmentWidth * 0.75,
              color: Colors.grey.shade200,
              alignment: Alignment.center,
              child: Icon(
                Icons.broken_image,
                color: Colors.grey.shade400,
                size: 32.sp,
              ),
            ),
          ),
        ),
      );
    } else {
      final name = msg.attachmentName ?? 'Attachment'.tr;
      final isPdf =
          name.toLowerCase().endsWith('.pdf') ||
          (msg.attachmentMime ?? '').contains('pdf');
      media = GestureDetector(
        onTap: hasUrl
            ? () => _handleAttachmentTap(url, name, msg.attachmentMime)
            : null,
        child: Container(
          width: attachmentWidth,
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.r),
            border: Border.all(color: AppColors.border),
          ),
          child: Row(
            children: [
              Icon(
                isPdf ? Icons.picture_as_pdf : Icons.insert_drive_file,
                color: isPdf ? Colors.red.shade400 : Color(0xFF6CA34D),
                size: 28.sp,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 13.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Align(
      alignment: msg.isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: EdgeInsets.only(bottom: 16.h),
        constraints: BoxConstraints(maxWidth: Get.width * 0.75),
        child: Column(
          crossAxisAlignment: msg.isMe
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            media,
            if (msg.text.trim().isNotEmpty) ...[
              SizedBox(height: 6.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: msg.isMe ? Color(0xFFF2FBF0) : Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Text(
                  msg.text,
                  style: TextStyle(
                    fontSize: 14.sp,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _openImageFullScreen(String url) {
    Get.dialog(
      Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: EdgeInsets.all(16.w),
        child: Stack(
          alignment: Alignment.topRight,
          children: [
            InteractiveViewer(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.r),
                child: CachedNetworkImage(
                  imageUrl: url,
                  fit: BoxFit.contain,
                  placeholder: (_, _) => SizedBox(
                    height: 240.h,
                    child: const Center(
                      child: CircularProgressIndicator(color: Colors.white),
                    ),
                  ),
                  errorWidget: (_, _, _) => Icon(
                    Icons.broken_image,
                    color: Colors.white70,
                    size: 48.sp,
                  ),
                ),
              ),
            ),
            IconButton(
              icon: Icon(Icons.close, color: Colors.white),
              onPressed: () => Get.back(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInputArea() {
    return SafeArea(
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
        decoration: BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Obx(() {
              final f = _staged.value;
              if (f == null) return SizedBox.shrink();
              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.all(8.w),
                decoration: BoxDecoration(
                  color: Color(0xFFF2FBF0),
                  borderRadius: BorderRadius.circular(12.r),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.r),
                      child: _stagedIsPdf.value
                          ? Container(
                              width: 48.w,
                              height: 48.h,
                              color: Colors.grey.shade100,
                              alignment: Alignment.center,
                              child: Icon(
                                Icons.picture_as_pdf,
                                color: Colors.red.shade400,
                                size: 26.sp,
                              ),
                            )
                          : Image.file(
                              f,
                              width: 48.w,
                              height: 48.h,
                              fit: BoxFit.cover,
                            ),
                    ),
                    SizedBox(width: 10.w),
                    Expanded(
                      child: Text(
                        f.path.split('/').last,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12.sp,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, size: 18.sp, color: Colors.grey),
                      onPressed: () => _staged.value = null,
                    ),
                  ],
                ),
              );
            }),

            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.attach_file,
                    color: AppColors.textSecondary,
                    size: 22.sp,
                  ),
                  onPressed: _showAttachSheet,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Color(0xFFF9F9F9),
                      borderRadius: BorderRadius.circular(24.r),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: Obx(() {
                      final isDeclinedState = _ctrl.isDeclined.value;
                      return TextField(
                        controller: _inputCtrl,
                        enabled: !isDeclinedState,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) => _sendMessage(),
                        decoration: InputDecoration(
                          hintText:
                              (isDeclinedState
                                      ? "Chat deactivated"
                                      : "Type a message...")
                                  .tr,
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16.w,
                            vertical: 10.h,
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                SizedBox(width: 8.w),
                CircleAvatar(
                  backgroundColor: Color(0xFF6A9B5D),
                  radius: 22.r,
                  child: IconButton(
                    icon: Icon(Icons.send, color: Colors.white, size: 18.sp),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
