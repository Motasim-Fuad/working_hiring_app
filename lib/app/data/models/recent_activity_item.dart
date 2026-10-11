class RecentActivityItem {
  final String? title;
  final String? description;
  final String? type;
  final String? timestamp;
  final String? icon;

  const RecentActivityItem({
    this.title,
    this.description,
    this.type,
    this.timestamp,
    this.icon,
  });

  factory RecentActivityItem.fromJson(Map<String, dynamic> json) {
    return RecentActivityItem(
      title: json['action'] as String? ?? json['title'] as String?,
      description: json['description'] as String?,
      type: json['type'] as String?,
      timestamp: json['timestamp'] as String? ?? json['created_at'] as String?,
      icon: json['icon'] as String?,
    );
  }
}
