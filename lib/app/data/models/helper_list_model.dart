import 'package:working_hiring/app/data/utils/json_parsers.dart';

class HelperListModel {
  final int id;
  final String? companyName;
  final String? photo;
  final double? hourlyRate;
  final double? rating;
  final int? totalTasks;
  final String? location;
  final double? distance;
  final bool? isVerified;
  final bool? availabilityStatus;
  final List<String>? categories;
  final String? bio;

  HelperListModel({
    required this.id,
    this.companyName,
    this.photo,
    this.hourlyRate,
    this.rating,
    this.totalTasks,
    this.location,
    this.distance,
    this.isVerified,
    this.availabilityStatus,
    this.categories,
    this.bio,
  });

  String get name => companyName ?? 'Unknown';
  String get avatarUrl => photo ?? '';
  String get categoryText => categories?.join(', ') ?? 'General';

  factory HelperListModel.fromJson(Map<String, dynamic> json) {
    String? buildLocation(Map<String, dynamic>? loc) {
      if (loc == null) return null;
      final parts = [
        loc['address_line'],
        loc['city'],
      ].where((e) => e != null && e.toString().isNotEmpty);
      return parts.isNotEmpty ? parts.join(', ') : null;
    }

    List<String>? buildCategories(List<dynamic>? cats) {
      if (cats == null) return null;
      return cats
          .map(
            (e) => (e is Map<String, dynamic>)
                ? (e['title'] ?? '').toString()
                : e.toString(),
          )
          .where((e) => e.isNotEmpty)
          .toList();
    }

    return HelperListModel(
      id: json['id'] as int,
      companyName: json['company_name'] as String?,
      photo: json['logo'] as String?,
      hourlyRate: parseDouble(json['hourly_rate']),
      rating: parseDouble(json['rating']),
      totalTasks: parseInt(json['total_jobs']),
      location: buildLocation(json['office_location'] as Map<String, dynamic>?),
      distance: parseDouble(json['distance_km']),
      isVerified: json['is_verified'] as bool?,
      availabilityStatus: json['availability_status'] as bool?,
      categories: buildCategories(json['service_category'] as List<dynamic>?),
      bio: json['details'] as String?,
    );
  }
}
