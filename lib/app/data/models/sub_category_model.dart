class SubCategoryModel {
  final int id;
  final String? title;
  final String? description;
  final String? icon;
  final int? category;

  const SubCategoryModel({
    required this.id,
    this.title,
    this.description,
    this.icon,
    this.category,
  });

  factory SubCategoryModel.fromJson(Map<String, dynamic> json) {
    return SubCategoryModel(
      id: json['id'] as int,
      title: json['title'] as String?,
      description: json['description'] as String?,
      icon: json['icon'] as String?,
      category: json['category'] as int?,
    );
  }
}
