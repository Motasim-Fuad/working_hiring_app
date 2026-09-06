class VoucherModel {
  final String id;
  final String code;
  final double discountAmount;
  final String merchantName;
  final double minSpend;
  final DateTime expiryDate;
  final String type; // 'Restaurants', 'Shops'

  VoucherModel({
    required this.id,
    required this.code,
    required this.discountAmount,
    required this.merchantName,
    required this.minSpend,
    required this.expiryDate,
    required this.type,
  });
}
