class PayoutMethod {
  final int id;
  final String methodType;
  final String? accountHolderName;
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final bool isDefault;
  final bool isVerified;

  PayoutMethod({
    required this.id,
    required this.methodType,
    this.accountHolderName,
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.isDefault = false,
    this.isVerified = false,
  });

  factory PayoutMethod.fromJson(Map<String, dynamic> json) {
    return PayoutMethod(
      id: json['id'] as int,
      methodType: json['method_type'] as String? ?? 'BANK',
      accountHolderName: json['account_holder_name'] as String?,
      bankName: json['bank_name'] as String?,
      accountNumber: json['account_number'] as String?,
      ifscCode: json['ifsc_code'] as String?,
      isDefault: json['is_default'] as bool? ?? false,
      isVerified: json['is_verified'] as bool? ?? false,
    );
  }
}
