import '../../service/api_service.dart';
import '../../service/api_url.dart';

/// Wraps the provider payout-method endpoints (spec §6.12). Mirrors the
/// customer payment-method shape in `BillingPaymentsController`.
class PayoutMethodRepository {
  final ApiClient _client;

  PayoutMethodRepository(this._client);

  String _fullUrl(String path) => '${ApiUrl.baseUrl}$path';

  Future<List<Map<String, dynamic>>> list() async {
    _client.profileType = 'provider';
    final response = await _client.get(url: _fullUrl(ApiUrl.providerPayoutMethods));
    final data = parseApiResponse(response);
    final list = data is List ? data : (data as Map)['results'] as List? ?? [];
    return list.cast<Map<String, dynamic>>();
  }

  Future<Map<String, dynamic>> create(Map<String, dynamic> body) async {
    _client.profileType = 'provider';
    final response = await _client.post(
      url: _fullUrl(ApiUrl.providerPayoutMethods),
      body: body,
    );
    final data = parseApiResponse(response);
    return data as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> update(int id, Map<String, dynamic> body) async {
    _client.profileType = 'provider';
    final response = await _client.patch(
      url: '${_fullUrl(ApiUrl.providerPayoutMethods)}$id/',
      body: body,
    );
    final data = parseApiResponse(response);
    return data as Map<String, dynamic>;
  }

  Future<void> delete(int id) async {
    _client.profileType = 'provider';
    await _client.delete(
      url: '${_fullUrl(ApiUrl.providerPayoutMethods)}$id/',
      isBasic: false,
      code: 200,
    );
  }

  Future<void> setDefault(int id) async {
    _client.profileType = 'provider';
    await _client.post(
      url: '${_fullUrl(ApiUrl.providerPayoutMethods)}$id/set-default/',
      body: const {},
    );
  }
}
