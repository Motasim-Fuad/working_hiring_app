import 'package:working_hiring/app/data/models/recent_activity_item.dart';
export 'package:working_hiring/app/data/models/recent_activity_item.dart';

class ActivityModel {
  final int activeOrders;
  final int completedOrders;
  final double totalSpent;
  final double avgRating;
  final List<RecentActivityItem> recentActivities;

  const ActivityModel({
    this.activeOrders = 0,
    this.completedOrders = 0,
    this.totalSpent = 0.0,
    this.avgRating = 0.0,
    this.recentActivities = const [],
  });

  factory ActivityModel.fromJson(Map<String, dynamic> json) {
    final activity = json['my_activity'] as Map<String, dynamic>? ?? json;
    return ActivityModel(
      activeOrders: activity['active_orders'] as int? ?? 0,
      completedOrders: activity['completed_orders'] as int? ?? 0,
      totalSpent: (activity['total_spent'] as num?)?.toDouble() ?? 0.0,
      avgRating: (activity['avg_rating'] as num?)?.toDouble() ?? 0.0,
      recentActivities:
          (json['recent_activities'] as List<dynamic>?)
              ?.map(
                (e) => RecentActivityItem.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }
}
