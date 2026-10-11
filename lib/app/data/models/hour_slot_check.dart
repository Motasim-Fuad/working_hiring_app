import 'package:working_hiring/app/data/models/availability_model.dart';
import 'package:working_hiring/app/data/models/date_slot.dart';

class HourSlotCheck {
  final bool isAvailable;
  final String message;
  final String? slot;
  final List<DateSlot> alternatives;

  const HourSlotCheck({
    required this.isAvailable,
    this.message = '',
    this.slot,
    this.alternatives = const [],
  });

  factory HourSlotCheck.fromJson(Map<String, dynamic> json) {
    final avail = (json['is_available'] ?? json['is_availasble']) == true;
    final rawAlt =
        (json['available_slots'] ?? json['available_slot']) as List<dynamic>?;
    return HourSlotCheck(
      isAvailable: avail,
      message: json['message']?.toString() ?? '',
      slot: json['slot']?.toString(),
      alternatives:
          rawAlt
              ?.map((e) => DateSlot.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );
  }
}
