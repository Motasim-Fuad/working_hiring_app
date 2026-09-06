import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:get/get_navigation/src/root/parse_route.dart';
import 'package:working_hiring/app/data/models/saved_helper_model.dart';
import 'dart:convert';
import '../../service/api_service.dart';
import '../../service/api_url.dart';

class HelperListModel {
  final int id;
  final String? companyName;
  final String? photo;
  final double? hourlyRate;
  final double? rating;
  final int? totalTasks;
  final String? location;
  final double? distance;
  final bool? isVerified;
  final bool? availabilityStatus;
  final List<String>? categories;
  final String? bio;

  HelperListModel({
    required this.id,
    this.companyName,
    this.photo,
    this.hourlyRate,
    this.rating,
    this.totalTasks,
    this.location,
    this.distance,
    this.isVerified,
    this.availabilityStatus,
    this.categories,
    this.bio,
  });

  String get name => companyName ?? 'Unknown';
  String get avatarUrl => photo ?? '';
  String get categoryText => categories?.join(', ') ?? 'General';

  factory HelperListModel.fromJson(Map<String, dynamic> json) {
    String? buildLocation(Map<String, dynamic>? loc) {
      if (loc == null) return null;
      final parts = [loc['address_line'], loc['city']].where((e) => e != null && e.toString().isNotEmpty);
      return parts.isNotEmpty ? parts.join(', ') : null;
    }

    List<String>? buildCategories(List<dynamic>? cats) {
      if (cats == null) return null;
      return cats
          .map((e) => (e is Map<String, dynamic>) ? (e['title'] ?? '').toString() : e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return HelperListModel(
      id: json['id'] as int,
      companyName: json['company_name'] as String?,
      photo: json['logo'] as String?,
      hourlyRate: _parseDouble(json['hourly_rate']),
      rating: _parseDouble(json['rating']),
      totalTasks: _parseInt(json['total_jobs']),
      location: buildLocation(json['office_location'] as Map<String, dynamic>?),
      distance: _parseDouble(json['distance_km']),
      isVerified: json['is_verified'] as bool?,
      availabilityStatus: json['availability_status'] as bool?,
      categories: buildCategories(json['service_category'] as List<dynamic>?),
      bio: json['details'] as String?,
    );
  }
}

class HelperDetailModel {
  final int id;
  final String? companyName;
  final String? photo;
  final double? hourlyRate;
  final double? minBookingHours;
  final double? rating;
  final int? totalTasks;
  final String? location;
  final double? distance;
  final String? bio;
  final bool? isVerified;
  final List<String>? categories;
  final List<dynamic>? portfolio;
  final List<dynamic>? reviews;

  HelperDetailModel({
    required this.id,
    this.companyName,
    this.photo,
    this.hourlyRate,
    this.minBookingHours,
    this.rating,
    this.totalTasks,
    this.location,
    this.distance,
    this.bio,
    this.isVerified,
    this.categories,
    this.portfolio,
    this.reviews,
  });

  factory HelperDetailModel.fromJson(Map<String, dynamic> json) {
    String? buildLocation(Map<String, dynamic>? loc) {
      if (loc == null) return null;
      final parts = [loc['address_line'], loc['city']].where((e) => e != null && e.toString().isNotEmpty);
      return parts.isNotEmpty ? parts.join(', ') : null;
    }

    List<String>? buildCategories(List<dynamic>? cats) {
      if (cats == null) return null;
      return cats
          .map((e) => (e is Map<String, dynamic>) ? (e['title'] ?? '').toString() : e.toString())
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return HelperDetailModel(
      id: json['id'] as int,
      companyName: json['company_name'] as String?,
      photo: json['logo'] as String?,
      hourlyRate: _parseDouble(json['hourly_rate']),
      minBookingHours: _parseDouble(json['min_booking_hours']),
      rating: _parseDouble(json['rating']),
      totalTasks: _parseInt(json['total_jobs']),
      location: buildLocation(json['office_location'] as Map<String, dynamic>?),
      distance: _parseDouble(json['distance_km']),
      bio: json['details'] as String?,
      isVerified: json['is_verified'] as bool?,
      categories: buildCategories(json['service_category'] as List<dynamic>?),
      portfolio: json['portfolio'] as List<dynamic>?,
      reviews: json['reviews_and_ratings'] as List<dynamic>?,
    );
  }
}

double? _parseDouble(dynamic value) {
  if (value == null) return null;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

int? _parseInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

class HelperListResult {
  final List<HelperListModel> helpers;
  final String? nextUrl;

  HelperListResult({required this.helpers, this.nextUrl});
}






class HelperRepository {
  final ApiClient _client;

  HelperRepository(this._client);

  String _fullUrl(String path) => '${ApiUrl.baseUrl}$path';

  // ---------- GET Helpers ----------
  Future<HelperListResult> getHelpers({
    String? query,
    int? categoryId,
    double? distanceRadius,
    double? budget,
    double? rating,
    bool? availability,
    String? sortBy,
    String? profileType,
  }) async {
    _client.profileType = profileType;
    final params = <String, String>{};
    if (query != null && query.isNotEmpty) params['q'] = query;
    if (categoryId != null) params['category_id'] = categoryId.toString();
    if (distanceRadius != null) params['distance_radius'] = distanceRadius.toString();
    if (budget != null) params['budget'] = budget.toString();
    if (rating != null) params['rating'] = rating.toString();
    if (availability != null) params['availability'] = availability ? 'True' : 'False';
    if (sortBy != null) params['sort_by'] = sortBy;

    final url = '${_fullUrl(ApiUrl.helpers)}?${Uri(queryParameters: params).query}';
    final response = await _client.get(url: url);
    final decoded = response.body;
    final isPaginated = decoded is Map && decoded.containsKey('next');
    final data = parseApiResponse(response);
    final list = data is List ? data : (data as Map)['results'] as List;
    final helpers = list
        .map((e) => HelperListModel.fromJson(e as Map<String, dynamic>))
        .toList();
    String? nextUrl;
    if (isPaginated && decoded['next'] is String) {
      nextUrl = decoded['next'] as String;
    }
    return HelperListResult(helpers: helpers, nextUrl: nextUrl);
  }

  Future<HelperListResult> getHelpersFromUrl(String url,
      {String? profileType}) async {
    _client.profileType = profileType;
    final response = await _client.get(url: url);
    final decoded = response.body;
    final isPaginated = decoded is Map && decoded.containsKey('next');
    final data = parseApiResponse(response);
    final list = data is List ? data : (data as Map)['results'] as List;
    final helpers = list
        .map((e) => HelperListModel.fromJson(e as Map<String, dynamic>))
        .toList();
    String? nextUrl;
    if (isPaginated && decoded['next'] is String) {
      nextUrl = decoded['next'] as String;
    }
    return HelperListResult(helpers: helpers, nextUrl: nextUrl);
  }

  Future<HelperDetailModel> getHelperDetail(int id,
      {String? profileType}) async {
    _client.profileType = profileType;
    final response =
    await _client.get(url: '${_fullUrl(ApiUrl.helpers)}$id/');
    final data = parseApiResponse(response);
    return HelperDetailModel.fromJson(data as Map<String, dynamic>);
  }

  Future<List<HelperListModel>> getRecommendedHelpers(
      {double? lat, double? lng, String? profileType}) async {
    _client.profileType = profileType;
    var url = _fullUrl(ApiUrl.recommendedHelpers);
    if (lat != null && lng != null) {
      url += '?current_location=$lat,$lng';
    }
    final response = await _client.get(url: url);
    final data = parseApiResponse(response);
    final list = data as List<dynamic>;
    return list
        .map((e) => HelperListModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  // ---------- SAVED HELPERS ----------

  /// Get the list of saved helpers.
  /// Response format: {"status":true, "data":[{"id":3, "helper":{...}}]}
  Future<List<SavedHelperEntry>> getSavedHelpers({String? profileType}) async {
    _client.profileType = profileType;
    final response = await _client.get(url: _fullUrl(ApiUrl.savedHelpers));
    final data = parseApiResponse(response);
    final list = data is List ? data : (data as Map)['results'] as List;
    return list.map((e) => SavedHelperEntry.fromJson(e as Map<String, dynamic>)).toList();
  }

  /// Save a helper – POST to /add-helper/{helperId}/
  Future<void> saveHelper(int helperId, {String? profileType}) async {
    _client.profileType = profileType;
    await _client.post(
      url: '${_fullUrl(ApiUrl.savedHelpers)}add-helper/$helperId/',
    );
  }

  /// Remove a saved helper by its entry ID.
  /// The backend returns 200 OK with {"status": true, "message": "Helper removed from saved helpers."}
  Future<void> removeSavedHelper(int entryId, {String? profileType}) async {
    _client.profileType = profileType;
    final url = '${_fullUrl(ApiUrl.savedHelpers)}$entryId/remove-helper/';

    final response = await _client.deleteHelper(
      url: url,
      code: 200,   // ✅ backend returns 200 OK
      showResult: true,
    );

    if (response == null) {
      throw ApiException('Failed to remove saved helper. Server returned an error.');
    }

    // Check for explicit failure in response
    if (response is Map && response.containsKey('status') && response['status'] == false) {
      final message = response['message']?.toString() ?? 'Failed to remove saved helper.';
      throw ApiException(message);
    }

    // Success – no exception thrown.
  }

  /// Convenience: remove by helper id (fetches entry id internally)
  Future<void> removeSavedHelperByHelperId(int helperId, {String? profileType}) async {
    final saved = await getSavedHelpers(profileType: profileType);
    final entry = saved.firstWhereOrNull((e) => e.helper.id == helperId);
    if (entry == null) {
      throw ApiException('Helper not found in saved list.');
    }
    await removeSavedHelper(entry.entryId, profileType: profileType);
  }

  // ---------- HELPER PROFILE MANAGEMENT ----------

  Future<Map<String, dynamic>> getMyHelperProfile() async {
    _client.profileType = 'provider';
    final response =
    await _client.get(url: _fullUrl(ApiUrl.helperProfile));
    final data = parseApiResponse(response);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createHelperProfile(
      Map<String, dynamic> body, {
        File? logoFile,
      }) async {
    _client.profileType = 'provider';

    if (logoFile == null) {
      final response = await _client.post(
        url: _fullUrl(ApiUrl.createHelperProfile),
        body: body,
      );
      final data = parseApiResponse(response);
      return data as Map<String, dynamic>;
    }

    final (single, repeated) = _splitFields(body);
    final response = await _client.multipartRepeated(
      url: _fullUrl(ApiUrl.createHelperProfile),
      reqType: 'POST',
      singleFields: single,
      repeatedFields: repeated,
      files: [MultipartBody('logo', logoFile)],
    );
    final data = parseApiResponse(response);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> createAddress(
      Map<String, dynamic> body) async {
    _client.profileType = 'provider';
    final response = await _client.post(
      url: _fullUrl(ApiUrl.userAddresses),
      body: body,
    );
    final data = parseApiResponse(response);
    return data as Map<String, dynamic>;
  }

  Future<void> setOfficeLocation(int addressId) async {
    _client.profileType = 'provider';
    await _client.post(
      url: _fullUrl(ApiUrl.providerAddressUpdate),
      body: {'address_object_id': addressId},
    );
  }

  Future<Map<String, dynamic>> updateHelperProfile(
      Map<String, dynamic> body, {
        File? logoFile,
      }) async {
    _client.profileType = 'provider';

    if (logoFile == null) {
      final response = await _client.patch(
        url: _fullUrl(ApiUrl.helperProfile),
        body: body,
      );
      final data = parseApiResponse(response);
      return data as Map<String, dynamic>;
    }

    final (single, repeated) = _splitFields(body);
    final response = await _client.multipartRepeated(
      url: _fullUrl(ApiUrl.helperProfile),
      reqType: 'PATCH',
      singleFields: single,
      repeatedFields: repeated,
      files: [MultipartBody('logo', logoFile)],
    );
    final data = parseApiResponse(response);
    return data as Map<String, dynamic>;
  }

  Future<void> deleteHelperProfile() async {
    _client.profileType = 'provider';
    await _client.deleteHelper(url: _fullUrl(ApiUrl.helperProfile));
  }

  // ---------- Helper methods ----------
  (Map<String, String>, Map<String, List<String>>) _splitFields(
      Map<String, dynamic> data) {
    final single = <String, String>{};
    final repeated = <String, List<String>>{};
    data.forEach((key, value) {
      if (value == null) return;
      if (value is List) {
        repeated[key] = value.map((e) => e.toString()).toList();
      } else {
        single[key] = value.toString();
      }
    });
    return (single, repeated);
  }
}