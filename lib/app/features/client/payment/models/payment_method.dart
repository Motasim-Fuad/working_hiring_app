class PaymentMethod {
  final String id;
  final String last4;
  final String type;
  final String icon;
  final bool isDefault;

  PaymentMethod({
    required this.id,
    required this.last4,
    required this.type,
    required this.icon,
    this.isDefault = false,
  });

  factory PaymentMethod.fromJson(Map<String, dynamic> json) {
    final brand = json['brand'] as String? ?? 'Card';
    return PaymentMethod(
      id: json['id'].toString(),
      last4: json['last4'] as String? ?? '****',
      type: brand,
      icon: _iconForBrand(brand),
      isDefault: json['is_default'] as bool? ?? false,
    );
  }

  static String _iconForBrand(String? brand) {
    switch (brand?.toUpperCase()) {
      case 'MASTERCARD':
        return 'assets/icons/icon_mastercard.svg';
      default:
        return 'assets/icons/icon_visa.svg';
    }
  }
}
