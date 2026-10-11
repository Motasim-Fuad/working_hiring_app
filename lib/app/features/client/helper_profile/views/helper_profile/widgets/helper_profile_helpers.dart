import 'package:intl/intl.dart';

String reviewDate(dynamic review) {
  if (review is! Map) return '';
  final raw = review['created_at'] ?? review['date'] ?? review['created'];
  if (raw == null) return '';
  final parsed = DateTime.tryParse(raw.toString());
  if (parsed == null) return '';
  return DateFormat('MMM d, yyyy').format(parsed.toLocal());
}

double? reviewRating(dynamic r) {
  if (r is Map) {
    final v = r['rating'] ?? r['stars'] ?? r['score'];
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v);
  }
  return null;
}

String reviewText(dynamic r) {
  if (r is Map) {
    final v = r['review'] ?? r['comment'] ?? r['text'] ?? r['message'] ?? '';
    return v.toString();
  }
  return '';
}
