import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:working_hiring/app/service/websocket/reconnecting_socket.dart';

class _FakeSink implements WebSocketSink {
  final _FakeChannel channel;
  _FakeSink(this.channel);

  @override
  void add(dynamic data) => channel.sent.add(data);

  @override
  Future<void> close([int? closeCode, String? closeReason]) async {
    channel.closedByClient = true;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _FakeChannel implements WebSocketChannel {
  final controller = StreamController<dynamic>();
  final readyCompleter = Completer<void>();
  final sent = <dynamic>[];
  bool closedByClient = false;
  int? _closeCode;

  _FakeChannel({bool readyNow = true}) {
    if (readyNow) readyCompleter.complete();
  }

  void drop([int? code]) {
    _closeCode = code;
    controller.close();
  }

  @override
  Future<void> get ready => readyCompleter.future;
  @override
  Stream<dynamic> get stream => controller.stream;
  @override
  WebSocketSink get sink => _FakeSink(this);
  @override
  int? get closeCode => _closeCode;
  @override
  String? get closeReason => null;
  @override
  String? get protocol => null;

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

Future<void> _settle() => Future<void>.delayed(const Duration(milliseconds: 5));

void main() {
  late List<_FakeChannel> channels;
  late List<Map<String, dynamic>> frames;
  late int reconnects;
  late List<int> rejected;
  Uri? uri;
  bool readyNow = true;

  ReconnectingSocket build({bool retryWithoutToken = false}) =>
      ReconnectingSocket(
        label: 'test',
        buildUri: () async => uri,
        onFrame: frames.add,
        onReconnected: () => reconnects++,
        onAuthRejected: rejected.add,
        retryWithoutToken: retryWithoutToken,
        backoff: (_) => Duration.zero,
        connector: (_) {
          final c = _FakeChannel(readyNow: readyNow);
          channels.add(c);
          return c;
        },
      );

  setUp(() {
    channels = [];
    frames = [];
    reconnects = 0;
    rejected = [];
    uri = Uri.parse('ws://x/ws/?token=t');
    readyNow = true;
  });

  test('connects, decodes frames and sends payloads', () async {
    final socket = build();
    await socket.connect();

    expect(socket.isConnected.value, isTrue);
    channels.single.controller.add(jsonEncode({'type': 'hello'}));
    await _settle();
    expect(frames.single['type'], 'hello');

    expect(socket.send({'a': 1}), isTrue);
    expect(channels.single.sent.single, jsonEncode({'a': 1}));
  });

  test('reconnects after a drop and reports it once', () async {
    final socket = build();
    await socket.connect();

    channels.first.drop(1006);
    await _settle();

    expect(channels, hasLength(2));
    expect(socket.isConnected.value, isTrue);
    expect(reconnects, 1);
  });

  test('intentional disconnect never reconnects', () async {
    final socket = build();
    await socket.connect();
    await socket.disconnect();
    channels.first.drop(1000);
    await _settle();

    expect(channels, hasLength(1));
    expect(channels.first.closedByClient, isTrue);
    expect(socket.isConnected.value, isFalse);
    expect(socket.send({'a': 1}), isFalse);
  });

  test('auth close codes stop reconnecting and report rejection', () async {
    final socket = build();
    await socket.connect();
    channels.first.drop(4001);
    await _settle();

    expect(rejected, [4001]);
    expect(channels, hasLength(1));
    expect(socket.isActive, isFalse);
  });

  test('a handshake that finishes after disconnect is closed', () async {
    readyNow = false;
    final socket = build();
    final pending = socket.connect();
    await _settle();
    await socket.disconnect();
    channels.first.readyCompleter.complete();
    await pending;
    await _settle();

    expect(socket.isConnected.value, isFalse);
    expect(channels.first.closedByClient, isTrue);
  });

  test('no token: retries only when allowed', () async {
    uri = null;
    final notify = build();
    await notify.connect();
    await _settle();
    expect(channels, isEmpty);

    final chat = build(retryWithoutToken: true);
    final pending = chat.connect();
    uri = Uri.parse('ws://x/ws/?token=t');
    await pending;
    await _settle();
    expect(channels, hasLength(1));
    await chat.disconnect();
  });

  test(
    'resume re-opens a dropped socket after retries are exhausted',
    () async {
      var online = true;
      final socket = ReconnectingSocket(
        label: 'test',
        buildUri: () async => uri,
        onFrame: frames.add,
        onAuthRejected: rejected.add,
        backoff: (_) => Duration.zero,
        connector: (_) {
          final c = _FakeChannel(readyNow: online);
          if (!online) c.readyCompleter.completeError(StateError('offline'));
          channels.add(c);
          return c;
        },
      );
      await socket.connect();
      online = false;
      channels.first.drop(1006);
      await _settle();
      await _settle();
      online = true;

      expect(socket.isConnected.value, isFalse);
      final attempts = channels.length;
      expect(attempts, 1 + ReconnectingSocket.maxRetries);

      socket.resume();
      await _settle();
      expect(socket.isConnected.value, isTrue);
    },
  );

  test('exponential backoff is clamped between 2s and 32s', () {
    expect(
      ReconnectingSocket.exponentialBackoff(1),
      const Duration(seconds: 2),
    );
    expect(
      ReconnectingSocket.exponentialBackoff(3),
      const Duration(seconds: 8),
    );
    expect(
      ReconnectingSocket.exponentialBackoff(9),
      const Duration(seconds: 32),
    );
  });
}
