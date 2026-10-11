String formatTimeAgo(String? isoTimestamp) {
  if (isoTimestamp == null || isoTimestamp.isEmpty) return '';
  final dt = DateTime.tryParse(isoTimestamp);
  if (dt == null) return isoTimestamp;
  final diff = DateTime.now().difference(dt.toLocal());
  if (diff.inMinutes < 1) return 'now';
  if (diff.inMinutes < 60) return '${diff.inMinutes}m';
  if (diff.inHours < 24) return '${diff.inHours}h';
  if (diff.inDays < 7) return '${diff.inDays}d';
  return '${(diff.inDays / 7).floor()}w';
}
