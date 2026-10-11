import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:working_hiring/app/data/models/order_event.dart';
import 'package:working_hiring/app/data/repositories/chat_repository.dart';
import 'package:working_hiring/app/data/repositories/order_repository.dart';
import 'package:working_hiring/app/data/repositories/availability_repository.dart';
import 'package:working_hiring/app/data/models/availability_model.dart';
import 'package:working_hiring/app/service/api_service.dart';
import 'package:working_hiring/app/service/order_event_bus.dart';
import 'package:working_hiring/app/service/reviewed_orders.dart';
import 'package:working_hiring/app/service/websocket_service.dart';
import 'package:working_hiring/app/service/notification_dispatcher.dart';
import 'package:working_hiring/app/features/shell/controllers/main_controller.dart';

import 'package:working_hiring/app/features/chat/models/chat_model.dart';
import 'package:working_hiring/app/features/chat/models/message_model.dart';
import 'package:working_hiring/app/features/chat/models/message_type.dart';
import 'package:working_hiring/app/features/chat/mappers/order_event_message_mapper.dart';
import 'package:working_hiring/app/features/chat/utils/media_message_type.dart';
import 'package:working_hiring/app/features/chat/utils/media_url.dart';
import 'package:working_hiring/app/features/chat/utils/message_timeline.dart';
import 'package:working_hiring/app/features/chat/utils/time_ago.dart';

export 'package:working_hiring/app/features/chat/models/chat_model.dart';
export 'package:working_hiring/app/features/chat/models/message_model.dart';
export 'package:working_hiring/app/features/chat/models/message_type.dart';

class MessageController extends GetxController {
  final ChatRepository _chatRepo;
  final OrderRepository _orderRepo;
  final AvailabilityRepository _availabilityRepo;

  MessageController(this._chatRepo, this._orderRepo, this._availabilityRepo);

  final RxList<ChatModel> chats = <ChatModel>[].obs;
  final RxBool isLoadingRooms = false.obs;
  final Map<String, int> _messageLoadEpoch = <String, int>{};
  final RxSet<String> _historyLoading = <String>{}.obs;
  final Map<int, List<String>> _orderAttachmentCache = <int, List<String>>{};
  final Set<int> _loadingOrderAttachments = <int>{};
  String? _activeRoomUuid;
  ChatModel? _activeChatModel;

  final RxBool isDeclined = false.obs;
  final RxBool isJobUnderNegotiation = false.obs;

  MainController get _mainCtrl => Get.find<MainController>();

  bool get _isProvider => _mainCtrl.activePhase.value == 2;

  String get _currentRole => _isProvider ? 'provider' : 'client';

  String get _profileType => _isProvider ? 'provider' : 'customer';

  @override
  void onInit() {
    super.onInit();
    loadRooms();
    _setupWebSocketNotifications();
    ever(_mainCtrl.activePhase, (_) => loadRooms());
  }

  @override
  void onClose() {
    disconnectFromChatRoom();
    _notifyUnsub?.call();
    super.onClose();
  }

  String _historyKey(ChatModel chat) =>
      chat.roomUuid ?? 'room_${chat.roomId ?? identityHashCode(chat)}';

  /// True while the first/latest history request for [chat] is in flight.
  bool isHistoryLoading(ChatModel chat) =>
      _historyLoading.contains(_historyKey(chat));

  Future<void> loadMessages(ChatModel chat) async {
    final loadKey = _historyKey(chat);
    final loadEpoch = (_messageLoadEpoch[loadKey] ?? 0) + 1;
    _messageLoadEpoch[loadKey] = loadEpoch;
    _historyLoading.add(loadKey);
    try {
      await _loadMessages(chat, loadKey, loadEpoch);
    } finally {
      if (_messageLoadEpoch[loadKey] == loadEpoch) {
        _historyLoading.remove(loadKey);
      }
    }
  }

  Future<void> _loadMessages(
    ChatModel chat,
    String loadKey,
    int loadEpoch,
  ) async {
    final int? roomId = chat.roomId;
    final String? uuid = chat.roomUuid;
    debugPrint('[MSG] loadMessages start — roomId=$roomId uuid=$uuid');

    if (roomId != null) {
      try {
        final msgs = await _chatRepo.getMessages(
          roomId,
          profileType: _profileType,
        );
        if (_messageLoadEpoch[loadKey] != loadEpoch) return;
        _processAndSetMessages(chat, msgs);
        return;
      } catch (e) {
        debugPrint(
          '[MSG] loadMessages with roomId failed: $e, falling back to UUID',
        );
      }
    }

    if (uuid != null && uuid.isNotEmpty) {
      try {
        final msgs = await _chatRepo.getMessagesByUuid(
          uuid,
          profileType: _profileType,
        );
        if (_messageLoadEpoch[loadKey] != loadEpoch) return;
        _processAndSetMessages(chat, msgs);
        return;
      } catch (e) {
        debugPrint('[MSG] loadMessages with UUID failed: $e');
        Get.snackbar("Error".tr, "Could not load message history.".tr);
      }
    } else {
      debugPrint('[MSG] Neither roomId nor UUID available for history.');
    }
  }

