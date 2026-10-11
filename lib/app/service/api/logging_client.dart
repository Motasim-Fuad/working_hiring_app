import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:working_hiring/app/service/api_service.dart';

/// A [http.BaseClient] that logs every HTTP request and response to the
/// terminal. Wrap all calls through [ApiClient] so every endpoint is captured
/// without per-method print statements.
class LoggingClient extends http.BaseClient {
  final http.Client _inner = http.Client();

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final start = DateTime.now();

    final buffer = StringBuffer();
    buffer.writeln(
      '╔═══════════════════════════════════════════════════════════',
    );
    buffer.writeln('║ API REQUEST');
    buffer.writeln('║ ${request.method} ${request.url}');
    buffer.writeln('║ Headers: ${request.headers}');
    if (request is http.Request) {
      buffer.writeln('║ Body: ${request.body}');
    } else if (request is http.MultipartRequest) {
      buffer.writeln('║ Fields: ${request.fields}');
      buffer.writeln('║ Files: ${request.files.map((f) => f.filename)}');
    }
    debugPrint(buffer.toString());

    final streamedResponse = await _inner.send(request);
    final elapsed = DateTime.now().difference(start);

    final bytes = await streamedResponse.stream.toBytes();
    final bodyStr = utf8.decode(bytes, allowMalformed: true);

    final respBuffer = StringBuffer();
    respBuffer.writeln(
      '║───────────────────────────────────────────────────────────',
    );
    respBuffer.writeln(
      '║ API RESPONSE  |  ${streamedResponse.statusCode} ${streamedResponse.reasonPhrase}  |  ${elapsed.inMilliseconds}ms',
    );
    respBuffer.writeln('║ URL: ${request.url}');
    if (bodyStr.length <= 2000) {
      respBuffer.writeln('║ Body: $bodyStr');
    } else {
      respBuffer.writeln(
        '║ Body (truncated): ${bodyStr.substring(0, 2000)}...',
      );
    }
    respBuffer.writeln(
      '╚═══════════════════════════════════════════════════════════',
    );
    debugPrint(respBuffer.toString());

    return http.StreamedResponse(
      Stream.value(bytes),
      streamedResponse.statusCode,
      contentLength: bytes.length,
      request: streamedResponse.request,
      headers: streamedResponse.headers,
      isRedirect: streamedResponse.isRedirect,
      persistentConnection: streamedResponse.persistentConnection,
      reasonPhrase: streamedResponse.reasonPhrase,
    );
  }
}
