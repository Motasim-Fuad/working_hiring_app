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
    // CurrentUserInfoSerializer returns 'display_address' (combined).
    // UserAddressSerializer returns 'address_line' and 'city' separately.
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

class UserModel {
  final int id;
  final String? firstName;
  final String? lastName;
  final String? username;
  final String? email;
  final String? phone;
  final String? photo;
  final String? language;
  final String? defaultProfile;
  final AddressModel? address;
  final bool hasProviderProfile;
  final bool hasCustomerProfile;
  final String? providerVerificationStatus;

  const UserModel({
    required this.id,
    this.firstName,
    this.lastName,
    this.username,
    this.email,
    this.phone,
    this.photo,
    this.language,
    this.defaultProfile,
    this.address,
    this.hasProviderProfile = false,
    this.hasCustomerProfile = false,
    this.providerVerificationStatus,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as int,
      firstName: json['first_name'] as String?,
      lastName: json['last_name'] as String?,
      username: json['username'] as String?,
      email: json['email'] as String?,
      phone: json['phone'] as String?,
      photo: json['photo'] as String?,
      language: json['language'] as String?,
      defaultProfile: json['default_profile'] as String?,
      address: json['address'] != null
          ? AddressModel.fromJson(json['address'] as Map<String, dynamic>)
          : null,
      hasProviderProfile: json['has_provider_profile'] as bool? ?? false,
      hasCustomerProfile: json['has_customer_profile'] as bool? ?? false,
      providerVerificationStatus:
          json['provider_verification_status'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'photo': photo,
      'language': language,
      if (address != null) 'address': address!.toJson(),
    };
  }
}
