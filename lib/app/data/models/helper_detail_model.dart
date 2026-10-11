import 'package:working_hiring/app/data/utils/json_parsers.dart';

class HelperDetailModel {
  final int id;
  final String? companyName;
  final String? photo;
  final double? hourlyRate;
  final double? minBookingHours;
  final double? rating;
  final int? totalTasks;
  final String? location;
  final double? distance;
  final String? bio;
  final bool? isVerified;
  final List<String>? categories;
  final List<dynamic>? portfolio;
  final List<dynamic>? reviews;

  HelperDetailModel({
    required this.id,
    this.companyName,
    this.photo,
    this.hourlyRate,
    this.minBookingHours,
    this.rating,
    this.totalTasks,
    this.location,
    this.distance,
    this.bio,
    this.isVerified,
    this.categories,
    this.portfolio,
    this.reviews,
  });

  factory HelperDetailModel.fromJson(Map<String, dynamic> json) {
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

    return HelperDetailModel(
      id: json['id'] as int,
      companyName: json['company_name'] as String?,
      photo: json['logo'] as String?,
      hourlyRate: parseDouble(json['hourly_rate']),
      minBookingHours: parseDouble(json['min_booking_hours']),
      rating: parseDouble(json['rating']),
      totalTasks: parseInt(json['total_jobs']),
      location: buildLocation(json['office_location'] as Map<String, dynamic>?),
      distance: parseDouble(json['distance_km']),
      bio: json['details'] as String?,
      isVerified: json['is_verified'] as bool?,
      categories: buildCategories(json['service_category'] as List<dynamic>?),
      portfolio: json['portfolio'] as List<dynamic>?,
      reviews: json['reviews_and_ratings'] as List<dynamic>?,
    );
  }
}
