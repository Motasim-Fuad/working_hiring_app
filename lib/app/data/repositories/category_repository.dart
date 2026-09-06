import '../../service/api_service.dart';
import '../../service/api_url.dart';
import '../models/category_model.dart';

class CategoryRepository {
  final ApiClient _client;

  CategoryRepository(this._client);

  String _fullUrl(String path) => '${ApiUrl.baseUrl}$path';

  Future<List<CategoryModel>> getCategories({String? profileType}) async {
    _client.profileType = profileType;
    final response = await _client.get(url: _fullUrl(ApiUrl.categories));
    final data = parseApiResponse(response);
    final list = data as List<dynamic>;
    return list
        .map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<SubCategoryModel>> getSubCategories({String? profileType}) async {
    _client.profileType = profileType;
    final response = await _client.get(url: _fullUrl(ApiUrl.subCategories));
    final data = parseApiResponse(response);
    final list = data as List<dynamic>;
    return list
        .map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}