  Future<void> loadRooms() async {
    if (isLoadingRooms.value) return;
    isLoadingRooms.value = true;
    try {
      final rooms = _isProvider
          ? await _chatRepo.getProviderRooms()
          : await _chatRepo.getCustomerRooms();

      final existingChats = <String, ChatModel>{};
      for (final c in chats) {
        if (c.roomUuid != null) {
          existingChats[c.roomUuid!] = c;
        } else if (c.roomId != null) {
          existingChats['id_${c.roomId}'] = c;
        }
      }

      final newChats = <ChatModel>[];
      for (final r in rooms) {
        ChatModel? existing;
        existing = existingChats[r.uuid];

        final String fullAvatarUrl = absoluteMediaUrl(r.photo);

        if (existing != null) {
          final updatedChat = ChatModel(
            name: r.name ?? existing.name,
            avatar: fullAvatarUrl.isNotEmpty ? fullAvatarUrl : existing.avatar,
            lastMessage: r.lastMessage ?? existing.lastMessage,
            timeAgo: formatTimeAgo(r.lastMessageTime),
            isOnline: r.isOnline ?? existing.isOnline,
            hasUnread: (r.unreadCount ?? 0) > 0 || existing.hasUnread,
            roomUuid: r.uuid,
            roomId: r.id,
            messages: existing.messages,
          );
          newChats.add(updatedChat);
        } else {
          newChats.add(
            ChatModel(
              name: r.name ?? 'User',
              avatar: fullAvatarUrl,
              lastMessage: r.lastMessage ?? '',
              timeAgo: formatTimeAgo(r.lastMessageTime),
              isOnline: r.isOnline ?? false,
              hasUnread: (r.unreadCount ?? 0) > 0,
              roomUuid: r.uuid,
              roomId: r.id,
            ),
          );
        }
      }

      for (final c in existingChats.values) {
        final stillExists = newChats.any(
          (nc) =>
              (c.roomUuid != null && nc.roomUuid == c.roomUuid) ||
              (c.roomId != null && nc.roomId == c.roomId),
        );
        if (!stillExists) {
          newChats.add(c);
        }
      }

      chats.value = newChats;
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      debugPrint('MessageController.loadRooms error: $e');
    }
    isLoadingRooms.value = false;
  }

  int _countCountersForOrder(List<ChatMessageModel> msgs, int? orderId) {
    if (orderId == null) return 0;
    var count = 0;
    for (final m in msgs) {
      final type = (m.eventType ?? '').toUpperCase();
      final oid = (m.eventData?['id'] as num?)?.toInt();
      if (type == 'ORDER_COUNTER' && oid == orderId) count++;
    }
    return count;
  }

  bool _isOrderTimelineItem(MessageModel message) => message.orderId != null;

  /// Combines the newest order event with data already known by the current
  /// card. The incoming event owns the timestamp, id, sender and state, while
  /// older non-null presentation data is kept when a compact WebSocket event
  /// omits it.
  MessageModel _mergeOrderCard(
    MessageModel? previous,
    MessageModel incoming, {
    int? counterCount,
  }) {
    final cachedAttachments = incoming.orderId == null
        ? const <String>[]
        : (_orderAttachmentCache[incoming.orderId!] ?? const <String>[]);
    if (previous == null) {
      if (counterCount != null) incoming.counterCount = counterCount;
      if (incoming.orderAttachments.isEmpty && cachedAttachments.isNotEmpty) {
        incoming.orderAttachments = List<String>.from(cachedAttachments);
      }
      return incoming;
    }

    return incoming.copyWith(
      taskTitle: incoming.taskTitle ?? previous.taskTitle,
      category: incoming.category ?? previous.category,
      address: incoming.address ?? previous.address,
      date: incoming.date ?? previous.date,
      timeSlot: incoming.timeSlot ?? previous.timeSlot,
      endTime: incoming.endTime ?? previous.endTime,
      jobState: incoming.jobState ?? previous.jobState,
      budget: incoming.budget ?? previous.budget,
      proposedBudget: incoming.proposedBudget ?? previous.proposedBudget,
      proposedDate: incoming.proposedDate ?? previous.proposedDate,
      proposedTimeSlot: incoming.proposedTimeSlot ?? previous.proposedTimeSlot,
      laborCost: incoming.laborCost ?? previous.laborCost,
      materialsCost: incoming.materialsCost ?? previous.materialsCost,
      duration: incoming.duration ?? previous.duration,
      description: incoming.description ?? previous.description,
      photoUrl: incoming.photoUrl ?? previous.photoUrl,
      clientRating: incoming.clientRating ?? previous.clientRating,
      cancellationReason:
          incoming.cancellationReason ?? previous.cancellationReason,
      counterMessage: incoming.counterMessage ?? previous.counterMessage,
      orderAttachments: incoming.orderAttachments.isNotEmpty
          ? incoming.orderAttachments
          : previous.orderAttachments.isNotEmpty
          ? previous.orderAttachments
          : cachedAttachments,
      changesRequestId: incoming.changesRequestId ?? previous.changesRequestId,
      changesType: incoming.changesType ?? previous.changesType,
      changesRequestStatus:
          incoming.changesRequestStatus ?? previous.changesRequestStatus,
      proposedHour: incoming.proposedHour ?? previous.proposedHour,
      proposedDateStr: incoming.proposedDateStr ?? previous.proposedDateStr,
      proposedTime: incoming.proposedTime ?? previous.proposedTime,
      proposedMessage: incoming.proposedMessage ?? previous.proposedMessage,
      confirmationOtp: incoming.confirmationOtp ?? previous.confirmationOtp,
      counterCount:
          counterCount ??
          (incoming.counterCount > previous.counterCount
              ? incoming.counterCount
              : previous.counterCount),
      hoursSet: incoming.hoursSet || previous.hoursSet,
      workCompleted: incoming.workCompleted || previous.workCompleted,
      feedbackGiven: incoming.feedbackGiven || previous.feedbackGiven,
    );
  }

  /// Keeps exactly one visible card for an order. Removing the old card and
  /// inserting the merged card with the newest event timestamp naturally
  /// moves it behind every normal message that happened before that event.
  void _upsertOrderCard(
    List<MessageModel> target,
    MessageModel incoming, {
    int? counterCount,
  }) {
    final orderId = incoming.orderId;
    if (orderId == null) {
      target.add(incoming);
      return;
    }

    MessageModel? previous;
    for (final message in target) {
      if (message.orderId == orderId) previous = message;
    }

    // History APIs commonly return newest-first while live messages arrive in
    // chronological order. Never let an older history/live race move the card
    // backwards or replace the newest state.
    if (previous != null) {
      final previousTime = parseMessageTime(previous.time);
      final incomingTime = parseMessageTime(incoming.time);
      final incomingIsOlder = previous.time == 'Now' && !previous.isTemporary
          ? incoming.time != 'Now'
          : previousTime != null &&
                incomingTime != null &&
                incomingTime.isBefore(previousTime);
      if (incomingIsOlder) {
        if (counterCount != null && counterCount > previous.counterCount) {
          previous.counterCount = counterCount;
        }
        return;
      }
    }

    target.removeWhere((message) => message.orderId == orderId);
    target.add(_mergeOrderCard(previous, incoming, counterCount: counterCount));
  }

