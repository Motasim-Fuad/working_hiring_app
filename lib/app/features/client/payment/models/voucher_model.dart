class VoucherModel {
  final String id;
  final String amount;
  final String title;
  final String code;
  final bool isUsed;

  VoucherModel({
    required this.id,
    required this.amount,
    required this.title,
    required this.code,
    this.isUsed = false,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    final discountType = json['discount_type'] as String? ?? 'FLAT';
    final value = json['value'] as String? ?? '0';
    final displayAmount = discountType == 'PERCENTAGE' ? '$value%' : '\$$value';
    return VoucherModel(
      id: json['id'].toString(),
      amount: displayAmount,
      title: '$displayAmount Discount',
      code: json['code'] as String? ?? '',
      isUsed: json['is_used'] as bool? ?? false,
    );
  }
}
