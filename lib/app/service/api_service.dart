import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:get/get_connect/http/src/request/request.dart';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';

import 'package:working_hiring/app/core/constants/app_constants.dart';
import 'package:working_hiring/app/service/api_url.dart';
import 'package:working_hiring/app/service/logger.dart';
import 'package:working_hiring/app/service/shared_prefs_helper.dart';
import 'package:working_hiring/app/service/api/logging_client.dart';
import 'package:working_hiring/app/service/api/api_exception.dart';
import 'package:working_hiring/app/service/api/multipart_body.dart';
export 'package:working_hiring/app/service/api/logging_client.dart';
export 'package:working_hiring/app/service/api/api_exception.dart';
export 'package:working_hiring/app/service/api/multipart_body.dart';

final log = logger(ApiClient);

Map<String, String> basicHeaderInfo() {
  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
  };
}

Future<Map<String, String>> bearerHeaderInfo({String? profileType}) async {
  final token = await SharedPrefsHelper.getString(AppConstants.token);
  final headers = {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.authorizationHeader: "Bearer $token",
  };
  if (profileType != null && profileType.isNotEmpty) {
    headers['profile-type'] = profileType;
  }
  return headers;
}

Future<Map<String, String>> childBearerHeaderInfo() async {
  var token = await SharedPrefsHelper.getString(AppConstants.childToken);
  if (token.isEmpty) {
    // Fallback to parent token when child token is not available
    // (e.g. parent mode after child registration, before child login).
    token = await SharedPrefsHelper.getString(AppConstants.token);
    debugPrint("Child token empty, falling back to parent token");
  }
  return {
    HttpHeaders.acceptHeader: "application/json",
    HttpHeaders.contentTypeHeader: "application/json",
    HttpHeaders.authorizationHeader: "Bearer $token",
  };
}

String noInternetConnection = "No internet connection.!";

/// Decodes [body] as JSON. On failure, logs [url] and the raw body before
/// rethrowing so the failing endpoint and server response are visible in logs.
dynamic safeJsonDecode(String body, String url) {
  try {
    return jsonDecode(body);
  } on FormatException {
    log.e('JSON parse failed for URL: $url');
    log.e(
      'Response body (first 500 chars): ${body.substring(0, body.length > 500 ? 500 : body.length)}',
    );
    rethrow;
  }
}

class ApiClient {
  final http.Client _client = LoggingClient();

  /// Set this before making calls that require a profile-type header.
  /// Valid values: "customer" or "provider".
  String? profileType;

  bool _isRefreshing = false;

  /// Attempts a silent token refresh. Returns true if successful.
  Future<bool> _tryRefreshToken() async {
    if (_isRefreshing) return false;
    _isRefreshing = true;
    try {
      final refresh = await SharedPrefsHelper.getString(
        AppConstants.refreshToken,
      );
      if (refresh.isEmpty) return false;
      final response = await _client.post(
        Uri.parse('${ApiUrl.baseUrl}${ApiUrl.refreshToken}'),
        body: jsonEncode({'refresh': refresh}),
        headers: basicHeaderInfo(),
      );
      if (response.statusCode == 200) {
        final body = safeJsonDecode(response.body, ApiUrl.refreshToken);
        if (body is Map && body['status'] == true) {
          final data = body['data'] as Map<String, dynamic>?;
          final newAccess = data?['access'] as String?;
          if (newAccess != null && newAccess.isNotEmpty) {
            await SharedPrefsHelper.setString(AppConstants.token, newAccess);
            return true;
          }
        }
      }
      return false;
    } catch (_) {
      return false;
    } finally {
      _isRefreshing = false;
    }
  }

  void _redirectToLogin() {
    SharedPrefsHelper.clearAll();
    Get.offAllNamed('/login');
  }