  void _processAndSetMessages(ChatModel chat, List<ChatMessageModel> msgs) {
    debugPrint('[MSG] got ${msgs.length} messages from API');
    final orderedMessages = [...msgs]
      ..sort((a, b) {
        final aTime = parseMessageTime(a.createdAt ?? '');
        final bTime = parseMessageTime(b.createdAt ?? '');
        if (aTime == null && bTime == null) return 0;
        if (aTime == null) return -1;
        if (bTime == null) return 1;
        return aTime.compareTo(bTime);
      });
    final history = <MessageModel>[];
    final seenMessageIds = <int>{};
    final counterByOrder = <int, int>{};

    for (final raw in orderedMessages) {
      final orderId = (raw.eventData?['id'] as num?)?.toInt();
      if ((raw.eventType ?? '').toUpperCase() == OrderEventType.orderCounter &&
          orderId != null) {
        counterByOrder[orderId] = (counterByOrder[orderId] ?? 0) + 1;
      }
    }

    for (final m in orderedMessages) {
      try {
        // A chat-message id identifies one concrete server message. Unlike
        // orderId + eventType, it does not collapse two valid counters or two
        // valid status transitions for the same order.
        if (m.id != null && !seenMessageIds.add(m.id!)) continue;

        final isMe = _isProvider
            ? m.senderRole == 'PROVIDER'
            : m.senderRole == 'CUSTOMER';
        final senderRole = isMe
            ? _currentRole
            : (_isProvider ? 'client' : 'provider');
        final mtype = (m.messageType ?? '').toUpperCase();
        MessageModel? newMsg;

        if (mtype == 'EVENT') {
          final order = m.eventData != null
              ? OrderSnapshot.fromJson(m.eventData!)
              : null;
          final reference = m.referenceData != null
              ? OrderChangesRequest.fromJson(m.referenceData!)
              : null;
          final event = OrderEvent(
            id: m.id ?? 0,
            eventType: m.eventType ?? '',
            order: order,
            reference: reference,
            createdAt: m.createdAt,
            sender: m.senderRole,
            chatMessageId: m.id,
            timestamp: m.createdAt,
            roomUuid: chat.roomUuid,
          );
          newMsg = OrderEventMessageMapper.build(
            event,
            isMe: isMe,
            senderRole: senderRole,
            chatMessageId: m.id,
            timestamp: OrderEventMessageMapper.timelineTimestamp(
              event,
              m.createdAt ?? '',
            ),
          );
          if (newMsg.orderId != null) {
            newMsg.counterCount = _countCountersForOrder(
              orderedMessages,
              newMsg.orderId,
            );
          }
        } else if (isMediaMessageType(mtype)) {
          final att = m.attachmentData;
          newMsg = MessageModel(
            id: m.id,
            text: m.text ?? '',
            isMe: isMe,
            senderRole: senderRole,
            time: m.createdAt ?? '',
            type: mediaMessageTypeFor(mtype),
            attachmentUrl: absoluteMediaUrl(att?['file_url'] as String?),
            attachmentName: att?['name'] as String?,
            attachmentSize: (att?['size'] as num?)?.toInt(),
            attachmentMime: att?['mime'] as String?,
          );
        } else {
          newMsg = MessageModel(
            id: m.id,
            text: m.text ?? '',
            isMe: isMe,
            senderRole: senderRole,
            time: m.createdAt ?? '',
            type: MessageType.text,
          );
        }
        if (_isOrderTimelineItem(newMsg)) {
          _upsertOrderCard(
            history,
            newMsg,
            counterCount: counterByOrder[newMsg.orderId],
          );
        } else {
          history.add(newMsg);
        }
      } catch (e) {
        debugPrint('loadMessages: skipping malformed message id=${m.id}: $e');
      }
    }

    final ordersWithHourSet = <int>{};
    final ordersCompleted = <int>{};
    for (final m in orderedMessages) {
      final oid = (m.eventData?['id'] as num?)?.toInt();
      if (oid == null) continue;
      if (m.eventType == OrderEventType.orderHourSet) {
        ordersWithHourSet.add(oid);
      }
      if (m.eventType == OrderEventType.orderCompleted) {
        ordersCompleted.add(oid);
      }
    }
    for (final m in history) {
      if (m.orderId == null) continue;
      if (ordersWithHourSet.contains(m.orderId)) m.hoursSet = true;
      if (ordersCompleted.contains(m.orderId)) m.workCompleted = true;
      // Chat history events do not currently contain the backend review
      // flags. Restore the current user's persisted result immediately so a
      // completed card cannot re-enable Rate & Review on room re-entry.
      if (ReviewedOrders.has(m.orderId!)) m.feedbackGiven = true;
    }

    final historyIds = history.map((m) => m.id).whereType<int>().toSet();
    final liveOnly = chat.messages
        .where(
          (m) => m.isTemporary || (m.id != null && !historyIds.contains(m.id)),
        )
        .toList();

    final allMsgs = <MessageModel>[...history];
    for (final message in liveOnly) {
      if (_isOrderTimelineItem(message)) {
        _upsertOrderCard(allMsgs, message);
      } else if (message.id == null ||
          !allMsgs.any((existing) => existing.id == message.id)) {
        allMsgs.add(message);
      }
    }
    _sortMessages(allMsgs);
    chat.messages.value = allMsgs;
    _restoreFeedbackStateFromOrderDetail(chat, allMsgs);
    if (!_isProvider) {
      for (final message in allMsgs) {
        if (message.eventType == OrderEventType.orderWorkStart &&
            message.orderId != null &&
            (message.confirmationOtp == null ||
                message.confirmationOtp!.isEmpty)) {
          _enrichWorkStartWithOtp(chat, message, message.orderId!);
        }
      }
    }
    debugPrint(
      '[MSG] loaded ${history.length} history + '
      '${liveOnly.length} live messages; one latest card per order',
    );
  }

