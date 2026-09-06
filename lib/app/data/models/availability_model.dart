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

class DateSlot {
  final String slot;
  final String status;

  const DateSlot({
    required this.slot,
    this.status = 'UNAVAILABLE',
  });

  bool get isBooked => status == 'BOOKED';
  bool get isAvailable => status == 'AVAILABLE';

  factory DateSlot.fromJson(Map<String, dynamic> json) {
    return DateSlot(
      slot: json['slot'] as String,
      status: (json['status'] as String? ?? 'unavailable').toUpperCase(),
    );
  }
}

class HourSlotCheck {
  final bool isAvailable;
  final String message;
  final String? slot; // e.g. "12:00 PM - 03:00 PM" when available
  final List<DateSlot> alternatives;

  const HourSlotCheck({
    required this.isAvailable,
    this.message = '',
    this.slot,
    this.alternatives = const [],
  });

  factory HourSlotCheck.fromJson(Map<String, dynamic> json) {
    // backend has typos: is_availasble / is_available, available_slot(s)
    final avail = (json['is_available'] ?? json['is_availasble']) == true;
    final rawAlt = (json['available_slots'] ?? json['available_slot']) as List<dynamic>?;
    return HourSlotCheck(
      isAvailable: avail,
      message: json['message']?.toString() ?? '',
      slot: json['slot']?.toString(),
      alternatives: rawAlt
          ?.map((e) => DateSlot.fromJson(e as Map<String, dynamic>))
          .toList() ??
          const [],
    );
  }
}

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
