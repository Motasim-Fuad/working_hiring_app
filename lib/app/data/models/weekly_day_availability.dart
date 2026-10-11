class WeeklyDayAvailability {
  final int id;
  final String day;
  final String dayStatus;
  final String? startTime;
  final String? endTime;

  const WeeklyDayAvailability({
    required this.id,
    this.day = '',
    this.dayStatus = 'OFF',
    this.startTime,
    this.endTime,
  });

  bool get isAvailable => dayStatus == 'AVAILABLE';

  factory WeeklyDayAvailability.fromJson(Map<String, dynamic> json) {
    final rawStatus = json['day_status'];
    final String dayStatus;
    if (rawStatus is int) {
      dayStatus = rawStatus == 1 ? 'AVAILABLE' : 'OFF';
    } else {
      dayStatus = (rawStatus as String?) ?? 'OFF';
    }
    return WeeklyDayAvailability(
      id: json['id'] as int,
      day: json['day'] as String? ?? '',
      dayStatus: dayStatus,
      startTime: json['start_time'] as String?,
      endTime: json['end_time'] as String?,
    );
  }
}