  /// The order-detail endpoint is the source of truth for review state. Chat
  /// history only carries the older order-event snapshot, so hydrate the
  /// role-specific flag after rebuilding the canonical card. This also heals
  /// local storage after reinstall/login on another device.
  Future<void> _restoreFeedbackStateFromOrderDetail(
    ChatModel chat,
    List<MessageModel> messages,
  ) async {
    final orderIds = messages
        .where((m) => m.orderId != null && m.workCompleted)
        .map((m) => m.orderId!)
        .toSet();

    for (final orderId in orderIds) {
      try {
        final detail = _isProvider
            ? await _orderRepo.getProviderOrderDetail(orderId)
            : await _orderRepo.getCustomerOrderDetail(orderId);
        final reviewed = _isProvider
            ? detail.isProviderReview
            : detail.isCustomerReview;
        if (!reviewed) continue;

        ReviewedOrders.mark(orderId);
        var changed = false;
        for (final message in chat.messages) {
          if (message.orderId == orderId && !message.feedbackGiven) {
            message.feedbackGiven = true;
            changed = true;
          }
        }
        if (changed) chat.messages.refresh();
      } catch (e) {
        debugPrint('Review-state hydration failed for order #$orderId: $e');
      }
    }
  }

  void _sortMessages(List<MessageModel> messages) {
    messages.sort(compareMessageTimeline);
  }

  void sortChatMessages(ChatModel chat) {
    _sortMessages(chat.messages);
  }

  Future<void> sendMessage(ChatModel chat, String text) async {
    if (chat.roomUuid == null || text.trim().isEmpty) return;

    final wsService = _findWsService();
    final wsConnected = wsService != null && wsService.isChatConnected.value;

    if (!wsConnected) {
      Get.snackbar(
        "Not Connected".tr,
        "Reconnecting… please try again in a moment.".tr,
        snackPosition: SnackPosition.TOP,
      );
      return;
    }

    final tempId = -DateTime.now().millisecondsSinceEpoch;

    final sentMsg = MessageModel(
      id: tempId,
      text: text,
      isMe: true,
      senderRole: _currentRole,
      time: 'Now',
      type: MessageType.text,
    );

    chat.messages.add(sentMsg);
    _sortMessages(chat.messages);
    chat.messages.refresh();

    wsService.sendChatMessage({'message': text, 'type': 'text'});
  }

  Future<bool> sendAttachment(
    ChatModel chat,
    File file,
    String type, {
    String? caption,
  }) async {
    final ws = _findWsService();
    if (ws == null || !ws.isChatConnected.value) {
      Get.snackbar(
        'Not Connected'.tr,
        'Reconnecting… please try again in a moment.'.tr,
        snackPosition: SnackPosition.TOP,
      );
      return false;
    }
    final ok = await ws.sendChatAttachment(
      file: file,
      type: type,
      caption: caption,
    );
    if (!ok) {
      Get.snackbar(
        'Upload Failed'.tr,
        'File missing or exceeds the 25 MB limit.'.tr,
        snackPosition: SnackPosition.TOP,
      );
    }
    return ok;
  }

  void _onWsChatMessage(Map<String, dynamic> data) {
    debugPrint('[WS-IN] $data');
    final outerType = data['type'] as String?;
    if (outerType != null && outerType != 'chat_message') {
      debugPrint('[WS] Ignoring unknown frame type: $outerType');
      return;
    }

    final messageType = (data['message_type'] as String?) ?? '';

    if (messageType == 'delete') {
      final messageId = data['message_id'] as int?;
      if (_activeRoomUuid != null && messageId != null) {
        for (final c in chats) {
          if (c.roomUuid == _activeRoomUuid) {
            c.messages.removeWhere((m) => m.id == messageId);
            c.messages.refresh();
            break;
          }
        }
      }
      return;
    }

    if (messageType == 'EVENT') {
      _handleEventFrame(data);
      return;
    }

    if (_activeRoomUuid == null) return;

    final sender = ((data['sender'] as String?) ?? '').toUpperCase();
    final isMe = sender == _profileType.toUpperCase();
    final senderRole = isMe
        ? _currentRole
        : (_isProvider ? 'client' : 'provider');
    final wsId = data['id'] as int?;
    final wsText = (data['content'] as String?) ?? '';
    final wsTime = data['timestamp']?.toString() ?? 'Now';

    ChatModel? targetChat;
    for (final c in chats) {
      if (c.roomUuid == _activeRoomUuid) {
        targetChat = c;
        break;
      }
    }
    if (targetChat == null) return;

    MessageModel? tempMsg;
    if (wsId != null) {
      tempMsg = targetChat.messages.firstWhereOrNull(
        (m) => m.isTemporary && m.text == wsText && m.isMe == isMe,
      );
    }

    if (tempMsg != null && wsId != null) {
      final index = targetChat.messages.indexOf(tempMsg);
      if (index != -1) {
        final realMsg = tempMsg.copyWith(id: wsId, time: wsTime);
        targetChat.messages[index] = realMsg;
        _sortMessages(targetChat.messages);
        targetChat.messages.refresh();
        debugPrint('[WS] Replaced temporary message (id=$wsId)');
        return;
      }
    }

    MessageModel newMsg;
    if (isMediaMessageType(messageType)) {
      final raw = data['attachments'];
      Map<String, dynamic>? att;
      if (raw is List && raw.isNotEmpty && raw.first is Map<String, dynamic>) {
        att = raw.first as Map<String, dynamic>;
      } else if (raw is Map<String, dynamic> && raw.isNotEmpty) {
        att = raw;
      }
      newMsg = MessageModel(
        id: wsId,
        text: wsText,
        isMe: isMe,
        senderRole: senderRole,
        time: wsTime,
        type: mediaMessageTypeFor(messageType),
        attachmentUrl: absoluteMediaUrl(
          (att?['file_url'] ?? att?['url']) as String?,
        ),
        attachmentName: att?['name'] as String?,
        attachmentSize: (att?['size'] as num?)?.toInt(),
        attachmentMime: att?['mime'] as String?,
      );
    } else {
      newMsg = MessageModel(
        id: wsId,
        text: wsText,
        isMe: isMe,
        senderRole: senderRole,
        time: wsTime,
        type: MessageType.text,
      );
    }

    targetChat.messages.add(newMsg);
    _sortMessages(targetChat.messages);
    targetChat.messages.refresh();
  }