  Future<Response> get({
    required String url,
    bool isBasic = false,
    bool useChildToken = false,
    int duration = 30,
    bool showResult = true,
    BuildContext? context,
  }) async {
    if (showResult) {
      log.i('GET request');
      log.i(url);
    }

    try {
      Future<http.Response> makeCall() async {
        final headers = isBasic
            ? basicHeaderInfo()
            : useChildToken
            ? await childBearerHeaderInfo()
            : await bearerHeaderInfo(profileType: profileType);
        return _client
            .get(Uri.parse(url), headers: headers)
            .timeout(Duration(seconds: duration));
      }

      var response = await makeCall();

      if (!isBasic && response.statusCode == 401) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          response = await makeCall();
          if (response.statusCode == 401) _redirectToLogin();
        } else {
          _redirectToLogin();
        }
      }

      if (showResult) {
        log.d("Body => ${response.body}");
        log.d("Status Code => ${response.statusCode}");

        log.i('GET response');
      }

      var body = safeJsonDecode(response.body, url);

      return Response(
        body: body ?? response.body,
        bodyString: response.body.toString(),
        request: Request(
          headers: response.request!.headers,
          method: response.request!.method,
          url: response.request!.url,
        ),
        headers: response.headers,
        statusCode: response.statusCode,
        statusText: response.reasonPhrase,
      );
    } on TimeoutException {
      log.e('Error Alert Timeout Exception');

      log.e('Time out exception$url');

      return Response(
        body: {},
        statusCode: 400,
        statusText: 'Time out exception $url',
      );
    } on http.ClientException catch (err, stackrace) {
      log.e('Error Alert Client Exception');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());
      return Response(
        body: {},
        statusCode: 400,
        statusText: 'Error Alert Client Exception $url',
      );
    } catch (e) {
      log.e('Other Error Alert');

      log.e('unlisted error received for URL: $url');

      log.e("$e");

      return Response(
        body: {},
        statusCode: 400,
        statusText: "Something went wrong",
      );
    }
  }

  Future<Response> post({
    required String url,
    bool isBasic = false,
    bool useChildToken = false,
    Map<String, dynamic>? body,
    BuildContext? context,
    int duration = 300000,
    bool showResult = true,
  }) async {
    try {
      if (showResult) {
        log.i('POST request');

        log.i("URL => $url");

        log.i("Body => $body");
      }

      final encodedBody = jsonEncode(body);
      Future<http.Response> makePostCall() async {
        final headers = isBasic
            ? basicHeaderInfo()
            : useChildToken
            ? await childBearerHeaderInfo()
            : await bearerHeaderInfo(profileType: profileType);
        return _client
            .post(Uri.parse(url), body: encodedBody, headers: headers)
            .timeout(Duration(seconds: duration));
      }

      var response = await makePostCall();

      if (!isBasic && response.statusCode == 401) {
        final refreshed = await _tryRefreshToken();
        if (refreshed) {
          response = await makePostCall();
          if (response.statusCode == 401) _redirectToLogin();
        } else {
          _redirectToLogin();
        }
      }

      if (showResult) {
        log.i("response.body => ${response.body}");
      }

      log.i("response.statusCode => ${response.statusCode}");

      log.i('POST response');

      body = safeJsonDecode(response.body, url);

      return Response(
        body: body ?? response.body,
        bodyString: response.body.toString(),
        request: Request(
          headers: response.request!.headers,
          method: response.request!.method,
          url: response.request!.url,
        ),
        headers: response.headers,
        statusCode: response.statusCode,
        statusText: response.reasonPhrase,
      );
    } on TimeoutException {
      log.e('Error Alert Timeout Exception');

      log.e('Time out exception$url');

      return Response(
        body: {},
        statusCode: 400,
        statusText: 'Time out exception $url',
      );
    } on http.ClientException catch (err, stackrace) {
      log.e('Error Alert Client Exception');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return Response(
        body: {},
        statusCode: 400,
        statusText: 'client exception hitted $url',
      );
    } catch (e) {
      log.e('Other Error Alert');

      log.e('unlisted error received for URL: $url');

      log.e("$e");

      return Response(
        body: {},
        statusCode: 400,
        statusText: 'Other Error Alert',
      );
    }
  }

  Future<Response> patch({
    required String url,
    bool isBasic = false,
    Map<String, dynamic>? body,
    int duration = 30,
    bool showResult = true,
  }) async {
    try {
      if (showResult) {
        log.i('PATCH request');

        log.i("URL => $url");

        log.i("Body => $body");
      }

      final response = await _client
          .patch(
            Uri.parse(url),
            body: jsonEncode(body),
            headers: isBasic
                ? basicHeaderInfo()
                : await bearerHeaderInfo(profileType: profileType),
          )
          .timeout(Duration(seconds: duration));

      if (showResult) {
        log.i("response.body => ${response.body}");
        log.i("response.statusCode => ${response.statusCode}");
        log.i('PATCH response');
      }

      body = safeJsonDecode(response.body, url);

      return Response(
        body: body ?? response.body,
        bodyString: response.body.toString(),
        request: Request(
          headers: response.request!.headers,
          method: response.request!.method,
          url: response.request!.url,
        ),
        headers: response.headers,
        statusCode: response.statusCode,
        statusText: response.reasonPhrase,
      );
    } on TimeoutException {
      log.e('Error Alert Timeout Exception');

      log.e('Time out exception$url');

      return Response(
        body: {},
        statusCode: 400,
        statusText: 'Time out exception $url',
      );
    } on http.ClientException catch (err, stackrace) {
      log.e('Error Alert Client Exception');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return Response(
        body: {},
        statusCode: 400,
        statusText: 'client exception hitted $url',
      );
    } catch (e) {
      log.e('Other Error Alert');

      log.e('unlisted error received for URL: $url');

      log.e("$e");

      return Response(
        body: {},
        statusCode: 400,
        statusText: 'Other Error Alert',
      );
    }
  }

  Future<Response> postPlainText({
    required String url,
    bool isBasic = false,
    Map<String, dynamic>? body,
    required BuildContext context,
    int duration = 30,
    bool showResult = true,
  }) async {
    try {
      if (showResult) {
        log.i('POST PLAIN TEXT request');

        log.i("URL => $url");

        log.i("Body => $body");
      }

      final response = await _client
          .post(
            Uri.parse(url),
            body: jsonEncode(body),
            headers: isBasic ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));

      if (showResult) {
        log.i("response.body => ${response.body}");
      }

      log.i("response.statusCode => ${response.statusCode}");

      log.i('POST PLAIN TEXT response');

      return Response(
        body: response.body,
        bodyString: response.body.toString(),
        request: Request(
          headers: response.request!.headers,
          method: response.request!.method,
          url: response.request!.url,
        ),
        headers: response.headers,
        statusCode: response.statusCode,
        statusText: response.reasonPhrase,
      );
    } on TimeoutException {
      log.e('Error Alert Timeout Exception');

      log.e('Time out exception$url');

      return Response(
        body: {},
        statusCode: 400,
        statusText: 'Time out exception $url',
      );
    } on http.ClientException catch (err, stackrace) {
      log.e('Error Alert Client Exception');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return Response(
        body: {},
        statusCode: 400,
        statusText: 'client exception hitted $url',
      );
    } catch (e) {
      log.e('Other Error Alert');

      log.e('unlisted error received');

      log.e("$e");

      return const Response(
        body: {},
        statusCode: 400,
        statusText: 'Other Error Alert',
      );
    }
  }

  Future<Map<String, dynamic>?> paramGet({
    String? url,
    bool? isBasic,
    Map<String, String>? body,
    int code = 200,
    int duration = 15,
    bool showResult = true,
  }) async {
    log.i('GET (params) request');

    log.i("##body given --> ");

    if (showResult) {
      log.i(body);
    }

    log.i("##url list --> $url");

    log.i('GET (params) request end');

    try {
      final response = await _client
          .get(
            Uri.parse(url!).replace(queryParameters: body),
            headers: isBasic! ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(const Duration(seconds: 15));

      log.i('GET (params) response');

      if (showResult) {
        log.i(response.body.toString());
      }

      log.i('GET (params) response end');

      if (response.statusCode == code) {
        return safeJsonDecode(response.body, url);
      } else {
        log.e('Error Alert');

        log.e(
          'unknown error hitted in status code  ${safeJsonDecode(response.body, url)}',
        );

        return null;
      }
    } on TimeoutException {
      log.e('Error Alert');

      log.e('Time out exception$url');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('Error Alert');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('Error Alert');

      log.e('#url->$url||#body -> $body');

      log.e('unlisted error received');

      log.e("$e");

      return null;
    }
  }

  Future<Response> multipartRequest({
    required String url,
    required String reqType,
    bool isBasic = false,
    Map<String, String>? body,
    required List<MultipartBody> multipartBody,
    bool showResult = true,
  }) async {
    try {
      if (showResult) {
        log.i('MULTIPART $reqType request');

        log.i("===> URL => $url");

        log.i("body: $body");
      }

      final request = http.MultipartRequest(reqType, Uri.parse(url))
        ..fields.addAll(body ?? {})
        ..headers.addAll(
          isBasic
              ? basicHeaderInfo()
              : await bearerHeaderInfo(profileType: profileType),
        );
      request.headers.remove(HttpHeaders.contentTypeHeader);

      for (final element in multipartBody) {
        if (element.file.path.isEmpty) continue;

        final mimeType = lookupMimeType(element.file.path);
        final multipartImg = await http.MultipartFile.fromPath(
          element.key,
          element.file.path,
          contentType: MediaType.parse(mimeType!),
        );
        request.files.add(multipartImg);
      }

      var response = await _client.send(request);
      var jsonData = await http.Response.fromStream(response);

      if (showResult) {
        log.i("===> Response Body => ${jsonData.body}");

        log.i("===> Status Code =>${response.statusCode}");

        log.i('MULTIPART $reqType response');
      }

      var decodeBody = safeJsonDecode(jsonData.body, url);

      return Response(body: decodeBody, statusCode: response.statusCode);
    } on TimeoutException {
      log.e('Error Alert Timeout Exception');

      log.e('Time out exception$url');

      return const Response(
        body: {},
        statusCode: 400,
        statusText: 'Error Alert Timeout Exception',
      );
    } on http.ClientException catch (err, stackrace) {
      log.e('Error Alert Client Exception');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return const Response(
        body: {},
        statusCode: 400,
        statusText: 'client exception hitted',
      );
    } catch (e) {
      log.e('Other Error Alert');

      log.e('unlisted error received for URL: $url');

      log.e("$e");

      return const Response(
        body: {},
        statusCode: 400,
        statusText: 'Other Error Alert',
      );
    }
  }

  Future<Map<String, dynamic>?> deleteHelper({
    String? url,
    bool? isBasic,
    int code = 202,
    bool isLogout = false,
    int duration = 15,
    bool showResult = false,
  }) async {
    if (url == null) return null;

    log.i('DELETE request');
    log.i(url);
    log.i('DELETE request end');

    try {
      var headers = (isBasic ?? false)
          ? basicHeaderInfo()
          : await bearerHeaderInfo(profileType: profileType);

      if (isLogout) {}

      log.i(headers);

      final response = await _client
          .delete(Uri.parse(url), headers: headers)
          .timeout(Duration(seconds: duration));

      log.i('DELETE response');

      if (showResult) {
        log.i(response.body.toString());
      }

      log.i(response.statusCode);

      log.i('DELETE response end');

      if (response.statusCode == code) {
        if (response.body.isEmpty) return {};
        try {
          return jsonDecode(response.body);
        } catch (_) {
          return {};
        }
      } else {
        log.e('Error Alert');
        log.e('unknown error hitted in status code ${response.statusCode}');
        return null;
      }
    } on TimeoutException {
      log.e('Error Alert');
      log.e('Time out exception$url');
      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('Error Alert');
      log.e('client exception hitted');
      log.e(err.toString());
      log.e(stackrace.toString());
      return null;
    } catch (e) {
      log.e('Error Alert');
      log.e('unlisted error received for URL: $url');
      log.e("$e");
      return null;
    }
  }

  Future<Map<String, dynamic>?> delete({
    String? url,
    bool? isBasic,
    int code = 202,
    bool isLogout = false,
    int duration = 15,
    bool showResult = false,
  }) async {
    log.i('DELETE request');

    log.i(url);

    log.i('DELETE request end');

    try {
      var headers = isBasic! ? basicHeaderInfo() : await bearerHeaderInfo();

      if (isLogout) {}

      log.i(headers);

      final response = await _client
          .delete(Uri.parse(url!), headers: headers)
          .timeout(Duration(seconds: duration));

      log.i('DELETE response');

      if (showResult) {
        log.i(response.body.toString());
      }

      log.i(response.statusCode);

      log.i('DELETE response');

      if (response.statusCode == code) {
        return jsonDecode(response.body);
      } else {
        log.e('Error Alert');

        log.e(
          'unknown error hitted in status code  ${jsonDecode(response.body)}',
        );

        return null;
      }
    } on TimeoutException {
      log.e('Error Alert');

      log.e('Time out exception$url');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('Error Alert');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('Error Alert');

      log.e('unlisted error received for URL: $url');

      log.e("$e");

      return null;
    }
  }

  /// Multipart request that supports REPEATED form fields (same key multiple
  /// times) — needed when Django reads values with `request.POST.getlist(...)`,
  /// e.g. `service_category=1&service_category=2`. The standard
  /// [multipartRequest] stores fields in a Map, so it cannot express repeats;
  /// this builds the multipart body manually instead.
  ///
  /// [singleFields]   : normal one-value fields (company_name, hourly_rate…)
  /// [repeatedFields] : key → list of values, each emitted as its own part
  /// [files]          : file parts (logo, etc.)
  Future<Response> multipartRepeated({
    required String url,
    required String reqType,
    Map<String, String>? singleFields,
    Map<String, List<String>>? repeatedFields,
    List<MultipartBody> files = const [],
    bool showResult = true,
  }) async {
    try {
      if (showResult) {
        log.i('MULTIPART(repeated) $reqType request');
        log.i('===> URL => $url');
        log.i('single: $singleFields');
        log.i('repeated: $repeatedFields');
      }

      final uri = Uri.parse(url);
      final headers = await bearerHeaderInfo(profileType: profileType);
      headers.remove(HttpHeaders.contentTypeHeader);

      final boundary =
          '----dartFormBoundary${DateTime.now().millisecondsSinceEpoch}';
      headers[HttpHeaders.contentTypeHeader] =
          'multipart/form-data; boundary=$boundary';

      final body = <int>[];
      void writeLine(String s) => body.addAll(utf8.encode('$s\r\n'));

      singleFields?.forEach((key, value) {
        writeLine('--$boundary');
        writeLine('Content-Disposition: form-data; name="$key"');
        writeLine('');
        writeLine(value);
      });

      repeatedFields?.forEach((key, values) {
        for (final v in values) {
          writeLine('--$boundary');
          writeLine('Content-Disposition: form-data; name="$key"');
          writeLine('');
          writeLine(v);
        }
      });

      for (final f in files) {
        if (f.file.path.isEmpty) continue;
        final mimeType =
            lookupMimeType(f.file.path) ?? 'application/octet-stream';
        final filename = f.file.path.split('/').last;
        final bytes = await f.file.readAsBytes();
        writeLine('--$boundary');
        writeLine(
          'Content-Disposition: form-data; name="${f.key}"; filename="$filename"',
        );
        writeLine('Content-Type: $mimeType');
        writeLine('');
        body.addAll(bytes);
        body.addAll(utf8.encode('\r\n'));
      }

      writeLine('--$boundary--');

      // Use a StreamedRequest so the raw (binary) body — which contains image
      // bytes — is sent as-is. http.Request treats bodyBytes via an encoding
      // and throws "Invalid UTF-8 byte" on binary file data.
      final streamedReq = http.StreamedRequest(reqType, uri)
        ..headers.addAll(headers)
        ..contentLength = body.length;
      streamedReq.sink.add(body);
      unawaited(streamedReq.sink.close());

      final streamed = await _client.send(streamedReq);
      // Decode the response bytes ourselves as UTF-8. http.Response.body uses
      // latin1 by default unless the server sends a charset, which throws
      // "Invalid UTF-8 byte" on UTF-8 payloads.
      final respBytes = await streamed.stream.toBytes();
      final respBody = utf8.decode(respBytes, allowMalformed: true);

      if (showResult) {
        log.i('===> Response Body => $respBody');
        log.i('===> Status Code => ${streamed.statusCode}');
        log.i('MULTIPART(repeated) $reqType request end');
      }

      final decodeBody = safeJsonDecode(respBody, url);
      return Response(body: decodeBody, statusCode: streamed.statusCode);
    } catch (e) {
      log.e('multipartRepeated error: $e');
      return const Response(
        body: {},
        statusCode: 400,
        statusText: 'multipartRepeated error',
      );
    }
  }

  Future<Map<String, dynamic>?> put({
    String? url,
    bool? isBasic,
    Map<String, dynamic>? body,
    int code = 202,
    int duration = 15,
    bool showResult = false,
  }) async {
    try {
      log.i('PUT request');

      log.i(url);

      log.i(body);

      log.i('PUT request end');

      final response = await _client
          .put(
            Uri.parse(url!),
            body: jsonEncode(body),
            headers: isBasic! ? basicHeaderInfo() : await bearerHeaderInfo(),
          )
          .timeout(Duration(seconds: duration));

      log.i('PUT response');

      if (showResult) {
        log.i(response.body);
      }

      log.i(response.statusCode);

      log.i('PUT response end');

      if (response.statusCode == code) {
        return safeJsonDecode(response.body, url);
      } else {
        log.e('Error Alert');

        log.e(
          'unknown error hitted in status code  ${safeJsonDecode(response.body, url)}',
        );

        return null;
      }
    } on TimeoutException {
      log.e('Error Alert');

      log.e('Time out exception$url');

      return null;
    } on http.ClientException catch (err, stackrace) {
      log.e('Error Alert');

      log.e('client exception hitted');

      log.e(err.toString());

      log.e(stackrace.toString());

      return null;
    } catch (e) {
      log.e('Error Alert');

      log.e('unlisted catch error received for URL: $url');

      log.e(e.toString());

      return null;
    }
  }
}

