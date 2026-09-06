import 'dart:io';

import 'package:flutter/foundation.dart';

import '../../service/api_service.dart';
import '../../service/api_url.dart';
import '../models/order_model.dart';
import '../models/activity_model.dart';

class OrderRepository {
  final ApiClient _client;

  OrderRepository(this._client);

  String _fullUrl(String path) => '${ApiUrl.baseUrl}$path';

  // ----- Customer Orders -----

  Future<List<OrderModel>> getCustomerOrders({
    String? status,
    String? query,
    int? categoryId,
    double? budget,
    String? workingDate,
    String? profileType,
  }) async {
    _client.profileType = profileType ?? 'customer';
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (query != null) params['q'] = query;
    if (categoryId != null) params['category_id'] = categoryId.toString();
    if (budget != null) params['budget'] = budget.toStringAsFixed(2);
    if (workingDate != null) params['working_date'] = workingDate;

    final url = '${_fullUrl(ApiUrl.customerOrders)}?${Uri(queryParameters: params).query}';
    final response = await _client.get(url: url);
    final data = parseApiResponse(response);
    final list = (data is List ? data : (data as Map)['results']) as List<dynamic>;
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> getCustomerOrderDetail(int id) async {
    _client.profileType = 'customer';
    final response = await _client.get(url: _fullUrl(ApiUrl.customerOrderDetail(id)));

    // 🐛 DEBUG — full raw response
    debugPrint('===== ORDER DETAIL RAW (id=$id) =====');
    debugPrint('statusCode: ${response.statusCode}');
    _printLong(response.body.toString());
    debugPrint('=====================================');

    final data = parseApiResponse(response);

    if (data is Map) {
      debugPrint('keys: ${data.keys.toList()}');
      debugPrint('confirmation_otp (raw key): ${data['confirmation_otp']}');
      debugPrint('confirmationOtp (alt key):  ${data['confirmationOtp']}');
      debugPrint('otp (alt key):              ${data['otp']}');
    }

    final order = OrderModel.fromJson(data as Map<String, dynamic>);
    debugPrint('>>> parsed order.confirmationOtp = ${order.confirmationOtp}');
    debugPrint('>>> parsed order.status          = ${order.status}');

    return order;
  }

// debugPrint boro JSON-e line truncate kore, tai chunk kore print kori
  void _printLong(String text, {int chunk = 800}) {
    for (var i = 0; i < text.length; i += chunk) {
      debugPrint(text.substring(i, i + chunk > text.length ? text.length : i + chunk));
    }
  }

  Future<void> acceptOrder(int id) async {
    _client.profileType = 'customer';
    await _client.get(url: _fullUrl(ApiUrl.customerOrderAccept(id)));
  }

  Future<void> payAndConfirm(int id) async {
    _client.profileType = 'customer';
    await _client.get(url: _fullUrl(ApiUrl.customerOrderPayAndConfirm(id)));
  }

  Future<void> sendCounterOffer(int id, double budget, String message) async {
    _client.profileType = 'customer';
    await _client.post(
      url: _fullUrl(ApiUrl.customerOrderCounter(id)),
      body: {'budget': budget.toStringAsFixed(2), 'message': message},
    );
  }

  Future<void> cancelOrder(int id, String message) async {
    _client.profileType = 'customer';
    await _client.post(
      url: _fullUrl(ApiUrl.customerOrderCancel(id)),
      body: {'message': message},
    );
  }

  Future<void> giveFeedback(int id, int rating, String review) async {
    _client.profileType = 'customer';
    await _client.post(
      url: _fullUrl(ApiUrl.customerOrderGiveFeedback(id)),
      body: {'rating': rating, 'review': review},
    );
  }

  Future<void> cancelAcceptCustomer(
      int id, int changesRequestId, String action) async {
    _client.profileType = 'customer';
    await _client.post(
      url: _fullUrl(ApiUrl.customerOrderCancelAccept(id)),
      body: {'changes_request_id': changesRequestId, 'action': action},
    );
  }

  Future<void> customerProposeNewTime(
    int id, {
    required String action,
    String? date,
    String? time,
    String? message,
    int? requestId,
    String? status,
  }) async {
    _client.profileType = 'customer';
    final body = <String, dynamic>{'action': action};
    if (date != null) body['date'] = date;
    if (time != null) body['time'] = time;
    if (message != null) body['message'] = message;
    if (requestId != null) body['request_id'] = requestId;
    if (status != null) body['status'] = status;
    await _client.post(
      url: _fullUrl(ApiUrl.customerOrderProposeNewTime(id)),
      body: body,
    );
  }

  // ----- Provider Orders -----

  Future<void> cancelAcceptProvider(
      int id, int changesRequestId, String action) async {
    _client.profileType = 'provider';
    await _client.post(
      url: _fullUrl(ApiUrl.providerOrderCancelAccept(id)),
      body: {'changes_request_id': changesRequestId, 'action': action},
    );
  }

  Future<void> providerProposeNewTime(
    int id, {
    required String action,
    String? date,
    String? time,
    String? message,
    int? requestId,
    String? status,
  }) async {
    _client.profileType = 'provider';
    final body = <String, dynamic>{'action': action};
    if (date != null) body['date'] = date;
    if (time != null) body['time'] = time;
    if (message != null) body['message'] = message;
    if (requestId != null) body['request_id'] = requestId;
    if (status != null) body['status'] = status;
    await _client.post(
      url: _fullUrl(ApiUrl.providerOrderProposeNewTime(id)),
      body: body,
    );
  }

  Future<void> setWorkHour(int id, int setHour, {String? message}) async {
    _client.profileType = 'provider';
    final body = <String, dynamic>{'set_hour': setHour};
    if (message != null) body['message'] = message;
    await _client.post(
      url: _fullUrl(ApiUrl.providerOrderSetWorkHour(id)),
      body: body,
    );
  }

  Future<List<OrderModel>> getProviderOrders({
    String? status,
    String? query,
    int? categoryId,
    double? budget,
    String? workingDate,
    String? createdAt,
    String? profileType,
  }) async {
    _client.profileType = profileType ?? 'provider';
    final params = <String, String>{};
    if (status != null) params['status'] = status;
    if (query != null) params['q'] = query;
    if (categoryId != null) params['category_id'] = categoryId.toString();
    if (budget != null) params['budget'] = budget.toStringAsFixed(2);
    if (workingDate != null) params['working_date'] = workingDate;
    if (createdAt != null) params['created_at'] = createdAt;

    final url = '${_fullUrl(ApiUrl.providerOrders)}?${Uri(queryParameters: params).query}';
    final response = await _client.get(url: url);
    final data = parseApiResponse(response);
    final list = (data is List ? data : (data as Map)['results']) as List<dynamic>;
    return list
        .map((e) => OrderModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<OrderModel> getProviderOrderDetail(int id) async {
    _client.profileType = 'provider';
    final response = await _client.get(url: _fullUrl(ApiUrl.providerOrderDetail(id)));
    final data = parseApiResponse(response);
    return OrderModel.fromJson(data as Map<String, dynamic>);
  }

  Future<void> acceptProviderOrder(int id) async {
    _client.profileType = 'provider';
    await _client.get(url: _fullUrl(ApiUrl.providerOrderAccept(id)));
  }

  Future<void> sendProviderCounterOffer(int id, double budget, String message) async {
    _client.profileType = 'provider';
    await _client.post(
      url: _fullUrl(ApiUrl.providerOrderCounter(id)),
      body: {'budget': budget.toStringAsFixed(2), 'message': message},
    );
  }

  Future<String> startWork(
      int id,
      String address,
      double lat,
      double lng,
      ) async {
    _client.profileType = 'provider';

    final response = await _client.post(
      url: _fullUrl(ApiUrl.providerOrderStartWork(id)),
      body: {
        'start': true,
        'address': address,
        'lat': lat,
        'lng': lng,
      },
    );

    parseApiResponse(response);

    return response.body['message'] ?? '';
  }

  Future<void> completeWork(int id, String otp) async {
    _client.profileType = 'provider';

    final response = await _client.post(
      url: _fullUrl(ApiUrl.providerOrderComplete(id)),
      body: {
        'otp': otp,
      },
    );

    parseApiResponse(response);
  }

  Future<void> cancelProviderOrder(int id, String message) async {
    _client.profileType = 'provider';
    await _client.post(
      url: _fullUrl(ApiUrl.providerOrderCancel(id)),
      body: {'message': message},
    );
  }

  Future<void> giveProviderFeedback(int id, int rating, String review) async {
    _client.profileType = 'provider';
    await _client.post(
      url: _fullUrl(ApiUrl.providerOrderGiveFeedback(id)),
      body: {'rating': rating, 'review': review},
    );
  }

  // ----- Order Creation -----

  /// Creates a customer order. Pass [attachments] for reference photos/files
  /// and the request is sent as multipart/form-data per API spec §7.2.
  ///
  /// Returns the created order so callers can pre-subscribe to the new chat
  /// room over WS — the `ORDER_CREATED` broadcast (WS spec §8) fires before
  /// the customer's client could possibly be connected, so without the
  /// returned id the event card has to be back-filled via REST history.
  Future<OrderModel> createOrder(
    Map<String, dynamic> data, {
    List<File>? attachments,
  }) async {
    _client.profileType = 'customer';

    if (attachments == null || attachments.isEmpty) {
      final response = await _client.post(
        url: _fullUrl(ApiUrl.orderCreate),
        body: data,
      );
      final body = parseApiResponse(response);
      return OrderModel.fromJson(body as Map<String, dynamic>);
    }

    // Multipart: stringify every field; the server parses decimals/ints
    // from the form value strings.
    final fields = <String, String>{};
    data.forEach((key, value) {
      if (value == null) return;
      fields[key] = value.toString();
    });
    final response = await _client.multipartRequest(
      url: _fullUrl(ApiUrl.orderCreate),
      reqType: 'POST',
      body: fields,
      multipartBody: [
        for (final f in attachments) MultipartBody('attachments', f),
      ],
    );
    final body = parseApiResponse(response);
    return OrderModel.fromJson(body as Map<String, dynamic>);
  }

  // ----- Payment Transactions (§7.4) -----

  Future<List<Map<String, dynamic>>> getPaymentTransactions({
    String? profileType,
  }) async {
    _client.profileType = profileType;
    final response = await _client.get(url: _fullUrl(ApiUrl.paymentTransactions));
    final body = response.body;
    if (body is Map && body['status'] == true) {
      final list = (body['results'] as List?) ?? (body['data'] as List?) ?? [];
      return list.cast<Map<String, dynamic>>();
    }
    throw ApiException(_extractMessage(response));
  }

  // ----- Activity / Dashboard Stats -----

  Future<ActivityModel> getActivity({String? profileType}) async {
    _client.profileType = profileType ?? 'customer';
    final response = await _client.get(url: _fullUrl(ApiUrl.activity));
    final data = parseApiResponse(response);
    return ActivityModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<OrderModel>> getNextJobOrders({String? profileType}) async {
    _client.profileType = profileType ?? 'provider';
    final response = await _client.get(url: _fullUrl(ApiUrl.providerNextJobOrders));
    final data = parseApiResponse(response);
    final list = data as List<dynamic>;
    return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Map<String, dynamic>> getEarningsOverview() async {
    _client.profileType = 'provider';
    final response = await _client.get(url: _fullUrl(ApiUrl.providerEarningsOverview));
    final body = response.body;
    if (body is Map && body['status'] == true) {
      return {
        'data': body['data'],
        'reports': body['reports'],
      };
    }
    throw ApiException(_extractMessage(response));
  }

  Future<Map<String, dynamic>> getEarningsTransactions() async {
    _client.profileType = 'provider';
    final response = await _client.get(url: _fullUrl(ApiUrl.providerEarningsTransactions));
    final body = response.body;
    if (body is Map && body['status'] == true) {
      return body['data'] as Map<String, dynamic>? ?? {};
    }
    throw ApiException(_extractMessage(response));
  }

  String _extractMessage(dynamic response) {
    try {
      final body = response.body;
      if (body is Map) {
        final msg = body['message'];
        if (msg is String) return msg;
      }
    } catch (_) {}
    return 'Something went wrong. Please try again.';
  }
}