  void _handleEventFrame(Map<String, dynamic> data) {
    final roomUuid = _activeRoomUuid;
    final event = OrderEvent.fromChatFrame(data, roomUuid: roomUuid);

    _findBus()?.emit(event);

    if (roomUuid == null) return;

    final chat =
        _activeChatModel ??
        chats.firstWhereOrNull((c) => c.roomUuid == roomUuid);
    if (chat == null) return;

    final senderUpper = (event.sender ?? '').toUpperCase();
    final isMe = senderUpper == _profileType.toUpperCase();
    final senderRole = isMe
        ? _currentRole
        : (_isProvider ? 'client' : 'provider');
    final timestamp = OrderEventMessageMapper.timelineTimestamp(
      event,
      event.timestamp ?? 'Now',
    );
    final chatMessageId = event.chatMessageId;
    final orderId = event.order?.id;
    final eventType = event.eventType;

    // WebSocket may echo a frame already loaded from history. Only the exact
    // server chat-message id is a duplicate; event type is not.
    if (chatMessageId != null &&
        chat.messages.any((message) => message.id == chatMessageId)) {
      debugPrint('[WS] Event message $chatMessageId already applied');
      return;
    }

    if (eventType == OrderEventType.orderCounter && orderId != null) {
      final previous = _lastMessageForOrder(chat.messages, orderId);
      final incoming = OrderEventMessageMapper.build(
        event,
        isMe: isMe,
        senderRole: senderRole,
        chatMessageId: event.chatMessageId,
        timestamp: event.timestamp ?? 'Now',
      );
      final alreadyAppliedOptimistically =
          isMe && (previous?.isTemporary ?? false);
      final nextCounterCount = alreadyAppliedOptimistically
          ? previous!.counterCount
          : (previous?.counterCount ?? 0) + 1;
      _upsertOrderCard(
        chat.messages,
        incoming,
        counterCount: nextCounterCount > 2 ? 2 : nextCounterCount,
      );
      _sortMessages(chat.messages);
      chat.messages.refresh();
      debugPrint(
        '[WS] Moved counter card for order $orderId to latest '
        '(count=${nextCounterCount > 2 ? 2 : nextCounterCount}, '
        'sender=$senderRole)',
      );
      return;
    }

    final msg = OrderEventMessageMapper.build(
      event,
      isMe: isMe,
      senderRole: senderRole,
      chatMessageId: chatMessageId,
      timestamp: timestamp,
    );
    if (orderId != null) {
      final cnt = chat.messages
          .where((m) => m.orderId == orderId)
          .fold<int>(0, (p, m) => m.counterCount > p ? m.counterCount : p);
      msg.counterCount = cnt;
    }

    if (orderId != null) {
      _upsertOrderCard(chat.messages, msg);
    } else {
      chat.messages.add(msg);
    }
    _sortMessages(chat.messages);
    chat.messages.refresh();

    if (event.eventType == OrderEventType.orderWorkStart &&
        !_isProvider &&
        event.order?.id != null) {
      // _upsertOrderCard merges into a new canonical object. Enrich that
      // visible object, not the incoming object that may already be removed.
      final visibleCard =
          _lastMessageForOrder(chat.messages, event.order!.id) ?? msg;
      _enrichWorkStartWithOtp(chat, visibleCard, event.order!.id);
    }
  }

  WebSocketService? _findWsService() {
    if (Get.isRegistered<WebSocketService>()) {
      return Get.find<WebSocketService>();
    }
    return null;
  }

  MessageModel? _lastMessageForOrder(List<MessageModel> messages, int orderId) {
    for (var index = messages.length - 1; index >= 0; index--) {
      final message = messages[index];
      if (message.orderId == orderId) return message;
    }
    return null;
  }

  void connectToChatRoom(String roomUuid) {
    final ws = _findWsService();
    if (ws == null) return;

    if (_activeRoomUuid == roomUuid && ws.isChatConnected.value) {
      debugPrint('[WS] Already connected to room $roomUuid — keeping socket');
      _activeChatModel =
          chats.firstWhereOrNull((c) => c.roomUuid == roomUuid) ??
          _activeChatModel;
      return;
    }

    _activeRoomUuid = roomUuid;
    _activeChatModel = chats.firstWhereOrNull((c) => c.roomUuid == roomUuid);

    ws.onChatMessage = _onWsChatMessage;
    ws.onChatReconnected = (uuid) async {
      final chat = chats.firstWhereOrNull((c) => c.roomUuid == uuid);
      if (chat == null) return;
      await loadMessages(chat);
      debugPrint('[WS] Reconnected and reloaded messages for room $uuid');
    };

    ws.connectToChat(roomUuid, _profileType);
  }

  void disconnectFromChatRoom() {
    final ws = _findWsService();
    if (ws == null) return;
    _activeRoomUuid = null;
    _activeChatModel = null;
    ws.onChatMessage = null;
    ws.onChatReconnected = null;
    ws.disconnectChat();
  }

  VoidCallback? _notifyUnsub;

