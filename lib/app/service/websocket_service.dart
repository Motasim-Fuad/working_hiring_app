import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart' as p;
import 'package:web_socket_channel/web_socket_channel.dart';

import 'shared_prefs_helper.dart';
import '../core/constants/app_constants.dart';
import 'api_url.dart';

/// Manages WebSocket connections for real-time chat and notifications.
/// Connects to the Django Channels backend with JWT authentication.
///
/// Close-code policy (spec §9.1):
///   - 4001 / 4003 → auth or permission failure; do NOT reconnect, sign user out.
///   - 1006 / other → network error; exponential backoff 2s → 30s.
class WebSocketService extends GetxService {
  WebSocketChannel? _chatChannel;
  WebSocketChannel? _notifyChannel;
  Timer? _chatReconnectTimer;
  Timer? _notifyReconnectTimer;

  int _chatRetryCount = 0;
  int _notifyRetryCount = 0;
  static const int _maxRetries = 6; // 2,4,8,16,30,30 → ~90s of attempts

  /// Close codes that mean "do not reconnect" per spec §9.1.
  static const Set<int> _terminalCloseCodes = {4001, 4003};

  final RxBool isChatConnected = false.obs;
  final RxBool isNotifyConnected = false.obs;

  /// Callback invoked when a chat message arrives from the WebSocket.
  void Function(Map<String, dynamic> data)? onChatMessage;

  /// Callback invoked when a notification arrives from the WebSocket.
  void Function(Map<String, dynamic> data)? onNotification;

  /// Fired after a successful **reconnect** (not the initial connect).
  /// Consumers should re-fetch chat history to fill any gap of missed frames
  /// during the outage — see spec §7.5.
  void Function(String roomUuid)? onChatReconnected;

  String get _wsBaseUrl {
    // Derive from the REST base URL so there is a single source of truth.
    // Strip the /api/v1 path suffix and swap http(s) → ws(s).
    final base = ApiUrl.baseUrl.replaceFirst(RegExp(r'/api/v1/?$'), '');
    return base.replaceFirst('https://', 'wss://').replaceFirst('http://', 'ws://');
  }

  Future<String?> _getToken() async {
    final token = await SharedPrefsHelper.getString(AppConstants.token);
    if (token.isEmpty) return null;
    return token;
  }

  // ── Chat WebSocket ──────────────────────────────────────────

  Future<void> connectToChat(String roomUuid, String profileType) async {
    await disconnectChat();
    _chatRetryCount = 0;
    await _doConnectChat(roomUuid, profileType);
  }

  Future<void> _doConnectChat(String roomUuid, String profileType) async {
    final token = await _getToken();
    if (token == null) {
      debugPrint('[WS] Cannot connect chat — no token, retrying');
      _scheduleChatReconnect(roomUuid, profileType);
      return;
    }

    final uri = Uri.parse(
      '$_wsBaseUrl/ws/chat/$roomUuid/${profileType.toUpperCase()}/?token=$token',
    );
    debugPrint('[WS] Connecting chat: $uri');

    final isReconnect = _chatRetryCount > 0;

    try {
      final channel = WebSocketChannel.connect(uri);
      await channel.ready;
      _chatChannel = channel;
      isChatConnected.value = true;
      _chatRetryCount = 0;
      if (isReconnect) {
        // Spec §7.5: after reconnect, the client must back-fill any missed
        // history. Hand off to the consumer that owns REST access.
        try {
          onChatReconnected?.call(roomUuid);
        } catch (e) {
          debugPrint('[WS] onChatReconnected handler error: $e');
        }
      }

      channel.stream.listen(
        (data) {
          // Stale-channel guard: ignore frames from a channel that has been
          // superseded by a fresh connectToChat(...) for a different room.
          if (!identical(_chatChannel, channel)) return;
          try {
            final decoded = jsonDecode(data as String) as Map<String, dynamic>;
            onChatMessage?.call(decoded);
          } catch (e) {
            debugPrint('[WS] Chat parse error: $e');
          }
        },
        onError: (error) {
          if (!identical(_chatChannel, channel)) return;
          debugPrint('[WS] Chat error: $error');
          isChatConnected.value = false;
          _handleChatClose(channel.closeCode, roomUuid, profileType);
        },
        onDone: () {
          debugPrint('[WS] Chat closed (code=${channel.closeCode})');
          // If disconnectChat() (or a navigation to a different room) has
          // already replaced/cleared _chatChannel, this onDone is the result
          // of the intentional close — don't schedule a reconnect to a room
          // the user no longer cares about.
          if (!identical(_chatChannel, channel)) return;
          isChatConnected.value = false;
          _handleChatClose(channel.closeCode, roomUuid, profileType);
        },
      );
    } catch (e) {
      debugPrint('[WS] Chat connect failed: $e');
      isChatConnected.value = false;
      _scheduleChatReconnect(roomUuid, profileType);
    }
  }

