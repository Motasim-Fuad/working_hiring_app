class ServiceCategory {
  int? id;
  String? title;

  ServiceCategory({this.id, this.title});

  factory ServiceCategory.fromJson(Map<String, dynamic> json) {
    return ServiceCategory(id: json['id'], title: json['title']);
  }
}
