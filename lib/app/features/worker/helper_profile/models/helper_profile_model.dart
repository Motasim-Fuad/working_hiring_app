import 'package:working_hiring/app/features/worker/helper_profile/models/office_location.dart';
import 'package:working_hiring/app/features/worker/helper_profile/models/service_category.dart';
import 'package:working_hiring/app/features/worker/helper_profile/models/portfolio_item.dart';
import 'package:working_hiring/app/features/worker/helper_profile/models/review.dart';
export 'package:working_hiring/app/features/worker/helper_profile/models/helper_profile_response.dart';
export 'package:working_hiring/app/features/worker/helper_profile/models/office_location.dart';
export 'package:working_hiring/app/features/worker/helper_profile/models/service_category.dart';
export 'package:working_hiring/app/features/worker/helper_profile/models/portfolio_item.dart';
export 'package:working_hiring/app/features/worker/helper_profile/models/review.dart';
export 'package:working_hiring/app/features/worker/helper_profile/models/customer.dart';

class HelperProfileModel {
  String? companyName;
  String? logo;
  String? details;
  String? hourlyRate;
  String? minBookingHours;
  OfficeLocation? officeLocation;
  int? strikeCount;
  String? accountStatus;
  bool? availabilityStatus;
  bool? isVerified;
  double? completeRate;
  int? totalJobs;
  double? rating;
  List<ServiceCategory>? serviceCategory;
  List<PortfolioItem>? portfolio;
  List<Review>? reviewsAndRatings;

  HelperProfileModel({
    this.companyName,
    this.logo,
    this.details,
    this.hourlyRate,
    this.minBookingHours,
    this.officeLocation,
    this.strikeCount,
    this.accountStatus,
    this.availabilityStatus,
    this.isVerified,
    this.completeRate,
    this.totalJobs,
    this.rating,
    this.serviceCategory,
    this.portfolio,
    this.reviewsAndRatings,
  });

  factory HelperProfileModel.fromJson(Map<String, dynamic> json) {
    return HelperProfileModel(
      companyName: json['company_name'],
      logo: json['logo'],
      details: json['details'],
      hourlyRate: json['hourly_rate']?.toString(),
      minBookingHours: json['min_booking_hours']?.toString(),
      officeLocation: json['office_location'] != null
          ? OfficeLocation.fromJson(json['office_location'])
          : null,
      strikeCount: json['strike_count'],
      accountStatus: json['account_status'],
      availabilityStatus: json['availability_status'],
      isVerified: json['is_verified'],
      completeRate: json['complete_rate'] != null
          ? double.tryParse(json['complete_rate'].toString())
          : null,
      totalJobs: json['total_jobs'],
      rating: json['rating'] != null
          ? double.tryParse(json['rating'].toString())
          : null,
      serviceCategory: json['service_category'] != null
          ? (json['service_category'] as List)
                .map((i) => ServiceCategory.fromJson(i))
                .toList()
          : null,
      portfolio: json['portfolio'] != null
          ? (json['portfolio'] as List)
                .map((i) => PortfolioItem.fromJson(i))
                .toList()
          : null,
      reviewsAndRatings: json['reviews_and_ratings'] != null
          ? (json['reviews_and_ratings'] as List)
                .map((i) => Review.fromJson(i))
                .toList()
          : null,
    );
  }
}
