import 'dart:io';
import 'package:flutter/foundation.dart';

import '../../service/api_service.dart';
import '../../service/api_url.dart';
import '../models/user_model.dart';

class UserRepository {
  final ApiClient _client;

  UserRepository(this._client);

  String _fullUrl(String path) => '${ApiUrl.baseUrl}$path';

  /// Get the currently authenticated user's profile.
  /// The /current-user/ endpoint uses user_mode as a query param (CUSTOMER/PROVIDER),
  /// not the profile-type header used by other endpoints.
  Future<UserModel> getCurrentUser({String? profileType}) async {
    _client.profileType = profileType;
    var url = _fullUrl(ApiUrl.currentUser);
    if (profileType != null && profileType.isNotEmpty) {
      url += '?user_mode=${profileType.toUpperCase()}';
    }
    final response = await _client.get(url: url);
    final data = parseApiResponse(response);
    return UserModel.fromJson(data as Map<String, dynamic>);
  }

  /// Update the current user's profile. Pass [photoFile] to upload a new
  /// avatar; when provided, the request is sent as multipart/form-data
  /// per spec §6.1.
  Future<UserModel> updateCurrentUser(
    Map<String, dynamic> data, {
    String? profileType,
    File? photoFile,
  }) async {
    _client.profileType = profileType;

    if (photoFile == null) {
      final response = await _client.patch(
        url: _fullUrl(ApiUrl.currentUser),
        body: data,
      );
      final respData = parseApiResponse(response);
      return UserModel.fromJson(respData as Map<String, dynamic>);
    }

    final fields = <String, String>{};
    data.forEach((key, value) {
      if (value == null) return;
      fields[key] = value.toString();
    });
    final response = await _client.multipartRequest(
      url: _fullUrl(ApiUrl.currentUser),
      reqType: 'PATCH',
      body: fields,
      multipartBody: [MultipartBody('photo', photoFile)],
    );
    final respData = parseApiResponse(response);
    return UserModel.fromJson(respData as Map<String, dynamic>);
  }

  /// Get user's saved addresses.
  Future<List<AddressModel>> getAddresses({String? profileType}) async {
    _client.profileType = profileType;
    final response = await _client.get(url: _fullUrl(ApiUrl.userAddresses));
    final respData = parseApiResponse(response);
    final list = respData as List<dynamic>;
    return list
        .map((e) => AddressModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Create a new address.
  Future<AddressModel> createAddress(Map<String, dynamic> data,
      {String? profileType}) async {
    _client.profileType = profileType;
    final response = await _client.post(
      url: _fullUrl(ApiUrl.userAddresses),
      body: data,
    );
    final respData = parseApiResponse(response);
    return AddressModel.fromJson(respData as Map<String, dynamic>);
  }

  /// Update an existing address.
  Future<AddressModel> updateAddress(int id, Map<String, dynamic> data,
      {String? profileType}) async {
    _client.profileType = profileType;
    final response = await _client.patch(
      url: '${_fullUrl(ApiUrl.userAddresses)}$id/',
      body: data,
    );
    final respData = parseApiResponse(response);
    return AddressModel.fromJson(respData as Map<String, dynamic>);
  }

  /// Delete an address.
  Future<void> deleteAddress(int id, {String? profileType}) async {
    _client.profileType = profileType;
    final result = await _client.delete(
      url: '${_fullUrl(ApiUrl.userAddresses)}$id/',
    );
    if (result == null || result['status'] != true) {
      throw ApiException(result?['message'] ?? 'Delete failed', result);
    }
  }

  /// Set user's preferred language.
  Future<void> setLanguage(String language, {String? profileType}) async {
    _client.profileType = profileType;
    await _client.post(
      url: _fullUrl(ApiUrl.userLanguage),
      body: {'language': language},
    );
  }

  /// Get the user's current language preference from the backend.
  Future<String?> getLanguage() async {
    final response = await _client.get(url: _fullUrl(ApiUrl.userLanguage));
    try {
      final data = parseApiResponse(response);
      if (data is Map) return data['language'] as String?;
    } on ApiException {
      return null;
    }
    return null;
  }

  /// Delete the current user's account.
  Future<void> deleteAccount() async {
    await _client.delete(url: _fullUrl(ApiUrl.currentUser));
  }

  // ----- Provider Verification -----

  Future<Map<String, dynamic>?> getVerificationStatus({String? profileType}) async {
    _client.profileType = profileType ?? 'provider';
    final response = await _client.get(url: _fullUrl(ApiUrl.providerVerification));
    try {
      return parseApiResponse(response) as Map<String, dynamic>?;
    } on ApiException {
      return null;
    }
  }

  Future<void> submitVerification({
    required Map<String, String> fields,
    required String documentFilePath,
    String? profileType,
  }) async {
    _client.profileType = profileType ?? 'provider';
    final response = await _client.multipartRequest(
      url: _fullUrl(ApiUrl.providerVerification),
      reqType: 'POST',
      body: fields,
      multipartBody: [
        MultipartBody('document', File(documentFilePath)),
      ],
    );
    parseApiResponse(response);
  }

  // ----- Referrals -----

  // lib/data/repositories/user_repository.dart

  Future<String?> getReferralCode() async {
    try {
      // No profile type needed for this endpoint
      final response = await _client.get(
        url: _fullUrl(ApiUrl.myReferralCode),
      );
      // Response body is: {"status": true, "referral_code": "75K26R9U"}
      final body = response.body;
      if (body is Map && body['status'] == true && body.containsKey('referral_code')) {
        return body['referral_code'] as String;
      }
      return null;
    } catch (e) {
      debugPrint('getReferralCode error: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getMyReferrals() async {
    final response = await _client.get(url: _fullUrl(ApiUrl.myReferrals));
    try {
      final data = parseApiResponse(response);
      final list = data is List ? data : (data as Map)['data'] as List? ?? [];
      return list.cast<Map<String, dynamic>>();
    } on ApiException {
      return [];
    }
  }

  // ----- Reviews -----

  Future<List<Map<String, dynamic>>> getCustomerReviews() async {
    _client.profileType = 'customer';
    final response = await _client.get(url: _fullUrl(ApiUrl.customerReviews));
    try {
      final data = parseApiResponse(response);
      final list = data is List ? data : (data as Map)['data'] as List? ?? [];
      return list.cast<Map<String, dynamic>>();
    } on ApiException {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getProviderReviews() async {
    _client.profileType = 'provider';
    final response = await _client.get(url: _fullUrl(ApiUrl.providerReviews));
    try {
      final data = parseApiResponse(response);
      final list = data is List ? data : (data as Map)['data'] as List? ?? [];
      return list.cast<Map<String, dynamic>>();
    } on ApiException {
      return [];
    }
  }
}
