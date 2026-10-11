import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;

import 'package:working_hiring/app/core/constants/app_constants.dart';
import 'package:working_hiring/app/service/api_url.dart';
import 'package:working_hiring/app/service/shared_prefs_helper.dart';
import 'package:working_hiring/app/service/websocket/reconnecting_socket.dart';

/// Real-time chat and notification sockets for the Django Channels backend,
/// authenticated with the JWT access token.
///
/// Only one chat room socket is open at a time. Both sockets reconnect with
/// exponential backoff, and are re-opened when the app returns to the
/// foreground if they dropped while it was in the background.
class WebSocketService extends GetxService with WidgetsBindingObserver {
  /// Max file size accepted by the server per spec §9.1.
  static const int maxAttachmentBytes = 25 * 1024 * 1024;

  /// Callback invoked when a chat message arrives from the WebSocket.
  void Function(Map<String, dynamic> data)? onChatMessage;

  /// Callback invoked when a notification arrives from the WebSocket.
  void Function(Map<String, dynamic> data)? onNotification;

  /// Fired after a successful **reconnect** (not the initial connect).
  /// Consumers should re-fetch chat history to fill any gap of missed frames
  /// during the outage — see spec §7.5.
  void Function(String roomUuid)? onChatReconnected;

  String? _chatRoomUuid;
  String? _chatProfileType;

  late final ReconnectingSocket _chat = ReconnectingSocket(
    label: 'chat',
    retryWithoutToken: true,
    buildUri: _chatUri,
    onFrame: (frame) => onChatMessage?.call(frame),
    onReconnected: () {
      final room = _chatRoomUuid;
      if (room != null) onChatReconnected?.call(room);
    },
    onAuthRejected: (_) => _signOut(),
  );

  late final ReconnectingSocket _notify = ReconnectingSocket(
    label: 'notify',
    buildUri: _notificationUri,
    onFrame: (frame) => onNotification?.call(frame),
    onAuthRejected: (_) => _signOut(),
  );

  RxBool get isChatConnected => _chat.isConnected;
  RxBool get isNotifyConnected => _notify.isConnected;

  String get _wsBaseUrl {
    final base = ApiUrl.baseUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');
    return base
        .replaceFirst('https://', 'wss://')
        .replaceFirst('http://', 'ws://');
  }

  Future<String?> _getToken() async {
    final token = await SharedPrefsHelper.getString(AppConstants.token);
    return token.isEmpty ? null : token;
  }

  Future<Uri?> _chatUri() async {
    final token = await _getToken();
    final room = _chatRoomUuid;
    final profile = _chatProfileType;
    if (token == null || room == null || profile == null) return null;
    return Uri.parse(
      '$_wsBaseUrl/ws/chat/$room/${profile.toUpperCase()}/?token=$token',
    );
  }

  Future<Uri?> _notificationUri() async {
    final token = await _getToken();
    if (token == null) return null;
    return Uri.parse('$_wsBaseUrl/ws/notification/?token=$token');
  }

  Future<void> connectToChat(String roomUuid, String profileType) async {
    await _chat.disconnect();
    _chatRoomUuid = roomUuid;
    _chatProfileType = profileType;
    await _chat.connect();
  }

  Future<void> disconnectChat() async {
    await _chat.disconnect();
    _chatRoomUuid = null;
    _chatProfileType = null;
  }

  void sendChatMessage(Map<String, dynamic> payload) => _chat.send(payload);

  /// Sends a media attachment (image/video/audio/file) over the chat WS
  /// following spec §9.1. Returns `false` if the file is missing or too large.
  Future<bool> sendChatAttachment({
    required File file,
    required String type,
    String? caption,
  }) async {
    if (!_chat.isConnected.value) {
      debugPrint('[WS:chat] Cannot send attachment — not connected');
      return false;
    }
    if (!await file.exists()) {
      debugPrint('[WS:chat] Attachment file missing: ${file.path}');
      return false;
    }
    final size = await file.length();
    if (size > maxAttachmentBytes) {
      debugPrint('[WS:chat] Attachment exceeds 25MB limit (${size}B)');
      return false;
    }
    final bytes = await file.readAsBytes();
    final mime = lookupMimeType(file.path) ?? 'application/octet-stream';
    return _chat.send({
      'type': type,
      if (caption != null && caption.isNotEmpty) 'message': caption,
      'attachment_name': p.basename(file.path),
      'attachment_size': size,
      'raw_file': 'data:$mime;base64,${base64Encode(bytes)}',
    });
  }

  /// Sends a delete-message event per spec §9.1.
  void sendChatDelete({required int messageId, required String roomUuid}) {
    _chat.send({'type': 'delete', 'message_id': messageId, 'roomId': roomUuid});
  }

  Future<void> connectToNotifications() async {
    if (_notify.isConnected.value) return;
    await _notify.connect();
  }

  Future<void> disconnectNotifications() => _notify.disconnect();

  Future<void> _signOut() async {
    // Spec §4.2: 4001/4003 are permanent auth failures. Tear down both
    // sockets, clear tokens, and route to login so the user starts clean.
    await disconnectChat();
    await disconnectNotifications();
    await SharedPrefsHelper.remove(AppConstants.token);
    await SharedPrefsHelper.remove(AppConstants.refreshToken);
    try {
      Get.offAllNamed('/login');
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _chat.resume();
      _notify.resume();
    }
  }

  @override
  void onInit() {
    super.onInit();
    WidgetsBinding.instance.addObserver(this);
    // Warm start: a persisted token connects immediately; otherwise the auth
    // flow calls connectToNotifications() after storing tokens.
    connectToNotifications();
  }

  @override
  void onClose() {
    WidgetsBinding.instance.removeObserver(this);
    disconnectChat();
    disconnectNotifications();
    super.onClose();
  }
}