  void _handleChatClose(int? closeCode, String roomUuid, String profileType) {
    if (closeCode != null && _terminalCloseCodes.contains(closeCode)) {
      debugPrint('[WS] Chat refused (code=$closeCode) — aborting reconnect.');
      _signOut();
      return;
    }
    _scheduleChatReconnect(roomUuid, profileType);
  }

  void _scheduleChatReconnect(String roomUuid, String profileType) {
    if (_chatRetryCount >= _maxRetries) {
      debugPrint('[WS] Chat: max retries reached, giving up');
      return;
    }
    _chatRetryCount++;
    final delay = _backoff(_chatRetryCount);
    debugPrint('[WS] Chat reconnect in ${delay.inSeconds}s (attempt $_chatRetryCount/$_maxRetries)');
    _chatReconnectTimer?.cancel();
    _chatReconnectTimer = Timer(delay, () => _doConnectChat(roomUuid, profileType));
  }

  /// Exponential backoff (2s → 32s) per spec §7.5.
  Duration _backoff(int attempt) {
    final seconds = (1 << attempt).clamp(2, 32); // 2,4,8,16,32,32...
    return Duration(seconds: seconds);
  }

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

  Future<void> disconnectChat() async {
    _chatReconnectTimer?.cancel();
    _chatReconnectTimer = null;
    _chatRetryCount = 0;
    // Clear _chatChannel BEFORE awaiting the close so the stream listener's
    // onDone can detect the intentional close (identical(_chatChannel,
    // channel) == false) and skip scheduling a stale reconnect.
    final ch = _chatChannel;
    _chatChannel = null;
    await ch?.sink.close();
    isChatConnected.value = false;
  }

  void sendChatMessage(Map<String, dynamic> payload) {
    if (_chatChannel == null) {
      debugPrint('[WS] Cannot send — not connected');
      return;
    }
    _chatChannel!.sink.add(jsonEncode(payload));
  }

  /// Max file size accepted by the server per spec §9.1.
  static const int maxAttachmentBytes = 25 * 1024 * 1024;

  /// Sends a media attachment (image/video/audio/file) over the chat WS
  /// following spec §9.1. Returns `false` if the file is missing or too large.
  Future<bool> sendChatAttachment({
    required File file,
    required String type, // "image" | "video" | "audio" | "file"
    String? caption,
  }) async {
    if (_chatChannel == null) {
      debugPrint('[WS] Cannot send attachment — not connected');
      return false;
    }
    if (!await file.exists()) {
      debugPrint('[WS] Attachment file missing: ${file.path}');
      return false;
    }
    final size = await file.length();
    if (size > maxAttachmentBytes) {
      debugPrint('[WS] Attachment exceeds 25MB limit (${size}B)');
      return false;
    }
    final bytes = await file.readAsBytes();
    final mime = lookupMimeType(file.path) ?? 'application/octet-stream';
    final dataUri = 'data:$mime;base64,${base64Encode(bytes)}';
    final payload = <String, dynamic>{
      'type': type,
      if (caption != null && caption.isNotEmpty) 'message': caption,
      'attachment_name': p.basename(file.path),
      'attachment_size': size,
      'raw_file': dataUri,
    };
    _chatChannel!.sink.add(jsonEncode(payload));
    return true;
  }

