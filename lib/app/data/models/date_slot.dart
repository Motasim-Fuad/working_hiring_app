class DateSlot {
  final String slot;
  final String status;

  const DateSlot({required this.slot, this.status = 'UNAVAILABLE'});

  bool get isBooked => status == 'BOOKED';
  bool get isAvailable => status == 'AVAILABLE';

  factory DateSlot.fromJson(Map<String, dynamic> json) {
    return DateSlot(
      slot: json['slot'] as String,
      status: (json['status'] as String? ?? 'unavailable').toUpperCase(),
    );
  }
}
