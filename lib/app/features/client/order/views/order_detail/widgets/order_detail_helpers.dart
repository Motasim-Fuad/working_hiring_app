import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

DateTime? parseDateTime(String? dateStr) {
  if (dateStr == null) return null;
  try {
    return DateTime.parse(dateStr);
  } catch (_) {
    return null;
  }
}

String formatDate(DateTime? dt) {
  if (dt == null) return 'N/A';
  return DateFormat('dd MMM yyyy, hh:mm a').format(dt);
}

String formatWorkingSchedule(
  String? date,
  String? start,
  String? end,
  int? hours,
) {
  final parts = <String>[];
  if (date != null) {
    parts.add('Date Value'.trParams({'date': date}));
  }
  if (start != null) {
    parts.add('Start Value'.trParams({'time': start}));
  }
  if (end != null) {
    parts.add('End Value'.trParams({'time': end}));
  }
  if (hours != null) {
    parts.add('Duration Hours'.trParams({'hours': '$hours'}));
  }
  return parts.join('\n');
}

Color getStatusColor(String status) {
  switch (status.toUpperCase()) {
    case 'PENDING':
      return Colors.orange;
    case 'IN_PROGRESS':
    case 'ACCEPT':
    case 'CONFIRM':
      return Colors.blue;
    case 'COMPLETED':
      return Colors.green;
    case 'CANCELLED':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

String formatCurrency(double amount) {
  return NumberFormat.currency(symbol: '\$', decimalDigits: 0).format(amount);
}
