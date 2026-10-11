class PortfolioItem {
  int? id;
  String? title;
  String? description;
  String? workingDate;
  String? picture;

  PortfolioItem({
    this.id,
    this.title,
    this.description,
    this.workingDate,
    this.picture,
  });

  factory PortfolioItem.fromJson(Map<String, dynamic> json) {
    return PortfolioItem(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      workingDate: json['working_date'],
      picture: json['picture'],
    );
  }
}