  /// Sends a delete-message event per spec §9.1.
  void sendChatDelete({required int messageId, required String roomUuid}) {
    if (_chatChannel == null) {
      debugPrint('[WS] Cannot delete — not connected');
      return;
    }
    _chatChannel!.sink.add(jsonEncode({
      'type': 'delete',
      'message_id': messageId,
      'roomId': roomUuid,
    }));
  }

  // ── Notification WebSocket ──────────────────────────────────

  Future<void> connectToNotifications() async {
    if (isNotifyConnected.value) return;
    _notifyRetryCount = 0;
    await _doConnectNotifications();
  }

  Future<void> _doConnectNotifications() async {
    if (isNotifyConnected.value) return;

    final token = await _getToken();
    if (token == null) {
      debugPrint('[WS] Cannot connect notifications — no token, deferring');
      // Don't schedule a blind retry: this socket starts before login, so
      // an unauthenticated app would loop. The auth flow re-invokes
      // connectToNotifications() once tokens are written.
      return;
    }

    final uri = Uri.parse('$_wsBaseUrl/ws/notification/?token=$token');
    debugPrint('[WS] Connecting notifications: $uri');

    try {
      final channel = WebSocketChannel.connect(uri);
      await channel.ready;
      _notifyChannel = channel;
      isNotifyConnected.value = true;
      _notifyRetryCount = 0;

      channel.stream.listen(
        (data) {
          try {
            final decoded = jsonDecode(data as String) as Map<String, dynamic>;
            onNotification?.call(decoded);
          } catch (e) {
            debugPrint('[WS] Notify parse error: $e');
          }
        },
        onError: (error) {
          debugPrint('[WS] Notify error: $error');
          isNotifyConnected.value = false;
          _handleNotifyClose(channel.closeCode);
        },
        onDone: () {
          debugPrint('[WS] Notify closed (code=${channel.closeCode})');
          isNotifyConnected.value = false;
          _handleNotifyClose(channel.closeCode);
        },
      );
    } catch (e) {
      debugPrint('[WS] Notify connect failed: $e');
      isNotifyConnected.value = false;
      _scheduleNotifyReconnect();
    }
  }

  void _handleNotifyClose(int? closeCode) {
    if (closeCode != null && _terminalCloseCodes.contains(closeCode)) {
      debugPrint('[WS] Notify refused (code=$closeCode) — aborting reconnect.');
      _signOut();
      return;
    }
    _scheduleNotifyReconnect();
  }

  void _scheduleNotifyReconnect() {
    if (_notifyRetryCount >= _maxRetries) {
      debugPrint('[WS] Notify: max retries reached, giving up');
      return;
    }
    _notifyRetryCount++;
    final delay = _backoff(_notifyRetryCount);
    debugPrint('[WS] Notify reconnect in ${delay.inSeconds}s (attempt $_notifyRetryCount/$_maxRetries)');
    _notifyReconnectTimer?.cancel();
    _notifyReconnectTimer = Timer(delay, () => _doConnectNotifications());
  }

  Future<void> disconnectNotifications() async {
    _notifyReconnectTimer?.cancel();
    _notifyReconnectTimer = null;
    _notifyRetryCount = 0;
    await _notifyChannel?.sink.close();
    _notifyChannel = null;
    isNotifyConnected.value = false;
  }

  @override
  void onInit() {
    super.onInit();
    // Attempt notification connection — if a token is already persisted
    // (warm start / app relaunch) this succeeds; otherwise the auth flow
    // calls connectToNotifications() after storing tokens.
    connectToNotifications();
  }

  @override
  void onClose() {
    disconnectChat();
    disconnectNotifications();
    super.onClose();
  }
}
