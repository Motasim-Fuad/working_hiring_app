String formatDate(String iso) {
  try {
    final dt = DateTime.parse(iso);
    return '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return iso;
  }
}

String formatTime(String iso) {
  try {
    final dt = DateTime.parse(iso);
    return '${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
  } catch (_) {
    return '';
  }
}
