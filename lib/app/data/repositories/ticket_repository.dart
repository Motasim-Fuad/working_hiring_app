// lib/data/repositories/ticket_repository.dart
import 'dart:io';
import 'package:working_hiring/app/service/api_service.dart';
import '../../service/api_url.dart';
import '../models/order_model.dart';
import '../models/ticket_model.dart';

class TicketRepository {
  final ApiClient _client;

  TicketRepository(this._client);

  String _fullUrl(String path) => '${ApiUrl.baseUrl}$path';

  /// Helper to extract a list from the parsed response.
  /// [parsed] may be a Map (with 'data' key) or a List.
  List<dynamic> _extractDataList(dynamic parsed) {
    if (parsed is List) return parsed;
    if (parsed is Map && parsed.containsKey('data')) {
      final data = parsed['data'];
      if (data is List) return data;
    }
    return [];
  }

  // ---------- Orders (Customer) ----------
  Future<List<OrderModel>> getCustomerOrders({String? profileType}) async {
    _client.profileType = profileType ?? 'CUSTOMER';
    final response = await _client.get(url: _fullUrl(ApiUrl.customerOrders));
    final parsed = parseApiResponse(response);
    final list = _extractDataList(parsed);
    return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ---------- Orders (Provider) ----------
  Future<List<OrderModel>> getProviderOrders({String? profileType}) async {
    _client.profileType = profileType ?? 'PROVIDER';
    final response = await _client.get(url: _fullUrl(ApiUrl.providerOrders));
    final parsed = parseApiResponse(response);
    final list = _extractDataList(parsed);
    return list.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  // ---------- Tickets ----------
  Future<List<TicketModel>> getTickets({String? profileType}) async {
    _client.profileType = profileType ?? 'CUSTOMER';
    final response = await _client.get(url: _fullUrl(ApiUrl.tickets));
    final parsed = parseApiResponse(response);
    final list = _extractDataList(parsed);
    return list.map((e) => TicketModel.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TicketModel> getTicketDetail(int id, {String? profileType}) async {
    _client.profileType = profileType ?? 'CUSTOMER';
    final response = await _client.get(url: _fullUrl(ApiUrl.ticketDetail(id)));
    final parsed = parseApiResponse(response);
    // For detail, the parsed data is a single object (Map)
    if (parsed is Map<String, dynamic>) {
      return TicketModel.fromJson(parsed);
    } else {
      throw Exception('Unexpected response format for ticket detail');
    }
  }

  Future<TicketModel> createTicket({
    required String subject,
    required String summary,
    required int orderId,
    String? attachmentPath,
    String? profileType,
  }) async {
    _client.profileType = profileType ?? 'CUSTOMER';

    final body = {
      'subject': subject,
      'summary': summary,
      'order': orderId.toString(),
    };

    if (attachmentPath != null && attachmentPath.isNotEmpty) {
      final response = await _client.multipartRequest(
        url: _fullUrl(ApiUrl.tickets),
        reqType: 'POST',
        body: body,
        multipartBody: [MultipartBody('attachment', File(attachmentPath))],
      );
      final parsed = parseApiResponse(response);
      if (parsed is Map<String, dynamic>) {
        return TicketModel.fromJson(parsed);
      } else {
        throw Exception('Unexpected response format');
      }
    }

    final response = await _client.post(
      url: _fullUrl(ApiUrl.tickets),
      body: body,
    );
    final parsed = parseApiResponse(response);
    if (parsed is Map<String, dynamic>) {
      return TicketModel.fromJson(parsed);
    } else {
      throw Exception('Unexpected response format');
    }
  }

  Future<TicketReplyModel> replyToTicket(
      int id,
      String message, {
        String? attachmentPath,
        String? profileType,
      }) async {
    _client.profileType = profileType ?? 'CUSTOMER';

    final body = {'message': message};

    if (attachmentPath != null && attachmentPath.isNotEmpty) {
      final response = await _client.multipartRequest(
        url: _fullUrl(ApiUrl.ticketReply(id)),
        reqType: 'POST',
        body: body,
        multipartBody: [MultipartBody('attachment', File(attachmentPath))],
      );
      final parsed = parseApiResponse(response);
      if (parsed is Map<String, dynamic>) {
        return TicketReplyModel.fromJson(parsed);
      } else {
        throw Exception('Unexpected response format');
      }
    }

    final response = await _client.post(
      url: _fullUrl(ApiUrl.ticketReply(id)),
      body: body,
    );
    final parsed = parseApiResponse(response);
    if (parsed is Map<String, dynamic>) {
      return TicketReplyModel.fromJson(parsed);
    } else {
      throw Exception('Unexpected response format');
    }
  }

  Future<void> closeTicket(int id, {String? profileType}) async {
    _client.profileType = profileType ?? 'CUSTOMER';
    final response = await _client.post(
      url: _fullUrl(ApiUrl.ticketClose(id)),
    );
    parseApiResponse(response); // ignore result
  }
}