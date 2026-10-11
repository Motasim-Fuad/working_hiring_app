import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:web_socket_channel/io.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

typedef SocketConnector = WebSocketChannel Function(Uri uri);

/// One self-healing WebSocket connection.
///
/// Close-code policy (spec §9.1):
///   - 4001 / 4003 → auth or permission failure; never reconnect,
///     [onAuthRejected] is called instead.
///   - anything else → exponential backoff, up to [maxRetries] attempts.
///
/// Every [connect]/[disconnect] bumps a generation counter so frames, errors
/// and late `ready` completions from a superseded channel are ignored and
/// cannot resurrect a socket the caller already closed.
class ReconnectingSocket {
  static const Set<int> terminalCloseCodes = {4001, 4003};
  static const int maxRetries = 6;

  final String label;

  /// Returns null when the user has no token yet.
  final Future<Uri?> Function() buildUri;
  final void Function(Map<String, dynamic> frame) onFrame;
  final void Function(int closeCode) onAuthRejected;

  /// Fired after a successful re-connect (not the first connect) so callers
  /// can back-fill anything missed during the outage (spec §7.5).
  final VoidCallback? onReconnected;

  /// Chat retries while the token is missing; notifications wait for the
  /// auth flow to call [connect] again instead of looping before login.
  final bool retryWithoutToken;
  final SocketConnector _connector;
  final Duration Function(int attempt) _backoff;

  ReconnectingSocket({
    required this.label,
    required this.buildUri,
    required this.onFrame,
    required this.onAuthRejected,
    this.onReconnected,
    this.retryWithoutToken = false,
    SocketConnector? connector,
    Duration Function(int attempt)? backoff,
  }) : _connector = connector ?? _defaultConnector,
       _backoff = backoff ?? exponentialBackoff;

  final RxBool isConnected = false.obs;

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _retryTimer;
  int _retryCount = 0;
  int _generation = 0;
  bool _active = false;
  bool _hasConnectedThisSession = false;

  /// True between [connect] and [disconnect], even while reconnecting.
  bool get isActive => _active;

  static WebSocketChannel _defaultConnector(Uri uri) =>
      IOWebSocketChannel.connect(
        uri,
        pingInterval: const Duration(seconds: 20),
        connectTimeout: const Duration(seconds: 15),
      );

  /// 2s → 32s (2, 4, 8, 16, 32, 32 …).
  static Duration exponentialBackoff(int attempt) =>
      Duration(seconds: (1 << attempt).clamp(2, 32));

  Future<void> connect() async {
    await disconnect();
    _active = true;
    await _open(_generation);
  }

  /// Re-opens a dropped connection immediately, e.g. when the app returns to
  /// the foreground after the retry budget was exhausted in the background.
  void resume() {
    if (!_active || isConnected.value || _channel != null) return;
    _retryTimer?.cancel();
    _retryCount = 0;
    _open(_generation);
  }

  bool send(Object payload) {
    final channel = _channel;
    if (channel == null || !isConnected.value) {
      debugPrint('[WS:$label] Cannot send — not connected');
      return false;
    }
    channel.sink.add(payload is String ? payload : jsonEncode(payload));
    return true;
  }

  Future<void> disconnect() async {
    _active = false;
    _generation++;
    _retryTimer?.cancel();
    _retryTimer = null;
    _retryCount = 0;
    _hasConnectedThisSession = false;
    final subscription = _subscription;
    final channel = _channel;
    _subscription = null;
    _channel = null;
    isConnected.value = false;
    await subscription?.cancel();
    await channel?.sink.close();
  }

  Future<void> _open(int generation) async {
    final uri = await buildUri();
    if (generation != _generation) return;
    if (uri == null) {
      debugPrint('[WS:$label] No token');
      if (retryWithoutToken) _scheduleRetry(generation);
      return;
    }

    debugPrint('[WS:$label] Connecting ${uri.replace(query: '')}');
    final WebSocketChannel channel;
    try {
      channel = _connector(uri);
      await channel.ready;
    } catch (e) {
      if (generation != _generation) return;
      debugPrint('[WS:$label] Connect failed: $e');
      _scheduleRetry(generation);
      return;
    }

    if (generation != _generation) {
      unawaited(channel.sink.close());
      return;
    }

    final isReconnect = _hasConnectedThisSession;
    _channel = channel;
    _hasConnectedThisSession = true;
    _retryCount = 0;
    isConnected.value = true;

    _subscription = channel.stream.listen(
      (data) {
        if (generation != _generation) return;
        try {
          final decoded = jsonDecode(data as String);
          if (decoded is Map<String, dynamic>) onFrame(decoded);
        } catch (e) {
          debugPrint('[WS:$label] Frame error: $e');
        }
      },
      onError: (Object error) {
        debugPrint('[WS:$label] Error: $error');
        _onClosed(generation, channel);
      },
      onDone: () => _onClosed(generation, channel),
      cancelOnError: true,
    );

    if (isReconnect) {
      try {
        onReconnected?.call();
      } catch (e) {
        debugPrint('[WS:$label] onReconnected handler error: $e');
      }
    }
  }

  void _onClosed(int generation, WebSocketChannel channel) {
    if (generation != _generation || !identical(_channel, channel)) return;
    final code = channel.closeCode;
    debugPrint('[WS:$label] Closed (code=$code)');
    _channel = null;
    _subscription = null;
    isConnected.value = false;

    if (code != null && terminalCloseCodes.contains(code)) {
      debugPrint('[WS:$label] Refused (code=$code) — not reconnecting');
      _active = false;
      onAuthRejected(code);
      return;
    }
    _scheduleRetry(generation);
  }

  void _scheduleRetry(int generation) {
    if (!_active || generation != _generation) return;
    if (_retryCount >= maxRetries) {
      debugPrint('[WS:$label] Max retries reached; waiting for resume()');
      return;
    }
    _retryCount++;
    final delay = _backoff(_retryCount);
    debugPrint(
      '[WS:$label] Reconnect in ${delay.inSeconds}s '
      '(attempt $_retryCount/$maxRetries)',
    );
    _retryTimer?.cancel();
    _retryTimer = Timer(delay, () {
      if (generation == _generation) _open(generation);
    });
  }
}
