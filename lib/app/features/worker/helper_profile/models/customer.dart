class Customer {
  int? id;
  String? firstName;
  String? lastName;
  String? photo;

  Customer({this.id, this.firstName, this.lastName, this.photo});

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      photo: json['photo'],
    );
  }
}
