class AddressModel {
  final int? id;
  final String? addressLine;
  final String? city;
  final double? lat;
  final double? lng;
  final bool? isDefault;

  const AddressModel({
    this.id,
    this.addressLine,
    this.city,
    this.lat,
    this.lng,
    this.isDefault,
  });

  factory AddressModel.fromJson(Map<String, dynamic> json) {
    final displayAddress = json['display_address'] as String?;
    final addressLine = json['address_line'] as String? ?? displayAddress;
    final city = json['city'] as String?;

    return AddressModel(
      id: json['id'] as int?,
      addressLine: addressLine,
      city: city,
      lat: (json['lat'] as num?)?.toDouble(),
      lng: (json['lng'] as num?)?.toDouble(),
      isDefault: json['is_default'] as bool?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (addressLine != null) 'address_line': addressLine,
      if (city != null) 'city': city,
      if (lat != null) 'lat': lat,
      if (lng != null) 'lng': lng,
      if (isDefault != null) 'is_default': isDefault,
    };
  }
}
