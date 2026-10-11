class OfficeLocation {
  int? id;
  String? addressLine;
  String? city;
  double? lat;
  double? lng;

  OfficeLocation({this.id, this.addressLine, this.city, this.lat, this.lng});

  factory OfficeLocation.fromJson(Map<String, dynamic> json) {
    return OfficeLocation(
      id: json['id'],
      addressLine: json['address_line'],
      city: json['city'],
      lat: json['lat'],
      lng: json['lng'],
    );
  }
}