/// Parses the backend's standard response envelope.
/// Backend returns: {"status": true/false, "data": {...}, "message": "..."}
/// Throws [ApiException] if status is false, otherwise returns the inner data.
dynamic parseApiResponse(Response response) {
  final body = response.body;
  if (body is Map && body['status'] == true) {
    final data = body['data'];
    if (data != null) return data;
    // Paginated endpoints (notifications, chat history) put `results` on the
    // envelope instead of wrapping the list in `data`.
    if (body.containsKey('results')) return body;
    return data;
  }
  final message = _extractErrorMessage(response);
  throw ApiException(message, body);
}

/// Extracts a human-readable error message from backend responses.
///
/// The backend returns errors in several formats:
/// - {"status": false, "message": "plain text"}
/// - {"status": false, "message": {"field_name": "This field is required."}}
/// - {"detail": "Authentication credentials were not provided."}
/// - Non-Map responses (HTML error pages, etc.)
String _extractErrorMessage(Response response) {
  final body = response.body;
  if (body is! Map) {
    if (response.statusCode == 401 || response.statusCode == 403) {
      return 'Session expired. Please log in again.';
    }
    if (response.statusCode == 500) {
      return 'Server error. Please try again later.';
    }
    return 'Something went wrong. Please try again.';
  }

  final rawMessage = body['message'];

  if (rawMessage == null) {
    if (body['detail'] is String) return body['detail'];
    for (final value in body.values) {
      if (value is List && value.isNotEmpty) return value.first.toString();
      if (value is String && value.isNotEmpty) return value;
    }
    return 'Something went wrong. Please try again.';
  }

  if (rawMessage is String) return rawMessage;

  if (rawMessage is Map) {
    final parts = <String>[];
    for (final entry in rawMessage.entries) {
      final key = entry.key.toString();
      final value = entry.value.toString();
      if (key == 'non_field_errors' || key == 'detail') {
        parts.add(value);
      } else {
        parts.add('$key: $value');
      }
    }
    if (parts.isNotEmpty) return parts.join('\n');
  }

  return rawMessage.toString();
}