  // ws.onNotification is a single callback; always go through
  // NotificationDispatcher so multiple controllers can listen.
  void _setupWebSocketNotifications() {
    final ws = _findWsService();
    if (ws == null) return;
    _notifyUnsub = NotificationDispatcher.instance.addListener((data) {
      final entityType = (data['entity_type'] as String?)?.toLowerCase();
      final entityId = data['entity'];

      if (entityType == 'order' && entityId is int) {
        _enrichAndEmitOrderEvent(entityId);
      }

      if (entityType == null ||
          entityType == 'message' ||
          entityType == 'chat') {
        loadRooms();
      }
    });
  }

  Future<void> _enrichAndEmitOrderEvent(int orderId) async {
    final bus = _findBus();
    if (bus == null) return;
    try {
      final order = _isProvider
          ? await _orderRepo.getProviderOrderDetail(orderId)
          : await _orderRepo.getCustomerOrderDetail(orderId);
      final snapshot = OrderSnapshot(
        id: order.id,
        title: order.title,
        description: order.description,
        amount: order.amount,
        status: order.effectiveStatus,
        paymentStatus: order.effectivePaymentStatus,
        workingDate: order.workingDate,
        workingStartTime: order.workingStartTime,
        workingHour: order.workingHour,
        endTime: order.endTime,
        createdAt: order.createdAt,
      );
      bus.emit(
        OrderEvent(
          id: 0,
          eventType: OrderEventType.orderUpdated,
          order: snapshot,
        ),
      );
    } catch (e) {
      debugPrint('Failed to enrich order #$orderId from notification: $e');
    }
  }

  Future<void> _enrichWorkStartWithOtp(
    ChatModel chat,
    MessageModel msg,
    int orderId,
  ) async {
    try {
      final detail = await _orderRepo.getCustomerOrderDetail(orderId);
      final otp = detail.confirmationOtp?.trim();
      msg.confirmationOtp = otp?.isNotEmpty == true
          ? otp
          : 'Please check Order Details';
      chat.messages.refresh();
    } on ApiException catch (e) {
      msg.confirmationOtp = e.message.trim().isNotEmpty
          ? e.message
          : 'Please check Order Details';
      chat.messages.refresh();
      debugPrint('Failed to fetch OTP for order #$orderId: ${e.message}');
    } catch (e) {
      msg.confirmationOtp = 'Please check Order Details';
      chat.messages.refresh();
      debugPrint('Failed to fetch OTP for order #$orderId: $e');
    }
  }

  Future<void> loadOrderAttachments(MessageModel msg) async {
    final orderId = msg.orderId;
    if (orderId == null) return;

    final cached = _orderAttachmentCache[orderId];
    if (cached != null && cached.isNotEmpty) {
      _applyOrderAttachments(orderId, cached, fallback: msg);
      return;
    }
    if (msg.orderAttachments.isNotEmpty) {
      _orderAttachmentCache[orderId] = List<String>.from(msg.orderAttachments);
      _applyOrderAttachments(orderId, msg.orderAttachments, fallback: msg);
      return;
    }
    if (!_loadingOrderAttachments.add(orderId)) return;

    try {
      for (var attempt = 0; attempt < 3; attempt++) {
        if (attempt > 0) {
          await Future<void>.delayed(
            Duration(milliseconds: attempt == 1 ? 350 : 800),
          );
        }
        final detail = _isProvider
            ? await _orderRepo.getProviderOrderDetail(orderId)
            : await _orderRepo.getCustomerOrderDetail(orderId);
        final urls = (detail.attachments ?? [])
            .where((u) => u.trim().isNotEmpty)
            .map(absoluteMediaUrl)
            .toSet()
            .toList();
        if (urls.isEmpty) continue;

        _orderAttachmentCache[orderId] = List<String>.unmodifiable(urls);
        _applyOrderAttachments(orderId, urls, fallback: msg);
        debugPrint(
          'loadOrderAttachments success for #$orderId: ${urls.length} file(s)',
        );
        return;
      }
      debugPrint('loadOrderAttachments empty after retries for #$orderId');
    } catch (e) {
      debugPrint('loadOrderAttachments failed for #$orderId: $e');
    } finally {
      _loadingOrderAttachments.remove(orderId);
    }
  }

  void _applyOrderAttachments(
    int orderId,
    List<String> urls, {
    MessageModel? fallback,
  }) {
    var updatedCurrentCard = false;
    for (final c in chats) {
      var chatChanged = false;
      for (final current in c.messages) {
        if (current.orderId != orderId) continue;
        current.orderAttachments = List<String>.from(urls);
        chatChanged = true;
        updatedCurrentCard = true;
      }
      if (chatChanged) c.messages.refresh();
    }
    if (!updatedCurrentCard && fallback != null) {
      fallback.orderAttachments = List<String>.from(urls);
    }
  }

  OrderEventBus? _findBus() {
    if (Get.isRegistered<OrderEventBus>()) {
      return Get.find<OrderEventBus>();
    }
    return null;
  }

  Future<ChatModel> startChat(
    int providerId,
    String name, {
    String? photo,
  }) async {
    try {
      final room = await _chatRepo.startChat(providerId);
      _chatRepo.rememberRoomCompany(room.uuid, name: name, logo: photo);
      final chat = ChatModel(
        name: name,
        avatar: photo ?? '',
        lastMessage: '',
        timeAgo: '',
        roomUuid: room.uuid,
        roomId: room.id,
      );
      chats.add(chat);
      return chat;
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
      rethrow;
    }
  }

  void deleteMessage(ChatModel chat, MessageModel msg) {
    final ws = _findWsService();
    final msgId = msg.id;
    final roomUuid = chat.roomUuid;
    if (ws == null ||
        !ws.isChatConnected.value ||
        msgId == null ||
        roomUuid == null) {
      return;
    }
    ws.sendChatDelete(messageId: msgId, roomUuid: roomUuid);
    chat.messages.removeWhere((m) => m.id == msgId);
    chat.messages.refresh();
  }

