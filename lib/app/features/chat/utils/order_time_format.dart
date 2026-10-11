import 'package:flutter/material.dart';
import 'package:working_hiring/app/features/chat/controllers/message_controller.dart';

TimeOfDay? parseOrderTime(String? raw) {
  if (raw == null || raw.trim().isEmpty) return null;
  final value = raw.trim().toUpperCase();
  final match = RegExp(
    r'^(\d{1,2}):(\d{2})(?::\d{2})?\s*(AM|PM)?$',
  ).firstMatch(value);
  if (match == null) return null;
  var hour = int.tryParse(match.group(1)!) ?? 0;
  final minute = int.tryParse(match.group(2)!) ?? 0;
  final period = match.group(3);
  if (period == 'PM' && hour < 12) hour += 12;
  if (period == 'AM' && hour == 12) hour = 0;
  if (hour > 23 || minute > 59) return null;
  return TimeOfDay(hour: hour, minute: minute);
}

String displayOrderTime(BuildContext context, String? raw) {
  final parsed = parseOrderTime(raw);
  if (parsed == null) return (raw == null || raw.trim().isEmpty) ? '—' : raw;
  return MaterialLocalizations.of(
    context,
  ).formatTimeOfDay(parsed, alwaysUse24HourFormat: false);
}

String displayOrderEndTime(BuildContext context, MessageModel msg) {
  if ((msg.endTime ?? '').trim().isNotEmpty) {
    return displayOrderTime(context, msg.endTime);
  }
  final start = parseOrderTime(msg.timeSlot);
  final hours = int.tryParse(
    RegExp(r'\d+').firstMatch(msg.duration ?? '')?.group(0) ?? '',
  );
  if (start == null || hours == null) return '—';
  final totalMinutes =
      (start.hour * 60 + start.minute + hours * 60) % (24 * 60);
  return MaterialLocalizations.of(context).formatTimeOfDay(
    TimeOfDay(hour: totalMinutes ~/ 60, minute: totalMinutes % 60),
    alwaysUse24HourFormat: false,
  );
}
