import 'package:working_hiring/app/data/models/sub_category_model.dart';
export 'package:working_hiring/app/data/models/sub_category_model.dart';

class CategoryModel {
  final int id;
  final String? title;
  final String? description;
  final String? icon;
  final String? image;
  final List<SubCategoryModel> subcategories;

  const CategoryModel({
    required this.id,
    this.title,
    this.description,
    this.icon,
    this.image,
    this.subcategories = const [],
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as int,
      title: json['title'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      image: json['image'] as String?,
      subcategories:
          (json['subcategory'] as List<dynamic>?)
              ?.map((e) => SubCategoryModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}