  Future<void> onAcceptQuote(MessageModel quote, ChatModel chat) async {
    final orderId = quote.orderId;
    if (orderId == null) {
      Get.snackbar("Error".tr, "Order information missing.".tr);
      return;
    }
    try {
      if (_isProvider) {
        await _orderRepo.acceptProviderOrder(orderId);
      } else {
        await _orderRepo.acceptOrder(orderId);
      }
      quote.offerStatus = 'accepted';
      isJobUnderNegotiation.value = false;
      chat.messages.refresh();
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      Get.snackbar("Error".tr, "Failed to accept. Please try again.".tr);
    }
  }

  Future<bool> sendCounterOffer(
    ChatModel chat,
    MessageModel originalQuote,
    double newPrice,
    String currentRole,
    String message,
  ) async {
    final orderId = originalQuote.orderId;
    if (orderId == null) {
      Get.snackbar("Error".tr, "Order information missing.".tr);
      return false;
    }
    try {
      if (_isProvider) {
        await _orderRepo.sendProviderCounterOffer(orderId, newPrice, message);
      } else {
        await _orderRepo.sendCounterOffer(orderId, newPrice, message);
      }
      // The backend broadcasts the canonical ORDER_COUNTER event. Do not
      // overwrite that real timestamp with a local `Now` card after the REST
      // response wins/loses the race. Refetch also recovers if WS was missed.
      await loadMessages(chat);
      isJobUnderNegotiation.value = true;
      _ensureCounterVisible(chat, orderId, newPrice, message);
      chat.messages.refresh();
      return true;
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
      return false;
    } catch (e) {
      Get.snackbar("Error".tr, "Failed to send counter offer.".tr);
      return false;
    }
  }

  /// If history/WS missed the COUNTER event, keep the just-sent offer visible.
  void _ensureCounterVisible(
    ChatModel chat,
    int orderId,
    double newPrice,
    String message,
  ) {
    final card = _lastMessageForOrder(chat.messages, orderId);
    if (card == null) return;
    final alreadyShown =
        card.counterCount > 0 ||
        (card.eventType ?? '').toUpperCase() == OrderEventType.orderCounter;
    if (alreadyShown) {
      if ((card.counterMessage == null || card.counterMessage!.isEmpty) &&
          message.isNotEmpty) {
        card.counterMessage = message;
      }
      return;
    }
    final idx = chat.messages.lastIndexWhere((m) => m.orderId == orderId);
    if (idx < 0) return;
    chat.messages[idx] = card.copyWith(
      isMe: true,
      senderRole: _currentRole,
      text: newPrice > 0
          ? 'Counter Offer Value'.trParams({
              'amount': '\$${newPrice.toStringAsFixed(2)}',
            })
          : 'Counter offer'.tr,
      offerStatus: 'pending',
      proposedBudget: newPrice > 0 ? newPrice : card.proposedBudget,
      counterMessage: message.isNotEmpty ? message : card.counterMessage,
      eventType: OrderEventType.orderCounter,
      counterCount: 1,
    );
  }

  Future<void> reloadChatsForOrder(
    int orderId, {
    double? budget,
    String? message,
  }) async {
    final targets = chats
        .where(
          (c) =>
              c.roomUuid == _activeRoomUuid ||
              c.messages.any((m) => m.orderId == orderId),
        )
        .toList();
    for (final chat in targets) {
      await loadMessages(chat);
      if (budget != null) {
        _ensureCounterVisible(chat, orderId, budget, message ?? '');
        chat.messages.refresh();
      }
    }
  }

