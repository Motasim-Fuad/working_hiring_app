class OrderSnapshot {
  final int id;
  final String? title;
  final String? description;
  final String? area;
  final double? amount;
  final String? status;
  final String? paymentStatus;
  final String? workingDate;
  final String? workingStartTime;
  final int? workingHour;
  final String? endTime;
  final String? endDatetime;
  final String? createdAt;

  OrderSnapshot({
    required this.id,
    this.title,
    this.description,
    this.area,
    this.amount,
    this.status,
    this.paymentStatus,
    this.workingDate,
    this.workingStartTime,
    this.workingHour,
    this.endTime,
    this.endDatetime,
    this.createdAt,
  });

  factory OrderSnapshot.fromJson(Map<String, dynamic> j) => OrderSnapshot(
    id: (j['id'] as num?)?.toInt() ?? 0,
    title: j['title'] as String?,
    description: j['description'] as String?,
    area: j['area'] as String?,
    amount: double.tryParse(j['amount']?.toString() ?? ''),
    status: j['status'] as String?,
    paymentStatus: j['payment_status'] as String?,
    workingDate: j['working_date'] as String?,
    workingStartTime: j['working_start_time'] as String?,
    workingHour: (j['working_hour'] as num?)?.toInt(),
    endTime: j['end_time'] as String?,
    endDatetime: j['end_datetime'] as String?,
    createdAt: j['created_at'] as String?,
  );
}
