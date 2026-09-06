class CustomerScreenSlide {
  final int id;
  final String? image;
  final String? title;
  final String? subtitle;
  final int? sortOrder;

  const CustomerScreenSlide({
    required this.id,
    this.image,
    this.title,
    this.subtitle,
    this.sortOrder,
  });

  factory CustomerScreenSlide.fromJson(Map<String, dynamic> json) {
    return CustomerScreenSlide(
      id: json['id'] as int,
      image: json['photo'] as String?,
      title: json['text'] as String?,
      subtitle: json['text'] as String?,
      sortOrder: json['id'] as int?,
    );
  }
}
