class SlotException {
  final String date;
  final String? startTime;
  final String? endTime;
  final bool isAvailable;

  const SlotException({
    required this.date,
    this.startTime,
    this.endTime,
    this.isAvailable = false,
  });

  factory SlotException.fromJson(Map<String, dynamic> json) {
    return SlotException(
      date: json['date'] as String,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
      isAvailable: json['is_available'] as bool? ?? false,
    );
  }
}