  Future<void> onDeclineQuote(MessageModel quote, ChatModel chat) async {
    final orderId = quote.orderId;
    if (orderId == null) {
      Get.snackbar("Error".tr, "Order information missing.".tr);
      return;
    }
    try {
      // Order/My Job use these same backend endpoints for declining a pending
      // offer, so Chat must not remain a local-only state change.
      if (_isProvider) {
        await _orderRepo.cancelProviderOrder(orderId, 'Offer declined');
      } else {
        await _orderRepo.cancelOrder(orderId, 'Offer declined');
      }
      quote.offerStatus = 'declined';
      await loadMessages(chat);
      chat.messages.refresh();
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (_) {
      Get.snackbar("Error".tr, "Failed to decline. Please try again.".tr);
    }
  }

  Future<void> cancelRequest(
    MessageModel msg,
    ChatModel chat, {
    String reason = "Cancelled by user",
  }) async {
    final orderId = msg.orderId;
    if (orderId == null) {
      msg.offerStatus = 'cancelled';
      msg.cancellationReason = reason;
      chat.messages.refresh();
      return;
    }
    try {
      if (_isProvider) {
        await _orderRepo.cancelProviderOrder(orderId, reason);
      } else {
        await _orderRepo.cancelOrder(orderId, reason);
      }
      await loadMessages(chat);
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
    } catch (e) {
      Get.snackbar("Error".tr, "Failed to cancel. Please try again.".tr);
    }
  }

  Future<void> processPayment(MessageModel offerMessage, ChatModel chat) async {
    final orderId = offerMessage.orderId;
    if (orderId == null) {
      Get.snackbar("Error".tr, "Order information missing.".tr);
      return;
    }
    try {
      await _orderRepo.payAndConfirm(orderId);
      offerMessage.offerStatus = 'paid';
      chat.messages.refresh();
    } on ApiException catch (e) {
      Get.snackbar("Payment Error", e.message);
    } catch (e) {
      Get.snackbar("Error".tr, "Payment failed. Please try again.".tr);
    }
  }

  Future<bool> setWorkHour(int orderId, int hours, {String? message}) async {
    try {
      await _orderRepo.setWorkHour(orderId, hours, message: message);
      _setOrderFlag(orderId, hoursSet: true);
      return true;
    } on ApiException catch (e) {
      Get.snackbar("Error", e.message);
      return false;
    } catch (e) {
      Get.snackbar("Error".tr, "Failed to set hours. Please try again.".tr);
      return false;
    }
  }

  void _setOrderFlag(
    int orderId, {
    bool? hoursSet,
    bool? workCompleted,
    bool? feedbackGiven,
  }) {
    for (final c in chats) {
      var changed = false;
      for (final m in c.messages) {
        if (m.orderId != orderId) continue;
        if (hoursSet != null) {
          m.hoursSet = hoursSet;
          changed = true;
        }
        if (workCompleted != null) {
          m.workCompleted = workCompleted;
          changed = true;
        }
        if (feedbackGiven != null) {
          m.feedbackGiven = feedbackGiven;
          changed = true;
        }
      }
      if (changed) c.messages.refresh();
    }
  }

  Future<void> respondToCancellation(
    MessageModel msg,
    ChatModel chat,
    String action,
  ) async {
    final orderId = msg.orderId;
    final requestId = msg.changesRequestId;
    if (orderId == null || requestId == null) {
      Get.snackbar('Error'.tr, 'Cancellation reference missing.'.tr);
      return;
    }
    try {
      if (_isProvider) {
        await _orderRepo.cancelAcceptProvider(orderId, requestId, action);
      } else {
        await _orderRepo.cancelAcceptCustomer(orderId, requestId, action);
      }
      await loadMessages(chat);
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to respond. Please try again.'.tr);
    }
  }

  Future<void> respondToTimeChange(
    MessageModel msg,
    ChatModel chat,
    String action,
  ) async {
    final orderId = msg.orderId;
    final requestId = msg.changesRequestId;

    if (orderId == null) {
      Get.snackbar('Error'.tr, 'Order reference missing.'.tr);
      return;
    }
    if (requestId == null) {
      Get.snackbar(
        'Error'.tr,
        'Request ID missing. Please refresh the chat.'.tr,
      );
      return;
    }

    try {
      final apiStatus = action.toUpperCase() == 'ACCEPT' ? 'accept' : 'decline';

      if (_isProvider) {
        await _orderRepo.providerProposeNewTime(
          orderId,
          action: 'update',
          requestId: requestId,
          status: apiStatus,
        );
      } else {
        await _orderRepo.customerProposeNewTime(
          orderId,
          action: 'update',
          requestId: requestId,
          status: apiStatus,
        );
      }

      msg.offerStatus = action.toUpperCase() == 'ACCEPT'
          ? 'accepted'
          : 'declined';
      chat.messages.refresh();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to respond. Please try again.'.tr);
    }
  }

  Future<void> confirmHourChange(
    MessageModel msg,
    ChatModel chat,
    String action,
  ) async {
    final orderId = msg.orderId;
    final requestId = msg.changesRequestId;

    if (orderId == null) {
      Get.snackbar('Error'.tr, 'Order reference missing.'.tr);
      return;
    }
    if (requestId == null) {
      Get.snackbar(
        'Error'.tr,
        'Request ID missing. Please refresh the chat.'.tr,
      );
      return;
    }

    try {
      final apiStatus = action.toUpperCase() == 'ACCEPT' ? 'accept' : 'decline';

      await _orderRepo.customerProposeNewTime(
        orderId,
        action: 'update',
        requestId: requestId,
        status: apiStatus,
      );

      msg.offerStatus = action.toUpperCase() == 'ACCEPT'
          ? 'accepted'
          : 'declined';
      chat.messages.refresh();
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
    } catch (e) {
      Get.snackbar('Error'.tr, 'Failed to respond. Please try again.'.tr);
    }
  }

  Future<List<DateSlot>> fetchAvailableSlots(DateTime date) async {
    try {
      final all = await _availabilityRepo.getDateSlotList(
        date,
        profileType: 'provider',
      );
      return all.where((s) => s.isAvailable).toList();
    } catch (e) {
      debugPrint('[ProposeTime] fetchAvailableSlots error: $e');
      return [];
    }
  }

  Future<bool> proposeNewTimeFromOrder(
    int orderId,
    String date,
    String time,
    String message,
  ) async {
    if (!_isProvider) {
      Get.snackbar('Error'.tr, 'Only providers can propose a new time.'.tr);
      return false;
    }
    try {
      await _orderRepo.providerProposeNewTime(
        orderId,
        action: 'create',
        date: date,
        time: time,
        message: message,
      );
      return true;
    } on ApiException catch (e) {
      final msg = e.message;
      final isAvailabilityError =
          msg.toLowerCase().contains('unavailable') ||
          msg.toLowerCase().contains('unavailasble');
      Get.snackbar(
        'Cannot Propose Time',
        isAvailabilityError
            ? 'Your availability is currently set to OFF.\nGo to Profile → turn ON your availability, then try again.'
            : msg,
        snackPosition: SnackPosition.TOP,
        duration: Duration(seconds: 7),
        backgroundColor: Colors.orange.shade100,
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Failed to propose new time. Please try again.'.tr,
      );
      return false;
    }
  }

  /// Returns whether the backend accepted the OTP.
  Future<bool> completeWorkWithOtp(int orderId, String otp) async {
    try {
      await _orderRepo.completeWork(orderId, otp);
      _setOrderFlag(orderId, workCompleted: true);
      return true;
    } on ApiException catch (e) {
      // Backend returns 400 + status:false for a wrong OTP — this is
      // exactly that case. Surface the real backend message (e.g.
      // "Invalid OTP") rather than a generic one, and DO NOT mark the
      // job complete.
      Get.snackbar(
        'Invalid Code',
        e.message,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
        duration: Duration(seconds: 5),
      );
      return false;
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Failed to complete. Please try again.'.tr,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
      return false;
    }
  }

  Future<bool> submitFeedback(int orderId, int rating, String review) async {
    try {
      if (_isProvider) {
        await _orderRepo.giveProviderFeedback(orderId, rating, review);
      } else {
        await _orderRepo.giveFeedback(orderId, rating, review);
      }
      _setOrderFlag(orderId, feedbackGiven: true);
      ReviewedOrders.mark(orderId);
      return true;
    } on ApiException catch (e) {
      Get.snackbar('Error', e.message);
      return false;
    } catch (e) {
      Get.snackbar(
        'Error'.tr,
        'Failed to submit feedback. Please try again.'.tr,
      );
      return false;
    }
  }
}
