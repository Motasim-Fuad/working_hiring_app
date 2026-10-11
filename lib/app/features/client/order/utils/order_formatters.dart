import 'package:intl/intl.dart';

String formatOrderDate(String? dateStr) {
  if (dateStr == null) return '';
  try {
    final d = DateTime.parse(dateStr);
    return DateFormat("d MMM, yyyy").format(d);
  } catch (_) {
    return dateStr;
  }
}

String formatOrderAmount(num? amount) {
  return '\$${(amount ?? 0).toStringAsFixed(0)}';
}
